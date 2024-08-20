#!/bin/bash

THUMBPRINT=$(echo | openssl s_client -servername oidc.eks.us-east-1.amazonaws.com -showcerts -connect oidc.eks.us-east-1.amazonaws.com:443 2>/dev/null | openssl x509 -fingerprint -noout | cut -d'=' -f2 | sed 's/://g')

# Output the thumbprint in JSON format
echo "{\"thumbprint\": \"$THUMBPRINT\"}"
