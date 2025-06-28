-- vytvorte pohlad, ktory vypise menny zoznam studentov, ktori su sikovni studenti (najhorsia znamka C)
create or replace view sikovni_studenti
as select distinct meno, PRIEZVISKO
from STUDENT s
join os_udaje o using (rod_cislo)
where not exists (
    select 1
    from ZAP_PREDMETY z
    where z.OS_CISLO = s.OS_CISLO
    and VYSLEDOK is null
    and VYSLEDOK in 'DEF'
);

create or replace view sikovni_studenti
as select meno, PRIEZVISKO, OS_CISLO
from OS_UDAJE o
join student s using (rod_cislo)
where exists (
    select 1
    from ZAP_PREDMETY z
    where s.OS_CISLO = z.OS_CISLO
)
and not exists (
    select 1
    from ZAP_PREDMETY z
    where s.OS_CISLO = z.OS_CISLO
    and VYSLEDOK not in ('A', 'B', 'C')
)
and exists (
    select 1
    from ZAP_PREDMETY z
    where s.OS_CISLO = z.OS_CISLO
    and VYSLEDOK is not null
);

select * from sikovni_studenti;

------------------------------------------------------------------------------------------------------------------------

declare
    cursor stud_cur is (select meno, priezvisko from OS_UDAJE);
begin
    for s in stud_cur loop
        DBMS_OUTPUT.put_line(s.MENO || ' ' || s.PRIEZVISKO || ' ' || stud_cur%rowcount);
    end loop;
end;


-- vypiste osoby ktore nikdy neboli studentom

declare
    cursor nestudenti is (
        select meno, priezvisko, ROD_CISLO
        from OS_UDAJE o
        where not exists (
            select 1
            from student s
            where s.ROD_CISLO = o.ROD_CISLO
        )
    );
    zaznam nestudenti%rowtype;
begin
    open nestudenti;
        loop
            fetch nestudenti into zaznam;
            exit when nestudenti%notfound;
            DBMS_OUTPUT.PUT_LINE(
                    nestudenti%rowcount || '. ' || zaznam.MENO || ' ' ||
                    zaznam.PRIEZVISKO || ' ' || zaznam.ROD_CISLO

            );
        end loop;
    close nestudenti;
end;

-- dalsia uloha

declare
    cursor ucitelia is (
        select meno, PRIEZVISKO, OS_CISLO, KATEDRA from UCITEL
    );
    cursor predmety(p_uc ZAP_PREDMETY.PREDNASAJUCI%type) is (
        select CIS_PREDM, NAZOV from PREDMET pr
        where exists(
            select 1
            from ZAP_PREDMETY zp
            where zp.PREDNASAJUCI = p_uc
            and zp.CIS_PREDM = pr.CIS_PREDM
        )
    );
    cursor studenti(p_pr ZAP_PREDMETY.CIS_PREDM%type) is (
        select OS_CISLO from ZAP_PREDMETY
        where CIS_PREDM = p_pr
    );
    stud studenti%rowtype;
begin
    for uc in ucitelia loop
        DBMS_OUTPUT.PUT_LINE(
            ucitelia%rowcount || '. ' || uc.MENO || ' ' ||
            uc.PRIEZVISKO || ' ' || uc.OS_CISLO || ' ' || uc.KATEDRA
        );
        DBMS_OUTPUT.PUT_LINE('Uci tieto predmety: ');
        for pr in predmety(uc.OS_CISLO) loop
            DBMS_OUTPUT.PUT_LINE(
                '    ' || pr%rowcount || '. ' || pr.CIS_PREDM || ' ' ||
                pr.NAZOV
            );
            open studenti(pr.CIS_PREDM);
                loop
                    fetch studenti into stud;
                    exit when studenti%notfound or studenti%rowcount > 10;
                    DBMS_OUTPUT.PUT(stud.OS_CISLO || ' ');
                end loop;
                DBMS_OUTPUT.PUT_LINE('');
            close studenti;
        end loop;
    end loop;
end;
/

-- dalsia uloha

-- dalsia uloha

declare
    cursor menoslov is
        select meno, PRIEZVISKO, ROD_CISLO
        from OS_UDAJE;
    cursor os_cisla_osob(p_rc STUDENT.ROD_CISLO%type) is
        select OS_CISLO from STUDENT
        where rod_cislo = p_rc;
begin
    for osoba in menoslov loop
        DBMS_OUTPUT.PUT(osoba.MENO || ' ' || osoba.PRIEZVISKO || '    ');
        for os_cisla in os_cisla_osob(osoba.ROD_CISLO) loop
            DBMS_OUTPUT.PUT(os_cisla.OS_CISLO || ' ');
        end loop;
        DBMS_OUTPUT.PUT_LINE('');
    end loop;
end;
/

----

-- prijmy

select sum(CENA_DEN*POCET_OSOB)
from lod
join plavba using (id_lod)
join cena_plavby using (id_plavba)
join ZAKAZNIK_PLAVBA using (id_plavba)