-- 1 - vsetky udaje o vsetkych studentoch
select * from STUDENT;

-- 2 - menny zoznam vsetkych studentov v druhom rocniku
select MENO, PRIEZVISKO from OS_UDAJE o join STUDENT s using(rod_cislo) where s.rocnik=2;

-- 3 - menny zoznam studentov narodenych v rokoch 1985-1989
select MENO, PRIEZVISKO from OS_UDAJE join STUDENT using(rod_cislo)
where substr(ROD_CISLO, 1, 2) between 85 and 89;

-- 4 - menny zoznam studentov, ktori studuju na detasovanom pracovisku Prievidza (druhy znak stud. skup. = P)
select MENO, PRIEZVISKO from OS_UDAJE join STUDENT s using(rod_cislo)
where s.ST_SKUPINA like '_P%';

-- 5 - predchadzajuci vypis utriedte podla priezviska
select MENO, PRIEZVISKO from OS_UDAJE o join STUDENT s using(rod_cislo)
where s.ST_SKUPINA like '_P%'
order by o.PRIEZVISKO;

-- 6 - menny zoznam studentov, ktori studuju predmet BI06 a usporiadajte ich
select MENO, PRIEZVISKO from OS_UDAJE o
join STUDENT s using(rod_cislo)
join ZAP_PREDMETY z using(os_cislo)
where z.CIS_PREDM = 'BI06'
order by o.PRIEZVISKO;

-- 7 - vsetky kombinacie prednasajuci/cis_predm ktore sa nachadzaju v zap_predmety tak, aby sa eliminovali duplikaty
select distinct PREDNASAJUCI, CIS_PREDM from ZAP_PREDMETY;

-- 8 - k predchadzajucemu doplne meno ucitela a nazov predmetu
select distinct PREDNASAJUCI, CIS_PREDM, NAZOV, MENO, PRIEZVISKO from ZAP_PREDMETY z
join PREDMET p using(cis_predm)
join UCITEL u on(z.PREDNASAJUCI = u.OS_CISLO);

-- 9 - mena ucitelov ktori ucia studentov druheho rocnika bakalarskeho studia (st_odbor je z intervalu <100, 199>)
select distinct MENO, PRIEZVISKO from ZAP_PREDMETY z
join STUDENT s using(os_cislo)
join UCITEL u on(z.PREDNASAJUCI = u.OS_CISLO)
where s.ST_ODBOR between 100 and 199;

-- 10 - nazvy predmetov studenta s priezviskom Balaz
select NAZOV from ZAP_PREDMETY z
join STUDENT s using(os_cislo)
join OS_UDAJE o using(rod_cislo)
join PREDMET p using(cis_predm)
where o.PRIEZVISKO = 'Balaz';

-- 11 - pocet riadkov v tabulke zap_predmety
select count(*) from ZAP_PREDMETY;

-- 12 - pocet studentov, ktori maju zapisany predmet Zaklady databazovych systemov (BI06)
select count(*) from STUDENT s
join ZAP_PREDMETY z using (os_cislo)
where z.CIS_PREDM = 'BI06';

-- 13 - menny zoznam studentov s datumom narodenia
-- select
-- OS_UDAJE.MENO || ' ' || OS_UDAJE.PRIEZVISKO as cele_meno,
-- to_char(to_date(substr(ROD_CISLO, 0, 6), 'YYMMDD'), 'DD.MM.YYYY') as datum_narodenia  -- mesiac moze byt viac ako 50 :((
-- from STUDENT join OS_UDAJE using (rod_cislo);

select MENO, PRIEZVISKO,
substr(rod_cislo, 5, 2) || '.' || decode(substr(rod_cislo, 3, 2), 5, '0', 6, 1, substr(rod_cislo, 3, 2)) || '.19' || substr(rod_cislo, 1, 2)
from OS_UDAJE join STUDENT using (rod_cislo);

-- 14 - pocet kreditov studenta s osobnym cislom 500439 za absolvovane predmety
select * from STUDENT where os_cislo = 500439; -- ?

-- 15 - menny zoznam studentov druheho rocnika + ich vek
-- select MENO, PRIEZVISKO, to_char(sysdate - to_date(substr(rod_cislo, 1, 2), 'YY'))
select MENO, PRIEZVISKO, sysdate, to_date(('19' || substr(rod_cislo, 1, 2)), 'YY')
from OS_UDAJE o
join STUDENT s using(rod_cislo) where s.rocnik=2;
