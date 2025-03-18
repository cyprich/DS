select *
 from os_udaje JOIN student using(rod_cislo);
 
select *
 from os_udaje JOIN student ON(os_udaje.rod_cislo=student.rod_cislo); 
 
select *
 from os_udaje o JOIN student s ON(o.rod_cislo=s.rod_cislo);  

select meno, priezvisko, os_udaje.rod_cislo, os_cislo
 from os_udaje JOIN student ON(os_udaje.rod_cislo=student.rod_cislo); 
 
select meno, priezvisko, rod_cislo
 from os_udaje o JOIN student s using(rod_cislo);
 
select meno, priezvisko, rod_cislo, length(rod_cislo), substr(priezvisko, 3,1)
 from os_udaje o JOIN student s using(rod_cislo)
                 JOIN zap_predmety using(os_cislo)
  where rocnik!=2 and ulica IS NOT null;           
  
select sysdate
 from os_udaje;
 
select sysdate
 from dual;
 
select * from dual;

describe os_udaje;

desc os_udaje;

d os_udaje;

desc dual;

select * 
 from student; -- 37
 
select * 
 from student join st_odbory using(st_odbor, st_zameranie); -- 37
 
select * 
 from student join st_odbory using(st_odbor); -- 88

select * 
 from student join st_odbory using(st_zameranie);    -- 137
 
 select round(123.56) from dual;
 
  select round(123.56,1) from dual;
  
  select round(123.56,-1) from dual;
  select round(123.56,-2) from dual;
  
  select mod(5,2) from dual;
  
  select mod(substr(rod_cislo, 3,2),50) from os_udaje;

select priezvisko, length(priezvisko), lower(priezvisko), upper(priezvisko), 
       initcap(priezvisko)
 from os_udaje;

select initcap('databazove SYSTEMY moj oblubeny predmet') from dual; 
select initcap('databazove.SYSTEMY.moj.oblubeny.predmet') from dual;  

select initcap('databazove.SYSTEMY.moj.oblubeny3predmet 3') from dual; 

select initcap('databazove SYSTEMY?moj_oblubeny.predmet') from dual;

select meno, priezvisko
 from os_udaje 
  where substr(meno,1,1)='M';
  
select meno, priezvisko
 from os_udaje 
  where meno like '%a%';  
  
select meno, priezvisko
 from os_udaje 
  where meno like '__a%';   
  
--regexp_like

select to_char(sysdate+1, 'DD.MM.YYYY HH24:MI:SS') from dual;

select to_char(sysdate+30, 'DD.MM.YYYY HH24:MI:SS') from dual;

select add_months(sysdate, 1) from dual;

select to_date('05-01.2000', 'DD.MM.YYYY') from dual;

select *
 from os_udaje 
  where rod_cislo IN (select rod_cislo from student);
  
select *
 from os_udaje 
  where rod_cislo NOT IN (select rod_cislo from student);  