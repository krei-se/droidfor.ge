#!/bin/bash

# source / input function

ldap_lookup() {

    local LDAP_RESULT_ARRAY
    local LDAP_RESULT_STATE
    local LDAP_UID LDAP_USERNAME LDAP_GID LDAP_GROUPNAME LDAP_HOME

    local LDAP_OUTPUT
    local LDAP_GROUP_OUTPUT

    # Parse ldapconfig.ini
    source <(grep = ldapconfig.ini)

    # Ensure required variables are set
    if [[ -z "$LDAP_URI" || -z "$LDAP_baseDN" ]]; then
        echo "LDAP configuration is missing. Check ldapconfig.ini. or copy ldapconfig.ini.example"
        exit 1
    fi

    # Email to search for (pass as argument)
    if [[ -z "$1" ]]; then
        echo "Usage: $0 <email>"
        exit 1
    fi

    USER_EMAIL="$1"

    if [[ -n $LDAP_lookupDN ]]; then
        echo "using lookup-dn"
        # Perform ldapsearch with lookupDN
        LDAP_OUTPUT=$(ldapsearch -x -H "$LDAP_URI" -D "$LDAP_lookupDN" -w "$LDAP_lookupPass" -b "$LDAP_baseDN" "(mail=$USER_EMAIL)" uidNumber uid gidNumber homeDirectory)
    else
        # Perform ldapsearch without lookupDN
        LDAP_OUTPUT=$(ldapsearch -H "$LDAP_URI" -b "$LDAP_baseDN" "(mail=$USER_EMAIL)" uid gidNumber)
    fi

    # Extract UID
    LDAP_UID=$(echo "$LDAP_OUTPUT" | grep '^uidNumber:' | awk '{print $2}')

    # Extract Username
    LDAP_USERNAME=$(echo "$LDAP_OUTPUT" | grep '^uid:' | awk '{print $2}')

    # Extract GID
    LDAP_GID=$(echo "$LDAP_OUTPUT" | grep '^gidNumber:' | awk '{print $2}')

    # Extract HOME
    LDAP_HOME=$(echo "$LDAP_OUTPUT" | grep '^homeDirectory:' | awk '{print $2}')

    LDAP_RESULT_STATE=true

    # Check if UID and GID were found
    if [[ -z "$LDAP_UID" ||-z "$LDAP_USERNAME" || -z "$LDAP_GID" || -z "$LDAP_HOME" ]]; then
        LDAP_RESULT_STATE=false
    fi

    # Get primary group name using GID
    LDAP_GROUPNAME=$(getent group "$LDAP_GID" | cut -d: -f1)

    if [[ -n $LDAP_lookupDN ]]; then
        # Perform ldapsearch with lookupDN
        echo "using lookup-dn"
        LDAP_GROUP_OUTPUT=$(ldapsearch -x -H "$LDAP_URI" -D "$LDAP_lookupDN" -w "$LDAP_lookupPass" -b "$LDAP_baseDN" "(&(objectClass=posixGroup)(gidNumber=$LDAP_GID))" cn)
    else
        # Perform ldapsearch without lookupDN
        LDAP_GROUP_OUTPUT=$(ldapsearch -H "$LDAP_URI" -b "$LDAP_baseDN" "(&(objectClass=posixGroup)(gidNumber=$LDAP_GID)" cn)
    fi

    LDAP_GROUPNAME=$(echo "$LDAP_GROUP_OUTPUT" | grep '^cn:' | awk '{print $2}')

    if [[ -z "$LDAP_GROUPNAME" ]]; then
        LDAP_RESULT_STATE=false
    fi

    LDAP_RESULT_ARRAY=("$LDAP_RESULT_STATE" "$LDAP_UID" "$LDAP_USERNAME" "$LDAP_GID" "$LDAP_GROUPNAME" "$LDAP_HOME")

    echo "${LDAP_RESULT_ARRAY[@]}"

}