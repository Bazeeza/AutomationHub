.# AutomationHub

# Déploiement .....
**Auteur But et Schéma planification**

| Élément        | Contenu         |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Référent**   | Guide de déploiement d’un serveur **Vaultwarden** (serveur compatible Bitwarden écrit en Rust) hébergé sur **AWS**, xxxx |
| **Émetteur**   | **Abdul-Bariu – Abdul-Majid – Aran**    |
| **Message**    | Présenter/documenter un tutoriel et les résultats du déploiement du serveur **Vaultwarden** sur AWS à l’aide des scripts Terraform.       |
| **Récepteur**  | M. Jérémy Massinon           |
| **Canal**      | GitLab                                |
| **Code**       | Français                                                                                                        |
| **Références** | [Vaultwarden](https://github.com/dani-garcia/vaultwarden) · [Terraform](https://developer.hashicorp.com/terraform/docs) · [AWS EC2 Docs](https://docs.aws.amazon.com/fr_fr/ec2/) · [AWS VPC Docs](https://docs.aws.amazon.com/vpc/) · |

-----


#### Prérequis

Avant de commencer, il faut :

- Un compte AWS functionelle avec les droits pour créer VPC, EC2, Elastic IP, etc.
- Un nom de domaine ou une zone DNS configuré
- Une machine Ubuntu avec accès Internet
- Votre script terraform qui est dans le répertoire Scripts-Terraform du projets git-lab H73-A25-TP3-Abdul_Aran_Azeez_Freddy 

-----

### C’est quoi Vaultwarden ?

 D’abord, **Vaultwarden** est un gestionnaire de mots de passe (un *vault*) qui permet de garder de façon sécurisée :

- des mots de passe  
- des identifiants  
- des notes



echo "════════════════════════════════════════════════════════════"
echo "  MASTER DIAGNOSTIC — $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "════════════════════════════════════════════════════════════"

echo ""
echo "── 1. ALL SERVICES ──"
for svc in afkbot5m shadow5m shadow_eth_5m shadow_sol_5m afkbot; do
    status=$(sudo systemctl is-active $svc 2>/dev/null)
    enabled=$(sudo systemctl is-enabled $svc 2>/dev/null)
    printf "  %-18s %-10s enabled:%s\n" "$svc" "$status" "$enabled"
done

echo ""
echo "── 2. COMPILE CHECKS ──"
cd ~/afk_bot_5m && source venv/bin/activate
python -m py_compile main_5m.py execution/order_manager.py core/kelly.py notifications/telegram_5m.py 2>&1 && echo "afk_bot_5m: OK"
cd ~/afk_bot && source venv/bin/activate
python -m py_compile main.py execution/order_manager.py signals/signal_engine.py 2>&1 && echo "afk_bot: OK"

echo ""
echo "── 3. LIBRARY VERSION SANITY (v2 only) ──"
grep "py_clob_client\." ~/afk_bot_5m/execution/order_manager.py | grep -v "v2" | wc -l | xargs -I{} echo "afk_bot_5m v1 leftovers: {}"
grep "py_clob_client\." ~/afk_bot/execution/order_manager.py | grep -v "v2" | wc -l | xargs -I{} echo "afk_bot v1 leftovers: {}"

echo ""
echo "── 4. REAL BALANCE (live connectivity proof) ──"
cd ~/afk_bot_5m && source venv/bin/activate
python3 -c "
import asyncio
from dotenv import load_dotenv
load_dotenv('.env')
async def main():
    from execution.order_manager import order_manager
    print(f'Balance: \${await order_manager.get_usdc_balance():.2f}')
asyncio.run(main())
"

echo ""
echo "── 5. BTC 5M KELLY STATUS (rolling window) ──"
python3 core/kelly.py 40

echo ""
echo "── 6. BTC 5M — TODAY'S CAP + TRADES ──"
python3 -c "
import sqlite3
conn = sqlite3.connect('bot5m.db')
cur = conn.cursor()
cur.execute(\"SELECT COUNT(*) FROM trades WHERE created_at >= datetime('now','start of day')\")
print(f'Trades today: {cur.fetchone()[0]} / 60')
cur.execute(\"SELECT COUNT(*), SUM(CASE WHEN status='won' THEN 1 ELSE 0 END), SUM(CASE WHEN status='lost' THEN 1 ELSE 0 END), SUM(CASE WHEN status='open' THEN 1 ELSE 0 END) FROM trades\")
print(f'All-time local: {cur.fetchone()}')
conn.close()
"

echo ""
echo "── 7. BTC 5M RECENT ACTIVITY ──"
tail -15 logs/bot5m_$(date +%F).log | grep -v "coinbase\|chainlink\|funding\|candle"

echo ""
echo "── 8. 15M/1H STATUS + RECENT ACTIVITY ──"
cd ~/afk_bot && source venv/bin/activate
curl -s http://localhost:8081/health
echo ""
tail -15 logs/bot_$(date +%F).log

echo ""
echo "── 9. 15M/1H TRADES TODAY ──"
python3 -c "
import sqlite3
conn = sqlite3.connect('bot.db')
cur = conn.cursor()
cur.execute(\"SELECT bot_id, COUNT(*), SUM(CASE WHEN status='won' THEN 1 ELSE 0 END), SUM(CASE WHEN status='lost' THEN 1 ELSE 0 END) FROM trades WHERE created_at >= datetime('now','start of day') GROUP BY bot_id\")
rows = cur.fetchall()
print(rows if rows else 'No trades today')
conn.close()
"

echo ""
echo "── 10. SHADOW LOGGERS — ALL THREE ──"
for pair in "BTC:/home/poly-bot/afk_bot_5m/shadow.db" "ETH:/home/poly-bot/afk_bots/eth_5m/shadow_eth.db" "SOL:/home/poly-bot/afk_bots/sol_5m/shadow_sol.db"; do
    asset="${pair%%:*}"; dbpath="${pair##*:}"
    python3 -c "
import sqlite3
conn = sqlite3.connect('$dbpath')
cur = conn.cursor()
cur.execute('SELECT COUNT(DISTINCT slug) FROM snapshots')
r=cur.fetchone()[0]
cur.execute('SELECT COUNT(*) FROM outcomes')
o=cur.fetchone()[0]
print(f'$asset: {r} rounds | {o} resolved | {o/300*100:.0f}% to 300')
conn.close()
"
done

echo ""
echo "── 11. ERROR SCAN (all logs, excluding routine noise) ──"
for f in ~/afk_bot_5m/logs/bot5m_$(date +%F).log ~/afk_bot/logs/bot_$(date +%F).log; do
    echo "-- $f --"
    grep -i "error\|traceback" "$f" 2>/dev/null | grep -v "Cloudflare\|Chainlink\|Coinbase" | tail -5
done

echo ""
echo "── 12. CRON JOBS (verify no broken 'source' patterns) ──"
crontab -l | while read line; do
    echo "$line" | grep -q "source venv" && echo "  ⚠️  $line" || echo "  ✅ $line"
done

echo ""
echo "── 13. DISK / DB SIZE SANITY ──"
df -h / | tail -1
du -sh ~/afk_bot/bot.db ~/afk_bot_5m/bot5m.db ~/afk_bot_5m/shadow.db 2>/dev/null

echo ""
echo "── 14. GRACEFUL SHUTDOWN TEST (15M/1H) ──"
time sudo systemctl restart afkbot
sleep 8
sudo systemctl status afkbot --no-pager | head -6

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  DIAGNOSTIC COMPLETE"
echo "════════════════════════════════════════════════════════════"






