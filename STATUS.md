# État de la contribution Matter — 6 novembre 2026

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
de dashboard jusqu'à `1288d93`. Les contrôles passent : **2 241 tests Rust**
(1 325 Moli et 916 ciblés de la pile), **191 tests frontend**, build web,
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
Le coffre durable est proposé séparément dans la [PR #148](https://github.com/rudy-io/moli-os/pull/148),
et la compatibilité Clippy dans la [PR #147](https://github.com/rudy-io/moli-os/pull/147).
La revue récente borne les verrous du coffre et préserve les appareils lors de la
redécouverte. Le timeout Hue ultérieur reste de cause inconnue ; les essais Hue
réussis sont historiques. Les tailles publiées sont liées aux artefacts identifiés,
sans nouvelle mesure de production après ces corrections.
L’intégration reste une décision des mainteneurs.
Les contrôles locaux ne valent pas approbation des workflows GitHub ni certification Matter.
