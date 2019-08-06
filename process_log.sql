
CREATE SEQUENCE SCHEMA.SEQ_PROC
  START WITH 1
  MAXVALUE 9999999999999999999999999999
  MINVALUE 0
  NOCYCLE
  NOCACHE
  NOORDER
  NOKEEP
  GLOBAL;


CREATE TABLE SCHEMA.PROCESS_LOG
(
  ID            NUMBER,
  OBJ_NAME      VARCHAR2(32 CHAR)               NOT NULL,
  BEGIN_DT      DATE,
  END_DT        DATE,
  STATE         VARCHAR2(32 CHAR),
  ERR_TEXT      VARCHAR2(4000 CHAR),
  SHOST         VARCHAR2(240 CHAR),
  SOS_USER      VARCHAR2(240 CHAR),
  SSESSIONID    VARCHAR2(40 CHAR),
  AUTHID        VARCHAR2(40 CHAR),
  USER_PROCESS  NUMBER                          DEFAULT null
)
TABLESPACE SCHEMA_DATA
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
MONITORING;

COMMENT ON TABLE SCHEMA.PROCESS_LOG IS '��� ���������� ������ � �������';

COMMENT ON COLUMN SCHEMA.PROCESS_LOG.ID IS 'PK';

COMMENT ON COLUMN SCHEMA.PROCESS_LOG.OBJ_NAME IS '�������� �������/MV etc...';

COMMENT ON COLUMN SCHEMA.PROCESS_LOG.BEGIN_DT IS '������ (����� timestamp �����)';

COMMENT ON COLUMN SCHEMA.PROCESS_LOG.END_DT IS '���������';

COMMENT ON COLUMN SCHEMA.PROCESS_LOG.STATE IS '������ DONE/ERROR/READY...';

COMMENT ON COLUMN SCHEMA.PROCESS_LOG.ERR_TEXT IS '����� ������';

COMMENT ON COLUMN SCHEMA.PROCESS_LOG.USER_PROCESS IS 'ID ����������������� ��������';


CREATE UNIQUE INDEX SCHEMA.PROCESS_LOG_PK ON SCHEMA.PROCESS_LOG
(ID)
LOGGING
TABLESPACE SCHEMA_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
PARALLEL ( DEGREE 12 INSTANCES 1 );

ALTER TABLE SCHEMA.PROCESS_LOG ADD (
  CONSTRAINT C_PROCESS_LOG_PK
  PRIMARY KEY
  (ID)
  USING INDEX SCHEMA.PROCESS_LOG_PK
  ENABLE VALIDATE);





CREATE OR REPLACE procedure SCHEMA.P_INS_LOG  --������ � ��� !!!
  (
--  nQID       in out number, -- ���� null ������ ����� �������, ���� PROCESS_LOG.ID ������ update �������
  sPROC_CODE    in varchar2, --��� ��������, �������� DM_SMS_PROGNOZ. ������ ����� ������-������� ��� ������-���������.
  sSTATE    in varchar2 default 'New',   -- ������. 19.09.2017 ����� �������� ������������ ������ ��� ������������� �����. �� ��� main ����� ���� ����� ��������� nID
  sERRTEXT  in varchar2 default null,    --����� ������
  nUSER_PROCESS in number default null  --ID ���������������� �������� 
  )
  is
    
    PRAGMA AUTONOMOUS_TRANSACTION; --����� ���������� � ��������
    nQID number;
  begin
--    if nQID is null then --�������
      select SEQ_PROC.nextval into nQID from dual;
      insert into PROCESS_LOG(ID, OBJ_NAME, BEGIN_DT,  STATE, ERR_TEXT, SHOST, SOS_USER, SSESSIONID, AUTHID, USER_PROCESS)
      values (nQID, sPROC_CODE, sysdate, substr(sSTATE,1,32), sERRTEXT,
        SYS_CONTEXT ('USERENV', 'HOST'),SYS_CONTEXT ('USERENV', 'OS_USER'),SYS_CONTEXT ('USERENV', 'SESSIONID'),SYS_CONTEXT ('USERENV', 'SESSION_USER'),
        nUSER_PROCESS
        );
      commit;
    
  end P_INS_LOG;
/