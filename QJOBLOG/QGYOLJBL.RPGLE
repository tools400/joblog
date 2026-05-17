**free
/if NOT DEFINED(QGYOLJBL)
/define QGYOLJBL

//  Open List of Job Log Messages (QGYOLJBL) API
dcl-pr QGYOLJBL extpgm('QGYOLJBL');
  o_rcvVar       char(65535) options(*varsize);
  i_lenRcvVar    int(10) const;
  o_listInf      char(80);
  i_numRcdsRtn   int(10) const;
  i_msgSlcInf    char(65535) options(*varsize) const;
  i_lenMsgSlcInf int(10) const;
  io_errCode     char(65535) options(*nopass: *varsize);
end-pr;

//  OLJL0100 Format
dcl-ds oljl0100_t qualified based(pDummy);
  ofsNxtEntry  int(10);
  ofsFldsRtn   int(10);
  numFldsRtn   int(10);
  msgSeverity  int(10);
  msgID        char(7);
  msgType      char(2);
  msgKey       char(4);
  msgFile      char(10);
  msgFLibSpcfd char(10);
  dateSnd      char(7);
  timeSnd      char(6);
  mSecs        char(6);
  threadId     char(8);
end-ds;
//  Reserved                                         CHAR(*)
//  Offset to the next field information returned    BINARY(4)
//  Length of field information returned             BINARY(4)
//  Identifier field                                 BINARY(4)
//  Type of data                                     CHAR(1)
//  Status of data                                   CHAR(1)
//  Reserved                                         CHAR(14)
//  Length of data                                   BINARY(4)
//  Data                                             CHAR(*)
//  Reserved                                         CHAR(14)

dcl-ds oljl0100_fieldInf_t qualified based(pDummy);
  ofsNxtFldInf int(10);
  lenFldInf    int(10);
  fieldId      int(10);
  dataType     char(1);
  dataSts      char(1);
  reserved     char(14);
  lenData      int(10);
end-ds;
//  Data                                             CHAR(*)
//  reserved                                         CHAR(*)

//  Message Selection Information Format
dcl-ds QGYOLJBL_msgSlcInf qualified based(pDummy);
  listDirection char(10);
  qJob          likeds(qJob_t);
  intJobID      char(16);
  strMsgKey     char(4);
  maxMsgLen     int(10);
  maxMsgHlpLen  int(10);
  ofsFldsIdnRtn int(10);
  numFldsRtn    int(10);
  ofsCallMsgQNm int(10);
  lenMsgQNm     int(10);
end-ds;
//  Identifiers of fields to return         ARRAY(*) of BINARY(4)
//  Call message queue name                 CHAR(*)

//  Valid Field Identifiers
dcl-c QGYOLJBL_ALERT_OPTION 0101;
dcl-c QGYOLJBL_RPLC_DATA 0201;
dcl-c QGYOLJBL_MSG 0301;
dcl-c QGYOLJBL_MSG_WITH_RPLC_DATA 0302;
dcl-c QGYOLJBL_MSG_HLP 0401;
dcl-c QGYOLJBL_MSG_HLP_WITH_RPLC_DATA 0402;
dcl-c QGYOLJBL_MSG_HLP_WITH_FMT_CHARS 0403;
dcl-c QGYOLJBL_MSG_HLP_WITH_RPLC_DATA_AND_FMT_CHARS 0404;
dcl-c QGYOLJBL_DDT_RPLY 0501;
dcl-c QGYOLJBL_QSND_JOB 0601;
dcl-c QGYOLJBL_SND_TYPE 0602;
dcl-c QGYOLJBL_SND_PGM 0603;
dcl-c QGYOLJBL_SND_MODULE 0604;
dcl-c QGYOLJBL_SND_PROC 0605;
dcl-c QGYOLJBL_SND_STMTS_ARRAY 0606;
dcl-c QGYOLJBL_SND_USRPRF 0607;
dcl-c QGYOLJBL_RCV_TYPE 0702;
dcl-c QGYOLJBL_RCV_PGM 0703;
dcl-c QGYOLJBL_RCV_MODULE 0704;
dcl-c QGYOLJBL_RCV_PROC 0705;
dcl-c QGYOLJBL_RCV_STMTS_ARRAY 0706;
dcl-c QGYOLJBL_MSGF_LIB 0801;
dcl-c QGYOLJBL_PRB_ID 0901;
dcl-c QGYOLJBL_RPLY_STATUS 1001;
dcl-c QGYOLJBL_REQ_STATUS 1101;
dcl-c QGYOLJBL_REQ_LEVEL 1201;
dcl-c QGYOLJBL_CCSID_TEXT 1301;
dcl-c QGYOLJBL_CCSID_CONV_STATUS_TEXT 1302;
dcl-c QGYOLJBL_CCSID_DATA 1303;
dcl-c QGYOLJBL_CCSID_CONV_STATUS_DATA 1304;

//   Qualified job name
/if NOT DEFINED(qJob_t    )
/define qJob_t
dcl-ds qJob_t qualified based(pDummy);
  name char(10);
  user char(10);
  nbr  char(6);
end-ds;
/endif

/endif
