#!/usr/bin/env bash

NGROK_DOMAIN="ngrok.me"
SUB_DOMAIN="test"
VALID_DATE=30

function help() {
  echo "Usage: "
  echo "  dt.sh [command] [subcommand] [-d <ngrok server domain>] [-t <crt valid date>]"
  echo "    <command> - 'gen-tls', 'test'"
  echo "      - 'gen-tls' - generate specify domain of ngrok client and server key and crt"
  echo "        <subcommand> - 'all', 'cli', 'srv'"
  echo "          - 'all' - client&server key and crt"
  echo "          - 'cli' - client key and crt"
  echo "          - 'srv' - server key and crt"
  echo "      - 'test' - append ngrok.me 127.0.0.1 to hosts"
  echo "        <subcommand>"
  echo "          - <subdomain> - test client subdomain, default 'test'"
  echo "Example: "
  echo "  gen-tls: "
  echo "    dt.sh gen-tls all -d test.ngrok.me -t 100"
  echo "    dt.sh gen-tls cli -d test.ngrok.me -t 7"
  echo "  test: "
  echo "    dt.sh test my -d test.ngrok.me"
}

COMMAND=$1
shift
SUB_COMMAND=$1
shift

while getopts "d:t:" opt; do
  case "$opt" in
  \?)
    help
    exit 0
    ;;
  d)
    NGROK_DOMAIN=${OPTARG}
    ;;
  t)
    VALID_DATE=${OPTARG}
    ;;
  esac
done

if [ "${COMMAND}" == "gen-tls" ]; then
  cd ./tls/
  mkdir ${NGROK_DOMAIN}
  cd ./${NGROK_DOMAIN}
  if [ "${SUB_COMMAND}" == "all" ]; then
    openssl genrsa -out client.key 2048
    openssl req -new -x509 -nodes -key client.key -days ${VALID_DATE} -subj "/CN=${NGROK_DOMAIN}" -out client.crt
    openssl genrsa -out server.key 2048
    openssl req -new -key server.key -subj "/CN=${NGROK_DOMAIN}" -out server.csr
    openssl x509 -req -in server.csr -CA client.crt -CAkey client.key -CAcreateserial -days ${VALID_DATE} -out server.crt
  elif [ "${SUB_COMMAND}" == "cli" ]; then
    openssl genrsa -out client.key 2048
    openssl req -new -x509 -nodes -key client.key -days ${VALID_DATE} -subj "/CN=${NGROK_DOMAIN}" -out client.crt
  elif [ "${SUB_COMMAND}" == "srv" ]; then
    openssl genrsa -out server.key 2048
    openssl req -new -key server.key -subj "/CN=${NGROK_DOMAIN}" -out server.csr
    openssl x509 -req -in server.csr -CA client.crt -CAkey client.key -CAcreateserial -days ${VALID_DATE} -out server.crt
  else
    help
    exit 1
  fi
elif [ "${COMMAND}" == "test" ]; then
  SUB_DOMAIN=${SUB_COMMAND}
  echo "127.0.0.1 ${NGROK_DOMAIN}" >> /etc/hosts
  echo "127.0.0.1 ${SUB_DOMAIN}.${NGROK_DOMAIN}" >> /etc/hosts
else
  help
  exit 1
fi


#./bin/ngrok --config mytest.yml --tls-cert-paths ./tls/test.ngrok.me/client.pem --log stdout start my