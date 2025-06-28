-- zabezpecte aby sa student nemohol znova zaregistrovat ako student ak momentalne student
create or replace trigger len_raz_student
    before insert on STUDENT
    for each row
declare
    pocet integer := 0;
begin
    select count(*)
    into pocet
    from student
    where ROD_CISLO = :new.rod_cislo and UKONCENIE is null;

    if pocet > 0 then
        raise_application_error(-20001, 'STUDENT NEMOZE BYT STUDENT VIAC AKO RAZ');
    end if;
end;

-- create or replace trigger len_raz_student
-- for insert on student
-- compound trigger
--     pocet integer := 0;
--
--     select count(*)
--     into pocet
--     from student
--     where ROD_CISLO = :new.rod_cislo and UKONCENIE is null;
--
--     if pocet > 0 then
--         raise_application_error(-20001, 'STUDENT NEMOZE BYT STUDENT VIAC AKO RAZ');
--     end if;
-- end;

select * from STUDENT;

-- nerobit insert select nad jednou tabulkou
insert into STUDENT
select 15, ST_ODBOR, ST_ZAMERANIE, ROD_CISLO, ROCNIK, ST_SKUPINA, STAV, null, sysdate  -- tu je problem
from STUDENT
where os_cislo = 123;

------------------------------------------------------------------------------------------------------------------------

-- vypisme mesto, okres, kraj, krajinu

create or replace view zilinske_mesta as
select psc, N_MESTA, ID_OKRESU, N_OKRESU, ID_KRAJA, N_KRAJA, ID_KRAJINY
from P_MESTO
join P_OKRES PO using (id_okresu)
join P_KRAJ PK using (id_kraja)
where ID_OKRESU = 'ZA'
order by 2
-- with check option
-- with read only
;

select * from zilinske_mesta;

create or replace trigger vloz_zilinske_mesto
instead of insert on zilinske_mesta
declare
    pocet integer := 0;
begin
    select count(*)
    into pocet
    from P_OKRES
    where ID_OKRESU = new.id_okresu;

    if pocet > 0 then
        insert into P_MESTO values (new.psc, new.n_mesta, new.id_okresu);
    else
        raise_application_error(-20001, 'taky okres neexistuje');
    end if;
end;

insert into zilinske_mesta
values('11111', 'Dolny Hricov', 'ZA', 'Zilina', 'ZA', 'Zilinsky', 'SVK');

-----------------------------------------------------------------------------------------------------------------------

-- 1 - definujte pohlad pohlad_st - menny zoznam studentov

create or replace view pohlad_st as
select meno, PRIEZVISKO, ST_SKUPINA
from STUDENT
join OS_UDAJE using (rod_cislo);

select * from pohlad_st;

-- 2 - pohlad_uc - menny zoznam ucitelov, ktori nieco ucia

select meno, priezvisko
from UCITEL
where exists(
    select
)
