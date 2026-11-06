<img src="assets/icon.svg" width="64" height="64" alt="">

# Molly — intégration Matter/Thread pour Moli OS

Ce dépôt rassemble le développement et les vérifications d'une contribution à
[Moli OS](https://github.com/rudy-io/moli-os). Le pilote est publié dans
[notre fork](https://github.com/Roddygithub/moli-os/tree/feat/matter-native)
et proposé dans la [PR officielle #144](https://github.com/rudy-io/moli-os/pull/144).
Les correctifs nécessaires
au contrôleur dans [notre fork Matter](https://github.com/Roddygithub/matter-rust/tree/moli-deadlines).
Le dépôt officiel n'est modifié que si ses mainteneurs acceptent une pull request.

État vérifié, mesures et étapes restantes : [STATUS.md](STATUS.md).
La proposition est discutée dans [Moli #142](https://github.com/rudy-io/moli-os/issues/142).

Le pilote natif couvre appairage sur IP, commandes OnOff, abonnements, capteurs
et endpoints derrière un pont. Il réutilise le coffre chiffré et la garde de Moli.
Un mode Bluetooth optionnel permet de transmettre à un appareil un dataset Thread
existant ; un routeur Thread reste nécessaire. Aucun service Python/Matter Server
n'est ajouté au chemin d'exécution.

Les tests de protocole utilisent une lampe virtuelle indépendante matter.js dans
un espace réseau isolé. Un essai réel sur pont Hue a validé OnOff via Moli/Matter,
avec observation indépendante et restauration de la lampe ; voir le rapport matériel
dans la contribution. Le support radio Thread/BLE reste à valider sur matériel.

[Cadrage](PROJECT-SPEC.md) · [Évaluation initiale](PROTOTYPE-RESULTS.md) ·
[Test d'interopérabilité](https://github.com/Roddygithub/moli-os/tree/feat/matter-native/tools/matter-e2e).

## Prototype initial

Les commandes suivantes concernent le petit prototype d'évaluation, pas le serveur Moli :

```sh
sh scripts/check-matter.sh       # fmt, clippy, 3 tests locaux + 36 tests de la pile
cargo run --locked --release    # création et relecture d'une fabric en mémoire
python scripts/measure-probe.py # mesure Linux du prototype vide, 30 secondes
```

Rust ≥1.89, Cargo, Git et Python 3 pour la mesure. Le premier contrôle télécharge
un checkout upstream épinglé dans `.cache/`. Il refuse un checkout modifié ou
d'une autre révision pour préserver la reproductibilité ; il ne le remet pas
à zéro automatiquement. Le réseau est nécessaire au téléchargement des sources.

Le prototype conserve les clés uniquement en mémoire et ne prend aucun code
d'appairage en entrée. Il ne découvre ni ne commande les appareils de la maison.
La restauration testée recrée le contrôleur dans le même processus : elle ne
valide pas une sauvegarde sur disque, une reprise après coupure ou un appareil réel.

`scripts/hue-pair.sh` est un outil d'appairage à l'API propriétaire Hue, distinct
de l'appairage Matter. Il n'est pas utilisé par le nouveau pilote.

## Récupérer la contribution

```sh
git clone --branch feat/matter-native https://github.com/Roddygithub/moli-os.git upstream
git -C upstream checkout 68d19e16f4f92867977311dd9a4f7396463e7782
```

Ce checkout est autonome : Cargo récupère la pile Matter à sa révision Git épinglée.
Le dossier frère `matter-stack` n'est nécessaire que pour travailler sur cette pile.
