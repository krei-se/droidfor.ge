#!/bin/bash

cp -dR skeleton.krei.se skeleton.$DF_DOMAIN_FQDN

echo "*" > skeleton.$DF_DOMAIN_FQDN/.gitignore

return 0