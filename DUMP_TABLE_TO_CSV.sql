create or replace procedure dump_table_to_csv( p_tname in varchar2,
 p_dir in varchar2,
 p_filename in varchar2 )
 
 /*
 
 05.08.2019 lukhnevsn
 procedure for import/export large tables, row by row.

'cause standart package has a lot of erros such that:
ORA-04068: existing state of packages has been discarded
ORA-04030: out of process memory when trying to allocate 16328 bytes (koh-kghu sessi,pl/sql vc2)


USAGE EXAMPLE:
===========================
begin
dump_table_to_csv( 'u_kiselevamn.croco_8',
                'U_USERS',
                'croco_8.csv' );
 end;
===========================

*/
 is
 l_output utl_file.file_type;
 l_theCursor integer default dbms_sql.open_cursor;
 l_columnValue varchar2(4000);
 l_status integer;
 l_query varchar2(1000)
 default 'select * from ' || p_tname;
 l_colCnt number := 0;
 l_separator varchar2(1);
 l_descTbl dbms_sql.desc_tab;
 begin
 l_output := utl_file.fopen( p_dir, p_filename, 'w' );
 execute immediate 'alter session set nls_date_format=''dd-mon-yyyy hh24:mi:ss'' ';
 
 dbms_sql.parse( l_theCursor, l_query, dbms_sql.native );
 dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl );
 
 for i in 1 .. l_colCnt loop
 utl_file.put( l_output, l_separator || '"' || l_descTbl(i).col_name || '"' );
 dbms_sql.define_column( l_theCursor, i, l_columnValue, 4000 );
 l_separator := ',';
 end loop;
 utl_file.new_line( l_output );
 
 l_status := dbms_sql.execute(l_theCursor);
 
 while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
 l_separator := '';
 for i in 1 .. l_colCnt loop
 dbms_sql.column_value( l_theCursor, i, l_columnValue );
 utl_file.put( l_output, l_separator || l_columnValue );
 l_separator := ',';
 end loop;
 utl_file.new_line( l_output );
 end loop;
dbms_sql.close_cursor(l_theCursor);
 utl_file.fclose( l_output );
 
 execute immediate 'alter session set nls_date_format=''dd-MON-yy'' ';
 exception
 when others then
 execute immediate 'alter session set nls_date_format=''dd-MON-yy'' ';
 raise;
 end;
 /