-- vsetky udaje o vsetkych studentoch

select *
from student;

-- menny zoznam vsetkych studentov 2. rocnika

select MENO, PRIEZVISKO, ROCNIK
from STUDENT
join OS_UDAJE using (rod_cislo)
where STUDENT.rocnik = 2;

-- menny zoznam studentov narodenych v rokoch 1985 - 1989

select MENO, PRIEZVISKO, substr(rod_cislo, 1, 2)
from STUDENT
join OS_UDAJE using (rod_cislo)
where substr(rod_cislo, 1, 2) between 85 and 89;

-- menny zoznam studentov ktori studuju na detasovanom pracovisku Prievidza (druhy znak studijnej skupiny je P)

select MENO, PRIEZVISKO, ST_SKUPINA
from STUDENT
join OS_UDAJE using (rod_cislo)
where substr(st_skupina, 2, 1) = 'P';

-- predchadzajuci vypis utriedte podla priezviska

select MENO, PRIEZVISKO, ST_SKUPINA
from STUDENT
join OS_UDAJE using (rod_cislo)
where substr(st_skupina, 2, 1) = 'P'
order by PRIEZVISKO;

-- menny zoznam studenov, ktori studuju predmet BI06 a usporiadajte ich

select distinct MENO, PRIEZVISKO
from STUDENT
join OS_UDAJE using (rod_cislo)
join ZAP_PREDMETY using (os_cislo)
where CIS_PREDM = 'BI06';

-- vsetky kombinacie prednasajuci/cis_predm, ktore sa nachadzaju v relacii zap_predmety tak, aby sa eliminovali duplikaty

select distinct PREDNASAJUCI, CIS_PREDM
from ZAP_PREDMETY;

-- k predchadzajucemu vypisu doplne meno ucitela a nazov predmetu

select distinct NAZOV, MENO || ' ' || PRIEZVISKO as ucitel, PREDNASAJUCI, CIS_PREDM
from ZAP_PREDMETY
join UCITEL on ZAP_PREDMETY.PREDNASAJUCI = UCITEL.OS_CISLO
join PREDMET using (cis_predm);

-- ucitelia, ktori ucia studentov druheho rocnika bakalarskeho studia (cislo studijneho odboru je z intervalu <100,199>)

select distinct MENO, PRIEZVISKO
from UCITEL u
join ZAP_PREDMETY z on (u.OS_CISLO = z.PREDNASAJUCI)
join STUDENT s on s.OS_CISLO = z.OS_CISLO
where s.st_odbor between 100 and 199;

-- nazvy predmetov studenta s priezviskom 'Balaz'

select NAZOV
from OS_UDAJE o
join STUDENT s using (rod_cislo)
join ZAP_PREDMETY z using (os_cislo)
join PREDMET using (cis_predm)
where o.PRIEZVISKO = 'Balaz';

-- pocet riadkov v tabulke zap_predmety

select count(*)
from ZAP_PREDMETY;

-- pocet studentov, ktori maju zapisany predmet 'Zaklady databazovych systemov'

select count(*)
from ZAP_PREDMETY z
join PREDMET p using (cis_predm)
where NAZOV = 'Zaklady databazovych systemov';

-- menny zoznam studentov spolu s datumom narodenia

select
    MENO, PRIEZVISKO,
    to_date(substr(rod_cislo, 5, 2) || '.' || decode(substr(rod_cislo, 3, 1), '5', '0', '6', '1', substr(rod_cislo, 3, 1)) || substr(rod_cislo, 4, 1) || '.19' || substr(rod_cislo, 1, 2), 'dd.MM.yyyy')
from STUDENT
join OS_UDAJE using (rod_cislo);

-- pocet kreditov studenta s osobnym cislom 500439 za absolvovane predmety

select sum(ECTS)
from ZAP_PREDMETY
where OS_CISLO = 500439
and VYSLEDOK is not null;

-- menny zoznam studentov druheho rocnika spolu s ich vekom

select
    MENO, PRIEZVISKO,
    trunc(months_between(sysdate , to_date(substr(rod_cislo, 5, 2) || '.' || decode(substr(rod_cislo, 3, 1), '5', '0', '6', '1', substr(rod_cislo, 3, 1)) || substr(rod_cislo, 4, 1) || '.19' || substr(rod_cislo, 1, 2), 'dd.MM.yyyy')) / 12)
from OS_UDAJE
join STUDENT using (rod_cislo)
where rocnik = 2;

-- zmente meno studenta Novy na Stary

update OS_UDAJE
set PRIEZVISKO = 'Stary'
where PRIEZVISKO = 'Novy';

select * from OS_UDAJE where PRIEZVISKO = 'Novy';
select * from OS_UDAJE where PRIEZVISKO = 'Stary';

-- zmente meno studenta, ktory ma osobne cislo 8 na Carlos

update OS_UDAJE o
set MENO = 'Carlos'
where exists(
    select 'x'
    from STUDENT s
    where s.OS_CISLO = 8
    and o.ROD_CISLO = s.ROD_CISLO
);

select *
from OS_UDAJE
join STUDENT using (rod_cislo)
-- where os_cislo = 8
;

-- zmente vsetkym prvakom cislo predmetu z BI11 na BI01

update ZAP_PREDMETY z
set CIS_PREDM = 'BI01'
where CIS_PREDM = 'BI11'
and exists(
    select 'x'
    from STUDENT s
    where s.ROCNIK = 1
    and s.OS_CISLO = z.OS_CISLO
);

select OS_CISLO, rocnik
from STUDENT
join ZAP_PREDMETY using (os_cislo)
where CIS_PREDM = 'BI01';

-- zmente vsetkym studentom, ktori nemaju nastaveny ziadny stav na stav S

update STUDENT
set stav = 'S'
where stav is null;

select * from STUDENT where stav is null;

-- zvyste studentom, ktori maju stav S a nie su v posledom rocniku rocnik o jedna
-- upravte aj studijnu skupinu, pricom pouzijete len jeden prikaz

update student
set
    ST_SKUPINA = substr(ST_SKUPINA, 1, 4) || rocnik + 1 || substr(ST_SKUPINA, 6, 1),
    rocnik = rocnik + 1
where stav = 'S'
  and (
    ((st_odbor between 100 and 199) and (rocnik < 3))
        or ((st_odbor between 200 and 299) and (rocnik < 2))
    )
;

select st_odbor, rocnik, st_skupina
from STUDENT
where stav = 'S'
and (
    ((st_odbor between 100 and 199) and (rocnik < 3))
    or ((st_odbor between 200 and 299) and (rocnik < 2))
    );

-- zmazte studentovi s osobnym cislom 123 predmet BE01

insert into ZAP_PREDMETY (OS_CISLO, CIS_PREDM, SKROK, PREDNASAJUCI, ECTS)
values (123, 'BE01', 2002, 'KME01', 6);

delete from ZAP_PREDMETY
where OS_CISLO = 123 and CIS_PREDM = 'BE01';

select *
from ZAP_PREDMETY
where OS_CISLO = 123
and CIS_PREDM = 'BE01';

-- zmazte vsetkym studentom st skupiny 5ZI022 predmet BI01

delete from ZAP_PREDMETY z
where CIS_PREDM = 'BI01'
and exists(
    select 'x'
    from STUDENT s
    where st_skupina = '5ZI022'
    and z.OS_CISLO = s.OS_CISLO
);

-- zmazte vsetky data vo vsetkych tabulkach (os_udaje, student, zap_predmety), ktore sa tykaju studentov zapisanych (dat_zapisu) v roku 1999

select *
from STUDENT
where to_char(dat_zapisu, 'yyyy') = 1999;

delete from ZAP_PREDMETY z
where exists(
    select 'x'
    from STUDENT s
    join ZAP_PREDMETY z on s.OS_CISLO = z.OS_CISLO
    where s.OS_CISLO = z.OS_CISLO
    and to_char(s.DAT_ZAPISU, 'yyyy') = 1999
);

delete from STUDENT
where to_char(dat_zapisu, 'yyyy') = 1999;

delete from OS_UDAJE o
where exists(
    select 'x'
    from STUDENT s
    where o.ROD_CISLO = s.ROD_CISLO
    and to_char(dat_zapisu, 'yyyy') = 1999
);

select *
from OS_UDAJE
where ROD_CISLO = '781015/4431';

rollback;

-- datum_od je minuly rok
select *
from P_ZAMESTNANEC
-- where to_char(DAT_OD, 'yyyy') = to_char(add_months(sysdate, -12), 'yyyy');
where extract(year from dat_od) = extract(year from DAT_OD) - 1;

-- datum_od je buduci rok
select *
from P_ZAMESTNANEC
where extract(year from dat_od) = extract(year from DAT_OD) + 1;

-- datum_od je minuly mesiac
select *
from P_ZAMESTNANEC
where extract(month from dat_od) = extract(month from DAT_OD) - 1;

-- datum_od je buduci mesiac
select *
from P_ZAMESTNANEC
where extract(month from dat_od) = extract(month from DAT_OD) + 1;

-- datum_od je o 2 tyzdne
select dat_od, trunc(dat_od)
from P_ZAMESTNANEC
where trunc(dat_od) = trunc(sysdate + 14);

-- datum_od a datum_do su v rovnakom mesiaci
select ROD_CISLO, DAT_OD, DAT_DO
from P_ZAMESTNANEC
where extract(month from DAT_OD) = extract(month from DAT_DO);

-- mezdi datum_od a datum_do neubehlo viac ako 3 roky (s presnostou na hodiny)
select ROD_CISLO, DAT_OD, DAT_DO
from P_ZAMESTNANEC
where months_between(DAT_OD, DAT_DO) < 12 * 3;

-- mezdi datum_od a datum_do neubehlo viac ako 12 hodin (s presnostou na hodiny)

select ROD_CISLO, DAT_OD, DAT_DO
from P_ZAMESTNANEC
where trunc(DAT_OD) = trunc(DAT_DO)
and extract(hour from DAT_OD) - extract(hour from DAT_DO) <= 12;

-- menny zoznam osob + id_poistenca, za ktore boli zaplatene odvody v minulom roku (potlacte duplicity)

select distinct MENO, PRIEZVISKO, ID_POISTENCA
from P_POISTENIE
join P_ODVOD_PLATBA using (id_poistenca)
join P_OSOBA using (rod_cislo)
where extract(year from DAT_PLATBY) = extract(year from add_months(sysdate, -12));

-- vyplatna listina prispevkov, ktore maju byt vyplatene tento mesiac
select *
from P_PRISPEVKY
where trunc(kedy, 'MM') = trunc(to_date('160301', 'yyMMdd'), 'MM');

-- pocet osob ktore su samoplatci (osoba je platitelom sama sebe)
select o.ROD_CISLO, p.ID_PLATITELA as platitel
from P_OSOBA o
join P_PLATITEL p on (rod_cislo = id_platitela)
where o.ROD_CISLO = p.ID_PLATITELA;

-- menny zoznam poberatelov prispevkov, kotrych percentualne vyjadrenie je >0.5. Pouzite exists

select MENO, PRIEZVISKO
from P_OSOBA o
where exists(
    select 'x'
    from P_POBERATEL p
    where p.PERC_VYJ > 0.5
    and o.ROD_CISLO = p.ROD_CISLO
);

-- vymazte osoby ktore skoncili pracovny pomer. predpokladajte ze uz nie su referencovane v inych tabulkach
delete from P_OSOBA o
where exists(
    select 'x'
    from P_ZAMESTNANEC z
    where DAT_DO < sysdate
    and DAT_DO is not null
    and o.ROD_CISLO = z.ROD_CISLO
);

-- vypiste poberatelov, ktori vzdy dostali viac ako 100 eur na prispevkoch (kazdy prispevok bol viac ako 100 eur)
select distinct ID_POBERATELA
from P_POBERATEL pob
where not exists(
    select 'x'
    from P_PRISPEVKY prisp
    where prisp.SUMA < 100
    and pob.ID_POBERATELA = prisp.ID_POBERATELA
);

-- zruste poberatelov (nastavte atribut dat_do), ktori patria do kategorie prispevkov so zakladnou vyskou 10 eur
update P_POBERATEL p
set DAT_DO = sysdate
where exists(
    select 'x'
    from P_TYP_PRISPEVKU t
    where t.ID_TYPU = p.ID_TYPU
    and t.ZAKL_VYSKA = 10
);

