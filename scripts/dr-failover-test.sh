#!/bin/bash
# =============================================================================
# Disaster Recovery Failover Test Script
# Tests the DR capabilities of the multi-cloud deployment
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  Multi-Cloud DR Failover Test${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Configuration
AWS_ENDPOINT=${AWS_ENDPOINT:-"http://aws-alb-dns-name.amazonaws.com"}
AZURE_ENDPOINT=${AZURE_ENDPOINT:-"http://azure-public-ip"}
DNS_ENDPOINT=${DNS_ENDPOINT:-"http://dr-app.example.com"}
HEALTH_PATH="/health"
TEST_RESULTS_FILE="dr-test-results-$(date +%Y%m%d-%H%M%S).json"

# Function: Check endpoint health
check_health() {
    local name=$1
    local url=$2
    local start_time=$(date +%s%N)
    
    if response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "${url}${HEALTH_PATH}" 2>/dev/null); then
        local end_time=$(date +%s%N)
        local latency=$(( (end_time - start_time) / 1000000 ))  # ms
        
        if [ "$response" = "200" ]; then
            echo -e "  ${GREEN}✅ ${name}: HEALTHY (${latency}ms)${NC}"
            return 0
        else
            echo -e "  ${RED}❌ ${name}: UNHEALTHY (HTTP ${response})${NC}"
            return 1
        fi
    else
        echo -e "  ${RED}❌ ${name}: UNREACHABLE${NC}"
        return 1
    fi
}

# Test 1: Pre-failover health check
echo -e "${YELLOW}Test 1: Pre-Failover Health Check${NC}"
echo "---"
check_health "AWS Primary" "$AWS_ENDPOINT" || true
check_health "Azure Secondary" "$AZURE_ENDPOINT" || true
check_health "DNS Endpoint" "$DNS_ENDPOINT" || true
echo ""

# Test 2: Simulate AWS failure
echo -e "${YELLOW}Test 2: Simulating AWS Primary Failure${NC}"
echo "---"
echo -e "  ${BLUE}ℹ️  To simulate: Stop AWS instances via console or:${NC}"
echo -e "  ${BLUE}   aws ec2 stop-instances --instance-ids <id>${NC}"
echo -e "  ${BLUE}   Or: terraform destroy -target=module.aws_compute${NC}"
echo ""
read -p "  Press Enter after simulating AWS failure (or Ctrl+C to skip)..."
echo ""

# Test 3: Measure failover time (RTO)
echo -e "${YELLOW}Test 3: Measuring Recovery Time Objective (RTO)${NC}"
echo "---"
FAILOVER_START=$(date +%s)
echo -e "  Failover started at: $(date)"
echo -e "  Waiting for DNS failover to Azure..."

max_wait=300  # 5 minutes
elapsed=0
while [ $elapsed -lt $max_wait ]; do
    if curl -s --connect-timeout 5 "${DNS_ENDPOINT}${HEALTH_PATH}" | grep -q 'healthy' 2>/dev/null; then
        FAILOVER_END=$(date +%s)
        RTO=$((FAILOVER_END - FAILOVER_START))
        echo -e "  ${GREEN}✅ Failover complete! RTO: ${RTO} seconds${NC}"
        break
    fi
    sleep 5
    elapsed=$((elapsed + 5))
    echo -e "  ⏳ Waiting... (${elapsed}s elapsed)"
done

if [ $elapsed -ge $max_wait ]; then
    echo -e "  ${RED}❌ Failover did not complete within ${max_wait}s${NC}"
    RTO="FAILED"
fi
echo ""

# Test 4: Post-failover verification
echo -e "${YELLOW}Test 4: Post-Failover Verification${NC}"
echo "---"
check_health "Azure (now active)" "$AZURE_ENDPOINT" || true
check_health "DNS Endpoint" "$DNS_ENDPOINT" || true
echo ""

# Test 5: Failback
echo -e "${YELLOW}Test 5: Failback to AWS${NC}"
echo "---"
echo -e "  ${BLUE}ℹ️  Restart AWS instances and wait for health checks${NC}"
read -p "  Press Enter after restarting AWS (or Ctrl+C to skip)..."
FAILBACK_START=$(date +%s)

elapsed=0
while [ $elapsed -lt $max_wait ]; do
    if curl -s --connect-timeout 5 "${AWS_ENDPOINT}${HEALTH_PATH}" | grep -q 'healthy' 2>/dev/null; then
        FAILBACK_END=$(date +%s)
        FAILBACK_TIME=$((FAILBACK_END - FAILBACK_START))
        echo -e "  ${GREEN}✅ Failback complete! Time: ${FAILBACK_TIME} seconds${NC}"
        break
    fi
    sleep 5
    elapsed=$((elapsed + 5))
    echo -e "  ⏳ Waiting... (${elapsed}s elapsed)"
done
echo ""

# Summary
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  DR Test Summary${NC}"
echo -e "${BLUE}============================================${NC}"
echo -e "  Date:            $(date)"
echo -e "  RTO Achieved:    ${RTO:-N/A}s (Target: <300s)"
echo -e "  Failback Time:   ${FAILBACK_TIME:-N/A}s"
echo -e "  AWS Endpoint:    ${AWS_ENDPOINT}"
echo -e "  Azure Endpoint:  ${AZURE_ENDPOINT}"
echo -e "${BLUE}============================================${NC}"
