heartbeat.monitors:
- type: http
  urls: ${url}
  schedule: '@every 1m'

output.logstash:
  hosts: ["localhost:5044"]
