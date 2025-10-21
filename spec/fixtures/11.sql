




-- %%
CREATE TABLE Federation (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    species TEXT NOT NULL,
    rank TEXT NOT NULL
);

-- %%


CREATE TABLE Enemies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    species TEXT NOT NULL,
    ship TEXT NOT NULL
);



-- %%

INSERT INTO Federation (name, species, rank) VALUES
('James T. Kirk', 'Human', 'Captain'),
('Spock', 'Vulcan', 'Commander'),
('Uhura', 'Human', 'Lieutenant'),
('Jean-Luc Picard', 'Human', 'Captain'),
('Data', 'Android', 'Lieutenant Commander');
-- %%
INSERT INTO Enemies (name, species, ship) VALUES
('Khan Noonien Singh', 'Human', 'SS Botany Bay'),
('Q', 'Q Continuum', 'N/A'),
('Borg Queen', 'Borg', 'Borg Cube');


-- %%
-- %%

-- vim: readonly:
