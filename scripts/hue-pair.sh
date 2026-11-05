#!/bin/bash
# Appairage du pont Hue pour Moli OS — à lancer quand vous êtes prêt.
# Appuyez sur le bouton du pont pendant que ce script tourne ; il attend indéfiniment.
# La clé est stockée hors du dépôt (chmod 600). Ctrl+C pour arrêter.
set -u
BRIDGE="${1:?Usage: hue-pair.sh <ip-du-pont>   (trouvable dans l'appli Hue ou sur la box)}"
OUT="$HOME/.config/moli-dev"
mkdir -p "$OUT" && chmod 700 "$OUT"
KEY="$OUT/hue.key"

if [ -s "$KEY" ]; then
    echo "Une clé existe déjà ($KEY). Supprimez-la d'abord si vous voulez en refaire une : rm $KEY"
    exit 0
fi

echo "Pont : $BRIDGE — APPUYEZ MAINTENANT SUR LE BOUTON du pont (LED bleue clignote)..."
echo "Le script attend indéfiniment. Ctrl+C pour annuler."
i=0
while true; do
    RESP=$(curl -s --max-time 3 -X POST -H "Content-Type: application/json" \
        -d '{"devicetype":"moli-os#agent-test","generateclientkey":true}' "http://$BRIDGE/api")
    if echo "$RESP" | grep -q '"success"'; then
        echo "$RESP" | sed -n 's/.*"username":"\([a-zA-Z0-9-]*\)".*/\1/p' > "$KEY"
        chmod 600 "$KEY"
        echo "APPARIEMENT RÉUSSI — clé stockée dans $KEY (jamais affichée à l'écran)."
        exit 0
    fi
    i=$((i + 1))
    [ $((i % 10)) -eq 0 ] && echo "...toujours en attente ($i tentatives) — appuyez sur le bouton du pont"
    sleep 2
done
