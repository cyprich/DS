-- priklady na precvicenie - model soc. poistovna

-- 1 - menny zoznam zien
select distinct meno, priezvisko
from p_osoba
where substr(rod_cislo, 3, 1) >= 5;

-- 2 - menny zoznam osob, ktore mali narodeniny minuly mesiac
select distinct meno, priezvisko
from p_osoba
where mod(substr(ROD_CISLO, 3, 2), 50) = to_char(add_months(sysdate, -1), 'MM');

-- 3 - menny zoznam osob, ktore aktualne nemaju ztp preukaz (platnost vsetkych preukazov vyprsala)
-- povedzme ze v roku 2015, lebo udaje su stare
select distinct meno, PRIEZVISKO
from P_OSOBA
join P_ZTP using (rod_cislo)
where DAT_DO < to_date(15 || to_char(sysdate, 'MMdd'), 'yyMMdd');

-- 4 - zoznam osob ktore nikdy nemali ziaden ztp
select distinct meno, PRIEZVISKO
from P_OSOBA o
where not exists(
    select 'x' from P_ZTP z
    where o.ROD_CISLO = z.ROD_CISLO
);

-- 5 - zoznam osob, ktore oslavuju tento rok okruhle narodeniny
select distinct meno, PRIEZVISKO
from P_OSOBA
where substr(ROD_CISLO, 2, 1) = substr(to_char(sysdate, 'yy'), 2, 1);

-- 6 - zoznam zamestnancov, ktorych poistenie plati zamestnavatel Tesco
select *
from P_ZAMESTNANEC zc
join P_ZAMESTNAVATEL zl on (zc.ID_ZAMESTNAVATELA = zl.ICO)
where zl.NAZOV = 'Tesco';

-- 7 - zoznam osob, ktore nikdy nepoberali prispevok v nezamestnanosti
select distinct MENO, PRIEZVISKO
from P_OSOBA
join P_POBERATEL using (rod_cislo)
join P_TYP_PRISPEVKU using (id_typu)
where ID_TYPU <> 3;

-- 8 - zoznam osob, ktore poberaju nejaky prispevok, ktory nie je prispevkom v nezamestnanosti
-- (prispevok v nezamestnanosti moze aj nemusi poberat)

-- ???

-- 9 - vypiste pocet osob ktore pracuju v Tescu na dobu neurcitu. nazov nech je celkovy_pocet
select count(*) as celkovy_pocet
from P_ZAMESTNANEC
where DAT_DO is null;

-- 10 - vypiste celkovu sumu zaplatenu (dat_platby je vyplneny) spolocnostou Tesco za minuly rok zamestnancom so zmluvou na dobu neurcitu
-- povedzme ze 10 rokov dozadu lebo data su stare
select sum(suma)
from P_POISTENIE
join P_ODVOD_PLATBA using (id_poistenca)
-- join P_ZAMESTNANEC using (id_poistenca)
join P_PLATITEL using (id_platitela)
join P_ZAMESTNAVATEL z on (ID_PLATITELA = z.ICO)
where DAT_PLATBY is not null
-- and P_ZAMESTNANEC.DAT_DO is null
and z.NAZOV = 'Tesco'
and to_char(DAT_PLATBY, 'yy') = to_char(add_months(sysdate, -120), 'yy');

-- 12 - zamestnajte osobu Karol Matiasko na ZU (85794515) od buduceho mesiaca na dobu neurcitu (potrebne info si vymyslite)
commit;

select *
from P_ZAMESTNAVATEL
join P_MESTO using (psc)
where P_ZAMESTNAVATEL.NAZOV = 'ZU';  -- ico ZU 85794515, psc ziliny 01026

select *
from P_POISTENIE
order by ID_POISTENCA desc;  -- dalsie volne id 8561


insert into P_PLATITEL values ('111111/1111');
insert into P_OSOBA values ('111111/1111', 'Karol', 'Matiasko', '01026', 'Univerzitna 1');
insert into P_POISTENIE values ('8561', '111111/1111', '111111/1111', 'n', to_date('111111', 'yyMMdd'), null);
insert into P_ZAMESTNANEC values ('85794515', '111111/1111', add_months(sysdate, 1), null, 8561);

select *
from P_ZAMESTNANEC
join P_OSOBA using (rod_cislo)
where MENO = 'Karol'
and PRIEZVISKO = 'Matiasko';

rollback;


-- 13 - do tabulky p_prispevky vlozte udaje - vyplatnu listinu pre aktualnych poberatelov prispevkov
-- obdobie bude buduci mesiac, kedy bude 15. daneho mesiaca, sumu vypocitajte podla sazdby a perc. vyjadrenia prispevku

insert into P_PRISPEVKY
select
    ID_POBERATELA,
    add_months(sysdate, 1),
    1,
    add_months(to_date('15' || to_char(sysdate, 'MMyy'), 'ddMMyy'), 1),
    (PERC_VYJ/100) * zakl_vyska
from P_POBERATEL
join P_TYP_PRISPEVKU using (id_typu)
where DAT_OD > add_months(sysdate, -120);  -- aktualny pred 10 rokmi, lebo udaje su stare

select *
from P_PRISPEVKY
order by KEDY desc;

-- 14 - vlozte poistencovi s id 6268 platby za vsetky mesiace roku 1965
-- sumu si vymyslite, platbu vzdy zrealizujte v posledny den daneho mesiaca

--- ???

-- 15 - vsetkym, ktorych percentualna miera <20% pozastavte vyplacanie prispevkov ku koncu aktualneho roka
select *
from P_POBERATEL
where PERC_VYJ < 20;

--- ???

-- 16 - zvyste aktualnu sumu prispevkov v nezamestnanosti o 10%. nezabudnite aktualizovat tabulku p_historia
update P_TYP_PRISPEVKU
set ZAKL_VYSKA = ZAKL_VYSKA * 1.1;

insert into P_HISTORIA
(ID_TYPU, DAT_OD, DAT_DO, ZAKL_VYSKA)
SELECT
    ID_TYPU,
    (
        select DAT_OD
        from P_HISTORIA
        join P_TYP_PRISPEVKU using (id_typu)
        where ID_TYPU = ID_TYPU
        order by DAT_do desc
        fetch first 1 row only
    ),
    sysdate,
    ZAKL_VYSKA / 1.1
from P_TYP_PRISPEVKU;

select * from P_TYP_PRISPEVKU;

select * from P_HISTORIA order by DAT_DO desc ;

-- 17 - pozastavte poistenie (hodnota dat_do na null) vsetkym, ktori doteraz nezaplatili na odvodch nic a nie su oslobodeni
update P_POISTENIE p
set DAT_DO = null
where lower(OSLOBODENY) <> 'n'
and not exists(
    select 'x'
    from P_ODVOD_PLATBA op
    where op.ID_POISTENCA = p.ID_POISTENCA
    and SUMA = 0
);
-- neviem ci dobre :/

-- 18 - pozastavte poberanie prispevku v nezamestnanosti vsetkym osobam, ktore zaroven pracuju
-- update P_POBERATEL p
-- set DAT_DO = sysdate
-- where exists(
--           select 'x'
--           from P_ZAMESTNANEC
--           join P_POISTENIE using (rod_cislo)
--           where P_ZAMESTNANEC.ROD_CISLO = rod_cislo
--           join P_POBERATEL p using (rod_cislo)
--           join P_TYP_PRISPEVKU using (id_typu)
--           where POPIS = 'nezamest'
-- );

-- ???

-- 19 - vymazte informacie o poisteni, ktore skoncilo pred rokom 2000. pozor na referencnu integritu
select *
from P_POISTENIE
where to_char(DAT_DO, 'yyyy') < 2000;

delete from P_ODVOD_PLATBA op
where exists(
    select 'x'
    from P_POISTENIE p
    where to_char(DAT_DO, 'yyyy') < 2000
    and op.ID_POISTENCA = p.ID_POISTENCA
);

rollback ;










