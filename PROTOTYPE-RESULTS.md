# Résultats du prototype — 5 novembre 2026

> Archive de l'évaluation initiale. Le pilote Moli et les correctifs de la pile ont
> été développés ensuite ; les blocages ci-dessous décrivent ce premier prototype.
> Voir le README et les résultats du test d'interopérabilité pour l'état ultérieur.

## Ce qui est livré

Un exécutable Rust et une suite reproductible sans équipement :

- dépendance crates.io `matter-controller =0.18.3`, OTA et BLE désactivés,
  versions transitives conservées dans `Cargo.lock` ;
- création d'une fabric et refus du doublon ; recréation du contrôleur depuis
  le snapshot en mémoire avec identité publique inchangée, y compris le
  compressed fabric ID ;
- rejet d'un snapshot corrompu et erreur explicite si le stockage refuse l'écriture ;
- script de mesure borné (Linux, `/proc`), sans installation de service.

Contrôles locaux : formatage, clippy avec `-D warnings`, 3 tests réussis,
compilation release avec Cargo/Rust 1.97 sur Linux x86_64.

Le script `scripts/check-matter.sh` exécute aussi les tests du projet
[matter-rust](https://github.com/phunapps/matter-rust/tree/c59b61fdd7cf0b9cfcd3b1257cb87f336e59a48d),
révision épinglée `c59b61fdd7cf0b9cfcd3b1257cb87f336e59a48d` :

- 1 commissionnement de bout en bout avec appareil simulé (PASE, attestation et CASE) ;
- 26 tests filtrés `over_loopback` : lectures, commandes, écritures et abonnements ;
- 8 tests filtrés `response_deadline` ;
- 1 test de maintien d'abonnements concurrents lors d'un réabonnement.

Ces 36 tests sont ceux de la bibliothèque, pas une preuve d'intégration Moli.
La révision Git et le paquet publié sont deux ensembles de sources distincts :
les tests Git complètent les 3 tests contre le paquet publié sans les remplacer.
Ils utilisent des pairs simulés et des racines de test, pas les racines de
confiance de production. Leur réussite ne valide pas un appareil commercial.

## Mesures

Une fabric vide, aucun appareil ni abonnement, environ 28 secondes après les
2 premières secondes du processus :

- binaire release : 5 063 272 octets (~4,83 Mio), liens dynamiques inclus séparément ;
- pic RSS observé : 5 572 Kio (~5,44 Mio) ;
- pic mémoire anonyme du processus : 496 Kio ;
- CPU observé : 0,000 % d'un cœur à la résolution des ticks Linux.

Mesure indicative, ni budget garanti ni mesure de cgroup. Aucun coût OTBR,
BLE, catalogue de nœuds, reconnexion ou trafic réel inclus. Aucun résultat
musl/ARM ni mesure du binaire Moli complet.

## Décision provisoire

`matter-controller` est un candidat praticable pour un prototype contrôleur
avec API haut niveau et licence Apache-2.0. Pas encore retenu pour la production.
`rs-matter` 0.4.1 est aussi Apache-2.0 et annonce Rust 1.87 ; c'est une boîte à
outils plus bas niveau permettant contrôleurs et accessoires. Aucun prototype
équivalent n'a encore été compilé avec lui : pas de comparaison de performance
entre les deux bibliothèques.

Trois points doivent être résolus avant de brancher les commandes de Moli :

1. **Version Rust.** Le paquet contrôleur annonce Rust 1.89, Moli annonce 1.88.
   Les dépendances verrouillées ne déclarent pas de minimum supérieur à 1.89,
   mais le minimum n'a pas été testé avec cette toolchain. Ne pas changer le
   minimum de Moli silencieusement.
2. **Durabilité.** `ControllerStore` est synchrone, le coffre de Moli expose des
   écritures asynchrones. Définir un adaptateur sans deadlock, chiffré, atomique,
   borné et compatible avec les réservations de compteurs. Le test local montre
   qu'un échec de sauvegarde de fabric laisse une fabric en mémoire dans la pile :
   après cette erreur il faut abandonner l'instance, pas continuer avec cet état.
   Aucun adaptateur de production ni reprise après crash n'est validé.
3. **Échéance et annulation.** Moli attend au plus 5 secondes et transmet une
   échéance absolue. La pile a son propre délai de réponse (30 secondes par
   défaut) et peut reconnecter puis réémettre après expiration MRP. Dans
   `actor.rs`, `handle_action` et `resume_resend_pending` n'exigent pas un
   destinataire de réponse encore vivant avant l'envoi. Un simple
   `tokio::time::timeout` autour de `Node::invoke` ne prouve donc pas l'absence
   d'envoi tardif. Il faut un test de régression puis un contrat d'annulation
   et d'échéance couvrant file, établissement de session et retransmissions.
   Les tests de délai de réponse qui passent ne couvrent pas cette garantie.

Prochaine tranche : construire le test ciblé d'envoi après abandon, résoudre le
contrat avec la pile choisie, puis l'adaptateur au coffre. Ensuite seulement
ajouter le pilote OnOff à Moli, avec un trajet de commande complet sous la garde.

## Essais possibles sans achat

Le [guide officiel Hue](https://www.philips-hue.com/en-ca/explore-hue/works-with/matter)
indique que les produits connectés à un pont Hue peuvent être exposés via Matter.
Un pont compatible et à jour pourrait donc servir plus tard de cible Matter sur
IP avec l'équipement existant. Vérifier le modèle, le firmware et le parcours
d'appairage avant l'essai. Ce serait un test de pont et d'endpoints bridgés,
pas de Thread ; aucune action sur la maison n'a été effectuée.

Pour Thread, il restera à valider routage IPv6, découverte et commissionnement
avec OTBR/radio, puis un appareil Thread réel. La simulation ne remplace pas
les essais de portée radio, sommeil, autonomie ou interopérabilité IKEA.

## Économie de contexte

Ponytail appliqué ; RTK disponible et utilisé pour les sorties adaptées. Revue
ciblée déléguée à GPT-6 Luna, reasoning low, service par défaut. Le catalogue
T3 propose aussi OpenCode/NVIDIA, mais n'indique pas leurs tarifs : aucune
gratuité n'est supposée. Pas d'agent supplémentaire pour refaire les tests déjà
effectués.
