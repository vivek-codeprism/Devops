input {
  beats {
    port => "5044"
  }
}

filter {
  if [monitor][status] == "up" {
    drop { }
  }
  throttle {
    before_count => 3
    after_count => 4
    period => 21600
    max_age => 43200
    key => "%{[error][message]}%{[monitor][id]}"
    add_tag => "throttled"
  }
  if "throttled" in [tags] {
    drop { }
  }
}

output {
  file {
    path => "/var/log/logstash/alert.log"
  }
  http {
    http_method => "post"
    url => "${webhook_url}"
    mapping => {
      text => "%{[error][message]} %{[monitor][id]}"
    }
  }
}
