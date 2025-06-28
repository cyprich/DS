-- vypiste poberatelov, ktorym boli vyplatene prispevky vzdy v prvych troch dnoch tyzdna

select *
from P_POBERATEL pob
where not exists(
    select 1
    from P_PRISPEVKY pri
    where pob.ID_POBERATELA = pri.ID_POBERATELA
    and to_char(KEDY, 'D') > 3
)
and exists(
    select 1
    from P_PRISPEVKY pri
    where pob.ID_POBERATELA = pri.ID_POBERATELA
);

---------------------------------------------------------------------------
-- PLSQL CVIKO 7

create or replace procedure vyskladaj_skupinu (
    pracovisko char(1),
    odbor number(3, 0),
    zameranie number(1, 0),
    rocnik number(1, 0),
    kruzok char(1),
    st_skupina out char(6)
)
IS
BEGIN
    st_skupina := 5 || pracovisko || (select distinct sk_odbor from PRIKLAD_DB2.st_odbory where c_st_odboru = odbor) || zameranie || rocnik || kruzok;
end;
/

select vyskladaj_skupinu('z', 100, 0, 1, 3) from dual;

select * from PRIKLAD_DB2.st_odbory order by popis_odboru;

-- 4 - vytvorte proceduru vloz_predmet, ktora vykona insert operaciu noveho predmetu do tabulky PREDMET
-- zabezpecte aby boli vyplnene vsetky NOT NULL stlpce este pred pokusom o vlozenie
-- skompilujte proceduru a vlozte nasledovne predmety

create or replace procedure vloz_predmet (
    cis_predm char(4),
    nazov varchar(20)
)
is
begin

end;
/