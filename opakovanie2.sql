---------- VIEW --------------------------------------------------------------------------------------------------------

-- 1 - vytvorte pohlad, ktory bude obsahovat osoby, a ich prisluchajuce poistenie (aj ak ziadne nemaju)

create or replace view poistene_osoby as
select *
from P_OSOBA
left join P_POISTENIE using (rod_cislo)
;

select * from poistene_osoby;

-- 2 - vytvorte pohlad, ktory bude obsahovat mesta a pocet osob s trvalym pobytom

create or replace view mesta_s_poctom_osob as
select N_MESTA, count(ROD_CISLO) as pocet_osob
from P_MESTO
join P_OSOBA using (psc)
group by N_MESTA
order by count(ROD_CISLO) desc
;

select * from mesta_s_poctom_osob;

-- 3 - vytvorte pohlad, ktory bude obsahovat zamestnancov a ich zamestnavatelov s datumom zaciatku pracovneho pomeru

create or replace view zamestnanci_pracovny_pomer as
select meno || ' ' || priezvisko zamestnanec, ROD_CISLO, DAT_OD zaciatok_pracovneho_pomeru, NAZOV zamestnavatel
from P_ZAMESTNANEC
join P_ZAMESTNAVATEL on P_ZAMESTNANEC.ID_ZAMESTNAVATELA = P_ZAMESTNAVATEL.ICO
join P_OSOBA using (rod_cislo);

select * from zamestnanci_pracovny_pomer;

-- 4 - vytvorte pohlad ktory bude obsahovat poistencov spolu s pocom ich odvodovych platieb

create view pocet_odvodovych_platieb as
select ROD_CISLO poistenec, count(suma) pocet_odvodovych_platieb
from P_POBERATEL
join P_POISTENIE using (rod_cislo)
join P_ODVOD_PLATBA using (id_poistenca)
group by ROD_CISLO
;

select * from pocet_odvodovych_platieb;

-- 5 - vytvorte pohlad ktory bude obsahovat osoby a ich typ postihnutia (ak existuje)

create or replace view typ_postihnutia_osoby as
select distinct meno, PRIEZVISKO, ROD_CISLO, NAZOV_POSTIHNUTIA
from P_OSOBA
join P_ZTP using (rod_cislo)
join P_TYP_POSTIHNUTIA using (id_postihnutia)
;

select * from typ_postihnutia_osoby;

-- 6 - vytvore pohlad, ktory bude obsahovat zamestnavatelov a pocet ich aktivnych zamestnancov

create or replace view aktivni_zamestnanci as
select nazov, count(ROD_CISLO) aktivni_zamestnanci
from P_ZAMESTNAVATEL zl
join P_ZAMESTNANEC zc on zl.ICO = zc.ID_ZAMESTNAVATELA
where
    (sysdate between zc.DAT_OD and zc.DAT_DO)
    or
    (sysdate > zc.DAT_OD and DAT_DO is null)
group by nazov
;

select * from aktivni_zamestnanci;

-- 7 - vytvorte pohlad, ktory bude obsahovat osoby, ktore su zaroven aj poitencami aj zamestnancami

create or replace view poistenci_zamestnanci as
select meno, PRIEZVISKO, ID_POISTENCA, ID_ZAMESTNAVATELA
from P_OSOBA
join P_ZAMESTNANEC using (rod_cislo)
where ID_POISTENCA is not null
;

select * from poistenci_zamestnanci;

-- 8 - vytvore pohlad, ktory bude obsahovat typy prispevkov a pocet osob, ktore ich poberaju

create or replace view pocet_osob_pre_prispevky as
select POPIS typ_prispevku, count(rod_cislo) pocet_osob
from P_TYP_PRISPEVKU
join P_POBERATEL using (id_typu)
group by POPIS
;

select * from pocet_osob_pre_prispevky;

-- 9 - vytvore pohlad, ktory bude obsahovat poistencov a datum ich poslednej platby

create or replace view posledna_platba_poistenca as
select ROD_CISLO, max(DAT_PLATBY) as posledna_platba
from P_POBERATEL
join P_POISTENIE using (rod_cislo)
join P_ODVOD_PLATBA using (id_poistenca)
group by ROD_CISLO
;

select * from posledna_platba_poistenca;

-- 10 - vytvorte pohlad, ktory bude obsahovat osoby a ich prispevky vratane nazvu typu prispevku

create or replace view nazov_typu_prispevku as
select meno, PRIEZVISKO, ROD_CISLO, popis nazov_typu_prispevku
from P_OSOBA
join P_POBERATEL using (rod_cislo)
join P_TYP_PRISPEVKU using (id_typu)
; -- not sure

select * from nazov_typu_prispevku;

---------- SELECT ------------------------------------------------------------------------------------------------------

-- 11 - pocet poistencov pre kazdeho platitela

select ID_PLATITELA, count(ID_POBERATELA) pocet_poistencov
from P_PLATITEL pl
join P_POISTENIE po using (id_platitela)
join P_POBERATEL pb on po.ID_POISTENCA = pb.ID_POBERATELA
group by ID_PLATITELA
order by count(ID_POBERATELA) desc
;

-- 12 - pocet osob podla mesta

select N_MESTA, count(ROD_CISLO)
from P_MESTO
join P_OSOBA using (psc)
group by N_MESTA
; -- toto uz bolo vo views?

-- 13 - pocet zaznamov v p_prispevky podla typu

select POPIS typ_prispevku, count(kedy) pocet_zaznamov
from P_PRISPEVKY
join P_TYP_PRISPEVKU using (id_typu)
group by POPIS
;

-- 14 - priemerna vyska prispevku podla typu

select popis nazov_prispevku, round(avg(suma), 2) priemerna_vyska
from P_PRISPEVKY
join P_TYP_PRISPEVKU using (id_typu)
group by popis
;

-- 15 - pocet roznych zamestnavatelov pre kazde psc

select N_MESTA, psc, count(ico) pocet_zamestnavatelov
from P_ZAMESTNAVATEL
join P_MESTO using (psc)
group by N_MESTA, psc
;

-- 16 - osoby, ktore su zaroven poistencami (exists)

select *
from P_OSOBA o
where exists(
    select 1
    from P_POBERATEL p
    where p.ROD_CISLO = o.ROD_CISLO
);

-- 17 - poistenci s aspon dvoma zaznamami v p_odvod_platba (exists)

select *
from P_POBERATEL pb
join P_POISTENIE po using (rod_cislo)
where exists (
    select 1
    from P_ODVOD_PLATBA op
    where op.ID_POISTENCA = po.ID_POISTENCA
    having count(*) >= 2
);

-- 18 - typy prispevkov pouzite aspon 3-krat (in)

select *
from P_TYP_PRISPEVKU p
where ID_TYPU in (
    select ID_TYPU
    from P_PRISPEVKY
    group by ID_TYPU
    having count(*) >= 3
);

-- 19 - osoby, ktore nie su poistencami (not exists)

select *
from P_OSOBA o
where not exists(
    select 1
    from P_POBERATEL p
    where p.ROD_CISLO = o.ROD_CISLO
);

-- 20 - osoby s najvyssim poctom odvodov (group by + order by + limit v poddotaze alebo min a max)

select meno, PRIEZVISKO, ID_POISTENCA
from P_OSOBA o
join P_POISTENIE p using (rod_cislo)
where exists(
    select op.ID_POISTENCA
    from P_ODVOD_PLATBA op
    where p.ID_POISTENCA = op.ID_POISTENCA
    group by op.ID_POISTENCA
    order by count(SUMA) desc
    fetch first 10 rows only
); -- toto nie je dobre

---------- FUNKCIE -----------------------------------------------------------------------------------------------------

-- 21 - pocet prispevkov pre poberatela

create or replace function pocet_prispevkov_pre_poberatela (p_id_poberatela P_POBERATEL.id_poberatela%type)
return integer
is
    pocet integer;
begin
    select count(*)
    into pocet
    from P_POBERATEL p
    where p_id_poberatela = p.ID_POBERATELA;

    return pocet;
end;
/

select * from P_POBERATEL;

select pocet_prispevkov_pre_poberatela(300) from dual;

-- 22 - celkova suma platieb pre poistenca

create or replace function celkova_suma_platieb_pre_poistenca(p_id_poistenca P_POBERATEL.id_poberatela%type)
return integer
is
    pocet integer;
begin
    select sum(suma)
    into pocet
    from P_POBERATEL
    join P_PRISPEVKY using (id_poberatela)
    where p_id_poistenca = ID_POBERATELA
    ;

    return pocet;
end;
/

select * from P_POBERATEL order by ID_POBERATELA desc;

select celkova_suma_platieb_pre_poistenca(6793) from dual;

-- 23 - zisti, ci ma osoba aspon 1 prispevok

create or replace function ma_osoba_prispevok(p_rod_cislo P_OSOBA.rod_cislo%type)
return varchar2
is
    pocet integer;
begin
    select count(*)
    into pocet
    from P_OSOBA os
    join P_POBERATEL pob using (rod_cislo)
    join P_PRISPEVKY pris using (id_poberatela)
    where ROD_CISLO = p_rod_cislo
    ;

    if (pocet > 1) then
        return 'true';
    else
        return 'false';
    end if;
end;
/

select *
from P_OSOBA
join P_POBERATEL using (rod_cislo)
join P_PRISPEVKY using (id_poberatela);

select ma_osoba_prispevok('840120/8420') from dual;

-- 24 - zisti, ci osoba zije v nitrianskom kraji

create or replace function zije_v_nitrianskom_kraji(p_rod_cislo P_OSOBA.rod_cislo%type)
return varchar2
is
    v_kraj varchar2(30) := '';
begin
    select N_KRAJA
    into v_kraj
    from P_KRAJ
    join P_OKRES using (id_kraja)
    join P_MESTO using (id_okresu)
    join P_OSOBA o using (psc)
    where o.ROD_CISLO = p_rod_cislo
    ;

    if (v_kraj = 'Nitriansky') then
        return 'true';
    else
        return 'false';
    end if;
end;
/

select zije_v_nitrianskom_kraji('750610/8467') from dual;

-- 25 - vrati pocet roznych rokov, v ktorych osoba poberala prispevok

create or replace function pocet_rokov_prispevkov_osoby(p_rod_cislo P_OSOBA.rod_cislo%type)
return varchar2
is
    pocet integer := 0;
begin
    select count(to_char(OBDOBIE, 'yy'))
    into pocet
    from P_OSOBA
    join P_POBERATEL using (rod_cislo)
    join P_PRISPEVKY using (id_poberatela)
    where ROD_CISLO = p_rod_cislo
    ;

    return pocet;
end;
/

select * from P_OSOBA;

select pocet_rokov_prispevkov_osoby('731207/9049') from dual;

-- 26 priemerna vyska prispevku podla typu pre daneho poberatela

create or replace function priemerna_vyska_prispevku_pre_poberatela(p_id_poberatela P_POBERATEL.ID_POBERATELA%type)
return number
is
    priemer number := 0;
begin
    select avg(suma)
    into priemer
    from P_PRISPEVKY
    join P_POBERATEL using (id_poberatela)
    where ID_POBERATELA = p_id_poberatela;

    return priemer;
end;
/

select * from P_POBERATEL order by ID_POBERATELA desc;

select priemerna_vyska_prispevku_pre_poberatela(12212) from dual;

-- 27 - pocet zamestnavatelov pre dane rodne cislo

create or replace function pocet_zamestnavatelov_pre_rod_cislo(p_rod_cislo P_ZAMESTNANEC.ROD_CISLO%type)
return integer
is
    pocet integer := 0;
begin
    select count(distinct ID_ZAMESTNAVATELA)
    into pocet
    from P_ZAMESTNANEC
    where ROD_CISLO = p_rod_cislo;

    return pocet;
end;
/

select ROD_CISLO from P_ZAMESTNANEC;
select distinct ROD_CISLO from P_ZAMESTNANEC;

select pocet_zamestnavatelov_pre_rod_cislo('790810/2895') from dual;

-- 28 - vrati true, ak ma osoba aktivne poistenie

create or replace function ma_osoba_aktivne_poistenie(p_rod_cislo P_OSOBA.ROD_CISLO%type)
return varchar2
is
    v_dat_od P_POISTENIE.DAT_OD%type;
    v_dat_do P_POISTENIE.DAT_DO%type;
begin
    select max(DAT_OD), max(DAT_DO)
    into v_dat_od, v_dat_do
    from P_POISTENIE
    where ROD_CISLO = p_rod_cislo
    ;

    if v_dat_do is null then
        v_dat_do := nvl(v_dat_do, sysdate + 1);
    end if;

    if sysdate > v_dat_od and sysdate < v_dat_do then
        return 'true';
    else
        return 'false';
    end if;
end;  -- tu nieco nie je dobre
/

select * from P_OSOBA;
select * from P_POISTENIE;

select ma_osoba_aktivne_poistenie('731207/9049') from dual;
select ma_osoba_aktivne_poistenie('815903/7755') from dual;

-- 29 - pocet zamestnani, ktore osoba absolvovala

select count(ROD_CISLO), count(distinct ROD_CISLO) from P_ZAMESTNANEC;

create or replace function pocet_zamestnani_osoby(p_rod_cislo P_ZAMESTNANEC.ROD_CISLO%type)
return integer
is
    pocet integer;
begin
    select count(ROD_CISLO)
    into pocet
    from P_ZAMESTNANEC
    where ROD_CISLO = p_rod_cislo
    ;

    return pocet;
end;
/

select * from P_OSOBA;
select * from P_ZAMESTNANEC;

select pocet_zamestnani_osoby('731207/9049') from dual;
select pocet_zamestnani_osoby('900711/0497') from dual;

-- 30 - celkova vyska zakladnej sumy pre vsetky typy prispevkov, ktore osoba dostala

create or replace function celkove_prispevky_osoby(p_rod_cislo P_OSOBA.ROD_CISLO%type)
return number
is
    pocet number;
begin
    select sum(ZAKL_VYSKA)
    into pocet
    from P_OSOBA
    join P_POBERATEL using (rod_cislo)
    join p_typ_prispevku using (id_typu)
    where ROD_CISLO = p_rod_cislo
    ;
    return pocet;
end;
/

select * from P_POBERATEL;

select celkove_prispevky_osoby('870325/8388') from dual;

---------- PROCEDURY - KURZORY -----------------------------------------------------------------------------------------

set serveroutput on;

-- 31 - vypis informacie o osobe podla rodneho cisla

create or replace procedure vypis_info_o_osobe(p_rod_cislo P_OSOBA.ROD_CISLO%type)
    as
        v_pocet integer;
        v_meno P_OSOBA.MENO%type;
        v_priezvisko P_OSOBA.PRIEZVISKO%type;
        v_psc P_OSOBA.PSC%type;
        v_ulica P_OSOBA.ULICA%type;
        v_mesto P_MESTO.N_MESTA%type;
    begin
        select count(*)
        into v_pocet
        from P_OSOBA
        where ROD_CISLO = p_rod_cislo;

        if v_pocet <= 0 then
            raise_application_error(-20001, 'Osoba s tymto rodnym cislom neexistuje');
        end if;

        select meno, PRIEZVISKO, psc, ulica
        into v_meno, v_priezvisko, v_psc, v_ulica
        from P_OSOBA
        where ROD_CISLO = p_rod_cislo;

        select N_MESTA
        into v_mesto
        from P_MESTO
        where PSC = v_psc;

        DBMS_OUTPUT.PUT_LINE('Osoba: ' || v_meno || ' ' || v_priezvisko || '; rodne cislo ' || p_rod_cislo || '; bydlisko ' || v_mesto || ' ' || v_ulica);
    end;
/

select * from p_osoba;

exec vypis_info_o_osobe('010101/1234');
exec vypis_info_o_osobe('731207/9049');

-- 32 - vypis historiu typu prispevku podla ID typu

create or replace procedure historia_typu_prispevku(p_id_typu P_TYP_PRISPEVKU.ID_TYPU%type)
    as
        cursor historia_curs(pp_id_typu P_TYP_PRISPEVKU.ID_TYPU%type) is
            select *
            from P_HISTORIA
            where ID_TYPU = pp_id_typu;
    begin
        DBMS_OUTPUT.PUT_LINE('Historia typu prispevku s id ' || p_id_typu || ':');

        for i in historia_curs(p_id_typu) loop
            DBMS_OUTPUT.PUT_LINE('    ' || historia_curs%rowcount || '. od ' || i.DAT_OD || ',  do ' ||
            i.DAT_DO || ',  zakladna vyska ' || i.ZAKL_VYSKA);
        end loop;
    end;
/

select *
from P_TYP_PRISPEVKU
join p_historia using (id_typu)
;

exec historia_typu_prispevku(1);

-- 33 - vypis pocet osob a poistencov v zadanom psc

create or replace procedure poces_podla_psc(p_psc P_MESTO.PSC%type)
    as
        v_osoby integer := 0;
        v_poistenci integer := 0;
    begin
        select count(*)
        into v_osoby
        from P_OSOBA
        where PSC = p_psc;

        select count(*)
        into v_osoby
        from P_OSOBA
        join P_POBERATEL using(rod_cislo)
        where PSC = p_psc;

        DBMS_OUTPUT.PUT_LINE('V meste s PSC ' || p_psc || ' je ' || v_osoby || ' osob a ' || v_poistenci || ' poistencov');
    end;
/

select * from p_mesto;

exec poces_podla_psc('97101');
exec poces_podla_psc('04000');

-- 34 - vypis mena zamestnancov pre kazdeho zamestnavatela vratane info o poisteni

create or replace procedure uloha34
as
    cursor cur_zamestnavatel is (
        select *
        from P_ZAMESTNAVATEL
    );

    cursor cur_zamestnanec(c_id_zamestnavatela P_ZAMESTNANEC.ID_ZAMESTNAVATELA%type) is (
        select MENO, PRIEZVISKO, ROD_CISLO, P_POISTENIE.ID_POISTENCA
        from P_ZAMESTNANEC
        join p_osoba using (rod_cislo)
        join P_POISTENIE using (rod_cislo)
        where ID_ZAMESTNAVATELA = c_id_zamestnavatela
    );

    begin
        for i in cur_zamestnavatel loop
            DBMS_OUTPUT.PUT_LINE('Zamestnavatel ' || i.NAZOV || ':');
            for j in cur_zamestnanec(i.ICO) loop
                DBMS_OUTPUT.PUT_LINE('    ' || cur_zamestnanec%rowcount ||  '. Zamestnanec ' || j.MENO || ' '
                || j.PRIEZVISKO || ' (rod. cislo ' || j.ROD_CISLO || ') ID poistenca ' || j.ID_POISTENCA);
            end loop;
        end loop;
    end;
/

exec uloha34;

-- 35 - vypis osoby ktore nemaju ziadne prispevky

set serveroutput on;

select meno, PRIEZVISKO, ROD_CISLO
from P_POBERATEL pob
join P_OSOBA os using (rod_cislo)
where not exists(
    select 1
    from P_PRISPEVKY pris
    where pris.ID_POBERATELA = pob.ID_POBERATELA
);

-- 36 - vypis sumu odvodov za zvolene obdobie a poistenca

create or replace procedure odvody_obdobie_poistenec
(p_obdobie P_ODVOD_PLATBA.OBDOBIE%type, p_poistenec P_POISTENIE.ID_POISTENCA%type)
as
    begin

    end;
/

select * from P_ODVOD_PLATBA;

-- 37 -
-- 38 -
-- 39 -
-- 40 -

---------- TRIGGRE -----------------------------------------------------------------------------------------------------

-- 41 nastav DAT_DO na NULL pri vklade do P_ZAMESTNANEC

create or replace trigger zamestnanec_doba_neurcita
    before insert on P_ZAMESTNANEC
    for each row
    begin
        :new.dat_do := null;
    end;
/

-- 42 - zakaz vlozit zapornu sumu do p_odvod_platba
-- ako to zabespecit inak (bez triggra)? - check constraint

create or replace trigger nezaporne_odvod_platba
    before insert on P_ODVOD_PLATBA
    for each row
    begin
        if :new.suma < 0 then
            raise_application_error(-20001, 'Suma v p_odvod_platba nemoze byt zaporna');
        end if;
    end;
/

-- 43 - kontrola existencie osoby pri vklade do p_poistenie
-- nieje toto zabezpecene referencnou integritou? alebo ako sa to vola?

create or replace trigger existuje_osoba
    before insert on P_POISTENIE
    for each row
    declare
        pocet integer := 0;
    begin
        select count(*)
        into pocet
        from P_OSOBA
        where ROD_CISLO = :new.rod_cislo;

        if pocet < 1 then
            raise_application_error(-20001, 'Osoba s tymto rodnym cislom neexistuje');
        end if;
    end;
/

-- drop trigger existuje_osoba;

-- 44 - zmazanie poistenia a zamestnani po zmazani osoby

create or replace trigger zmaz_osobu_zamestnanie_poistenie
    before delete on P_OSOBA
    for each row
    begin
        delete from P_ZAMESTNANEC
        where ROD_CISLO = :old.rod_cislo;

        delete from P_POISTENIE
        where ROD_CISLO = :old.rod_cislo;
    end;
/

-- 45 - zakaz duplicitneho aktivneho poistenia jednej osoby

create or replace trigger zakaz_duplicitneho_poistenia_osoby
    before insert on P_POISTENIE
    for each row
    declare
        pocet integer := 0;
    begin
        select count(*)
        into pocet
        from P_POISTENIE
        where ROD_CISLO = :new.rod_cislo
        and sysdate between DAT_OD and nvl(DAT_DO, sysdate + 1);

        if pocet > 0 then
            raise_application_error(-20001, 'Osoba nemoze mat viac ako jedno poistenie');
        end if;

    end;
/

-- drop trigger zakaz_duplicitneho_poistenia_osoby;

-- 46 - zakaz pridania zamestnanca starsieho ako 70 rokov

create or replace function rod_cislo_na_vek_dni(p_rod_cislo P_OSOBA.ROD_CISLO%type)
return integer
is
begin
    return sysdate - to_date(
        substr(p_rod_cislo, 1, 2) ||
        decode(substr(p_rod_cislo, 3, 1), 5, 0, 6, 1, substr(p_rod_cislo, 3, 1)) ||
        substr(p_rod_cislo, 4, 6), 'YYMMDD'
    );
end;

create or replace trigger nie_zamestnanci_starsi_70
    before insert on P_ZAMESTNANEC
    for each row
    declare
    begin
        if (rod_cislo_na_vek_dni(:new.ROD_CISLO) / 365) > 70 then
            raise_application_error(-20001, 'Zamestnanec nemoze byt starsi ako 70 rokov');
        end if;
    end;
/

-- 47 - pri vlozeni prispevku overit, ze suma v nezamestnanosti nie je vyssia nez 1000 eur

-- nechapem zadanie... budem robit ze suma nemoze byt >1000

create or replace trigger suma_menej_1000
    before insert on P_PRISPEVKY
    for each row
    begin
        if :new.suma > 1000 then
            raise_application_error(-20001, 'Suma prispevku nemoze byt viac ako 1000 eur');
        end if;
    end;
/

-- 48 - aktualizacia poctu zamestnancov v pomocnej tabulke pri novom vklade

create table p_pocet_zamestnancov (
    id_zamestnavatela char(11) primary key references P_ZAMESTNAVATEL(ico) not null,
    pocet_zamestnancov integer
);

create or replace trigger aktualizuj_pocet_zamestnancov
    after insert on P_ZAMESTNANEC
    for each row
    begin
        update p_pocet_zamestnancov
        set pocet_zamestnancov = (
            select count(*)
            from P_ZAMESTNANEC
            where id_zamestnavatela = :new.id_zamestnavatela
        )
        where id_zamestnavatela = :new.id_zamestnavatela;
    end;
/ -- toto actually neviem ci takto funguje

-- 49 ak sa vlozi novy typ prispevku, automaticky sa vlozi do p_historia s aktualnym datumom

create or replace trigger automaticky_p_historia
    before insert on P_TYP_PRISPEVKU
    for each row
    begin
        insert into P_HISTORIA values (:new.id_typu, sysdate, sysdate, :new.zakl_vyska);
    end;
/
-- drop trigger automaticky_p_historia;

-- 50 - zabrani vyplnit datum skusky s hodnotou vacsou ako 20:00

-- 20:00 je akoze cas skusky?

create or replace trigger nie_vecerne_skusky
    before insert on ZAP_PREDMETY
    for each row
    declare
    begin
        if to_char(:new.datum_sk, 'hh') >= 20 then
            raise_application_error(-20001, 'Skuska nemoze byt neskor ako 20:00 hodin');
        end if;
    end;
/

---------- DML ---------------------------------------------------------------------------------------------------------

-- 51 - vloz novu osobu, ktora ma nastaveny trvaly pobyt aj poistenie

insert into P_PLATITEL values('010125/1234');

insert into P_OSOBA
values ('010125/1234', 'Jozko', 'Mrkvicka', 97101, 'Namestie Slbody 1');

insert into P_POBERATEL (ID_POBERATELA, ROD_CISLO, ID_TYPU, PERC_VYJ, DAT_OD)
values (20001, '010125/1234', 3, 100, sysdate);

insert into P_POISTENIE (ID_POISTENCA, ROD_CISLO, ID_PLATITELA, OSLOBODENY, DAT_OD)
values (20001, '010125/1234', '010125/1234', 'n', sysdate);

rollback ;

-- 52 - zmen zamestnavatela pre konkretneho zamestnanca

select * from P_ZAMESTNANEC;
select * from P_ZAMESTNAVATEL;

update P_ZAMESTNANEC
set id_zamestnavatela = '12345678'
where ROD_CISLO = '880719/5573';

rollback;

-- 53 - odstran vsetky prispevky starsie ako 5 rokov

select * from P_PRISPEVKY order by kedy;
select count(*) from P_PRISPEVKY;

delete from P_PRISPEVKY
where months_between(sysdate, kedy) > 5 * 12;

rollback;

-- 54 - vloz novy typ prispevku a pridaj zaznam o jeho pouziti pre osobu

select * from P_TYP_PRISPEVKU;
select * from P_POBERATEL;

insert into P_TYP_PRISPEVKU
values (5, 500, 'len tak');

update P_POBERATEL
set ID_TYPU = 5
where ROD_CISLO = '870325/8388';

rollback;

-- 55 - vymazte vsektych poistencov, ktori maju ukoncene poistenie
-- (dat_do nie je null) a zaroven nemaju ziadne odvodove platby

select * from P_POISTENIE;
select count(*) from P_POISTENIE;

update P_ZAMESTNANEC z
set ID_POISTENCA = null
where exists(
    select 1
    from P_POISTENIE p
    where z.ID_POISTENCA = p.ID_POISTENCA
);

delete from P_POISTENIE p
where DAT_DO is not null
and not exists(
    select 1
    from P_ODVOD_PLATBA op
    where p.ID_POISTENCA = op.ID_POISTENCA
);

rollback;

-- 56 - odstran osoby, ktore nemaju ziadne poistenie, zamestnanie ani prispevok

-- pprispevky, ppoberatel, podvodplatba, pzamestnanec, ppoistenie, ptyppostihnutia, pztp, posoba, pplatitel
-- !!! opytat sa

-- 57 - vloz noveho poistenca so vsetkymi povinnymi udajmi a priradenou platbou

insert into P_PLATITEL values ('020225/1234');

insert into P_OSOBA values ('020225/1234', 'Jozko', 'Mrkvicka', 97101, 'Namestie Slobody 1');

insert into P_POBERATEL (ID_POBERATELA, ROD_CISLO, ID_TYPU, PERC_VYJ, DAT_OD)
values (20002, '020225/1234', 3, 100, sysdate);

insert into P_POISTENIE (ID_POISTENCA, ROD_CISLO, OSLOBODENY, DAT_OD)
values (20002, '020225/1234', 'n', sysdate);

-- select * from P_ODVOD_PLATBA order by CIS_PLATBY desc;
insert into P_ODVOD_PLATBA values (
    (select max(CIS_PLATBY)+1 from P_ODVOD_PLATBA),
20002, 10, sysdate, sysdate
);

rollback;

-- 58 - zmente mesto trvaleho pobytu na 'Bratislava' pre vsetky osoby, ktore maju momentalne psc zacinajuce na '9'

select * from P_OSOBA;
select * from P_OSOBA where substr(psc, 1, 1) = '9';

update P_OSOBA o
set psc = (select max(psc) from P_MESTO m where N_MESTA = 'Bratislava')
where substr(PSC, 1, 1) = 9;

rollback;

-- 59 - pridajte noveho poistenca na zaklade existujucej osoby
-- nastavte datum zaciatku poistenia na dnesny datum

insert into P_POISTENIE (ID_POISTENCA, ROD_CISLO, OSLOBODENY, DAT_OD) values (
    (select max(ID_POBERATELA)+1 from P_POBERATEL),
    (select max(ROD_CISLO) from P_OSOBA o),
    'n',
    sysdate
);

rollback;

-- 60 - aktualizuj typ postihnutia pre osoby, ktore maju len jeden prispevok

update P_POBERATEL pob
set ID_TYPU = 1
where exists (
    select 1
    from P_PRISPEVKY prisp
    where pob.ID_POBERATELA = prisp.ID_POBERATELA
    having count(OBDOBIE) = 1
);

rollback;

---------- VZTAHY A CHECK ----------------------------------------------------------------------------------------------

-- 61 - vytvorte vztah mezdi p_osoba a p_poistenie (FK)

alter table P_POISTENIE
add constraint fk_poistenie_osoba
foreign key (ROD_CISLO)
references P_OSOBA (ROD_CISLO);

alter table P_POISTENIE drop constraint fk_poistenie_osoba;

-- 62 - vytvorte vztah medzi p_osoba a p_zamestnanec (cudzi kluc)

alter table P_ZAMESTNANEC
add constraint fk_zamestnanec_osoba
foreign key (ROD_CISLO)
references P_OSOBA (rod_cislo);

alter table P_ZAMESTNANEC drop constraint fk_zamestnanec_osoba;

-- 63 - vytvorte check ktory zakaze prispevok s nuloovu hodnotou

select * from P_PRISPEVKY order by suma;
update P_PRISPEVKY set SUMA = 0 where SUMA = 0.01;

alter table P_PRISPEVKY
add check ( SUMA > 0 );

-- zrusenie
-- select *
-- from USER_CONSTRAINTS
-- where lower(TABLE_NAME) = 'p_prispevky'
-- -- and lower(SEARCH_CONDITION_VC) = 'suma > 0'
-- ;
--
-- alter table P_PRISPEVKY
-- drop constraint SYS_C00919933;

-- 64 - vytvorte check, ktory povoli odvod len od vysky 500 eur

alter table P_ODVOD_PLATBA
add check ( SUMA > 500 );

-- 65 - vytvorte check, ktory overi, ze datum ukoncenia zamestnania je po datume zaciatku

alter table P_ZAMESTNANEC
add check ( DAT_DO > DAT_OD );

-- 66 - vytvore tabulku p_dieta, kde kadze dieta ma ma rodica v p_osoba ako cudzi kluc

create table p_dieta (
    rod_cislo char(11) not null,
    rodic char(11) not null,
    primary key (rod_cislo),
    foreign key (rodic) references P_OSOBA (ROD_CISLO)
);

drop table p_dieta;

-- 67 - vytvorte tabulku p_adresa a naviazte ju na osobu pomocou cudzich klucov

-- ???

create table p_adresa (
    psc char(5) references P_OSOBA (psc),
    ulica varchar2(50) references P_OSOBA (ulica),
    primary key (psc, ulica)
);

-- 68 - vytvorte check, ktory overi, ze kod postihnutia je medzi 1 a 10

alter table P_ZTP
add check ( ID_POSTIHNUTIA between 1 and 10);

-- 69 - vytvorte vztah medzi prispevkom a p_typ_prispevku

alter table P_PRISPEVKY
add constraint fk_prispevky_typ_prispevku
foreign key (ID_TYPU) references P_TYP_PRISPEVKU(ID_TYPU);

alter table P_PRISPEVKY
drop constraint fk_prispevky_typ_prispevku;

-- 70 - vytvorte kompozitny primarny kluc na tabulke, kde kombinacia osoby a prispevku je unikatna

-- az tak uplne som nepochopil zadanie
alter table P_PRISPEVKY
add primary key (ID_POBERATELA, ID_TYPU);

---------- CAS ---------------------------------------------------------------------------------------------------------

-- 71 - vypocitajte vek kazdej osoby na zaklade datumu narodenia

select rod_cislo, substr(ROD_CISLO, 5, 2)
-- ,to_date(
--     substr(ROD_CISLO, 1, 2) ||
--     decode(substr(ROD_CISLO, 3, 1), 5, 0, 6, 1, 9, 0, substr(ROD_CISLO, 3, 1)) ||
--     decode(substr(ROD_CISLO, 4, 1), 9, 1, substr(ROD_CISLO, 4, 1)) ||
--     substr(ROD_CISLO, 5, 2),
--     'yymmdd'
-- )
from P_OSOBA
-- where substr(ROD_CISLO, 3, 2) > 62
order by substr(ROD_CISLO, 5, 2) desc
;

select round(abs(months_between(
    sysdate,
    to_date(
        substr(ROD_CISLO, 1, 2) ||
        decode(substr(ROD_CISLO, 3, 1), 5, 0, 6, 1, 9, 0, substr(ROD_CISLO, 3, 1)) ||
        decode(substr(ROD_CISLO, 4, 1), 9, 1, substr(ROD_CISLO, 4, 1)) ||
        substr(ROD_CISLO, 5, 2),
--         decode(substr(ROD_CISLO, 5, 1))  -- este dni su tam zle podavane
        'yymmdd'
    )
)) / 12, 2) vek
from P_OSOBA;
