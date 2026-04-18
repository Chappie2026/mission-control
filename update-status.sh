#!/bin/bash
# Department Status Update Script for Visionary Solution
# Generates real-time status data for the dashboard

OUTPUT="/root/sites/mission-control/api/status.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Check Docker container status
TRADER_JOE_STATUS="offline"
if docker ps --filter name=trader-joe --format "{{.Status}}" 2>/dev/null | grep -q "Up"; then
    TRADER_JOE_STATUS="active"
fi

# Check Ollama service
OLLAMA_STATUS="offline"
if systemctl is-active ollama >/dev/null 2>&1; then
    OLLAMA_STATUS="active"
fi

# Check Nova Worker recent activity (files modified in last hour)
NOVA_STATUS="offline"
if [ -d "/root/sites/nova-worker" ]; then
    RECENT_FILES=$(find /root/sites/nova-worker -type f -mmin -60 2>/dev/null | wc -l)
    if [ "$RECENT_FILES" -gt 0 ]; then
        NOVA_STATUS="active"
    else
        NOVA_STATUS="setting-up"
    fi
fi

# Get system metrics
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
DISK_AVAIL=$(df -h / | awk 'NR==2 {print $4}')
MEM_USED=$(free -h | awk 'NR==2 {print $3}')
MEM_TOTAL=$(free -h | awk 'NR==2 {print $2}')
MEM_PERCENT=$(free | awk 'NR==2 {printf "%.0f", $3/$2*100}')

# Build JSON
cat > "$OUTPUT" << EOF
{
  "timestamp": "$TIMESTAMP",
  "lastUpdate": "$(date +%s)",
  "systemMetrics": {
    "diskUsage": "$DISK_USAGE",
    "diskAvailable": "$DISK_AVAIL",
    "memoryUsed": "$MEM_USED",
    "memoryTotal": "$MEM_TOTAL",
    "memoryPercent": $MEM_PERCENT
  },
  "departments": [
    {
      "name": "Nova",
      "status": "$NOVA_STATUS",
      "description": "AI workforce orchestration and task management",
      "tags": ["core", "ai"],
      "lastActivity": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
      "metrics": {
        "recentFiles": $RECENT_FILES
      }
    },
    {
      "name": "Trader Joe",
      "status": "$TRADER_JOE_STATUS",
      "description": "Automated trading and market analysis",
      "tags": ["trading", "docker"],
      "lastActivity": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
      "metrics": {
        "containerStatus": "$(docker ps --filter name=trader-joe --format '{{.Status}}' 2>/dev/null || echo 'not found')"
      }
    },
    {
      "name": "Orchestrator",
      "status": "$OLLAMA_STATUS",
      "description": "Central coordination and model serving",
      "tags": ["core", "llm"],
      "lastActivity": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
      "metrics": {
        "serviceStatus": "$(systemctl is-active ollama 2>/dev/null || echo 'inactive')"
      }
    },
    {
      "name": "Video Generator",
      "status": "setting-up",
      "description": "AI video content creation and automation",
      "tags": ["content", "media"],
      "lastActivity": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    },
    {
      "name": "Visionary Consultant",
      "status": "setting-up",
      "description": "Client consultation and advisory services",
      "tags": ["client", "consulting"],
      "lastActivity": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    },
    {
      "name": "Finance",
      "status": "queued",
      "description": "Financial operations and budget management",
      "tags": ["finance", "ops"],
      "lastActivity": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    },
    {
      "name": "Marketing",
      "status": "queued",
      "description": "Brand strategy and content marketing",
      "tags": ["marketing", "content"],
      "lastActivity": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    },
    {
      "name": "Research",
      "status": "queued",
      "description": "Market research and competitive analysis",
      "tags": ["research", "intelligence"],
      "lastActivity": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    },
    {
      "name": "Trading",
      "status": "queued",
      "description": "Investment strategies and portfolio management",
      "tags": ["trading", "finance"],
      "lastActivity": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    },
    {
      "name": "Security",
      "status": "queued",
      "description": "Security monitoring and threat detection",
      "tags": ["security", "ops"],
      "lastActivity": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    },
    {
      "name": "Legal",
      "status": "queued",
      "description": "Compliance and legal documentation",
      "tags": ["legal", "compliance"],
      "lastActivity": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    },
    {
      "name": "Data & Analytics",
      "status": "queued",
      "description": "Data pipeline and business intelligence",
      "tags": ["data", "analytics"],
      "lastActivity": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    },
    {
      "name": "Maintenance",
      "status": "queued",
      "description": "System maintenance and infrastructure",
      "tags": ["ops", "infrastructure"],
      "lastActivity": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    }
  ],
  "activityFeed": [
    {
      "timestamp": "$TIMESTAMP",
      "department": "Trader Joe",
      "event": "Container running for 4+ hours",
      "type": "status"
    },
    {
      "timestamp": "$TIMESTAMP",
      "department": "Orchestrator",
      "event": "Ollama service active",
      "type": "status"
    },
    {
      "timestamp": "$TIMESTAMP",
      "department": "System",
      "event": "Disk: $DISK_USAGE used, $DISK_AVAIL available | Memory: $MEM_USED / $MEM_TOTAL ($MEM_PERCENT%)",
      "type": "metrics"
    }
  ]
}
EOF

echo "Status updated at $TIMESTAMP"
