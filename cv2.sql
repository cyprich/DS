-- menny zoznam ucitelov ktori prednasali/prednasaju nejaky predmet

select distinct meno, priezvisko from ucitel uc
    join zap_predmety zp
    on uc.os_cislo = zp.prednasajuci;
    
-- vypiste zapisane predmety studentov, ktore spravil dany student aspon pred 3600 dnami

select * from zap_predmety where datum_sk <= (sysdate - 3600);
select * from zap_predmety where (sysdate - datum_sk) >= 3600;
select * from zap_predmety where (sysdate - nvl(datum_sk, sysdate)) >= 3600;
    
-- pre kazdeho studenta vypiste priemerny pocet ziskanych kreditov

select os_cislo, avg(ects) from zap_predmety group by os_cislo;

-- vypiste informacie o studijnych odboroch ktore nikto nestuduje, resp. nestudoval

select * from st_odbory 
    where not exists(
        select 'x' from student 
            where student.st_odbor = st_odbory.st_odbor 
            and student.st_zameranie = st_odbory.st_zameranie);

select * from st_odbory 
    where st_odbor not in (select st_odbor from student) 
    and st_zameranie not in (select st_zameranie from student);
    -- EXISTS je viacej univerzalnejsi lebo IN nefunguje vzdy, hlavne ked PK je  viac ako z jedneho atributu
    
-- ----------------------------------------------------------------------------

-- 1
select * from student;

-- 2
select meno,priezvisko from os_udaje o join student s using(rod_cislo) where s.rocnik=2;

-- 3
select meno,priezvisko from os_udaje join student using(rod_cislo) where substr(rod_cislo, 1, 2) between '85' and '89';

-- 4
select meno,priezvisko from student join os_udaje using(rod_cislo) where st_skupina like '_P%';

-- 5
select meno,priezvisko from student join os_udaje using(rod_cislo) where st_skupina like '_P%' order by priezvisko;

-- 6
