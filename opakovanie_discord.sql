-- vypiste kolko unikatnych typov prispevkov bolo vyplatenych v minulom roku

select * from P_PRISPEVKY;

select id_typu, count(*)
from P_PRISPEVKY
where to_char(kedy, 'yy') = to_char(add_months(sysdate, -12), 'yy')
group by ID_TYPU;

-- vypiste priemernu sumu odvodenu do poistovne za minuly rok

select * from P_ODVOD_PLATBA;

select avg(suma)
from P_ODVOD_PLATBA
where to_char(OBDOBIE, 'yy') = to_char(add_months(sysdate, -12), 'yy')

-- napis trigger, ktory zabezpeci, ze aktualizaciu zaznamu v tabulke p_poistenie moze vykonat len pouzivatel admin_poistovna

create or replace trigger neopravnena_uprava_poistenie
before insert on P_POISTENIE
    begin
        if lower(user) != 'admin_poistovna' then
            raise_application_error(-20001, 'Neopravneny pristup, upravy moze robit len pouzivatel "admin_poistovna"')
        end if;
    end;
/

drop trigger neopravnena_uprava_poistenie;

-- vytvorte funkciu ktora pre zadanu osobu vrati informaciu o tom, ci je aktualne zamestnana

create or replace function je_osoba_zamestnana(p_rod_cislo p_osoba.ROD_CISLO%type)
return char
    as
        v_pocet integer := 0;
    begin
        select count(*)
        into v_pocet
        from P_ZAMESTNANEC
        where ROD_CISLO = p_rod_cislo;

        if v_pocet > 0 then
            return 'a';
        else
            return 'n';
        end if;
    end;
/

select * from P_ZAMESTNANEC;

select je_osoba_zamestnana('900711/0497') from dual;
select je_osoba_zamestnana('010101/1234') from dual;
