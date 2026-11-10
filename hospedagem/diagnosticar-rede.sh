#!/bin/bash
# Diz, a partir da maquina do GitHub, se o servidor e alcancavel e quais portas
# respondem. Nao entra no servidor nem usa a chave. Serve para separar "porta
# errada" de "firewall bloqueando o GitHub". Sempre termina sem erro.

SERVIDOR="${SERVIDOR:-}"
PORTA="${PORTA:-22}"

case "$SERVIDOR" in
  "") echo "O segredo DESPERTAR_SSH_HOST esta vazio."; exit 0 ;;
  *://*|*/*|*:*|*" "*) echo "ATENCAO: DESPERTAR_SSH_HOST tem http, barra, dois-pontos ou espaco. Deve ser so o nome do servidor." ;;
esac
case "$PORTA" in
  *[!0-9]*) echo "ATENCAO: DESPERTAR_SSH_PORT nao e so numero." ;;
esac

if getent hosts "$SERVIDOR" >/dev/null 2>&1; then
  echo "Nome do servidor resolve no DNS: sim"
else
  echo "Nome do servidor resolve no DNS: NAO (confira DESPERTAR_SSH_HOST)"
  exit 0
fi

responde() { timeout 6 bash -c "exec 3<>/dev/tcp/$SERVIDOR/$1" 2>/dev/null; }

if responde "$PORTA"; then
  saudacao=$(timeout 6 bash -c "exec 3<>/dev/tcp/$SERVIDOR/$PORTA; head -c 60 <&3" 2>/dev/null | tr -d '\r\n' | tr -cd '[:print:]')
  echo "Porta configurada: responde. Saudacao do servico: ${saudacao:-(nenhuma)}"
else
  echo "Porta configurada: NAO responde"
fi

for p in 22 2222 22022 1022 2022 21 2083 443; do
  if responde "$p"; then echo "porta $p: responde"; else echo "porta $p: nao responde"; fi
done
exit 0
