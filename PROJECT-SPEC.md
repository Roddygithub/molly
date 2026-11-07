# Matter/Thread pour Moli OS

## Audit upstream — 5 novembre 2026

Référence examinée : `rudy-io/moli-os`, branche `main`, commit
`c04dd2510ad6524d3568c9d8633a632f8bd90fb7`. Copie de travail locale : `upstream/`
(clone indépendant, exclu du dépôt Moli-matter-thread).

Constats :

- [ARCHITECTURE.md, décision D9](https://github.com/rudy-io/moli-os/blob/c04dd2510ad6524d3568c9d8633a632f8bd90fb7/docs/ARCHITECTURE.md) prévoit d'évaluer Matter avec `rs-matter` après le MVP. C'est une intention, pas une implémentation.
- Aucun pilote `matter`, dépendance Matter ou intégration correspondante dans le workspace Cargo, `KINDS` et le catalogue de `main`.
- Les 23 branches publiques retournées par l'API ne portent pas de nom Matter/Thread/OTBR. Leurs contenus n'ont pas tous été audités.
- Les collections publiques issues et PR ont été parcourues sur deux pages chacune, états ouverts et fermés (jusqu'au numéro 141). Aucun sujet dédié à un contrôleur Matter/Thread identifié dans leurs titres et descriptions.
- [PR #2](https://github.com/rudy-io/moli-os/pull/2) : pilote DIRIGERA existant ; les appareils Matter sont derrière le hub IKEA.
- [PR #103](https://github.com/rudy-io/moli-os/pull/103) : conversion d'éclairement Matter dans DIRIGERA, pas un nouveau transport.
- [PR #32](https://github.com/rudy-io/moli-os/pull/32) : l'auteur mentionne des essais de lampes Govee via un serveur Matter. La description et les commentaires généraux consultés ne fournissent pas de contrôleur natif. Cette piste mérite une question au mainteneur.

Conclusion : pas de développement natif en cours identifié dans ce périmètre public.
Cela n'exclut pas des travaux privés, des forks, des discussions ou des commentaires
non examinés. Aucun message, issue ou PR n'a été publié pendant cet audit.

## Objectif et périmètre

Ajouter un contrôleur Matter local à Moli, sans imposer Home Assistant ou DIRIGERA.
Conserver Hue via son pilote existant. Le chauffage fil pilote et Zigbee2MQTT restent
un chantier séparé : ils ne conditionnent pas le premier jalon Matter.

Matter est le protocole applicatif ; Thread est un réseau IPv6. Moli doit contrôler
les appareils sur IP ; un routeur de bordure assure l'accès au réseau Thread.
Réutiliser [OTBR](https://openthread.io/guides/border-router), sans réécrire Thread.

## Points d'intégration vérifiés

- `crates/moli-runtime/src/driver.rs` : trait `Driver`, `DriverCtx`, publication des appareils, états, disponibilité et commandes avec échéance.
- `crates/moli-os/src/main.rs` : `KINDS` et `build_driver` ; `check-config` construit les pilotes sans les lancer.
- `Cargo.toml` et `crates/moli-os/Cargo.toml` : dépendances du nouveau pilote une fois la bibliothèque validée.
- `integrations/matter/` : manifeste, onboarding, README, fixtures anonymisées.
- `locales/fr/pilotes.json` et `locales/en/pilotes.json` : messages visibles.
- Réutiliser le hub, la garde, le superviseur, le coffre et les sémantiques existants. Pas de voie de commande parallèle.

## Choix à valider par un prototype

Comparer `rs-matter` (candidat de D9) et
[`matter-controller`](https://docs.rs/matter-controller/0.18.3/matter_controller/)
0.18.3 (documentation consultée : fabric persistante, commissionnement IP,
attestation, read/write/invoke et abonnements annoncés). Une documentation de
fonctionnalités ne prouve pas l'interopérabilité ni la sécurité du projet.

Avant de retenir une dépendance : vérifier licence et provenance, entretien,
API contrôleur réellement disponible, compatibilité Rust 1.88/musl/ARM,
annulation des opérations, tailles bornées, reconnexion et appareils sur batterie.
Vérifier séparément les capacités BLE et Thread ; ne pas les déduire du seul support IP.

La persistance doit couvrir l'identité du contrôleur, les clés de fabric et les
compteurs exigés par la pile, avec écritures atomiques et reprise après crash.
Adapter le stockage au coffre Moli ; ne pas accepter par défaut un FileStore en clair.
Codes d'appairage et dataset Thread : entrées privées, jamais journaux, TOML,
fixtures, dépôt ou réponses MCP. Définir sauvegarde/restauration sans réutilisation
non sûre des compteurs. Ne pas désactiver l'attestation pour faire passer une démo.

## Jalons et critères de sortie

1. **Prototype IP isolé** : compilation, commissionnement d'une cible de test,
   lecture/commande/abonnement, redémarrage sans réappairage, secret non affiché.
   Mesurer RAM anonyme, RSS, CPU et taille du binaire. Pas de serveur de remplacement
   ou d'interface utilisateur à construire pour ce prototype.
2. **Pilote Moli minimal** : OnOff sur une prise ou lampe ; identité stable issue
   de fabric/nœud/endpoint, capacités issues des clusters exposés ; garde conservée.
   Tester délai dépassé, arrêt, reconnexion, hors ligne et absence de commande rejouée.
3. **Thread** : OTBR existant ou radio RCP dédiée, routage IPv6 et découverte
   fonctionnels à travers le réseau Proxmox ; commissionnement BLE puis accès IP.
   Aucun dongle ou firmware choisi sans vérification de compatibilité.
4. **Capteurs IKEA** : température/humidité, contact, mouvement et fuite, avec
   abonnements, valeurs nulles, reprise et sommeil. Chaque référence reste
   « non validée » jusqu'à un essai matériel documenté (modèle, firmware, date).

Tests sans matériel : réponses simulées/anonymisées, conversion des unités,
capacités, erreurs, persistance et échéances. Tests réels sur cible neutre,
humain présent, état initial rétabli.

Le budget upstream est ≤32 Mio de mémoire anonyme, ≤0,5 % CPU au repos et image
≤25 Mo ; le plafond conteneur 128 Mio n'est pas un budget de consommation.
Mesurer aussi OTBR et tout service auxiliaire séparément puis au total.
Ces valeurs sont des objectifs upstream, aucune mesure locale de la future pile
Matter n'a encore été réalisée.

## Contribution

Préparer une proposition avant une grosse modification, conformément à
`upstream/CONTRIBUTING.md`. Première question : existe-t-il un prototype natif ou
un serveur Matter réutilisable derrière les essais de #32 ? Puis proposer le
pilote minimal et son stockage, sans refonte du cœur.

Avant toute PR de code : `sh scripts/check.sh` dans l'image de développement ;
si interface modifiée, build web et contrôle i18n. Documenter les limites matérielles
et les mesures. Aucun test de compilation n'est revendiqué pour ce cadrage documentaire.
