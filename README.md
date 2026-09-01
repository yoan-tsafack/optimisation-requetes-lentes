# Optimisation de requêtes lentes — PostgreSQL

Ce projet explore comment diagnostiquer et corriger des requêtes lentes sur une base PostgreSQL, en s'appuyant sur `EXPLAIN ANALYZE` et la création d'index ciblés. Il s'appuie sur la même base de gestion des stocks et fournisseurs que le projet [gestion-stocks-pme](https://github.com/Yoan-Tsafack/gestion-stocks-pme), enrichie avec un volume de données réaliste.

## Contexte

Sur une petite table, une requête mal écrite reste rapide, ce qui ne permet pas de démontrer grand chose. J'ai donc généré environ 60 000 lignes de commandes et 90 000 lignes de commande pour simuler plusieurs années d'activité, puis mesuré l'impact réel des index sur des requêtes courantes.

## Méthodologie

Pour chaque cas testé : mesure du temps d'exécution sans index avec `EXPLAIN ANALYZE`, création d'un index ciblé, puis nouvelle mesure pour comparer.

## Cas 1 : recherche par produit (faible sélectivité)

Recherche des lignes de commande pour un produit donné, qui représente environ 12% de la table. Résultat : l'index a été utilisé (`Bitmap Index Scan`), mais le gain de performance est resté minime. Ce cas illustre une nuance importante : un index n'apporte pas toujours un bénéfice spectaculaire, tout dépend de la sélectivité de la condition.

## Cas 2 : recherche par commande (forte sélectivité)

Recherche des lignes d'une commande précise, qui ne représente que 2 lignes sur environ 90 000. Là, la différence est flagrante.

Sans index, PostgreSQL fait un `Seq Scan` : il lit les 90 000 lignes une par une pour n'en garder que 2, ce qui prend 4.412 ms. Une fois l'index créé, la requête passe à un `Index Scan` qui va chercher directement les bonnes lignes, sans rien lire d'inutile : 0.068 ms. Soit environ 65 fois plus rapide, sur une opération toute simple qu'une vraie application ferait des centaines de fois par jour (afficher le détail d'une commande).

Soit un gain d'environ 65 fois, sur une opération courante dans une vraie application (afficher le détail d'une commande).

## Conclusion

L'efficacité d'un index dépend fortement de la sélectivité de la condition de recherche. Plus une valeur est rare dans la table, plus l'index apporte un gain important. C'est une nuance essentielle à avoir en tête avant de créer un index à l'aveugle.

## Fichiers

`generation_donnees_et_index.sql` contient la génération des données de test, les requêtes `EXPLAIN ANALYZE` avant/après, et la création des deux index.

## Ce que ce projet démontre

- Lecture et interprétation d'un plan d'exécution PostgreSQL
- Diagnostic de lenteur via `Seq Scan` et `Rows Removed by Filter`
- Création d'index ciblés et mesure de leur impact réel
- Compréhension de la notion de sélectivité, plutôt qu'une application mécanique des index