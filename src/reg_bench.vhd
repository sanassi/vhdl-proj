-- Declaration Type Tableau Memoire
type table is array(15 downto 0) of std_logic_vector(31 downto 0);
-- Fonction d'Initialisation du Banc de Registres
function init_banc return table is
    variable result : table;
begin
    for i in 14 downto 0 loop
        result(i) := (others=>'0');
    end loop;
    result(15):=X"00000030";
    return result;
end init_banc;
-- Déclaration et Initialisation du Banc de Registres 16x32 bits
signal Banc: table:=init_banc;
