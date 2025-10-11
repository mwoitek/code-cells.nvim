-- %%
CREATE TABLE Bands (
    band_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    formed_year INT
);

-- %%
INSERT INTO Bands (name, formed_year) VALUES
('Mayhem', 1984),
('Darkthrone', 1986),
('Behemoth', 1991);
