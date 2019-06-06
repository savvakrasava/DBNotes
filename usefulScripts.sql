--Datebase links!

create database link LINKNAME connect to SCHEMA IDENTIFIED BY "schema_pass" USING 'DESC_NAME_FROM_TNS' 

-- Create job 
DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
  ( job       => X 
   ,what      => 'begin
                        procedure_name;
                 end;'
  ,next_date => to_date('15.05.2019 01:00:00','dd/mm/yyyy hh24:mi:ss')
   ,interval  => 'TRUNC(SYSDATE+1)+6/24' /*daily at 6 am*/
   ,no_parse  => FALSE
  );
  SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
COMMIT;
END;

--гранты для создания шедулёра
--grants to create a sheduler
grant MANAGE SCHEDULER to SCHEMA;
grant CREATE JOB to SCHEMA;

--Создание SCHEDULER_JOB:
--create scheduler_job

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'NAME_OF_JOB'
      ,start_date      => TO_TIMESTAMP_TZ('2018/08/28 02:30:00.000000 +03:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'freq=DAILY;' /* https://docs.oracle.com/cd/B28359_01/server.111/b28310/scheduse004.htm#ADMIN12415 */
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'PLSQL_BLOCK'
      ,job_action      => ' declare
   job_x number :=0;
   err_code number;
   err_msg varchar2(1000 char);
   m_date1 date;
   m_date2 date;
   m_date3 date;
   load_dt date;
   pkg_name varchar2(1000 char):=''package_if_needed'';
   prc_name varchar2(1000 char):=''workflow'';
begin
         procedure_name;
end;'
      ,comments        => NULL
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'NAME_OF_JOB'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'NAME_OF_JOB'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'NAME_OF_JOB'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'NAME_OF_JOB'
     ,attribute => 'MAX_RUNS');
  BEGIN
    SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
      ( name      => 'NAME_OF_JOB'
       ,attribute => 'STOP_ON_WINDOW_CLOSE'
       ,value     => FALSE);
  EXCEPTION
    -- could fail if program is of type EXECUTABLE...
    WHEN OTHERS THEN
      NULL;
  END;
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'NAME_OF_JOB'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'NAME_OF_JOB'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'NAME_OF_JOB'
     ,attribute => 'AUTO_DROP'
     ,value     => FALSE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'NAME_OF_JOB'
END;
/ 



--правильное создание индексов
--proper index creation
create  index INDEX_NAME on TABLE_NAME("FIELD1","FIELD2")initrans 32 parallel 8 online;
alter index INDEX_NAME noparallel;

--delete in parallel

alter session set parallel_force_local = true;
alter session  enable parallel query;
alter session  enable parallel dml;
alter table TABLE_NAME nologging;

/* drop indexes for reduce i/o reads */

commit;

delete /*+ PARALLEL (10) */
from TABLE_NAME
where balalala;
commit;
alter table TABLE_NAME logging;


--flashback table

ALTER TABLE log ENABLE ROW MOVEMENT;
flashback table log to timestamp (SYSTIMESTAMP - interval '200' MINUTE);
ALTER TABLE log disable ROW MOVEMENT;
commit;

