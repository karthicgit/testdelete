CREATE TABLE FINOPS.OCI_FOCUS_REPORTS
(
  AVAILABILITYZONE            VARCHAR2(100),
  BILLEDCOST                  NUMBER,
  BILLINGACCOUNTID            VARCHAR2(100),
  BILLINGACCOUNTNAME          VARCHAR2(100),
  BILLINGCURRENCY             VARCHAR2(50),
  BILLINGPERIODEND            TIMESTAMP WITH TIME ZONE,
  BILLINGPERIODSTART          TIMESTAMP WITH TIME ZONE,
  CHARGECATEGORY              VARCHAR2(100),
  CHARGEDESCRIPTION           VARCHAR2(4000),
  CHARGEFREQUENCY             VARCHAR2(100),
  CHARGEPERIODEND             TIMESTAMP WITH LOCAL TIME ZONE,
  CHARGEPERIODSTART           TIMESTAMP WITH LOCAL TIME ZONE,
  CHARGESUBCATEGORY           VARCHAR2(50),
  COMMITMENTDISCOUNTCATEGORY  VARCHAR2(10),
  COMMITMENTDISCOUNTID        VARCHAR2(10),
  COMMITMENTDISCOUNTNAME      VARCHAR2(10),
  COMMITMENTDISCOUNTTYPE      VARCHAR2(10),
  EFFECTIVECOST               NUMBER,
  INVOICEISSUER               VARCHAR2(50),
  LISTCOST                    NUMBER,
  LISTUNITPRICE               NUMBER,
  PRICINGCATEGORY             VARCHAR2(10),
  PRICINGQUANTITY             NUMBER,
  PRICINGUNIT                 VARCHAR2(400),
  PROVIDER                    VARCHAR2(50),
  PUBLISHER                   VARCHAR2(1000),
  REGION                      VARCHAR2(50),
  RESOURCEID                  VARCHAR2(1000),
  RESOURCENAME                VARCHAR2(10),
  RESOURCETYPE                VARCHAR2(100),
  SERVICECATEGORY             VARCHAR2(100),
  SERVICENAME                 VARCHAR2(100),
  SKUID                       VARCHAR2(100),
  SKUPRICEID                  VARCHAR2(10),
  SUBACCOUNTID                VARCHAR2(200),
  SUBACCOUNTNAME              VARCHAR2(200),
  TAGS                        VARCHAR2(32767),
  USAGEQUANTITY               NUMBER,
  USAGEUNIT                   VARCHAR2(400),
  OCI_REFERENCENUMBER         VARCHAR2(4000),
  OCI_COMPARTMENTID           VARCHAR2(200),
  OCI_COMPARTMENTNAME         VARCHAR2(200),
  OCI_OVERAGEFLAG             VARCHAR2(100),
  OCI_UNITPRICEOVERAGE        NUMBER,
  OCI_BILLEDQUANTITYOVERAGE   NUMBER,
  OCI_COSTOVERAGE             NUMBER,
  OCI_ATTRIBUTEDUSAGE         NUMBER,
  OCI_ATTRIBUTEDCOST          NUMBER,
  OCI_BACKREFERENCENUMBER     VARCHAR2(4000),
   CONSTRAINT pk_oci_finops PRIMARY KEY (
    CHARGEPERIODSTART,
    SERVICENAME,
    OCI_REFERENCENUMBER
  ) USING INDEX LOCAL 
 
)
PARTITION BY RANGE (CHARGEPERIODSTART)
INTERVAL (NUMTODSINTERVAL(7,'DAY')) -- Automatically creates weekly partitions
(
    -- Initial partition for historical data
    PARTITION p_initial VALUES LESS THAN (TIMESTAMP'2025-01-28 00:00:00 UTC')
)

###pipeline
BEGIN
  dbms_cloud_pipeline.create_pipeline(
      pipeline_name =>'FINOPS_REPORT',
      pipeline_type => 'LOAD',
      description => 'pipeline to load FOCUS report');
END;

-- Set attributes for the dbms_cloud_pipeline.
BEGIN
  DBMS_CLOUD_PIPELINE.SET_ATTRIBUTE(
    pipeline_name => 'FINOPS_REPORT',
    attributes    => JSON_OBJECT(
      'credential_name' VALUE 'OCI$RESOURCE_PRINCIPAL',
      'location'        VALUE 'https://<objectstorageurl>/n/bling/b/<tenancyocid>/o/FOCUS Reports/<year>',
      'table_name'      VALUE 'OCI_FOCUS_REPORTS',
      'field_list'   VALUE q'[
     "AVAILABILITYZONE"            CHAR(4000)
    ,"BILLEDCOST"                  CHAR
    ,"BILLINGACCOUNTID"            CHAR
    ,"BILLINGACCOUNTNAME"          CHAR(32767)
    ,"BILLINGCURRENCY"             CHAR(4000)
    ,"BILLINGPERIODEND"            CHAR date_format TIMESTAMP WITH TIME ZONE MASK "YYYY-MM-DD\"T\"HH24:MI:SS.FF9TZR"
    ,"BILLINGPERIODSTART"          CHAR date_format TIMESTAMP WITH TIME ZONE MASK "YYYY-MM-DD\"T\"HH24:MI:SS.FF9TZR"
    ,"CHARGECATEGORY"              CHAR(4000)
    ,"CHARGEDESCRIPTION"           CHAR(4000)
    ,"CHARGEFREQUENCY"             CHAR(4000)
    ,"CHARGEPERIODEND"             CHAR date_format TIMESTAMP WITH TIME ZONE MASK "YYYY-MM-DD\"T\"HH24:MITZH:TZM"
    ,"CHARGEPERIODSTART"           CHAR date_format TIMESTAMP WITH TIME ZONE MASK "YYYY-MM-DD\"T\"HH24:MITZH:TZM"
    ,"CHARGESUBCATEGORY"           CHAR(32767)
    ,"COMMITMENTDISCOUNTCATEGORY"  CHAR(32767)
    ,"COMMITMENTDISCOUNTID"        CHAR(32767)
    ,"COMMITMENTDISCOUNTNAME"      CHAR(32767)
    ,"COMMITMENTDISCOUNTTYPE"      CHAR(32767)
    ,"EFFECTIVECOST"               CHAR
    ,"INVOICEISSUER"               CHAR(4000)
    ,"LISTCOST"                    CHAR
    ,"LISTUNITPRICE"               CHAR
    ,"PRICINGCATEGORY"             CHAR(32767)
    ,"PRICINGQUANTITY"             CHAR
    ,"PRICINGUNIT"                 CHAR(4000)
    ,"PROVIDER"                    CHAR(4000)
    ,"PUBLISHER"                   CHAR(4000)
    ,"REGION"                      CHAR(4000)
    ,"RESOURCEID"                  CHAR(4000)
    ,"RESOURCENAME"                CHAR(32767)
    ,"RESOURCETYPE"                CHAR(4000)
    ,"SERVICECATEGORY"             CHAR(4000)
    ,"SERVICENAME"                 CHAR(4000)
    ,"SKUID"                       CHAR(4000)
    ,"SKUPRICEID"                  CHAR(32767)
    ,"SUBACCOUNTID"                CHAR(4000)
    ,"SUBACCOUNTNAME"              CHAR(4000)
    ,"TAGS"                        CHAR(32767)
    ,"USAGEQUANTITY"               CHAR
    ,"USAGEUNIT"                   CHAR(4000)
    ,"OCI_REFERENCENUMBER"         CHAR(4000)
    ,"OCI_COMPARTMENTID"           CHAR(4000)
    ,"OCI_COMPARTMENTNAME"         CHAR(4000)
    ,"OCI_OVERAGEFLAG"             CHAR(4000)
    ,"OCI_UNITPRICEOVERAGE"        CHAR
    ,"OCI_BILLEDQUANTITYOVERAGE"   CHAR
    ,"OCI_COSTOVERAGE"             CHAR
    ,"OCI_ATTRIBUTEDUSAGE"         CHAR
    ,"OCI_ATTRIBUTEDCOST"          CHAR
    ,"OCI_BACKREFERENCENUMBER" CHAR]',
    'format'      VALUE '{
         "type": "csv",
         "delimiter" : ",",
         "ignoremissingcolumns" : true,
         "ignoreblanklines" : true,
         "blankasnull" : true,
         "trimspaces" : "lrtrim",
         "quote" : "\"",
         "characterset" : "AL32UTF8",
         "skipheaders" : 1,
         "logprefix" : "FOCUS",
         "logretention" : 7,
         "rejectlimit" : 10000000,
         "recorddelimiter" : "X''0D0A''",
         "compression": "gzip"
         }',
      'priority' VALUE 'HIGH',
      'interval' VALUE '240'
    )
  );
END;

--start the pipeline
begin
  dbms_cloud_pipeline.start_pipeline(
    pipeline_name => 'FINOPS_REPORT'
  );
end;
