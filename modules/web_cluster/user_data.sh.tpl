#!/bin/bash
# Bootstrap script for web_cluster instances (Amazon Linux 2023).
# Templated by Terraform via templatefile() in main.tf.

set -euo pipefail

dnf install -y httpd
systemctl enable httpd
systemctl start httpd

cat > /etc/httpd/conf.d/healthcheck.conf <<'EOF'
<Location "/">
  Require all granted
</Location>
EOF

cat > /var/www/html/index.html <<HTML
<!doctype html>
<html>
  <head><title>${project_name} (${environment})</title></head>
  <body>
    <h1>${project_name} — ${environment}</h1>
    <p>Served by $(hostname -f) via terraform-managed launch template.</p>
  </body>
</html>
HTML

systemctl restart httpd

# db_password is available here (e.g. written to an app config file) but is
# intentionally not echoed or logged.
