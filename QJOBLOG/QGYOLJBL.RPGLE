      /IF NOT DEFINED(QGYOLJBL)
      /DEFINE QGYOLJBL
      *
      *  Open List of Job Log Messages (QGYOLJBL) API
     D QGYOLJBL...
     D                 PR                  extpgm('QGYOLJBL')
     D  o_rcvVar                  65535A          options(*varsize)
     D  i_lenRcvVar                  10I 0 const
     D  o_listInf                    80A
     D  i_numRcdsRtn                 10I 0 const
     D  i_msgSlcInf               65535A   const  options(*varsize)
     D  i_lenMsgSlcInf...
     D                               10I 0 const
     D  io_errCode                65535A          options(*nopass: *varsize)
      *
      *  OLJL0100 Format
     D oljl0100_t...
     D                 DS                  qualified based(pDummy)
     D  ofsNxtEntry                  10I 0
     D  ofsFldsRtn                   10I 0
     D  numFldsRtn                   10I 0
     D  msgSeverity                  10I 0
     D  msgID                         7A
     D  msgType                       2A
     D  msgKey                        4A
     D  msgFile                      10A
     D  msgFLibSpcfd                 10A
     D  dateSnd                       7A
     D  timeSnd                       6A
     D  mSecs                         6A
     D  threadId                      8A
      *  Reserved                                         CHAR(*)
      *  Offset to the next field information returned    BINARY(4)
      *  Length of field information returned             BINARY(4)
      *  Identifier field                                 BINARY(4)
      *  Type of data                                     CHAR(1)
      *  Status of data                                   CHAR(1)
      *  Reserved                                         CHAR(14)
      *  Length of data                                   BINARY(4)
      *  Data                                             CHAR(*)
      *  Reserved                                         CHAR(14)
      *
     D oljl0100_fieldInf_t...
     D                 DS                  qualified based(pDummy)
     D  ofsNxtFldInf                 10I 0
     D  lenFldInf                    10I 0
     D  fieldId                      10I 0
     D  dataType                      1A
     D  dataSts                       1A
     D  reserved                     14A
     D  lenData                      10I 0
      *  Data                                             CHAR(*)
      *  reserved                                         CHAR(*)
      *
      *  Message Selection Information Format
     D QGYOLJBL_msgSlcInf...
     D                 DS                  qualified based(pDummy)
     D  listDirection                10A
     D  qJob                               likeds(qJob_t)
     D  intJobID                     16A
     D  strMsgKey                     4A
     D  maxMsgLen                    10I 0
     D  maxMsgHlpLen                 10I 0
     D  ofsFldsIdnRtn                10I 0
     D  numFldsRtn                   10I 0
     D  ofsCallMsgQNm                10I 0
     D  lenMsgQNm                    10I 0
      *  Identifiers of fields to return         ARRAY(*) of BINARY(4)
      *  Call message queue name                 CHAR(*)
      *
      *  Valid Field Identifiers
     D QGYOLJBL_ALERT_OPTION...
     D                 C                         0101
     D QGYOLJBL_RPLC_DATA...
     D                 C                         0201
     D QGYOLJBL_MSG...
     D                 C                         0301
     D QGYOLJBL_MSG_WITH_RPLC_DATA...
     D                 C                         0302
     D QGYOLJBL_MSG_HLP...
     D                 C                         0401
     D QGYOLJBL_MSG_HLP_WITH_RPLC_DATA...
     D                 C                         0402
     D QGYOLJBL_MSG_HLP_WITH_FMT_CHARS...
     D                 C                         0403
     D QGYOLJBL_MSG_HLP_WITH_RPLC_DATA_AND_FMT_CHARS...
     D                 C                         0404
     D QGYOLJBL_DDT_RPLY...
     D                 C                         0501
     D QGYOLJBL_QSND_JOB...
     D                 C                         0601
     D QGYOLJBL_SND_TYPE...
     D                 C                         0602
     D QGYOLJBL_SND_PGM...
     D                 C                         0603
     D QGYOLJBL_SND_MODULE...
     D                 C                         0604
     D QGYOLJBL_SND_PROC...
     D                 C                         0605
     D QGYOLJBL_SND_STMTS_ARRAY...
     D                 C                         0606
     D QGYOLJBL_SND_USRPRF...
     D                 C                         0607
     D QGYOLJBL_RCV_TYPE...
     D                 C                         0702
     D QGYOLJBL_RCV_PGM...
     D                 C                         0703
     D QGYOLJBL_RCV_MODULE...
     D                 C                         0704
     D QGYOLJBL_RCV_PROC...
     D                 C                         0705
     D QGYOLJBL_RCV_STMTS_ARRAY...
     D                 C                         0706
     D QGYOLJBL_MSGF_LIB...
     D                 C                         0801
     D QGYOLJBL_PRB_ID...
     D                 C                         0901
     D QGYOLJBL_RPLY_STATUS...
     D                 C                         1001
     D QGYOLJBL_REQ_STATUS...
     D                 C                         1101
     D QGYOLJBL_REQ_LEVEL...
     D                 C                         1201
     D QGYOLJBL_CCSID_TEXT...
     D                 C                         1301
     D QGYOLJBL_CCSID_CONV_STATUS_TEXT...
     D                 C                         1302
     D QGYOLJBL_CCSID_DATA...
     D                 C                         1303
     D QGYOLJBL_CCSID_CONV_STATUS_DATA...
     D                 C                         1304
      *
      *   Qualified job name
      /IF NOT DEFINED(qJob_t    )
      /DEFINE qJob_t
     D qJob_t          DS                  qualified           based(pDummy)
     D  name                         10A
     D  user                         10A
     D  nbr                           6A
      /ENDIF
      *
      /ENDIF
