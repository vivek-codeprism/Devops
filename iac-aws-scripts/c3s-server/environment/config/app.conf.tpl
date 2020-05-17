server {
  root ${nginx_home}/app;
  index index.html;
  server_name app.${environment}.${domain};
  listen 443 ssl;
  ssl_certificate /etc/ssl/certificate.pem;
  ssl_certificate_key /etc/ssl/private_key.pem;

  location ~ ^/api(?<fwd_path>/.*|)$ {
    client_max_body_size 512k;
    client_body_buffer_size 128k;
    proxy_pass http://127.0.0.1:5000$fwd_path$is_args$args;
    proxy_http_version 1.1;
    proxy_read_timeout 596h;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host      $host;
    proxy_set_header X-Real-IP $remote_addr;
  }
  location ~ ^/user-services(?<fwd_path>/.*|)$ {
    client_max_body_size 512k;
    client_body_buffer_size 128k;
    proxy_pass http://127.0.0.1:5984$fwd_path$is_args$args;
    proxy_http_version 1.1;
    proxy_read_timeout 596h;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host      $host;
    proxy_set_header X-Real-IP $remote_addr;
  }

  # Redirect non-https traffic to https
  listen 80;
  if ($scheme != "https") {
    return 301 https://$host$request_uri;
  }

}
