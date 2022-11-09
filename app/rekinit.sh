#!/usr/bin/env bash

echo "Kerberos sidecar container is started at $(date)."

cp /krb5.conf "$VOLUME"

if [ ! -f /etc/krb5.conf ]; then
    echo "/etc/krb5.conf not found, please map your volume to make it available to this container"
    exit 1
fi

if [[ -z "${PRINCIPAL// }" ]]; then echo "PRINCIPAL hasn't been provided"; exit 1; fi;
# prompt user for password
# IFS= read -s  -p "Enter $PRINCIPAL password:" PASSWORD
# echo ""
if [[ -z "${PASSWORD// }" ]]; then echo "PASSWORD hasn't been provided, exit"; exit 1; fi;
KEYTAB_SECURITY=${KEYTAB_SECURITY:-"rc4-hmac"}

# password verifications
echo "========== Verifying password... =========="
echo $PASSWORD | kinit -V $PRINCIPAL
ret_code=$?
if [ $ret_code != 0 ]; then
  echo "Error : Wrong username/password combination"
  exit $ret_code
fi

# # generate keytab
# echo "========== Generating Keytab... =========="
# KEYTAB_FILE=$(echo $PRINCIPAL | cut -d@ -f1 | cut -d/ -f1 | tr '[:upper:]' '[:lower:]').keytab
# ktutil < <(echo -e "addent -password -p $PRINCIPAL -k 1 -e $KEYTAB_SECURITY\n$PASSWORD\nwrite_kt $KEYTAB_FILE\nquit")

while true; do
  echo "*** Trying to kinit at $(date). ***"
  # kinit -kt "$SECRETS/$KEYTAB" "$PRINCIPAL"
  kinit -V -kt "$SECRETS/$KEYTAB" "$PRINCIPAL"

  result=$?
  if [ "$result" -eq 0]; then
    echo "kinit is successfull. Sleeping for $REKINIT_PERIOD seconds."
  else
    echo "kinit is exited with error. result code: $result"
    exit 1
  fi

  sleep "$REKINIT_PERIOD"
done
