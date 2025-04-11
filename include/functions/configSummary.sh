#!/bin/bash

export DF_CONFIG_SUMMARY="" #"Config Summary: \n"

# Domain

if [[ -n "$DF_DOMAIN_FQDN" ]]; then
    DF_CONFIG_SUMMARY+="🌐 Domain  : $DF_DOMAIN_FQDN \n"
else
    DF_CONFIG_SUMMARY+="🌐 Domain  : no DF_DOMAIN_FQDN set \n"
fi

if [[ -n "$DF_DOMAIN_FQDN" ]]; then

    if [[ -d "skeleton.$DF_DOMAIN_FQDN" ]]; then
        DF_CONFIG_SUMMARY+="        🩻 : Skeleton found in skeleton.$DF_DOMAIN_FQDN/ \n"
    else
        DF_CONFIG_SUMMARY+="        🩻 : ! No Skeleton found \n"
    fi

    # Services
        DF_CONFIG_SUMMARY+="        🤵 : "

    if [[ "$DF_DOMAIN_HAS_LDAP" -eq 1 ]]; then
        DF_CONFIG_SUMMARY+="🌳 LDAP. found "
    fi

    if [[ "$DF_DOMAIN_HAS_MPD" -eq 1 ]]; then
        DF_CONFIG_SUMMARY+="🎧 MPD. found "
    fi

    if [[ "$DF_DOMAIN_HAS_LDAP" -eq 0 && "$DF_DOMAIN_HAS_MPD" -eq 0 ]]; then
        DF_CONFIG_SUMMARY+="No Services found"
    fi

    DF_CONFIG_SUMMARY+="\n"

    # Kerberos

    if [[ -n "$DF_DOMAIN_KERBEROS_REALM" ]]; then
        DF_CONFIG_SUMMARY+="        🐩 : Kerberos Realm: $DF_DOMAIN_KERBEROS_REALM \n"
    fi

    if [[ -z "$DF_DOMAIN_KERBEROS_REALM" ]]; then
        DF_CONFIG_SUMMARY+="        🐩 : No Kerberos Realm found (TXT _kerberos. missing) \n"
    fi
    

fi
# Machine

if [[ -n "$DF_MACHINE_FQDN" ]]; then
    DF_CONFIG_SUMMARY+="📲 Machine : $DF_MACHINE_FQDN \n"
else
    DF_CONFIG_SUMMARY+="📲 Machine : no DF_MACHINE_FQDN set \n"
fi

if [[ -n "$DF_MACHINE_ADBID" ]]; then
    DF_CONFIG_SUMMARY+="    🤖 ADB : $DF_MACHINE_ADBID \n"
fi

if [[ -n "$DF_MACHINE_HASROOT" ]]; then
    DF_CONFIG_SUMMARY+="   🤿 Root : Magisk-Check passed \n"
fi

# User

if [[ -n "$DF_USER_UPN" ]]; then
    DF_CONFIG_SUMMARY+="👤 User    : $DF_USER_UPN \n"
else
    DF_CONFIG_SUMMARY+="👤 User    : no DF_USER_UPN set \n"
fi
