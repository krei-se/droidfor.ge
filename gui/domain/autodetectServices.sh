#!/bin/bash

# try to find whether a local ldap is present, prefer ldaps

echo "Trying to find the local ldap server via SRV-Record in $DF_DOMAIN_FQDN";
#ping -c 1 -W 2 ldap.$DF_DOMAIN_FQDN &> /dev/null

srv_record=$(dig +short SRV _ldaps._tcp.$DF_DOMAIN_FQDN | sort -n | head -n 1 )

# ldaps found
if [[ -n "$srv_record" ]]; then
    DF_DOMAIN_LDAP_TYPE="ldaps"
    DF_DOMAIN_LDAP_SRV=$srv_record
fi

# no ldaps-record found? Try ldap
if [[ -z "$srv_record" ]]; then
    srv_record=$(dig +short SRV _ldap._tcp.$DF_DOMAIN_FQDN | sort -n | head -n 1 )
    if [[ -n "$srv_record" ]]; then
        DF_DOMAIN_LDAP_TYPE="ldap"
        DF_DOMAIN_LDAP_SRV=$srv_record
    fi
fi

echo "$DF_DOMAIN_LDAP_SRV"

DF_DOMAIN_HAS_LDAP=0
DF_DOMAIN_LDAP_BASEDN=""

# Record found?
if [[ -n "$DF_DOMAIN_LDAP_SRV" ]]; then
    parts=($DF_DOMAIN_LDAP_SRV)
    DF_DOMAIN_LDAP_HOST=${parts[3]} # $(echo "$DF_DOMAIN_LDAP_SRV" | awk '{print $4}')
    DF_DOMAIN_LDAP_PORT=${parts[2]} # $(echo "$DF_DOMAIN_LDAP_SRV" | awk '{print $3}')

    ping -c 1 -W 2 "$DF_DOMAIN_LDAP_HOST" &> /dev/null

    if [[ $? -eq 0 ]]; then
        DF_DOMAIN_HAS_LDAP=1
        DF_DOMAIN_LDAP_URI="${DF_DOMAIN_LDAP_HOST}://${DF_DOMAIN_LDAP_HOST}:${DF_DOMAIN_LDAP_HOST}"
        # try to get the naming context
        DF_DOMAIN_LDAP_NC_OUTPUT=$(ldapsearch -x -H "$DF_DOMAIN_LDAP_URI" -s base -b "" namingContexts 2>/dev/null | awk '/^namingContexts:/ { print $2 }')
    
        # if there is one, use it for the baseDN. Do not try to guess it, have the user input it
        if [[ -n "$DF_DOMAIN_LDAP_NC_OUTPUT" ]]; then
            DF_DOMAIN_LDAP_BASEDN="$DF_DOMAIN_LDAP_NC_OUTPUT"
        fi 
    
    fi
fi

echo "Host: " "$DF_DOMAIN_LDAP_HOST"
echo "Port: " "$DF_DOMAIN_LDAP_PORT"

export DF_DOMAIN_HAS_LDAP
export DF_DOMAIN_LDAP_HOST
export DF_DOMAIN_LDAP_PORT
export DF_DOMAIN_LDAP_URI
export DF_DOMAIN_LDAP_BASEDN


export DF_DOMAIN_LDAP_NEEDSAUTH

#if [[ -n "$DF_DOMAIN_HAS_LDAP"]]; then



#fi

#echo $DF_DOMAIN_HAS_LDAP

echo "Trying to find a local mpd.$DF_DOMAIN_FQDN";
ping -c 1 -W 2 mpd.$DF_DOMAIN_FQDN &> /dev/null

if [[ $? -eq 0 ]]; then
    DF_DOMAIN_HAS_MPD=1
else
    DF_DOMAIN_HAS_MPD=0
fi

export DF_DOMAIN_HAS_MPD

DF_DOMAIN_KERBEROS_REALM=$(dig +short TXT _kerberos.$DF_DOMAIN_FQDN | head -n 1 | sed 's/\"//g')

export DF_DOMAIN_KERBEROS_REALM

return 0