-- 7.2

-- kolko zamestnancov ma zamestnavatel Tesco

select count(*)
from P_ZAMESTNANEC zc
join P_ZAMESTNAVATEL zl on zc.ROD_CISLO = zl.ICO
where zl.NAZOV = 'Tesco';

-- menny zoznam osob, ktore su oslobodene od platenia poistenia a nepoberaju ziaden prispevok

select MENO, PRIEZVISKO
from P_OSOBA o
where exists(
    select 'x'
    from P_POISTENIE p
    where p.oslobodeny in ('A', 'a')
    and p.ROD_CISLO = o.ROD_CISLO
)
and not exists(
    select 'x'
    from P_POBERATEL p
    where p.ROD_CISLO = o.ROD_CISLO
    and dat_od <= sysdate
    and (dat_do is null or DAT_DO > sysdate)
);

-- ku kazdej osobe sumu ktoru zaplatila za minuly kalendarny rok
-- ak nic nezaplatila, tak vypiste aspon jej meno a priezvisko

select meno, priezvisko, rod_cislo, sum(nvl(suma, 0))
from P_ODVOD_PLATBA
left join P_POISTENIE using (id_poistenca)
left join P_OSOBA using (rod_cislo)
group by meno, priezvisko, rod_cislo
order by sum(nvl(suma, 0));