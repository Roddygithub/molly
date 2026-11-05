# Point de reprise — projet en pause

Pause demandée par l'utilisateur pour redémarrer sa session. Ne lancer aucune
nouvelle tâche ni aucun test physique avant sa demande de reprise.

## État sauvegardé

- Copie indépendante `upstream/` : branche `feat/matter-native`, commit
  `1342216` (pilote, coffre durable, annulation, capteurs, BLE optionnel, tests).
  Arbre propre. Ce commit est local ; il n'est pas encore une PR officielle.
- Copie indépendante `matter-stack/` : commit
  `429350c0171d62fbf911b7600231ba0480d4b875`, arbre propre. Publié dans
  [Roddygithub/matter-rust, moli-deadlines](https://github.com/Roddygithub/matter-rust/tree/moli-deadlines).
- [Proposition officielle Moli #142](https://github.com/rudy-io/moli-os/issues/142)
  ouverte. Aucune pull request Moli n'a encore été créée.
- Le dépôt public de suivi est [Roddygithub/molly](https://github.com/Roddygithub/molly).
  Les deux copies Git de travail sont exclues de ce dépôt ; elles restent sur disque.

## Vérifications effectuées avant la pause

Dans l'image `docker/dev.Dockerfile`, via Podman rootless (`localhost/molly-dev`) :
`sh scripts/check.sh` termine avec code 0 : format, clippy, **1 306 tests**, catalogue
et contrôle anti-fuite. Catalogue : 40 paquets, six avertissements sur des profils
préexistants. Rapport local : `.cache/moli-final-check.log`.

Le petit prototype du dépôt de suivi passe également ses trois tests.
La pile contrôleur a passé 422 tests lors du dernier correctif ; les derniers
correctifs ciblés ont été revérifiés par un agent sans nouvelle anomalie relevée.

Le parcours complet Moli/Matter a été exécuté précédemment avec une lampe virtuelle
matter.js dans un espace réseau isolé. Il faut le rejouer sur le binaire final après
les étapes de publication ci-dessous. Voir `upstream/tools/matter-e2e/RESULTS.md`.
Les essais par API propriétaire Hue ne prouvent pas le fonctionnement du pilote
Matter. Aucun essai matériel Thread/BLE n'est revendiqué.

## Reprise : poursuivre ici, sans refaire l'audit

1. Lire les `AGENTS.md`, puis vérifier les arbres des trois dépôts. Ne pas régénérer
   de clé maître ni afficher les secrets existants.
2. Dans `upstream/crates/moli-matter/Cargo.toml`, remplacer les deux dépendances
   `../../../matter-stack/...` par des dépendances Git épinglées sur le commit
   publié ci-dessus. Régénérer le verrou Cargo. C'est le dernier blocage connu
   pour compiler depuis une copie indépendante du fork Moli.
3. `origin/main` de Moli a avancé de `c04dd25` à `9ce5868`. Rebaser la branche sur
   ce dernier état, puis exécuter les contrôles requis sur le résultat final.
4. Vérifier à nouveau la compilation optionnelle BLE et rejouer le test
   `tools/matter-e2e/run.sh` avec le binaire final. Mesurer le binaire Moli complet
   et documenter le coût de la dépendance avant de parler de budget respecté.
5. Publier la branche Moli dans le fork, ouvrir une PR en brouillon liée à #142,
   et la rattacher au fil T3 avec `link_pull_request`. Mentionner explicitement
   le fork de dépendance, Rust 1.89 et les limites matérielles.
6. Pour un essai Matter réel, il manque l'appairage Matter : la clé API Hue déjà
   obtenue ne le remplace pas. Le code se saisit par l'utilisateur localement via
   `scripts/pair-matter.sh`, jamais dans le chat. La cible neutre autorisée reste
   dans le contexte privé de la conversation ; aucun identifiant domestique
   n'entre dans les rapports publics.

La délégation T3 a renvoyé `parent_not_active` dans cette reprise. Une petite
revue native avec GPT-6 Luna a terminé ; aucune tâche de cette reprise n'est
laissée en cours. Ne pas recréer les délégations déjà terminées.
