**free
//=====================================================================*
//  Job Log API                                                        *
//=====================================================================*
//  Author  :  Thomas Raddatz                                          *
//  Date    :  19.05.2013                                              *
//  E-mail  :  thomas.raddatz@Tools400.de                              *
//  Homepage:  www.tools400.de                                         *
//=====================================================================*
//                                                                     *
//  This software is free software, you can redistribute it and/or     *
//  modify it under the terms of the GNU General Public License (GPL)  *
//  as published by the Free Software Foundation.                      *
//                                                                     *
//  See GNU General Public License for details.                        *
//          http://www.opensource.org                                  *
//          http://www.opensource.org/licenses/gpl-license.html        *
//                                                                     *
//=====================================================================*
//  History:                                                           *
//                                                                     *
//  Date        Name          Description                              *
//  ----------  ------------  ---------------------------------------  *
//  19.04.2019  Th.Raddatz    Fixed unexpected error because size of   *
//                            buffer 'oljl0100_buffer' was too small.  *
//                                                                     *
//  02.12.2019  Th.Raddatz    Fixed MCH0601 "Space offset is outside   *
//                            current limit" in procedure openJobLog().*
//                            Added JobLog_isComplete().               *
//                            Added parameter i_timeout to             *
//                            JobLog_open() to control whether the     *
//                            list is opened synchronously or          *
//                            asynchronously.                          *
//                                                                     *
//  03.12.2019  Th.Raddatz    Added JobLog_isOpen().                   *
//                            Changed JobLog_open() to discard the     *
//                            handle, if the job log could not be      *
//                            opened.                                  *
//                                                                     *
//  03.12.2019  Th.Raddatz    Changed number of records to be returned *
//                            by QGYOLJBL for asynchronous lists from  *
//                            0 to 1 dues to IBM's response to PMR     *
//                            TS003090284.                             *
//                                                                     *
//=====================================================================*
//   >>PRE-COMPILER<<                                                  *
//     >>CRTCMD<<  CRTRPGMOD   MODULE(&LI/&OB) +                       *
//                             SRCFILE(&SL/&SF) +                      *
//                             SRCMBR(&SM);                            *
//     >>COMPILE<<                                                     *
//       >>PARM<< TRUNCNBR(*NO);                                       *
//       >>PARM<< DBGVIEW(*LIST);                                      *
//       >>PARM<< TGTRLS(V7R1M0  );                                    *
//       >>PARM<< OPTION(*EVENTF);                                     *
//     >>END-COMPILE<<                                                 *
//     >>EXECUTE<<                                                     *
//   >>END-PRE-COMPILER<<                                              *
//=====================================================================*
ctl-opt nomain bnddir('QC2LE');
/copy QJOBLOG,H_SPEC
/copy QJOBLOG,COPYRIGHT
//=====================================================================*
//
// ------------------------------------
//  Constants
// ------------------------------------
dcl-c MSGKEY_NEXT x'00000000';
dcl-c MSGKEY_PREVIOUS x'FFFFFFFF';

// ------------------------------------
//  Type Definitions
// ------------------------------------
dcl-ds handle_t qualified based(pDummy);
  isOpen    ind;
  isEOF     ind;
  isAsync   ind;
  timeout   int(10);
  qJob      likeds(qJob_t);
  direction like(JobLog_direction_t);
  strMsgKey like(JobLog_msgKey_t);
  rcdNbr    int(10);
  listInf   likeds(qgy_opnListInf_t);
  options   likeds(listOptions_t);
end-ds;

dcl-ds listOptions_t qualified based(pDummy);
  isMsg       ind;
  msgSelectId int(10);
  isMsgHelp   ind;
  hlpSelectId int(10);
  isSender    ind;
  isReceiver  ind;
end-ds;

dcl-ds mixedData_t likeds(JobLog_stmts_t);

// ------------------------------------
//  Exported prototypes
// ------------------------------------
/copy QJOBLOG,PJOBLOG

// ------------------------------------
//  Imported prototypes
// ------------------------------------
/copy QJOBLOG,CLIB                          C Runtime Library
/copy QBASICS1,PBASICS1                     Tools/400 Runtime Library

// ------------------------------------
//  Internal prototypes
// ------------------------------------
/copy QJOBLOG,OPNLSTAPIS                    Process Open List APIs
/copy QJOBLOG,QGYOLJBL                      Open List of Job Log Messages (QGYOLJBL) API

//  Opens the job log and returns the first entry.
dcl-pr openJobLog ind extproc('openJobLog');
  i_qJob       likeds(qJob_t) const;
  i_options    like(JobLog_options_t) const;
  i_direction  like(JobLog_direction_t) const;
  i_msgKey     like(JobLog_msgKey_t) const;
  i_numRcdsRtn int(10) const;
  o_listInf    likeds(qgy_opnListInf_t);
  o_options    likeds(listOptions_t);
  o_errCode    likeds(errCode_t);
end-pr;

//  Waits until the specified list is completely built.
dcl-pr waitForListToComplete likeds(qgy_opnListInf_t) extproc('waitForListToComplete');
  i_hRequest like(qgy_opnListInf_t.hRequest) const;
  i_listInf  likeds(qgy_opnListInf_t) const;
  i_timeout  int(10) const;
  o_errCode  likeds(errCode_t);
end-pr;

//  Refreshs the "list information" on the progress of list-building.
dcl-pr refreshListInformation likeds(qgy_opnListInf_t) extproc('refreshListInformation');
  i_listInf likeds(qgy_opnListInf_t) const;
  o_errCode likeds(errCode_t);
end-pr;

//  Returns the next/previous job log entry.
dcl-pr getJobLogEntry likeds(JobLog_jobLogEntry_t) extproc('getJobLogEntry');
  i_hRequest like(qgy_opnListInf_t.hRequest) const;
  i_rcdNbr   int(10) const;
  i_options  likeds(listOptions_t) const;
  io_listInf likeds(qgy_opnListInf_t);
  o_errCode  likeds(errCode_t);
end-pr;

//  Retrieves the character data of the specified field identifier.
dcl-pr getCharData varchar(8192) extproc('getCharData');
  i_buffer  char(65535) options(*varsize);
  i_buffLen int(10) const;
  i_fieldId int(10) const;
end-pr;

//  Retrieves the mixed data of the specified field identifier.
dcl-pr getMixedData likeds(mixedData_t) extproc('getMixedData');
  i_buffer  char(65535) options(*varsize);
  i_buffLen int(10) const;
  i_fieldId int(10) const;
end-pr;

//  Retrieves the binary data of the specified field identifier.
dcl-pr getBinData int(10) extproc('getBinData');
  i_buffer  char(65535) options(*varsize);
  i_buffLen int(10) const;
  i_fieldId int(10) const;
end-pr;

//  Returns the data buffer of the specified field.
dcl-pr getData varchar(8192) extproc('getData');
  i_buffer  char(65535) options(*varsize);
  i_buffLen int(10) const;
  i_fieldId int(10) const;
end-pr;

//  Returns the default message key for a given direction.
dcl-pr getDftMsgKey like(JobLog_msgKey_t) extproc('getDftMsgKey');
  i_direction like(JobLog_direction_t) const;
end-pr;

//  Returns timestamp the message was send to the job log.
dcl-pr getTimeSent timestamp extproc('getTimeSent');
  i_oljl0100 likeds(oljl0100_t) const;
end-pr;

//  Returns cTrue, when the job associated with a given handle is open.
dcl-pr isOpen ind extproc('isOpen');
  i_pHandle pointer const;
end-pr;

//  Returns cTrue, when the job associated with a given handle is open.
dcl-pr isComplete ind extproc('isComplete');
  i_listInf likeds(qgy_opnListInf_t) const;
end-pr;

//  Returns cTrue, when the list is in error.
dcl-pr isError ind extproc('isError');
  i_listInf likeds(qgy_opnListInf_t) const;
end-pr;

//=========================================================================
//  Opens a job log.
//=========================================================================
//  Parameters:
//   i_qJob        - Optional. Job whose job log is opened.
//                   Default: current job
//   i_options     - Optional. Specifies the information that is
//                   retrieved from the job log.
//                   Default: JOBLOG_PREVIOUS
//   i_direction   - Optional. Direction to list the job log messages.
//                   Default: JOBLOG_OPTION_MSG + JOBLOG_OPTION_REPLACE_VARS
//   i_strMsgKey   - Optional. The message key to be used to begin
//                   searching for messages to list from the job.
//                   Default: depending on i_options.
//   i_timeout     - Optional. Wait timeout in seconds.
//                   Default: -1 (list is built synchronously)
//
//  Returns:
//   hJobLog         Handle of the job log.
//=========================================================================
//  See also: PMR TS003090284 (opened 4 Dec 2019)

//  QGYOLJBL does not return CPF3C53 when building the list asynchronously.
//  The first problem is that QGYOLJBL does not return error message
//  CPF3C53 (Job not found), when being called with a job that does not
//  exist.
//  The second problem is that QGYCLST crashes with CPF9999 (MCH0601) when
//  QGYOLJBL and QGYGTLE are called after QGYOLJBL has been called with a
//  non-existing job at the first attempt.
//=========================================================================
dcl-proc JobLog_open export;
  dcl-pi *n like(JobLog_handle_t);
    i_qJob      likeds(qJob_t) options(*nopass: *omit) const;
    i_options   like(JobLog_options_t) options(*nopass: *omit) const;
    i_direction like(JobLog_direction_t) options(*nopass: *omit) const;
    i_strMsgKey like(JobLog_msgKey_t) options(*nopass: *omit) const;
    i_timeout   int(10) options(*nopass: *omit) const;
  end-pi;

  //  Return value
  dcl-s hJobLog like(JobLog_handle_t);

  //  Parameter positions
  dcl-c p_qJob 1;
  dcl-c p_options 2;
  dcl-c p_direction 3;
  dcl-c p_strMsgKey 4;
  dcl-c p_timeout 5;

  //  Optional parameters
  dcl-ds qJob likeds(i_qJob) inz;
  dcl-s options like(i_options) inz;
  dcl-s direction like(i_direction) inz;
  dcl-s strMsgKey like(i_strMsgKey) inz;
  dcl-s timeout like(i_timeout) inz;
  dcl-s numRcdsRtn int(10) inz;

  //  Local fields
  dcl-ds errCode likeds(errCode_t) inz;

  //  Job log handle
  dcl-ds handle likeds(handle_t) based(pHandle);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if (%parms() >= p_qJob and %addr(i_qJob) <> *NULL);
    qJob = i_qJob;
  else;
    qJob.name = '*';
  endif;

  if (%parms() >= p_options and %addr(i_options) <> *NULL);
    options = i_options;
  else;
    options = JOBLOG_OPTION_MSG + JOBLOG_OPTION_REPLACE_VARS;
  endif;

  if (%parms() >= p_direction and %addr(i_direction) <> *NULL);
    direction = i_direction;
  else;
    direction = JOBLOG_PREVIOUS;
  endif;

  if (%parms() >= p_strMsgKey and %addr(i_strMsgKey) <> *NULL);
    strMsgKey = i_strMsgKey;
  else;
    strMsgKey = getDftMsgKey(direction);
  endif;

  if (%parms() >= p_timeout and %addr(i_timeout) <> *NULL);
    timeout = i_timeout;
    if (timeout <= 0);
      timeout = -1;
    endif;
  else;
    timeout = -1;
  endif;

  hJobLog = HANDLE_new('*JOBLOG': %size(handle_t));
  pHandle = HANDLE_getPointer(hJobLog);

  clear handle;
  handle.isOpen = cFalse;
  handle.isEOF = cTrue;
  handle.isAsync = (timeOut > 0);
  handle.timeout = timeout;
  handle.qJob = qJob;
  handle.direction = direction;
  handle.strMsgKey = strMsgKey;
  handle.rcdNbr = 0;
  clear handle.listInf;

  if (handle.isAsync);
    // Return 1 record immediately due to PMR TS003090284
    numRcdsRtn = 1;  // All records are built asynchronously
  // numRcdsRtn = 0;  // All records are built asynchronously
  else;
    numRcdsRtn = -1; // All records are built synchronously
  endif;

  handle.isOpen = openJobLog(
                     handle.qJob: options: handle.direction
                     : handle.strMsgKey: numRcdsRtn
                     : handle.listInf : handle.options: errCode);

  if (handle.isOpen);
    handle.isEOF = cFalse;
  else;
    JobLog_close(hJobLog);
  endif;

  return hJobLog;

end-proc;

//=========================================================================
//  Closes a given job log.
//=========================================================================
//  Parameters:
//   io_hJobLog    - Required. Handle that was returned by JobLog_open().
//
//  Returns:
//   void
//=========================================================================
dcl-proc JobLog_close export;
  dcl-pi *n;
    io_hJobLog like(JobLog_handle_t);
  end-pi;

  //  Local fields
  dcl-ds errCode likeds(errCode_t) inz;

  //  Job log handle
  dcl-ds handle likeds(handle_t) based(pHandle);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  pHandle = HANDLE_getPointer(io_hJobLog);
  if (isOpen(pHandle));
    QGYCLST(handle.listInf.hRequest: errCode);
    handle.isOpen = cFalse;
  endif;

  HANDLE_delete(io_hJobLog);
  io_hJobLog = HANDLE_NULL;

end-proc;

//=========================================================================
//  Returns cTrue when the list has been opened.
//=========================================================================
//  Parameters:
//   i_hJobLog     - Required. Handle that was returned by JobLog_open().
//
//  Returns:
//   isOpen        - Contains cTrue when the list has been opened,
//                   else cFalse.
//=========================================================================
dcl-proc JobLog_isOpen export;
  dcl-pi *n ind;
    i_hJobLog like(JobLog_handle_t) const;
  end-pi;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return isOpen(HANDLE_getPointer(i_hJobLog));

end-proc;

//=========================================================================
//  Returns cTrue when the list has been completly built.
//=========================================================================
//  Parameters:
//   io_hJobLog    - Required. Handle that was returned by JobLog_open().
//
//  Returns:
//   isComplete    - Contains cTrue when the list has been completely
//                   built, else cFalse.
//=========================================================================
dcl-proc JobLog_isComplete export;
  dcl-pi *n ind;
    i_hJobLog like(JobLog_handle_t) const;
  end-pi;

  //  Return value
  dcl-s isCompleteLcl ind;

  //  Local fields
  dcl-ds listInf likeds(qgy_opnListInf_t) inz;
  dcl-ds errCode likeds(errCode_t) inz;

  //  Job log handle
  dcl-ds handle likeds(handle_t) based(pHandle);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if (not isOpen(HANDLE_getPointer(i_hJobLog)));
    return cFalse;
  endif;

  listInf = refreshListInformation(handle.listInf: errCode);

  isCompleteLcl = isComplete(listInf.listStatInd);

  return isCompleteLcl;

end-proc;

//=========================================================================
//  Returns the next job log entry.
//=========================================================================
//  Parameters:
//   i_hJobLog     - Required. Handle that was returned by JobLog_open().
//   o_jobLogEntry - Required.
//
//  Returns:
//   hasData       - Returns cTrue if a job log entry is available,
//                   else cFalse.
//=========================================================================
dcl-proc JobLog_getEntry export;
  dcl-pi *n ind;
    i_hJobLog     like(JobLog_handle_t) const;
    o_jobLogEntry likeds(JobLog_jobLogEntry_t);
  end-pi;

  //  Local fields
  dcl-ds errCode likeds(errCode_t) inz;

  //  Job log handle
  dcl-ds handle likeds(handle_t) based(pHandle);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  pHandle = HANDLE_getPointer(i_hJobLog);
  if (not isOpen(pHandle));
    return cFalse;
  endif;

  if (handle.isEOF);
    return cFalse;
  endif;

  if (handle.isAsync);
    handle.listInf = waitForListToComplete(
                        handle.listInf.hRequest: handle.listInf
                        : handle.timeout: errCode);
    if (f_isApiError(errCode) or not isComplete(handle.listInf));
      return cFalse;
    endif;
  endif;

  o_jobLogEntry = getJobLogEntry(handle.listInf.hRequest
                                 : handle.rcdNbr + 1
                                 : handle.options
                                 : handle.listInf
                                 : errCode);
  if (f_isApiError(errCode));
    return cFalse;
  endif;

  handle.rcdNbr = handle.rcdNbr + 1;

  if (handle.rcdNbr >= handle.listInf.totalRcds);
    handle.isEOF = cTrue;
  endif;

  return cTrue;

end-proc;

//=========================================================================
//  Returns the newest job log entry.
//=========================================================================
//  Parameters:
//   i_qJob        - Optional. Full qualified name of the job whose
//                   newest job log entry is returned.
//   o_jobLogEntry - Required. Newest job log entry of the specified job.
//
//  Returns:
//   isAvailable   - Returns cTrue on success, else cFalse.
//=========================================================================
dcl-proc JobLog_getNewest export;
  dcl-pi *n ind;
    i_qJob        likeds(qJob_t) options(*omit) const;
    o_jobLogEntry likeds(JobLog_jobLogEntry_t);
  end-pi;

  //  Return value
  dcl-s isAvailable ind inz(cFalse);

  //  Parameter positions
  dcl-c p_qJob 1;

  //  Optional parameters
  dcl-ds qJob likeds(i_qJob) inz;

  //  Local fields
  dcl-ds listInf likeds(qgy_opnListInf_t) inz;
  dcl-ds options likeds(listOptions_t) inz;
  dcl-ds errCode likeds(errCode_t) inz;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if (%parms() >= p_qJob and %addr(i_qJob) <> *NULL);
    qJob = i_qJob;
  else;
    qJob.name = '*';
  endif;

  isAvailable = cFalse;

  // Build list asynchronously, but retrieve 1 record synchronously
  if (openJobLog(qJob
                 : JOBLOG_OPTION_MSG + JOBLOG_OPTION_REPLACE_VARS
                 : JOBLOG_PREVIOUS: getDftMsgKey(JOBLOG_PREVIOUS): 1
                 : listInf: options: errCode));
    o_jobLogEntry = getJobLogEntry(
                       listInf.hRequest: 1: options: listInf: errCode);
    if (listInf.RcdsRet > 0);
      isAvailable = cTrue;
    endif;
    QGYCLST(listInf.hRequest: errCode); // Close list
  endif;

  return isAvailable;

end-proc;

//=========================================================================
//  Returns the oldest job log entry.
//=========================================================================
//  Parameters:
//   i_qJob        - Optional. Full qualified name of the job whose
//                   oldest job log entry is returned.
//   o_jobLogEntry - Required. Oldest job log entry of the specified job.
//
//  Returns:
//   isAvailable   - Returns cTrue on success, else cFalse.
//=========================================================================
dcl-proc JobLog_getOldest export;
  dcl-pi *n ind;
    i_qJob        likeds(qJob_t) options(*omit) const;
    o_jobLogEntry likeds(JobLog_jobLogEntry_t);
  end-pi;

  //  Return value
  dcl-s isAvailable ind inz(cFalse);

  //  Parameter positions
  dcl-c p_qJob 1;

  //  Optional parameters
  dcl-ds qJob likeds(i_qJob) inz;

  //  Local fields
  dcl-ds listInf likeds(qgy_opnListInf_t) inz;
  dcl-ds options likeds(listOptions_t) inz;
  dcl-ds errCode likeds(errCode_t) inz;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if (%parms() >= p_qJob and %addr(i_qJob) <> *NULL);
    qJob = i_qJob;
  else;
    qJob.name = '*';
  endif;

  isAvailable = cFalse;

  // Build list asynchronously, but retrieve 1 record synchronously
  if (openJobLog(qJob
                 : JOBLOG_OPTION_MSG + JOBLOG_OPTION_REPLACE_VARS
                 : JOBLOG_NEXT: getDftMsgKey(JOBLOG_NEXT): 1
                 : listInf: options: errCode));
    o_jobLogEntry = getJobLogEntry(
                       listInf.hRequest: 1: options: listInf: errCode);
    if (listInf.RcdsRet > 0);
      isAvailable = cTrue;
    endif;
    QGYCLST(listInf.hRequest: errCode); // Close list
  endif;

  return isAvailable;

end-proc;

//=========================================================================
//  Returns the message type of a given job log entry.
//=========================================================================
//  Parameters:
//   job log entry - Job log entry returned by:
//                      JobLog_getEntry()
//                      JobLog_getNewest()
//                      JobLog_getOldest()
//
//  Returns:
//   msgType       - Message type
//=========================================================================
dcl-proc JobLog_getMessageType export;
  dcl-pi *n char(10);
    i_jobLogEntry likeds(JobLog_jobLogEntry_t) const;
  end-pi;

  dcl-s msgType char(10) inz;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  select;
  when (i_jobLogEntry.msgType = '01');
    msgType = '*COMP';
  when (i_jobLogEntry.msgType = '02');
    msgType = '*DIAG';
  when (i_jobLogEntry.msgType = '04');
    msgType = '*INFO';
  when (i_jobLogEntry.msgType = '05');
    msgType = '*INQ';
  when (i_jobLogEntry.msgType = '06');
    msgType = '*COPY';
  when (i_jobLogEntry.msgType = '08');
    msgType = '*RQS';
  when (i_jobLogEntry.msgType = '10');
    msgType = '*RQS';
  when (i_jobLogEntry.msgType = '14');
    msgType = '*NOTIFY';
  when (i_jobLogEntry.msgType = '15');
    msgType = '*ESCAPE';
  when (i_jobLogEntry.msgType = '16');
    msgType = '*NOTIFY';
  when (i_jobLogEntry.msgType = '17');
    msgType = '*ESCAPE';
  when (i_jobLogEntry.msgType = '21');
    msgType = '*REPLY';
  when (i_jobLogEntry.msgType = '22');
    msgType = '*REPLY';
  when (i_jobLogEntry.msgType = '23');
    msgType = '*REPLY';
  when (i_jobLogEntry.msgType = '24');
    msgType = '*REPLY';
  when (i_jobLogEntry.msgType = '25');
    msgType = '*REPLY';
  when (i_jobLogEntry.msgType = '26');
    msgType = '*REPLY';
  other;
    msgType = '*N';
  endsl;

  return msgType;

end-proc;

//=========================================================================
//  Returns cTrue if a given job log handle is NULL, else cFalse.
//=========================================================================
//  Parameters:
//   i_hJobLog     - Required. Job log handle.
//
//  Returns:
//   isNull        - Returns cTrue for a NULL handle, else cFalse.
//=========================================================================
dcl-proc JobLog_isNull export;
  dcl-pi *n ind;
    i_hJobLog like(JobLog_handle_t);
  end-pi;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return Handle_isNull(i_hJobLog);

end-proc;

//=========================================================================
//  Returns a NULL job log handle.
//=========================================================================
//  Parameters:
//   void
//
//  Returns:
//   handle        - A job log handle that is treated as NULL.
//=========================================================================
dcl-proc JobLog_null export;
  dcl-pi *n like(JobLog_handle_t);
  end-pi;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return Handle_null();

end-proc;

//=========================================================================
//  Opens the job log.
//=========================================================================
dcl-proc openJobLog;
  dcl-pi *n ind;
    i_qJob       likeds(qJob_t) const;
    i_options    like(JobLog_options_t) const;
    i_direction  like(JobLog_direction_t) const;
    i_msgKey     like(JobLog_msgKey_t) const;
    i_numRcdsRtn int(10) const;
    o_listInf    likeds(qgy_opnListInf_t);
    o_options    likeds(listOptions_t);
    o_errCode    likeds(errCode_t);
  end-pi;

  //  Return value
  dcl-s isOpen ind inz(cFalse);

  //  Local fields
  dcl-s buffSize int(10) inz;
  dcl-s buffer char(65535) based(pBuffer);
  dcl-s offs int(10) inz;

  dcl-ds slcInf likeds(QGYOLJBL_msgSlcInf);
  dcl-s sizeSlcInf int(10) inz;

  dcl-s numFldsRtn int(10) inz;
  dcl-ds fldsToRtn;
    fldRtn int(10) dim(32);
  end-ds;
  dcl-s sizeFldsRtn int(10) inz;

  dcl-s callMsgQ char(4) inz;
  dcl-s sizeCallMsgQ int(10) inz;

  dcl-s oljl0100_buffer char(8192);
  dcl-ds oljl0100 likeds(oljl0100_t) based(pOljl0100);
  dcl-s pOljl0100 pointer inz(%addr(oljl0100_buffer));
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  numFldsRtn = 0;
  clear o_options;

  // Return message text (first-level message text)
  if (f_isBitOn(JOBLOG_OPTION_MSG: i_options));
    o_options.isMsg = cTrue;
    numFldsRtn += 1;
    if (f_isBitOn(JOBLOG_OPTION_REPLACE_VARS: i_options));
      fldRtn(numFldsRtn) = QGYOLJBL_MSG_WITH_RPLC_DATA;
    else;
      fldRtn(numFldsRtn) = QGYOLJBL_MSG;
    endif;
    o_options.msgSelectId = fldRtn(numFldsRtn);
  endif;

  // Return message help (second-level message text)
  if (f_isBitOn(JOBLOG_OPTION_MSG_HELP: i_options));
    o_options.isMsgHelp = cTrue;
    numFldsRtn += 1;
    select;
    when (f_isBitOn(JOBLOG_OPTION_REPLACE_VARS: i_options) and
          f_isBitOn(JOBLOG_OPTION_RETURN_CTRL_CHARS: i_options));
      fldRtn(numFldsRtn)=QGYOLJBL_MSG_HLP_WITH_RPLC_DATA_AND_FMT_CHARS;
    when (f_isBitOn(JOBLOG_OPTION_REPLACE_VARS: i_options));
      fldRtn(numFldsRtn)=QGYOLJBL_MSG_HLP_WITH_RPLC_DATA;
    when (f_isBitOn(JOBLOG_OPTION_RETURN_CTRL_CHARS: i_options));
      fldRtn(numFldsRtn)=QGYOLJBL_MSG_HLP_WITH_FMT_CHARS;
    other;
      fldRtn(numFldsRtn)=QGYOLJBL_MSG_HLP;
    endsl;
    o_options.hlpSelectId = fldRtn(numFldsRtn);
  endif;

  // Return replacement data
  numFldsRtn += 1;
  fldRtn(numFldsRtn) = QGYOLJBL_RPLC_DATA;

  // Return message file library used
  numFldsRtn += 1;
  fldRtn(numFldsRtn) = QGYOLJBL_MSGF_LIB;

  // Return sender information
  if (f_isBitOn(JOBLOG_OPTION_SENDER: i_options));
    o_options.isSender = cTrue;
    numFldsRtn += 1;
    fldRtn(numFldsRtn) = QGYOLJBL_QSND_JOB;   // Sending job
    numFldsRtn += 1;
    fldRtn(numFldsRtn) = QGYOLJBL_SND_TYPE;   // Sending type
    numFldsRtn += 1;
    fldRtn(numFldsRtn) = QGYOLJBL_SND_PGM;    // Sending program
    numFldsRtn += 1;
    fldRtn(numFldsRtn) = QGYOLJBL_SND_MODULE; // Sending module
    numFldsRtn += 1;
    fldRtn(numFldsRtn) = QGYOLJBL_SND_PROC;   // Sending procedure
    numFldsRtn += 1;
    fldRtn(numFldsRtn) = QGYOLJBL_SND_STMTS_ARRAY; // Send. stmts array
    numFldsRtn += 1;
    fldRtn(numFldsRtn) = QGYOLJBL_SND_USRPRF; // Sending suer profile
  else;
    o_options.isSender = cFalse;
  endif;

  // Return receiver information
  if (f_isBitOn(JOBLOG_OPTION_RECEIVER: i_options));
    o_options.isReceiver = cTrue;
    numFldsRtn += 1;
    fldRtn(numFldsRtn) = QGYOLJBL_RCV_TYPE;   // Receiving type
    numFldsRtn += 1;
    fldRtn(numFldsRtn) = QGYOLJBL_RCV_PGM;    // Receiving program
    numFldsRtn += 1;
    fldRtn(numFldsRtn) = QGYOLJBL_RCV_MODULE; // Receiving module
    numFldsRtn += 1;
    fldRtn(numFldsRtn) = QGYOLJBL_RCV_PROC;   // Receiving procedure
    numFldsRtn += 1;
    fldRtn(numFldsRtn) = QGYOLJBL_RCV_STMTS_ARRAY; // Recv. stmts array
  else;
    o_options.isReceiver = cFalse;
  endif;

  callMsgQ = '*';

  sizeSlcInf = %size(slcInf);
  sizeFldsRtn = numFldsRtn * 4;
  sizeCallMsgQ = %len(%trimR(callMsgQ));

  // Prepare selection information
  clear slcInf;
  slcInf.listDirection = i_direction;
  slcInf.qJob = i_qJob;
  slcInf.intJobID = '';
  slcInf.strMsgKey = i_msgKey;
  slcInf.maxMsgLen = JOBLOG_MAX_MSG_TEXT_LEN;
  slcInf.maxMsgHlpLen = 0;
  slcInf.ofsFldsIdnRtn = %size(slcInf);
  slcInf.numFldsRtn = numFldsRtn;
  slcInf.ofsCallMsgQNm = %size(slcInf) + sizeFldsRtn;
  slcInf.lenMsgQNm = 1;

  // Calculate buffer size of selection information
  buffSize = sizeSlcInf + sizeFldsRtn + sizeCallMsgQ;

  pBuffer = %alloc(buffSize);
  offs = 0;
  memcpy(pBuffer + offs: %addr(slcInf): %size(slcInf));
  offs = offs + %size(slcInf);
  memcpy(pBuffer + offs: %addr(fldsToRtn): sizeFldsRtn);
  offs = offs + sizeFldsRtn;
  memcpy(pBuffer + offs: %addr(callMsgQ): sizeCallMsgQ);
  offs = offs + sizeCallMsgQ;

  clear o_errCode;
  o_errCode.bytPrv = %size(o_errCode);

  QGYOLJBL(oljl0100_buffer: %size(oljl0100_buffer): o_listInf
           : i_numRcdsRtn
           : %subst(buffer: 1: buffSize)
           : buffSize
           : o_errCode);

  if (pBuffer <> *NULL);
    dealloc(N) pBuffer;
  endif;

  if (f_isApiError(o_errCode));
    isOpen = cFalse;
  else;
    isOpen = cTrue;
  endif;

  return isOpen;

end-proc;

//=========================================================================
//  Waits until the specified list is completely built.
//=========================================================================
dcl-proc waitForListToComplete;
  dcl-pi *n likeds(qgy_opnListInf_t);
    i_hRequest like(qgy_opnListInf_t.hRequest) const;
    i_listInf  likeds(qgy_opnListInf_t) const;
    i_timeout  int(10) const;
    o_errCode  likeds(errCode_t);
  end-pi;

  //  Return value
  dcl-ds listInf likeds(qgy_opnListInf_t) inz;

  //  Local fields
  dcl-s waitTime int(10);
  dcl-s maxTimestamp timestamp;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  listInf = i_listInf;
  maxTimestamp = %timestamp() + %seconds(i_timeout);
  waitTime = 0;

  dow (not isComplete(listInf) and
       not isError(listInf) and
       %timestamp() < maxTimestamp);

    p_wait(waitTime); // Wait 1 second
    waitTime = 1;

    listInf = refreshListInformation(listInf: o_errCode);

  enddo;

  return listInf;

end-proc;

//=========================================================================
//  Refreshs the "list information" on the progress of list-building.
//=========================================================================
dcl-proc refreshListInformation;
  dcl-pi *n likeds(qgy_opnListInf_t);
    i_listInf likeds(qgy_opnListInf_t) const;
    o_errCode likeds(errCode_t);
  end-pi;

  //  Return value
  dcl-ds listInf likeds(qgy_opnListInf_t) inz;

  //  Local fields
  dcl-ds rtnVal qualified inz;
    ofsNxtEntry int(10);
    ofsFldsRtn  int(10);
  end-ds;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  clear o_errCode;
  o_errCode.bytPrv = %size(o_errCode);

  QGYGTLE(rtnVal: %size(rtnVal)
          : i_listInf.hRequest: listInf: 0: 0: o_errCode);

  if (f_isApiError(o_errCode));
    listInf = i_listInf;
    listInf.infComplInd = 'C';
    listInf.listStatInd = QGY_LIST_ERROR;
  endif;

  return listInf;

end-proc;

//=========================================================================
//  Returns the next/previous job log entry.
//=========================================================================
dcl-proc getJobLogEntry;
  dcl-pi *n likeds(JobLog_jobLogEntry_t);
    i_hRequest like(qgy_opnListInf_t.hRequest) const;
    i_rcdNbr   int(10) const;
    i_options  likeds(listOptions_t) const;
    io_listInf likeds(qgy_opnListInf_t);
    o_errCode  likeds(errCode_t);
  end-pi;

  //  Return value
  dcl-ds jobLogEntry likeds(JobLog_jobLogEntry_t) inz;

  //  Local fields
  dcl-s oljl0100_buffer char(24576);
  dcl-ds oljl0100 likeds(oljl0100_t) based(pOljl0100);
  dcl-s pOljl0100 pointer inz(%addr(oljl0100_buffer));
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  QGYGTLE(oljl0100_buffer: %size(oljl0100_buffer)
          : i_hRequest: io_listInf: 1: i_rcdNbr: o_errCode);

  clear jobLogEntry;

  if (o_errCode.bytAvl > 0);
    return jobLogEntry;
  endif;

  jobLogEntry.msgSeverity = oljl0100.msgSeverity;
  jobLogEntry.msgID = oljl0100.msgID;
  jobLogEntry.msgType = oljl0100.msgType;
  jobLogEntry.msgKey = oljl0100.msgKey;
  jobLogEntry.msgFile = oljl0100.msgFile;
  jobLogEntry.msgFLibSpcfd = oljl0100.msgFLibSpcfd;
  jobLogEntry.msgFLibUsed = getCharData(oljl0100_buffer
                                        : %size(oljl0100_buffer)
                                        : QGYOLJBL_MSGF_LIB);
  jobLogEntry.timeSent = getTimeSent(oljl0100);
  jobLogEntry.threadId = oljl0100.threadId;

  jobLogEntry.rplcData = getCharData(oljl0100_buffer
                                     : %size(oljl0100_buffer)
                                     : QGYOLJBL_RPLC_DATA);

  if (i_options.isMsg);
    jobLogEntry.msgText = getCharData(oljl0100_buffer
                                      : %size(oljl0100_buffer)
                                      : i_options.msgSelectId);
  endif;

  if (i_options.isMsgHelp);
    jobLogEntry.msgHelp = getCharData(oljl0100_buffer
                                      : %size(oljl0100_buffer)
                                      : i_options.hlpSelectId);
  endif;

  if (i_options.isSender);
    jobLogEntry.sender.job =
          getCharData(oljl0100_buffer: %size(oljl0100_buffer)
                      : QGYOLJBL_QSND_JOB);
    jobLogEntry.sender.type =
          getCharData(oljl0100_buffer: %size(oljl0100_buffer)
                      : QGYOLJBL_SND_TYPE);
    jobLogEntry.sender.pgm =
          getCharData(oljl0100_buffer: %size(oljl0100_buffer)
                      : QGYOLJBL_SND_PGM);
    jobLogEntry.sender.mod =
          getCharData(oljl0100_buffer: %size(oljl0100_buffer)
                      : QGYOLJBL_SND_MODULE);
    jobLogEntry.sender.proc =
          getCharData(oljl0100_buffer: %size(oljl0100_buffer)
                      : QGYOLJBL_SND_PROC);
    jobLogEntry.sender.stmts =
          getMixedData(oljl0100_buffer: %size(oljl0100_buffer)
                       : QGYOLJBL_SND_STMTS_ARRAY);
    jobLogEntry.sender.usrPrf =
          getCharData(oljl0100_buffer: %size(oljl0100_buffer)
                      : QGYOLJBL_SND_USRPRF);
  endif;

  if (i_options.isReceiver);
    jobLogEntry.receiver.type =
          getCharData(oljl0100_buffer: %size(oljl0100_buffer)
                      : QGYOLJBL_RCV_TYPE);
    jobLogEntry.receiver.pgm =
          getCharData(oljl0100_buffer: %size(oljl0100_buffer)
                      : QGYOLJBL_RCV_PGM);
    jobLogEntry.receiver.mod =
          getCharData(oljl0100_buffer: %size(oljl0100_buffer)
                      : QGYOLJBL_RCV_MODULE);
    jobLogEntry.receiver.proc =
          getCharData(oljl0100_buffer: %size(oljl0100_buffer)
                      : QGYOLJBL_RCV_PROC);
    jobLogEntry.receiver.stmts =
          getMixedData(oljl0100_buffer: %size(oljl0100_buffer)
                       : QGYOLJBL_RCV_STMTS_ARRAY);
  endif;

  return jobLogEntry;

end-proc;

//=========================================================================
//  Retrieves the character data of the specified field identifier.
//=========================================================================
dcl-proc getCharData;
  dcl-pi *n varchar(8192);
    i_buffer  char(65535) options(*varsize);
    i_buffLen int(10) const;
    i_fieldId int(10) const;
  end-pi;

  //  Return value
  dcl-s fieldData varchar(8192) inz;

  dcl-s lenData int(10);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  p_assert(i_fieldId =  101 or i_fieldId =  201 or
           i_fieldId =  301 or i_fieldId =  302 or
           i_fieldId =  401 or i_fieldId =  402 or
           i_fieldId =  403 or i_fieldId =  404 or
           i_fieldId =  501 or i_fieldId =  601 or
           i_fieldId =  602 or i_fieldId =  603 or
           i_fieldId =  604 or i_fieldId =  605 or
           i_fieldId =  607 or i_fieldId =  702 or
           i_fieldId =  703 or i_fieldId =  704 or
           i_fieldId =  705 or i_fieldId =  801 or
           i_fieldId =  901 or i_fieldId = 1001 or
           i_fieldId = 1101
  : 'Illegal procedure call for field with id: ' + %char(i_fieldId));

  fieldData = getData(i_buffer: i_buffLen: i_fieldId);

  return fieldData;

end-proc;

//=========================================================================
//  Retrieves the mixed data of the specified field identifier.
//=========================================================================
dcl-proc getMixedData;
  dcl-pi *n likeds(mixedData_t);
    i_buffer  char(65535) options(*varsize);
    i_buffLen int(10) const;
    i_fieldId int(10) const;
  end-pi;

  //  Return value
  dcl-ds fieldData likeds(mixedData_t);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  p_assert(i_fieldId = 606 or i_fieldId = 706
  : 'Illegal procedure call for field with id: ' + %char(i_fieldId));

  fieldData = getData(i_buffer: i_buffLen: i_fieldId);

  return fieldData;

end-proc;

//=========================================================================
//  Retrieves the binary data of the specified field identifier.
//=========================================================================
dcl-proc getBinData;
  dcl-pi *n int(10);
    i_buffer  char(65535) options(*varsize);
    i_buffLen int(10) const;
    i_fieldId int(10) const;
  end-pi;

  //  Return value
  dcl-s fieldData int(10) inz;

  //  Local fields
  dcl-ds charBuffer qualified;
    toBinValue int(10);
  end-ds;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  p_assert(i_fieldId = 1201 or i_fieldId = 1301 or
           i_fieldId = 1302 or i_fieldId = 1303 or
           i_fieldId = 1304
  : 'Illegal procedure call for field with id: ' + %char(i_fieldId));

  charBuffer = getData(i_buffer: i_buffLen: i_fieldId);
  fieldData = charBuffer.toBinValue;

  return fieldData;

end-proc;

//=========================================================================
//  Returns the data buffer of the specified field.
//=========================================================================
dcl-proc getData;
  dcl-pi *n varchar(8192);
    i_buffer  char(65535) options(*varsize);
    i_buffLen int(10) const;
    i_fieldId int(10) const;
  end-pi;

  //  Return value
  dcl-s fieldData varchar(8192) inz;

  //  Local fields
  dcl-ds oljl0100 likeds(oljl0100_t) based(pOljl0100);
  dcl-ds fieldInf likeds(oljl0100_fieldInf_t) based(pFieldInf);
  dcl-s data char(8192) based(pData);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  pOljl0100 = %addr(i_buffer);
  pFieldInf = pOljl0100 + oljl0100.ofsFldsRtn;

  dow (fieldInf.fieldId <> i_fieldId and fieldInf.ofsNxtFldInf <> 0);
    pFieldInf = pOljl0100 + fieldInf.ofsNxtFldInf;
    if (pFieldInf > pOljl0100 + i_buffLen);
      return '*ERR';
    endif;
  enddo;

  if (fieldInf.fieldId = i_fieldId);
    pData = pFieldInf + %size(fieldInf);
    if (fieldInf.lenData <= %len(data));
      fieldData = %subst(data: 1: fieldInf.lenData);
    else;
      fieldData = %subst(data: 1: %len(data));
    endif;
  else;
    fieldData = '';
  endif;

  return fieldData;

end-proc;

//=========================================================================
//  Returns the default message key for a given direction.
//=========================================================================
dcl-proc getDftMsgKey;
  dcl-pi *n like(JobLog_msgKey_t);
    i_direction like(JobLog_direction_t) const;
  end-pi;

  //  Return value
  dcl-s msgKey like(JobLog_msgKey_t);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if (i_direction = JOBLOG_PREVIOUS);
    msgKey = MSGKEY_PREVIOUS;
  else;
    msgKey = MSGKEY_NEXT;
  endif;

  return msgKey;

end-proc;

//=========================================================================
//  Returns timestamp the message was send to the job log.
//=========================================================================
dcl-proc getTimeSent;
  dcl-pi *n timestamp;
    i_oljl0100 likeds(oljl0100_t) const;
  end-pi;

  //  Return value
  dcl-s timeSent timestamp;

  dcl-s date date;
  dcl-s time time;
  dcl-s mSecs int(10);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  monitor;
    date = %date(i_oljl0100.dateSnd: *CYMD0);
    time = %time(i_oljl0100.timeSnd: *HMS0);
    mSecs = %int(i_oljl0100.mSecs);
    timeSent = date + time + %mseconds(mSecs);
  on-error;
    clear timeSent;
  endmon;

  return timeSent;

end-proc;

//=========================================================================
//  Returns cTrue, when the job associated with a given handle is open.
//=========================================================================
dcl-proc isOpen;
  dcl-pi *n ind;
    i_pHandle pointer const;
  end-pi;

  //  Return value
  dcl-s isOpen ind;

  //  Job log handle
  dcl-ds handle likeds(handle_t) based(i_pHandle);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if (i_pHandle <> *null and handle.isOpen);
    isOpen = cTrue;
  else;
    isOpen = cFalse;
  endif;

  return isOpen;

end-proc;

//=========================================================================
//  Returns cTrue, when the list has been completely built.
//=========================================================================
dcl-proc isComplete;
  dcl-pi *n ind;
    i_listInf likeds(qgy_opnListInf_t) const;
  end-pi;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return i_listInf.listStatInd = QGY_LIST_COMPLETE;

end-proc;

//=========================================================================
//  Returns cTrue, when the list is in error.
//=========================================================================
dcl-proc isError;
  dcl-pi *n ind;
    i_listInf likeds(qgy_opnListInf_t) const;
  end-pi;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return i_listInf.listStatInd = QGY_LIST_ERROR;

end-proc;

