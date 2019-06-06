-- grants for all tables
declare
    v_sql varchar2(4000 char);
    cursor allt_cont is (select table_name from all_tables where owner = 'SCHEMA');


begin

    for s in allt_cont loop
   v_sql:=  'grant select on ' || s.table_name || ' to SCHEMA'; 
        dbms_output.put_line( v_sql);    
        EXECUTE IMMEDIATE v_sql;
    end loop;

 
end;
;
/

;
-- grants for all tables views
declare
    v_sql varchar2(4000 char);
    cursor allt_cont is (select view_name from all_views where owner = 'SCHEMA');
 --  cursor allt_stg is (select * from all_tables where owner = 'SCHEMA');
begin
    for s in allt_cont loop
   v_sql:=  'grant select on ' || s.view_name || ' to SCHEMA'; 
        dbms_output.put_line( v_sql);    
        EXECUTE IMMEDIATE v_sql;
    end loop;
--   for so in allt_stg loop
--       dbms_output.put_line(s.owner || '.' || s.table_name);    
--      EXECUTE IMMEDIATE 'grant select on ' || s.owner || '.' || s.table_name 'to SCHEMA'; 
--   end loop;
end;
