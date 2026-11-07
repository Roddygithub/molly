# État de la contribution Matter — 7 novembre 2026

La contribution est proposée dans la [PR officielle Moli #144](https://github.com/rudy-io/moli-os/pull/144).
Le code se trouve dans la branche `feat/matter-native` du fork Moli ; les mainteneurs
peuvent l'intégrer directement. La pile corrigée est incluse dans `vendor/matter-rust`,
avec licence et provenance : aucune dépendance de build à un fork personnel ou à un
checkout voisin. Le dépôt présent sert au suivi et au prototype historique.

Fonctions proposées : OnOff, variation et couleur, stores de levage, thermostats
à consignes simples ou doubles, serrures soumises à approbation et capteurs.
L'activation dépend des capacités et politiques annoncées par chaque appareil.
Cela ne garantit pas toutes les fonctions de tous les produits Matter.

La dernière synchronisation intègre les changements officiels de sécurité API et
de dashboard jusqu'à `1288d93`. Les contrôles passent : **2 245 tests Rust**
(1 326 Moli et 919 ciblés de la pile), **191 tests frontend**, build web,
traductions FR/EN (3 623 clés), formatage, clippy, catalogue et anti-fuite.
Le minimum Rust 1.89 et l'audit des dépendances ont été contrôlés.

La suite indépendante matter.js valide les familles étendues sur des appareils
virtuels dans un réseau isolé : commandes, abonnements, approbation, refus sans
transmission, changement de politique PIN, reprise et refus d'états invalides.
Les résultats exacts des artefacts sont conservés dans la contribution.

L'essai physique historique a validé OnOff sur un pont Hue v2 avec observation
indépendante et restauration de l'état initial. Les autres familles physiques et
la radio Thread/BLE restent à valider sur du matériel adapté ; aucun nouvel essai
matériel n'est attendu de l'utilisateur.

Références maintenues dans la contribution :

- [Guide de revue](https://github.com/Roddygithub/moli-os/blob/feat/matter-native/integrations/matter/REVIEW.md)
- [Compatibilité par fonction](https://github.com/Roddygithub/moli-os/blob/feat/matter-native/integrations/matter/COMPATIBILITY.md)
- [Résultats et hash des images](https://github.com/Roddygithub/moli-os/blob/feat/matter-native/tools/matter-e2e/RESULTS.md)
- [Budgets et mesures](https://github.com/Roddygithub/moli-os/blob/feat/matter-native/docs/PERFORMANCE.md)

La contribution Matter est suivie dans la PR #144 officielle. Une fusion dans le
fork personnel (PR #1) ne signifie pas une intégration chez Moli.
Le coffre durable [#148](https://github.com/rudy-io/moli-os/pull/148) et la
compatibilité Clippy [#147](https://github.com/rudy-io/moli-os/pull/147) sont fusionnés
au dépôt officiel depuis le 6 novembre 2026. Matter #144 reste ouvert et non fusionné.

Les problèmes Hue ont été diagnostiqués : requête d'abonnement trop grande
(212 filtres réduits à 28), puis UFW bloquant le premier rapport périodique vers
le port UDP éphémère. Le port configurable et une règle hôte ciblée ont permis
190 secondes au repos, trois rapports périodiques, zéro coupure et zéro timeout.
L'essai OnOff réel a restauré l'état initial sans changer luminosité/couleur.
Le correctif indépendant SuppressResponse conserve les acquittements MRP.

Les artefacts du code `0445ca8`, reconstruits depuis un checkout propre, sont
identifiés dans RESULTS.md : image compacte **24 970 672 octets** (marge **29 328**
sous 25 000 000) ; standard **30 289 328 octets**, diagnostics identique au binaire
standard. Les preuves réelles et virtuelles restent liées à leurs binaires respectifs.
Le 7 novembre, les deux artefacts finaux standard et compact ont chacun passé la
suite virtuelle étendue complète, sans reconstruction : éclairage, stores,
thermostats, serrures sous approbation, politiques PIN, refus sans transmission,
reprise et refus des états invalides. Leurs SHA-256 correspondent à RESULTS.md.
Le test Hue de 190 secondes reste une preuve du binaire debug identifié dans
HARDWARE.md, pas un essai physique de ces releases.

## Décision en attente chez les mainteneurs

La CI de #144 n'est pas approuvée : elle exécute la pile vendoriée, dont le volume
et la charge de maintenance doivent être arbitrés par Rudy. Le mainteneur demande
de ne plus élargir les familles et de différer le rebase/conflit `mcp.rs` jusqu'à
cette décision. Aucun commit vide de déclenchement CI n'est utile.
Après la décision, le rebase retirera aussi les préalables #147/#148 déjà intégrés.
Les correctifs de bibliothèque peuvent être préparés indépendamment pour l'amont.

L'intégration de Matter n'est donc pas terminée dans Moli officiel. Les contrôles
locaux ne valent ni approbation de la CI distante, ni certification Matter.
