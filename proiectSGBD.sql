--Tratarea excep?iilor (minim 2 implicite, 2 explicite) 

set serveroutput on
--1)sa se modifice pretul produsului dupa id
declare
p_excep exception;
v_id produs.id_produs%type := &id;
begin
update produs set pret = pret * 1.05 where id_produs = v_id; 
if sql%found then
dbms_output.put_line('produsul cu id-ul ' || v_id || ' a fost modificat cu succes');
else
raise p_excep;
end if;
exception 
when p_excep then
dbms_output.put_line('id introdus gresit');
end;

--2) sa se verifice daca exista un client cu id ul dat de la tastatura
declare
v_id client.id_client%type:=&id;
begin
select id_client into v_id from client
where id_client=v_id;
DBMS_OUTPUT.PUT_LINE('Client gasit');
exception
when others then
DBMS_OUTPUT.PUT_LINE('Clientul nu a fost gasit!');
end;

--3)
declare
v_idcom comanda.id_comanda%type := '&idcom';
v_idcl comanda.id_client%type := '&idcl';
v_metoda comanda.metoda_plata%type := '&met';
begin
insert into comanda (id_comanda, id_client, metoda_plata) values (v_idcom, v_idcl, v_metoda);
exception 
when others then
DBMS_OUTPUT.PUT_LINE('Un camp sau mai multe au fost introduse gresit!');
end;

--4)sa se adauge un produs nou
declare
begin
insert into produs (id_produs, nume, pret) values (NULL, 'Navigatie passat', 500);
exception
when others then
DBMS_OUTPUT.PUT_LINE('Eroare! id-ul nu poate fi null!');
end;

--Gestionarea cursorilor: minim 3 implici?i ?i 3 explici?i (cu ?i f?r? parametri) 

--1
--afisarea produselor cu pret mai mare de 500
declare
CURSOR c1 is select * from rand_comanda;
begin
for i in c1 loop
if i.pret>500 then
DBMS_OUTPUT.PUT_LINE(i.id_produs||' '|| i.pret);
end if;
end loop;
end;
/

--2
--metoda de plata a unui client cu id ul de la tastatura
declare
cursor c1 is select * from comanda;
v_id comanda.id_comanda%type:=&id;
begin
for i in c1 loop
if v_id=i.id_comanda then
DBMS_OUTPUT.PUT_LINE(i.id_comanda||' '||i.metoda_plata );
end if;
end loop;
end;
/

--3
--primele 5 produse cu pret mai mare de 200
declare
contor number;
cursor c1 is select * from produs;
begin
for i in c1 loop
if i.pret >200 then 
contor:=contor+1;
DBMS_OUTPUT.PUT_LINE(i.nume||' '||i.descriere );
exit when contor=5;
end if;
end loop;
end;
/

--4
--comenzi cu mai mult de 2 produse
declare
cursor c1 is select* from rand_comanda;
v_cant rand_comanda.cantitate%type;
begin
for i in c1 loop
if i.cantitate >=2 then
DBMS_OUTPUT.PUT_LINE('comanda are '|| i.cantitate||' produse in valoare de '||i.pret ||'lei');
end if;
end loop;
end;
/

--5
--determinarea numelui unui client in functie de id
declare
cursor c1 is select * from client;
v_id client.id_client%type:=&id;
begin
for i in c1 loop
if v_id=i.id_client then 
DBMS_OUTPUT.PUT_LINE('persoana cu id-ul ' || i.id_client ||' are numele '|| i.nume);
end if;
end loop;
end;
/

--6
--10% reducere la produsele mai scumpe de 500
declare
cursor c1 is
select * from produs;
v_pret produs.pret%type;
begin
for i in c1 loop
if i.pret > 500 then
v_pret := i.pret * 0.9;
update produs set pret = v_pret where id_produs = i.id_produs;
end if;
end loop;
commit;
exception
when others then
rollback;
end;
/


--Func?ii, proceduri, includerea acestora în pachete (minim 3 func?ii, 3 proceduri ?i 2 pachete) 
--1
create or replace procedure ieftinire(p_pret in number, p_numar out number)
is 
e exception;
begin
update produs
set pret = 0.9*pret
where pret >p_pret;
if sql%found then 
p_numar := sql%rowcount;
else
raise e;
end if;
exception
when e then
p_numar := 0;
end;
declare
nr_produse number;
begin
ieftinire(&id, nr_produse);
if nr_produse != 0 then
DBMS_OUTPUT.PUT_LINE('am modificat pretul pentru ' || nr_produse ||' produse');
else
DBMS_OUTPUT.PUT_LINE('Pretul nu s a putu modifica!');
end if;
end;

--2
create or replace function categorii(p_id produs.id_produs%type)
return varchar2
is
v_pret produs.pret%type;
begin
select pret into v_pret from produs where id_produs = p_id;
if v_pret<300 then
return 'ieftin';
elsif v_pret between 300 and 500 then
return 'produs scumput';
else return 'produs scump';
end if;
exception
when no_data_found then
return 'nu exista produsul';
end;

declare 
v_func varchar2(32767); 
begin 
v_func := categorii(&id); 
dbms_output.put_line(v_func); 
end;
/

--3
create or replace function tip_comanda(p_id rand_comanda.id_comanda%type)
return varchar2
is
v_cantitate rand_comanda.cantitate%type;
begin
select cantitate into v_cantitate from rand_comanda where id_comanda = p_id;
if v_cantitate<2 then
return 'comanda simpla';
elsif v_cantitate <4 then
return 'comanda mica';
else return 'comanda mare';
end if;
exception
when no_data_found then
return 'nu exista produsul';
end;
declare 
v_func varchar2(32767); 
begin 
v_func := tip_comanda(&id); 
dbms_output.put_line(v_func); 
end;
/

--4
create or replace procedure ieftinire(p_pret in number, p_numar out number)
is 
e exception;
begin
update produs
set pret = 0.9*pret
where pret >p_pret;
if sql%found then 
p_numar := sql%rowcount;
else
raise e;
end if;
exception
when e then
p_numar := 0;
end;
declare
 v_pret number;
 v_numar number;
begin
 
 ieftinire(&v_pret, v_numar);
 dbms_output.put_line('Numarul de produse actualizate: ' || v_numar);
end;
/


--5
create or replace procedure print_contact(p_id NUMBER)
is
 r_contact client%ROWTYPE;
begin
 select *
 into r_contact
 from client
 where id_client = p_id;
 dbms_output.put_line( r_contact.nume || ' ' ||r_contact.prenume || ' ' || r_contact.mail ||' '|| 
r_contact.nr_tel );
 end;
exec print_contact(&id);

--6
create or replace function pretul_comenzii(p_id rand_comanda.id_comanda%type) 
 return varchar2 
is 
 v_pret rand_comanda.pret%type; 
begin 
select pret into v_pret from rand_comanda where id_comanda = p_id; 
if v_pret < 500 then
return 'comanda ieftina'; 
elsif v_pret < 1000 then 
return 'comanda medie'; 
else 
return 'comanda scumpa'; 
end if; 
exception 
when no_data_found then 
return 'nu exista produsul'; 
end;
/
declare 
v_func varchar2(32767); 
begin 
v_func := pretul_comenzii(&id); 
dbms_output.put_line(v_func); 
end;
/


--primul pachet
create or replace package pachet1
is
procedure ieftinire1(p_pret in number, p_numar out number);
procedure ieftinire2(p_pret in number, p_numar out number);
procedure print_contact(p_id NUMBER);
end;
create or replace package body pachet1
is
procedure ieftinire1(p_pret in number, p_numar out number)
is 
e exception;
begin
update produs
set pret = 0.9*pret
where pret >p_pret;
if sql%found then 
p_numar := sql%rowcount;
else
raise e;
end if;
exception
when e then
p_numar := 0;
end;
procedure ieftinire2(p_pret in number, p_numar out number)
is 
e exception;
begin
update produs
set pret = 0.9*pret
where pret >p_pret;
if sql%found then 
p_numar := sql%rowcount;
else
raise e;
end if;
exception
when e then
p_numar := 0;
end;
procedure ieftinire(p_pret in number, p_numar out number)
is 
e exception;
begin
update produs
set pret = 0.9*pret
where pret >p_pret;
if sql%found then 
p_numar := sql%rowcount;
else
raise e;
end if;
exception
when e then
p_numar := 0;
end;
procedure print_contact(p_id NUMBER)
is
r_contact client%ROWTYPE;
begin
select *
into r_contact
from client
where id_client = p_id;
dbms_output.put_line( r_contact.nume || ' ' ||r_contact.prenume || ' ' || r_contact.mail ||' '|| 
r_contact.nr_tel );
end;
end;

--al doilea pachet
create or replace package pachet2
is
function categorii(p_id produs.id_produs%type) return varchar2;
function tip_comanda(p_id rand_comanda.id_comanda%type) return varchar2;
function pretul_comenzii(p_id rand_comanda.id_comanda%type) return varchar2;
end;
create or replace package body pachet2
is
function categorii(p_id produs.id_produs%type)
return varchar2
is
v_pret produs.pret%type;
begin
select pret into v_pret from produs where id_produs = p_id;
if v_pret<300 then
return 'ieftin';
elsif v_pret between 300 and 500 then
return 'produs scumput';
else return 'produs scump';
end if;
exception
when no_data_found then
return 'nu exista produsul';
end;
function tip_comanda(p_id rand_comanda.id_comanda%type)
return varchar2
is
v_cantitate rand_comanda.cantitate%type;
begin
select cantitate into v_cantitate from rand_comanda where id_comanda = p_id;
if v_cantitate<2 then
return 'comanda simpla';
elsif v_cantitate <4 then
return 'comanda mica';
else return 'comanda mare';
end if;
exception
when no_data_found then
return 'nu exista produsul';
end;
function pretul_comenzii(p_id rand_comanda.id_comanda%type) 
 return varchar2 
is 
 v_pret rand_comanda.pret%type; 
begin 
select pret into v_pret from rand_comanda where id_comanda = p_id; 
if v_pret < 500 then 
return 'comanda ieftina'; 
elsif v_pret < 1000 then 
return 'comanda medie'; 
else 
return 'comanda scumpa'; 
end if; 
exception 
when no_data_found then 
return 'nu exista produsul';
end;
end;


--Declan?atori (minim 3) 
--1
create or replace trigger verif_pret
before
insert or update of pret on produs
for each row declare
produs_scump exception;
begin
if: new.pret>500 then
DBMS_OUTPUT.PUT_LINE('produsul este cam scump');
raise produs_scump;
end if;
end;


--2
create or replace trigger cantitate_mare
before
insert or update of cantitate on rand_comanda
for each row declare
prea_multe exception;
begin
if: new.cantitate>10 then
DBMS_OUTPUT.PUT_LINE('prea multe produse in comanda');
raise prea_multe;
end if;
end;

--3
create or replace trigger metoda_plata
before
insert or update of metoda_plata on comanda
for each row declare
fara_card exception;
begin
if: new.metoda_plata='card' then
DBMS_OUTPUT.PUT_LINE('nu functioneaza plata cu cardul momentan');
raise fara_card;
end if;
end;