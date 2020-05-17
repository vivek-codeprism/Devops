server {
  root ${nginx_home}/www;
  index index.html;
  server_name www.${environment}.${domain};
  listen 443 ssl;
  ssl_certificate /etc/ssl/certificate.pem;
  ssl_certificate_key /etc/ssl/private_key.pem;

  # Redirect non-https traffic to https
  listen 80;
  if ($scheme != "https") {
    return 301 https://$host$request_uri;
  }
}
