# État de la contribution — 5 novembre 2026

La contribution est publiée et proposée en **brouillon**, pas fusionnée ni déclarée
prête pour une installation stable :

- [PR officielle Moli #144](https://github.com/rudy-io/moli-os/pull/144), liée à
  [la proposition #142](https://github.com/rudy-io/moli-os/issues/142).
- Fork Moli, branche `feat/matter-native`, commit
  `f8ab3de978a221c36482eb492fd74b913c7d1cb2`, rebasé sur `9ce5868`.
- Pile Matter dans le fork `Roddygithub/matter-rust`, révision épinglée
  `429350c0171d62fbf911b7600231ba0480d4b875` (branche `moli-deadlines`).
- Les deux checkouts locaux sont indépendants du dépôt de suivi et exclus par
  `.gitignore`. Les sources publiées ci-dessus permettent de les recréer.

## Vérifications

`sh scripts/check.sh` dans l'image de développement musl, en ne montant que le
checkout Moli : **1 306 tests**, formatage, clippy, catalogue et anti-fuite passent.
Les six avertissements de catalogue concernent des profils préexistants.
Huit tests du pilote avec BLE activé passent également. Le build web de l'image
de production et le contrôle de traduction FR/EN passent.

L'image scratch du Dockerfile de production a été construite. Son binaire extrait
a passé le test indépendant matter.js : appairage avec attestation, découverte,
commandes REST, abonnements, reprise après redémarrage et refus d'états corrompus.
Les processus de test sont isolés du réseau physique. Résultats et hash dans
`upstream/tools/matter-e2e/RESULTS.md` et dans la branche publiée.

Image non compressée : **30 078 897 octets**, au-dessus de l'objectif de 25 Mo.
Avec une lampe virtuelle au repos sur 29,78 secondes : 17 156 Kio RSS et 3 484 Kio
de mémoire anonyme du processus ; CPU 0,000 % à la résolution des ticks. Ce ne sont
pas les mesures cgroup définies par le budget Moli. Aucun résultat matériel
Matter, Thread ou BLE n'est revendiqué.

## À traiter avant une version stable

1. Retour des mainteneurs sur le périmètre, le coffre durable, le fork de pile et
   le passage à Rust 1.89. Le minimum déclaré n'a pas été compilé séparément ;
   vérifications avec Rust 1.97 hôte et 1.99.1 musl.
2. Comparaison de taille au même build sans Matter, puis réduction/découpage ou
   arbitrage explicite du budget. Pas de référence HA ni de charge multi-appareils.
3. Appairage Matter réel distinct de l'API Hue. Les codes restent saisis localement
   par l'opérateur via `scripts/pair-matter.sh`, jamais dans un chat ou un dépôt.
4. Validation matérielle Thread/BLE, batterie et reprise après coupure. Le mode
   BLE transmet un dataset existant et ne remplace pas un routeur Thread.

Ne pas refaire les revues déjà clôturées : les précédents problèmes d'annulation,
de retransmissions MRP, de redécouverte et de cache au passage de lease ont été
corrigés et revérifiés. Pour les délégations gratuites, préférer les modèles
NVIDIA du provider OpenCode conformément au choix de l'utilisateur.
