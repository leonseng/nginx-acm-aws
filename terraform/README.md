
Generate certs
Use API GW hostname as common name, not APIM hostname!
```
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes
```

Install agents on APIGW and devportal
```
curl -k https://apim.acm-internal.aws.leonseng.com/install/nginx-agent > install.sh && sudo sh install.sh -g data-plane && sudo systemctl start nginx-agent


curl -k https://apim.acm-internal.aws.leonseng.com/install/nginx-agent > install.sh && sudo sh install.sh -g dev-portal && sudo systemctl start nginx-agent
```
