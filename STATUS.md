# État de la contribution — 6 novembre 2026

La contribution est publiée et proposée en **brouillon**, pas fusionnée ni déclarée
prête pour une installation stable :

- [PR officielle Moli #144](https://github.com/rudy-io/moli-os/pull/144), liée à
  [la proposition #142](https://github.com/rudy-io/moli-os/issues/142).
- Fork Moli, branche `feat/matter-native`, commit
  `f6d2e0b7ee909a94ffdce2b87d8399def42b3cde`, rebasé sur `9ce5868`.
- Pile Matter dans le fork `Roddygithub/matter-rust`, révision épinglée
  `d80b1a3fd2204119ddf47406f4bb59916ba7576b` (branche `moli-deadlines`).
- Les deux checkouts locaux sont indépendants du dépôt de suivi et exclus par
  `.gitignore`. Les sources publiées ci-dessus permettent de les recréer.

## Vérifications

`sh scripts/check.sh` dans l'image de développement musl, en ne montant que le
checkout Moli : **1 308 tests**, formatage, clippy, catalogue et anti-fuite passent.
Les six avertissements de catalogue concernent des profils préexistants.
Dix tests du pilote avec BLE activé passent également (compilation/tests, sans radio). Le build web de l'image
de production et le contrôle de traduction FR/EN passent.

L'image scratch du Dockerfile de production a été construite. Son binaire extrait
a passé le test indépendant matter.js : appairage avec attestation, découverte,
commandes REST, abonnements, reprise après redémarrage et refus d'états corrompus.
Les processus de test sont isolés du réseau physique. Résultats et hash dans
`upstream/tools/matter-e2e/RESULTS.md` et dans la branche publiée.

Image standard initiale non compressée : **30 113 713 octets**, au-dessus de l'objectif de 25 Mo.
Référence sans Matter construite au commit de base : **27 737 521 octets** ;
delta de la contribution **+2 376 192 octets (+8,57 %)**. Le budget était donc
déjà dépassé sans Matter et reste à traiter. Image finale construite au commit
`d6add50`, avec correctif d’attestation et noms bridgés.
Avec une lampe virtuelle au repos sur 29,78 secondes : 17 324 Kio RSS et 3 460 Kio
de mémoire anonyme du processus ; CPU 0,000 % à la résolution des ticks. Ce ne sont
pas les mesures cgroup définies par le budget Moli.

Un essai Matter IP réel a réussi sur un pont Hue v2 et une lampe neutre autorisée :
attestation, découverte bridgée/NodeLabel, commande OnOff via Moli REST/Matter,
abonnement, observation indépendante en lecture seule via Hue, restauration de l'état
initial sans changement de luminosité/couleur, et reprise des identités après redémarrage.
Rapport anonymisé : `upstream/integrations/matter/HARDWARE.md`. Le correctif d'attestation
commonName a passé 622 tests et une revue indépendante. Thread/BLE restent non validés.

## Suite : image compacte et minimum Rust vérifié

Une option explicite `MOLI_STRIP_SYMBOLS=true` produit une image de **24 827 312 octets**,
sous 25 Mo, sans retirer de pilote. Elle retire les noms de symboles des backtraces
locales ; le build standard les conserve par défaut. Le target `diagnostics` exporte
le binaire correspondant avec symboles, absent de l'image compacte. Les sections de
code/données et d'unwind sont identiques entre variantes. Le guide d'exploitation
et les résultats d'interopérabilité documentent ce compromis.

Le contrôle de l'application complète sous Rust 1.89.0 passe, après remplacement
de deux syntaxes préexistantes trop récentes, sans changement de comportement.
La revue des adaptations confirme que le contrôle de pièce reste avant les commandes.

## À traiter avant une version stable

1. Retour des mainteneurs sur le périmètre, le coffre durable, le fork de pile et
   le passage à Rust 1.89. `cargo check --locked -p moli-os` passe maintenant sur
   Rust 1.89.0 (application complète, fonctionnalités par défaut). Deux syntaxes
   préexistantes trop récentes ont été remplacées sans changement fonctionnel.
2. Option compacte sous 25 Mo validée et documentée ; choix du profil par défaut
   à arbitrer avec les mainteneurs (symboles de diagnostic conservés par défaut).
   Pas de référence HA ni de charge multi-appareils.
3. Étendre la validation Matter IP au-delà d'un pont et d'une lampe. Les codes restent
   saisis localement par l'opérateur via `scripts/pair-matter.sh`, jamais dans un chat ou un dépôt.
4. Validation matérielle Thread/BLE, batterie et reprise après coupure. Le mode
   BLE transmet un dataset existant et ne remplace pas un routeur Thread.

Ne pas refaire les revues déjà clôturées : les précédents problèmes d'annulation,
de retransmissions MRP, de redécouverte et de cache au passage de lease ont été
corrigés et revérifiés. Pour les délégations gratuites, préférer les modèles
NVIDIA du provider OpenCode conformément au choix de l'utilisateur.
