**free
/if NOT DEFINED(OPNLSTAPIS)
/define OPNLSTAPIS

//  Open list information format
dcl-ds qgy_opnListInf_t qualified based(pDummy);
  totalRcds     int(10);
  rcdsRet       int(10);
  hRequest      char(4);
  rcdLen        int(10);
  infComplInd   char(1);
  dateTimeCrt   char(13);
  listStatInd   char(1);
  reserved_01   char(1);
  lenInfRet     int(10);
  firstRcdInRcv int(10);
  reserved_02   char(40);
end-ds;

dcl-c QGY_LIST_PENDING '0';
dcl-c QGY_LIST_BEING_BUILT '1';
dcl-c QGY_LIST_COMPLETE '2';
dcl-c QGY_LIST_ERROR '3';
dcl-c QGY_LIST_PRIMED '4';
dcl-c QGY_LIST_TOO_MUCH_DATA '5';

//  Get List Entries (QGYGTLE) API
dcl-pr QGYGTLE extpgm('QGYGTLE');
  o_rcvVar     char(65535) options(*varsize);
  i_rcvVarLen  int(10) const;
  i_hRequest   char(4) const;
  o_opnListInf char(80);
  i_numRcdRtn  int(10) const;
  i_startRcd   int(10) const;
  io_errCode   char(65535) options(*varsize);
end-pr;

//  Close List (QGYCLST) API
dcl-pr QGYCLST extpgm('QGYCLST');
  i_hRequest char(4) const;
  io_errCode char(65535) options(*varsize);
end-pr;

//  List sort information: QGYOLOBJ / QGYOLSPL
dcl-ds qgy_sortInf_t qualified based(pDummy);
  numE     int(10);
  sortInfE likeds(qgy_sortInfE_t) dim(16);
end-ds;

dcl-ds qgy_sortInfE_t qualified based(pDummy);
  startPos   int(10);
  length     int(10);
  dataType   int(5);
  order      char(1);
  reserved_1 char(1);
end-ds;

/endif
