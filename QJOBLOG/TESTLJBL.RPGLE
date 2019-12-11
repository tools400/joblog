**free
//===============================================================
//  Test Program for PMR TS003090284
//===============================================================
//  PMR: QGYOLJBL does not return CPF3C53 when building
//       the list asynchronously (TS003090284, 4 Dec 2019)
//===============================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<< CRTBNDRPG    PGM(&LI/&OB) +
//                           SRCFILE(&SL/&SF) SRCMBR(&SM) +
//                           DFTACTGRP(*NO) ACTGRP(*NEW) +
//                           DBGVIEW(*LIST) TRUNCNBR(*NO);
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
//---------------------------------------------------------------
//   CRTBNDRPG  PGM(PMR1911.2/TESTLJBL)
//              SRCFILE(PMR1911.2/QSRC) SRCMBR(TESTLJBL)
//              DFTACTGRP(*NO) ACTGRP(*NEW)
//              DBGVIEW(*LIST) TRUNCNBR(*NO)
//===============================================================
ctl-opt main(main);

dcl-pr QGYOLJBL extpgm('QGYOLJBL');
  i_rcvVar char(65535) const options(*varsize);
  i_rcvVarLen int(10) const;
  o_listInf char(80);
  i_numRcdsRtn int(10) const;
  i_msgSlcInf char(65535) const options(*varsize);
  i_sizeMsgSlcInf int(10) const;
  io_errCode char(65535) options(*varsize);
end-pr;

dcl-ds listInf_t qualified template;
  totalRcds int(10);
  rcdsRtn int(10);
  handle char(4);
  rcdLen int(10);
  infComplete char(1);
  dateTimeCrt char(13);
  listStatus char(1);
  reserved_1 char(1);
  lenInfRtn int(10);
  firstRcd int(10);
  reserved_2 char(40);
end-ds;

dcl-ds slcInf_t qualified template;
  direction char(10);
  qJob likeds(qJob_t);
  intJobId char(16);
  strMsgKey char(4);
  maxMsgLen int(10);
  maxMsgHlpLen int(10);
  offsFldsRtn int(10);
  numFldsRtn int(10);
  offsCallMsgQName int(10);
  lenMsgQName int(10);
end-ds;

dcl-s fldId_t int(10) template;
dcl-s callMsgQName_t char(256) template;

dcl-ds qJob_t qualified template;
  name char(10);
  user char(10);
  nbr char(6);
end-ds;

dcl-ds oljl0100_t qualified template;
  offsNext int(10);
  offsFlds int(10);
  numFldsRtn int(10);
  severity int(10);
  id char(7);
  type char(2);
  key char(4);
  msgFile char(10);
  msgFileLib char(10);
  date char(7);
  time char(6);
  mSecs char(6);
  threadId char(8);
end-ds;

dcl-ds errCode_t qualified template;
  bytPrv int(10);
  bytAvl int(10);
  excId char(7);
  reserved_1 char(1);
  excDta char(256);
end-ds;

dcl-pr QGYGTLE extpgm('QGYGTLE');
  i_rcvVar char(65535) const options(*varsize);
  i_rcvVarLen int(10) const;
  i_handle char(4) const;
  o_listInf char(80);
  i_numRcdsRtn int(10) const;
  i_startRcd int(10) const;
  io_errCode char(65535) options(*varsize);
end-pr;

dcl-pr QGYCLST extpgm('QGYCLST');
  i_handle char(4) const;
  io_errCode char(65535) options(*varsize);
end-pr;

dcl-pr main extpgm('TESTLJBL') end-pr;

dcl-proc main;
  dcl-pi *n end-pi;

  dcl-s msgQName varchar(256);
  dcl-s handle char(4);
  dcl-ds qJob likeds(qJob_t);
  dcl-s oljl0100Buffer char(4000);
  dcl-ds oljl0100 likeds(oljl0100_t) based(pOljl0100);
  dcl-ds listInf likeds(listInf_t);
  dcl-s slcInfBuffer char(4000);
  dcl-ds slcInf likeds(slcInf_t) based(pSlcInf);
  dcl-s lenSlcInf int(10);
  dcl-s fldIds like(fldId_t) dim(32) based(pFldId);
  dcl-s callMsgQName like(callMsgQName_t) based(pCallMsgQName);
  dcl-ds errCode likeds(errCode_t);

  msgQName = '*';

  pSlcInf = %addr(slcInfBuffer);

  clear slcInf;
  slcInf.direction = '*PRV';
  slcInf.qJob.name = 'DONALD';
  slcInf.qJob.user = 'DUCK';
  slcInf.qJob.nbr = '123456';
  slcInf.intJobId = '';
  slcInf.strMsgKey = x'FFFFFFFF';
  slcInf.maxMsgLen = 50;
  slcInf.maxMsgHlpLen = 0;
  slcInf.offsFldsRtn = %size(slcInf);
  slcInf.numFldsRtn = 1;
  slcInf.offsCallMsgQName = slcInf.offsFldsRtn + (slcInf.numFldsRtn * %size(fldId_t));
  slcInf.lenMsgQName = %len(msgQName);


  pFldId = pSlcInf + slcInf.offsFldsRtn;
  fldIds(1) = 302;

  pCallMsgQName = pSlcInf + slcInf.offsCallMsgQName;
  callMsgQName = msgQName;

  lenSlcInf = %size(slcInf) + (slcInf.numFldsRtn * %size(fldId_t)) + slcInf.lenMsgQName;

  // =====================================================================
  //  First problem: QGYOLJBL does not return CPF3C53.
  // =====================================================================

  pOljl0100 = %addr(oljl0100Buffer);

  clear errCode;
  errCode.bytPrv = %size(errCode);

  // All records are built asynchronously in the list by a server job.
  QGYOLJBL(oljl0100: %size(oljl0100): listInf: 0: slcInf: lenSlcInf: errCode);
  if (errCode.bytAvl > 0);
     // Statement is never reached.
     dsply ('1.1 Error code is: ' + errCode.excId);
  else;
     // No error, although job not found. Instead error ...
     //   Function check. CPF3C53 unmonitored by QGYLSRVR at statement *N,
     //   instruction X'0117'.
     // ... at next call of QGYGTLE.
     // Expected behavor: QGYOLJBL should return CPF3C53 - Job not found.
  endif;

  handle = listInf.handle;

  QGYGTLE(oljl0100: %size(oljl0100Buffer): handle: listInf: 1: 1: errCode);
  if (errCode.bytAvl > 0);
     // Function check. CPF3C53 unmonitored by QGYLSRVR at statement *N, instruction X'0117'.
     // Error: GUI0115 - The list has been marked in error.
     dsply ('1.2 Error code is: ' + errCode.excId);
  endif;

  QGYCLST(handle: errCode);
  if (errCode.bytAvl > 0);
     dsply ('1.3 Error code is: ' + errCode.excId);
  endif;

  // =====================================================================
  //  Second problem: QGYGTLE and QGYCLST crash with unexpected errors
  //  without any reasons.
  // =====================================================================

  clear errCode;
  errCode.bytPrv = %size(errCode);

  slcInf.qJob.name = '*'; // Get job log of current job
  slcInf.qJob.user = '';
  slcInf.qJob.nbr = '';

  // All records are built asynchronously in the list by a server job.
  QGYOLJBL(oljl0100: %size(oljl0100): listInf: 0: slcInf: lenSlcInf: errCode);
  if (errCode.bytAvl > 0);
     // Statement is never reached.
     dsply ('2.1 Error code is: ' + errCode.excId);
  endif;

  handle = listInf.handle;
  QGYGTLE(oljl0100: %size(oljl0100Buffer): handle: listInf: 1: 1: errCode);
  if (errCode.bytAvl > 0);
     // Error occurred with receiver variable specified.
     // Error: GUI0115 - The list has been marked in error.
     dsply ('2.2 Error code is: ' + errCode.excId);
  endif;

  QGYCLST(handle: errCode); // MCH0601 - Space offset X'40404040' or
                            // X'0000000000000000' is outside current limit ...
  if (errCode.bytAvl > 0);
     // Error: CPF9999 - Function check.
     dsply ('2.3 Error code is: ' + errCode.excId);
  endif;

end-proc;
