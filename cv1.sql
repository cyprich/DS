select * from tabs;

desc os_udaje;

select to_char(sysdate, 'DD.MM.YYYY HH24:MI:SS'), user from dual;
select to_char(add_months(sysdate, 3), 'DD.MM.YYYY HH24:MI:SS Q'), user from dual;
select to_char(sysdate, 'day'), user from dual;
