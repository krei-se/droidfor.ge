#!/bin/bash

DF_HOSTNAME=$(hostname)

whiptail \
    --title "SRV/TXT-Record Howto" \
    --msgbox "\n\
Droidfor.ge checks your Domain via hostname -d, so make sure its set correctly in /etc/hosts\n\n\
Example:\n\
127.0.0.1    localhost\n\
127.0.1.1    $DF_HOSTNAME.$DF_DOMAIN_FQDN    $DF_HOSTNAME\n\n\
Droidfor.ge then checks the following TXT and SRV-Records via dig:\n\n\
- The SRV-Record _ldaps._tcp.$DF_DOMAIN_FQDN first, then just _ldap._tcp.$DF_DOMAIN_FQDN to get the hostname to your LDAP-Instance
- The TXT-Record _kerberos.$DF_DOMAIN_FQDN to get your Kerberos-Realm
- From the kerberos-Realm the SRV-Records _kerberos._tcp.REALM to get the main KDC\n
  you can define _kerberos-adm._tcp and _kpasswd._tcp but we don't need or check these \
\n\n\
- The SRV-Records _caldavs._tcp. and _caldavs._tcp for DAVx5 - these will never use non-SSL.\n
- The TXT-Records ed25519._tlsa.ca.$DF_DOMAIN_FQDN - non-standard, but enables copying of the linked CA.crt to your device
    Point this record to https://certs.$DF_DOMAIN_FQDN/ca.$DF_DOMAIN_FQDN.crt f.e. to have a webserver serve it\n
- A comfort task will check for the HOST mpd.$DF_DOMAIN_FQDN via simple ping to ease setup of MALP
\n\n\
For more details on how to set SRV and TXT-Records using OpnSense or OpenWRT please visit the Github Page" \
    40 $WT_WIDTH
#
return 0