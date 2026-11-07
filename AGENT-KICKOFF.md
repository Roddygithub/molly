# Démarrage du développement

Lire `PROJECT-SPEC.md` pour les résultats de l'audit, les sources et les critères.
`PROTOTYPE-RESULTS.md` est une archive du premier jalon. Le pilote existe désormais
dans `upstream/crates/moli-matter` ; la pile corrigée est dans `matter-stack`.
Ne pas refaire l'audit ni le prototype : vérifier les derniers commits et résultats.
Lire `STATUS.md` en priorité : la PR #144 est publiée, avec ses limites et les
révisions exactes. Le code upstream est dans `upstream/`, clone Git indépendant ignoré par Moli-matter-thread.
Lire son `AGENTS.md`, puis les documents qu'il impose avant toute modification.

1. Actualiser upstream et recontrôler branches/PR/roadmap Matter : ne pas dupliquer
   un chantier apparu depuis l'audit du 5 novembre 2026.
2. Évaluer un prototype contrôleur IP minimal avec les candidats documentés,
   en commençant par vérifier les API, licences et contraintes de stockage.
   Ne pas ajouter un pilote vide au catalogue et ne pas annoncer Thread fonctionnel
   avec un simple test réseau IP.
3. Documenter le candidat retenu avec preuve de compilation, persistance sûre et
   mesures. Si une contrainte empêche le natif léger, expliquer le résultat avant
   d'introduire un service supplémentaire.
4. Implémenter le premier chemin complet OnOff en réutilisant `DriverCtx`, la garde,
   les échéances et les traductions FR/EN. Une intégration et un test significatif
   valent mieux qu'un ensemble d'abstractions pour des clusters futurs.
5. Ajouter OTBR/Thread et les capteurs seulement après validation du jalon IP.

L'utilisateur autorise l'achèvement autonome, la publication du projet sur son
GitHub et la proposition de contribution à Moli. N'inclure aucune donnée de sa
maison dans les dépôts, les rapports ou les messages publics.
Ne pas intervenir sur Proxmox ou sur des appareils physiques sans contexte
d'installation et cible de test autorisée. Aucun secret en clair dans les fichiers.

## Préférences de travail

L'utilisateur autorise les sous-agents et le choix de modèles GPT/niveaux de
reasoning et modèles gratuits pour économiser les tokens. Découvrir le catalogue
T3 vivant ; ne pas déduire la gratuité d'un nom de fournisseur. Préférer les tâches
ciblées, sans duplication, et le reasoning faible pour les contrôles simples.
Pour les modèles gratuits, l'utilisateur préfère les modèles `nvidia/...` du
provider OpenCode ; éviter `opencode/...-free`. Vérifier leurs options dans le
catalogue vivant et ne pas relancer un travail déjà en cours pour changer de modèle.
Appliquer Ponytail et utiliser RTK pour les sorties adaptées, en conservant les
erreurs complètes si nécessaire. Ne pas déléguer plus cher que le travail économisé.
