-- vypiste pocet prispevkov, pri kotrych je pocet dni medzi obdobim a zaplatenim mensi ako 16

select count(*)
from P_PRISPEVKY
where abs(KEDY - OBDOBIE) < 16;

-- zabezpecte, aby nebol odvod_platby nebol plateny cez vikend

select to_char(sysdate + 4, 'D') from dual;
select to_char(sysdate, 'day') from dual;

create or replace trigger odvod_platba_nie_cez_vikend
    before insert on P_ODVOD_PLATBA
    for each row
declare
begin
    if to_char(:new.DAT_PLATBY, 'D') in ('1', '7') then
        raise_application_error(-20001, 'odvod_platba nemoze byt cez vikend!');
    end if;
end;
/

-- vytvorte funkciu ktora vypise pocet zamestnancov muzskeho pohlavia
-- a nasledne ju pouzite pri vypise zamestnavatelov
-- (vsetky atributy + funkcie)

create or replace function muzi_zamestnanci (
    p_ico P_ZAMESTNAVATEL.ICO%type
) return integer
is
    pocet integer := 0;
begin
    select count(*)
    into pocet
    from P_ZAMESTNANEC zc
    join P_ZAMESTNAVATEL zl on (zc.ID_ZAMESTNAVATELA = zl.ICO)
    where substr(ROD_CISLO, 3, 1) < 5
    and zl.ico = p_ico
    ;

    return pocet;
end;
/

select ico, nazov, psc, ulica, muzi_zamestnanci(ico) from P_ZAMESTNAVATEL;

-- vytvorte pohlad v ktorom sa pre kazdy kraj ktory ma aspon 10 miest, zobrazi pocet miest
-- zabezpecte, aby sa nedalo vkladat, odoberat, upravovat udaje cez pohlad

create or replace view pocet_miest_v_raji
as
    select ID_KRAJA, count(o.ID_OKRESU) as pocet_miest
    from P_KRAJ k
    join P_OKRES o using (id_kraja)
    join P_MESTO m using (id_okresu)
    having count(*) >= 10
    group by ID_KRAJA

    with read only
;

select * from pocet_miest_v_raji;

-- vytvorte proceduru, ktora pre kazdeho poberatela prispevku zobrazi jeho najvyssi prispevok

create or replace procedure najvyssi_prispevok_poberatela
as
    najvyssi integer;
    cursor poberatelia is
        select * from P_POBERATEL;
    cursor hodnoty(id_pob p.poberatel.id_poberatela%rowtype) is

begin
    for pob in poberatelia loop

    end loop;
end;
/

select najvyssi_prispevok_poberatela() from dual;
