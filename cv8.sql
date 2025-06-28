-- funkcia pre zadane cislo predmetu vypiste pocet uspecnych studentov

create or replace function pocet_uspesnych_studentov(
    p_cis_predm PREDMET.cis_predm%type
) return integer
is
    pocet integer := 0;
begin
    select count(*)
    into pocet
    from ZAP_PREDMETY
    where CIS_PREDM = p_cis_predm
    and VYSLEDOK is not null
    and VYSLEDOK <> 'F';

    return pocet;
end;
/

select pocet_uspesnych_studentov('IN05')from dual;

select CIS_PREDM from ZAP_PREDMETY;

-- vypiste najuspesnejsie a najmenej uspesne predmety naraz

create or replace procedure min_max_predmety
is
    cursor min_pred is
        select CIS_PREDM, nazov, pocet_uspesnych_studentov(CIS_PREDM) as pocet
        from PREDMET
        where pocet_uspesnych_studentov(CIS_PREDM)
              in (select max(pocet_uspesnych_studentov(CIS_PREDM)) from PREDMET);
    cursor max_pred is
        select CIS_PREDM, nazov, pocet_uspesnych_studentov(CIS_PREDM) as pocet
        from PREDMET
        where pocet_uspesnych_studentov(CIS_PREDM)
            in (select min(pocet_uspesnych_studentov(CIS_PREDM)) from PREDMET);

    cursor top_predm(hodnota integer) is
        select CIS_PREDM, NAZOV, pocet_uspesnych_studentov(CIS_PREDM) as pocet
        from PREDMET
        where pocet_uspesnych_studentov(CIS_PREDM) = hodnota;
    cursor min_max is select min(pocet_uspesnych_studentov(CIS_PREDM))
        from PREDMET
        union
        select max(pocet_uspesnych_studentov(CIS_PREDM)) from PREDMET;

begin
    DBMS_OUTPUT.PUT_LINE('Minimalne pocty: ');
    for pred in min_pred loop
        DBMS_OUTPUT.PUT_LINE(pred.CIS_PREDM || ' - ' || pred.nazov || ' - ' || pred.pocet);
    end loop;

    DBMS_OUTPUT.PUT_LINE('Maximalne pocty: ');
    for pred in max_pred loop
            DBMS_OUTPUT.PUT_LINE(pred.CIS_PREDM || ' - ' || pred.nazov || ' - ' || pred.pocet);
        end loop;

    for m_m in min_max loop
        DBMS_OUTPUT.PUT_LINE('Pocet: ' || m_m.top);
        for pred in top_predm(m_m.top) loop
            DBMS_OUTPUT.PUT_LINE(pred.CIS_PREDM || ' - ' || pred.NAZOV);
        end loop;
    end loop;
end;
/

set SERVEROUTPUT on;
exec mix_max_predmety;

select min_max_predmety() from dual;

select CIS_PREDM, nazov, pocet_uspesnych_studentov(CIS_PREDM)
from PREDMET
where pocet_uspesnych_studentov(CIS_PREDM)
in (
    (select max(pocet_uspesnych_studentov(CIS_PREDM)) from PREDMET)
    or
    (select max(pocet_uspesnych_studentov(CIS_PREDM)) from PREDMET)
);

-- poberatel nemoze poberat 2 prispevky toho isteho typu

select * from P_POBERATEL;

create or replace trigger len_jeden_typ_prisp
before insert on P_POBERATEL
for each row
declare
    pocet integer := 0;
begin
    select count(*)
    into pocet
    from P_POBERATEL
    where ROD_CISLO = :new.rod_cislo
    and id_typu = :new.id_typu
    and (dat_do is null or trunc(DAT_DO) > trunc(sysdate));

    if pocet > 0 then
        RAISE_APPLICATION_ERROR(-20001, 'NEMOZES POBERAT PRISPEVKY TOHO ISTEHO TYPU VIAC KRAT');
    end if;
end;
/

select * from P_POBERATEL where ROD_CISLO = '600213/0000';

insert into P_POBERATEL
values (12214, '600213/0000', 1, 15, trunc(sysdate), null);

insert into P_POBERATEL
values (12214, '600213/0000', 3, 15, trunc(sysdate), null);

rollback;

----------------

declare
cursor stud_meno_k is
    select ROD_CISLO, MENO, PRIEZVISKO, OS_CISLO, rocnik
    from OS_UDAJE
    join STUDENT using (rod_cislo)
    where MENO like 'K%';
begin
    for stud in stud_meno_k loop
        DBMS_OUTPUT.PUT_LINE(stud.OS_CISLO || ' - ' || stud.MENO || ' ' || stud.PRIEZVISKO || ' - ' || stud.ROD_CISLO);
    end loop;
end;
/

------------------------------------------------------------------------------------------------------------------------

