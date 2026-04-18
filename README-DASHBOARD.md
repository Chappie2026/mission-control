# Live Department Dashboard - Visionary Solution

## Overview
Dynamic department status dashboard running at `http://localhost:8200/department-dashboards.html`

## Components

### 1. Web Server (nginx)
- **Port:** 8200
- **Config:** `/etc/nginx/sites-available/mission-control`
- **Document Root:** `/root/sites/mission-control`
- **Status:** Active and running

### 2. Status API
- **Endpoint:** `http://localhost:8200/api/status.json`
- **Update Script:** `/root/sites/mission-control/update-status.sh`
- **Auto-Update:** Every 5 minutes via cron
- **Data Sources:**
  - Docker container `trader-joe` status
  - Systemd service `ollama` status
  - Nova Worker file activity (last hour)
  - System metrics (disk, memory)

### 3. Dashboard Features
- **Auto-refresh:** Every 5 minutes
- **Real-time metrics:** Disk usage, memory, active departments
- **Department cards:** 13 departments with status badges
- **Activity feed:** Recent events and system status
- **Responsive design:** Works on desktop, tablet, mobile
- **Color scheme:** Navy (#102a43) and Teal (#2cb1bc)

## Status Values
- **active** - Department is running and operational
- **setting-up** - Department is being configured
- **queued** - Department is planned but not yet started
- **offline** - Department is not running

## Departments Tracked
1. Nova - AI workforce orchestration
2. Trader Joe - Automated trading (Docker container)
3. Orchestrator - Model serving (Ollama)
4. Video Generator
5. Visionary Consultant
6. Finance
7. Marketing
8. Research
9. Trading
10. Security
11. Legal
12. Data & Analytics
13. Maintenance

## Manual Updates
To manually update the status data:
```bash
/root/sites/mission-control/update-status.sh
```

## Viewing the Dashboard
```bash
# View in browser
curl http://localhost:8200/department-dashboards.html

# View raw JSON data
curl http://localhost:8200/api/status.json | jq
```

## Cron Schedule
```
*/5 * * * * /root/sites/mission-control/update-status.sh > /dev/null 2>&1
```

## Troubleshooting

### Check nginx status
```bash
systemctl status nginx
```

### View nginx error logs
```bash
tail -f /var/log/nginx/error.log
```

### Test status update
```bash
/root/sites/mission-control/update-status.sh
cat /root/sites/mission-control/api/status.json | jq
```

### Restart nginx
```bash
systemctl reload nginx
```

## Next Steps
- Add more real-time checks for other departments
- Integrate with alerting system
- Add historical trend data
- Create API endpoints for department management
- Add authentication for external access
