-- Génère 30 000 commandes réparties entre 2020 et 2026
INSERT INTO commandes (id_fournisseur, date_commande, statut)
SELECT
    (floor(random() * 4) + 1)::int,
    DATE '2020-01-01' + (random() * 2400)::int,
    (ARRAY['livree','en_attente','annulee'])[floor(random() * 3 + 1)]
FROM generate_series(1, 30000);

-- Génère 2 à 4 lignes de commande pour chacune des commandes créées
INSERT INTO lignes_commande (id_commande, id_produit, quantite, prix_unitaire)
SELECT
    c.id_commande,
    (floor(random() * 8) + 1)::int,
    (floor(random() * 20) + 1)::int,
    round((random() * 50000 + 500)::numeric, 2)
FROM commandes c
CROSS JOIN generate_series(1, (floor(random() * 3) + 2)::int)
WHERE c.id_commande > 4;  -- on garde tes 4 commandes d'origine intactes

SELECT COUNT(*) FROM commandes;
SELECT COUNT(*) FROM lignes_commande;

EXPLAIN ANALYZE
SELECT lc.*, p.nom_produit
FROM lignes_commande lc
JOIN produits p ON p.id_produit = lc.id_produit
WHERE lc.id_produit = 5;


CREATE INDEX idx_lignes_commande_id_produit ON lignes_commande(id_produit);

EXPLAIN ANALYZE
SELECT lc.*, p.nom_produit
FROM lignes_commande lc
JOIN produits p ON p.id_produit = lc.id_produit
WHERE lc.id_produit = 5;

EXPLAIN ANALYZE
SELECT * FROM lignes_commande WHERE id_commande = 15000;

CREATE INDEX idx_lignes_commande_id_commande ON lignes_commande(id_commande);

EXPLAIN ANALYZE
SELECT * FROM lignes_commande WHERE id_commande = 15000;