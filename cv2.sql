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
    
