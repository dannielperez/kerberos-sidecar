#!/usr/bin/env bash

echo "Kerberos sidecar container is started at $(date)."

cp /krb5.conf "$VOLUME"

if [ ! -f /etc/krb5.conf ]; then
    echo "/etc/krb5.conf not found, please map your volume to make it available to this container"
    exit 1
fi

# if [[ -z "${PRINCIPAL// }" ]]; then echo "PRINCIPAL hasn't been provided"; exit 1; fi;
# # prompt user for password
# IFS= read -s  -p "Enter $PRINCIPAL password:" PASSWORD
# echo ""
# if [[ -z "${PASSWORD// }" ]]; then echo "PASSWORD hasn't been provided, exit"; exit 1; fi;

KEYTAB_SECURITY=${KEYTAB_SECURITY:-"AES256-SHA1"}

# # password verifications
# echo "========== Verifying password... =========="
# echo $PASSWORD | kinit -V $PRINCIPAL
# ret_code=$?
# if [ $ret_code != 0 ]; then
#   echo "Error : Wrong username/password combination"
#   exit $ret_code
# fi

# # # generate keytab
# # echo "========== Generating Keytab... =========="
# KEYTAB_FILE=$(echo $PRINCIPAL | cut -d@ -f1 | cut -d/ -f1 | tr '[:upper:]' '[:lower:]').keytab
# # ktutil < <(echo -e "addent -password -p $PRINCIPAL -k 1 -e $KEYTAB_SECURITY\n$PASSWORD\nwkt $KEYTAB_FILE\nquit")
# # printf "%b" "addent -password -p $PRINCIPAL -k 1 -e $KEYTAB_SECURITY\n$PASSWORD\nwkt $KEYTAB_FILE\nquit" | ktutil
# # printf "%b" "addent -password -p $PRINCIPAL -k 1 -e $KEYTAB_SECURITY\n$PASSWORD\nwrite_kt $KEYTAB_FILE" | ktutil
# echo -e "add_entry -password -p $PRINCIPAL -k 1 -e $KEYTAB_SECURITY\n$PASSWORD\nwkt $KEYTAB_FILE" | ktutil

while true; do
  echo "*** Trying to kinit at $(date). ***"
  # kinit -kt "$SECRETS/$KEYTAB" "$PRINCIPAL"
  # kinit -V -kt "$SECRETS/$KEYTAB" "$PRINCIPAL"
  kinit -V -kt $SECRETS/$KEYTAB $PRINCIPAL
  # kinit -V -kt $KEYTAB_FILE $PRINCIPAL

  result=$?
  if [ $result != 0 ]; then
    echo "Error : The keytab that was generated does not appear to work"
    exit $result
  else
    echo "kinit is successfull. Sleeping for $REKINIT_PERIOD seconds."
  fi

  sleep "$REKINIT_PERIOD"
done
