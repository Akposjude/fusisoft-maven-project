#!/bin/bash

# ================================
# Jenkins Connection
# ================================
JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_API_TOKEN="YOUR_API_TOKEN"
JOB_NAME="my-devops-pipeline"

# Trigger Types
ENABLE_GITHUB_WEBHOOK=true
ENABLE_POLL_SCM=true
ENABLE_CRON=true

# Poll SCM schedule
SCM_SCHEDULE="H/5 * * * *"      # Every 5 minutes

# Cron schedule
CRON_SCHEDULE="H 2 * * *"       # Daily at 2AM

# ================================
# Get CSRF Token
# ================================
CRUMB=$(curl -s -u "$JENKINS_USER:$JENKINS_API_TOKEN" \
"$JENKINS_URL/crumbIssuer/api/json" | jq -r '.crumb')

# ================================
# Download Job Config
# ================================
curl -s -u "$JENKINS_USER:$JENKINS_API_TOKEN" \
"$JENKINS_URL/job/$JOB_NAME/config.xml" > config.xml

# ================================
# Inject Triggers
# ================================
sed -i '/<triggers>/,/<\/triggers>/d' config.xml

cat >> config.xml <<EOF
<triggers>
EOF

if [ "$ENABLE_GITHUB_WEBHOOK" = true ]; then
cat >> config.xml <<EOF
  <com.cloudbees.jenkins.GitHubPushTrigger plugin="github">
    <spec></spec>
  </com.cloudbees.jenkins.GitHubPushTrigger>
EOF
fi

if [ "$ENABLE_POLL_SCM" = true ]; then
cat >> config.xml <<EOF
  <hudson.triggers.SCMTrigger>
    <spec>$SCM_SCHEDULE</spec>
  </hudson.triggers.SCMTrigger>
EOF
fi

if [ "$ENABLE_CRON" = true ]; then
cat >> config.xml <<EOF
  <hudson.triggers.TimerTrigger>
    <spec>$CRON_SCHEDULE</spec>
  </hudson.triggers.TimerTrigger>
EOF
fi

cat >> config.xml <<EOF
</triggers>
EOF

# ================================
# Upload Updated Config
# ================================
curl -X POST "$JENKINS_URL/job/$JOB_NAME/config.xml" \
-u "$JENKINS_USER:$JENKINS_API_TOKEN" \
-H "Jenkins-Crumb:$CRUMB" \
-H "Content-Type: application/xml" \
--data-binary @config.xml

echo "Triggers configured successfully for $JOB_NAME"

