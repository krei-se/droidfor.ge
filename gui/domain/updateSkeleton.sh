#!/bin/bash

if whiptail \
    --title "Update 🩻 Skeleton for $DF_DOMAIN_FQDN" \
    --yesno "If you git-pulled a newer version of Droidfor.ge, you can update your 🩻 Skeleton for $DF_DOMAIN_FQDN \
from the always greatfully improved Krei·se-Template. Notice this will overwrite any files in your user/machine-Tasks \
but not delete files you created. \n\nWhen you're ready to update your 🩻 Skeleton, press Yes!" \
    20 $WT_WIDTH; then
    cp -dR skeleton.krei.se skeleton.$DF_DOMAIN_FQDN
fi

#
return 0