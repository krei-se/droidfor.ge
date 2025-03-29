#!/bin/bash

# Parse ldapconfig.ini
source <(grep = ldapconfig.ini)

# Ensure required variables are set
if [[ -z "$LDAPuri" || -z "$LDAPlookupDN" || -z "$LDAPlookupPass" || -z "$LDAPbaseDN" ]]; then
    echo "LDAP configuration is missing. Check ldapconfig.ini."
    exit 1
fi

# Email to search for (pass as argument)
if [[ -z "$1" ]]; then
    echo "Usage: $0 <email>"
    exit 1
fi

USER_EMAIL="$1"


# Perform ldapsearch to get UID and GID
LDAP_OUTPUT=$(ldapsearch -x -H "$LDAPuri" -D "$LDAPlookupDN" -w "$LDAPlookupPass" -b "$LDAPbaseDN" "(mail=$USER_EMAIL)" uid gidNumber)

# Extract UID
LDAPUID=$(echo "$LDAP_OUTPUT" | grep '^uid:' | awk '{print $2}')

# Extract GID
LDAPGID=$(echo "$LDAP_OUTPUT" | grep '^gidNumber:' | awk '{print $2}')

# Extract HOME
LDAPHOME=$(echo "$LDAP_OUTPUT" | grep '^homeDirectory:' | awk '{print $2}')


# Check if UID and GID were found
if [[ -z "$LDAPUID" || -z "$LDAPGID" || -z "$LDAPHOME" ]]; then
    exit 1
fi


# Get primary group name using GID
LDAPGROUP_NAME=$(getent group "$LDAPGID" | cut -d: -f1)

# Output results
echo "LDAPUID=$LDAPUID"
echo "LDAPGID=$LDAPGID"
echo "LDAPGROUP_NAME=$LDAPGROUP_NAME"
echo "LDAPHOMME=$LDAPHOME"
