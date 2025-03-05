-- insert
insert into OS_UDAJE values ('830722/6247', 'Karol', 'Novy', null, null, null);
insert into OS_UDAJE values ('860114/2462', 'Karol', 'Lempassky', null, null, null);
select * from KVET3.osoba;
insert into OS_UDAJE(rod_cislo, meno, priezvisko) select ROD_CISLO, MENO, PRIEZVISKO from kvet3.osoba;
commit;

insert into STUDENT values (123, 101, 0, '830722/6247', 1, '5ZI012', null, null, null);
insert into STUDENT values (90, 101, 1, '860114/2462', 2, '5ZSA21', null, null, null);
-- ako sa pocita st_odbor? co je stav?
insert into STUDENT(ROD_CISLO, OS_CISLO, ROCNIK, ST_SKUPINA, ST_ODBOR, ST_ZAMERANIE)
select ROD_CISLO, OS_CISLO, ROCNIK, ST_SKUPINA, ST_ODBOR, ST_ZAMERANIE from kvet3.osoba;
commit;

-- insert into ZAP_PREDMETY values (123, 'BI11', 2008, null, null, null, null, null)

