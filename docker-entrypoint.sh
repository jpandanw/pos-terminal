#!/bin/sh

# If API_URL is set, inject it into the index.html meta tag
if [ -n "$API_URL" ]; then
  echo "Injecting API_URL: $API_URL"
  sed -i "s|<meta name=\"api-url\" content=\"[^\"]*\"|<meta name=\"api-url\" content=\"$API_URL\"|g" /usr/share/nginx/html/index.html
fi

# Execute NGINX CMD
exec "$@"
