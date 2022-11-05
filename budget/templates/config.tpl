redirect_url = "https://${domain}/oauth2/callback" 
upstreams = [
    "http://{{ docker_ip }}" # this is the IP from the docker network
]
authenticated_emails_file = "/etc/authenticated_emails.txt"
client_id = "${clientId}"
client_secret = "${clientSecret}"
pass_access_token = true
cookie_secret = "${cookieSecret}"
cookie_secure = true
skip_provider_button = false
ssl_insecure_skip_verify = true
http_address = "0.0.0.0:80"
tls_key_file = "/etc/letsencrypt/live/${domain}/privkey.pem"
tls_cert_file = "/etc/letsencrypt/live/${domain}/fullchain.pem"
