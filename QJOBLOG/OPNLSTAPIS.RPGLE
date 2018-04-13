      /IF NOT DEFINED(OPNLSTAPIS)
      /DEFINE OPNLSTAPIS
      *
      *  Open list information format
     D qgy_opnListInf_t...
     D                 DS                  qualified               based(pDummy)
     D  totalRcds                    10I 0
     D  rcdsRet                      10I 0
     D  hRequest                      4A
     D  rcdLen                       10I 0
     D  infComplInd                   1A
     D  dateTimeCrt                  13A
     D  listStatInd                   1A
     D  reserved_01                   1A
     D  lenInfRet                    10I 0
     D  firstRcdInRcv                10I 0
     D  reserved_02                  40A
      *
      *  Get List Entries (QGYGTLE) API
     D QGYGTLE...
     D                 PR                  extpgm('QGYGTLE')
     D  o_rcvVar                  65535A          options(*varsize)
     D  i_rcvVarLen                  10I 0 const
     D  i_hRequest                    4A   const
     D  o_opnListInf                 80A
     D  i_numRcdRtn                  10I 0 const
     D  i_startRcd                   10I 0 const
     D  io_errCode                65535A          options(*varsize)
      *
      *  Close List (QGYCLST) API
     D QGYCLST...
     D                 PR                  extpgm('QGYCLST')
     D  i_hRequest                    4A   const
     D  io_errCode                65535A          options(*varsize)
      *
      *  List sort information: QGYOLOBJ / QGYOLSPL
     D qgy_sortInf_t...
     D                 DS                  qualified               based(pDummy)
     D  numE                         10I 0
     D  sortInfE                           likeds(qgy_sortInfE_t   )
     D                                     dim(16)
      *
     D qgy_sortInfE_t...
     D                 DS                  qualified               based(pDummy)
     D  startPos                     10I 0
     D  length                       10I 0
     D  dataType                      5I 0
     D  order                         1A
     D  reserved_1                    1A
      *
      /ENDIF
