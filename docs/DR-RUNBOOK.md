# Disaster Recovery Runbook

## Multi-Cloud DR POC - Operational Procedures

---

## 1. DR Activation (AWS Failure)

### Automatic Failover (Primary Method)
Route53 health checks automatically detect AWS endpoint failure and switch DNS to Azure.

**Expected Timeline:**
| Step | Duration | Cumulative |
|------|----------|------------|
| Health check detects failure | 30-90s | ~1 min |
| DNS failover record activates | ~10s | ~1.5 min |
| DNS propagation (60s TTL) | 60s | ~2.5 min |
| Traffic reaches Azure | Immediate | ~3 min |
| **Total RTO** | | **< 5 min** |

### Manual Failover (If Automatic Fails)
```bash
# 1. Verify AWS is down
curl -f http://<aws-alb-dns>/health || echo "AWS is DOWN"

# 2. Verify Azure is up
curl -f http://<azure-public-ip>/health && echo "Azure is UP"

# 3. Manual DNS switch (Route53 console or CLI)
aws route53 change-resource-record-sets \
  --hosted-zone-id <ZONE_ID> \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "dr-app.example.com",
        "Type": "A",
        "TTL": 60,
        "ResourceRecords": [{"Value": "<azure-public-ip>"}]
      }
    }]
  }'

# 4. Verify DNS resolution
dig dr-app.example.com +short
```

---

## 2. DR Deactivation (Failback to AWS)

### Steps
1. **Verify AWS recovery**: Ensure all AWS instances are healthy
2. **Verify data sync**: Confirm Azure → AWS database sync is complete
3. **Route53 auto-failback**: If using failover routing, this is automatic
4. **Manual failback** (if needed): Update DNS back to AWS ALB

```bash
# Check AWS health
curl -f http://<aws-alb-dns>/health

# Check database sync status
PGPASSWORD=$DB_PASS psql -h <aws-rds-endpoint> -U dbadmin -d drapp \
  -c "SELECT count(*) FROM visits;"

# Compare with Azure
PGPASSWORD=$DB_PASS psql -h <azure-pg-fqdn> -U dbadmin -d drapp \
  -c "SELECT count(*) FROM visits;"
```

---

## 3. Common Issues & Resolution

### Issue: Health Check False Positive
**Symptom:** DNS fails over but AWS is actually running
**Resolution:**
```bash
# Check health check target
curl -v http://<aws-alb-dns>/health

# Verify security group allows health check traffic
aws ec2 describe-security-groups --group-ids <sg-id>

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn <tg-arn>
```

### Issue: Database Replication Lag
**Symptom:** Azure database is behind AWS
**Resolution:**
```bash
# Check replication status on AWS (source)
PGPASSWORD=$DB_PASS psql -h <aws-rds-endpoint> -U dbadmin -d drapp \
  -c "SELECT * FROM pg_stat_replication;"

# Verify logical replication slots
PGPASSWORD=$DB_PASS psql -h <aws-rds-endpoint> -U dbadmin -d drapp \
  -c "SELECT * FROM pg_replication_slots;"
```

### Issue: Terraform State Lock
**Symptom:** `Error locking state: ConditionalCheckFailedException`
**Resolution:**
```bash
# Check who holds the lock
aws dynamodb get-item \
  --table-name terraform-state-lock \
  --key '{"LockID": {"S": "multicloud-dr-terraform-state/dev/terraform.tfstate"}}'

# Force unlock (use with caution!)
terraform force-unlock <LOCK_ID>
```

---

## 4. Monitoring Checklist

### Daily
- [ ] Check CloudWatch dashboard for anomalies
- [ ] Verify Azure VM is running (standby)
- [ ] Review any triggered alerts

### Weekly
- [ ] Run DR failover test script
- [ ] Check database replication lag
- [ ] Review costs in AWS Cost Explorer + Azure Cost Management

### Monthly
- [ ] Full DR test (simulate AWS outage)
- [ ] Review and rotate secrets
- [ ] Update AMIs/VM images
- [ ] Review Terraform module versions

---

## 5. Contact & Escalation

| Level | Action | Timeframe |
|-------|--------|-----------|
| L1 | Check monitoring dashboards | 0-5 min |
| L2 | Run DR failover test script | 5-15 min |
| L3 | Manual intervention / Terraform apply | 15-30 min |
| L4 | Cloud provider support ticket | 30+ min |
