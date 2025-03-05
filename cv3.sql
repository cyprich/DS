-- vypiste menny zoznam studentov ktori sa narodili a nastupili v ten insty mesiac
select MENO,PRIEZVISKO from STUDENT s
join OS_UDAJE o using (rod_cislo)
where
    decode(substr(rod_cislo, 3, 1), 5, 0, 6, 1, substr(rod_cislo, 3, 1))
    || substr(rod_cislo, 4, 1)
    = (to_char(dat_zapisu, 'MM'))

select MENO,PRIEZVISKO from STUDENT s
join OS_UDAJE o using (rod_cislo)
where mod(substr(rod_cislo, 3, 2), 50) = to_char(dat_zapisu, 'MM')

--
-- commit
-- rollback
