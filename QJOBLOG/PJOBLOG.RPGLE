**free
/if NOT DEFINED(PJOBLOG)
/define PJOBLOG

//  Parameter values of JobLog_open(), i_direction:
dcl-c JOBLOG_NEXT '*NEXT';
dcl-c JOBLOG_PREVIOUS '*PRV';

//  Parameter values of JobLog_open(), i_options:
dcl-c JOBLOG_OPTION_REPLACE_VARS 1;
dcl-c JOBLOG_OPTION_RETURN_CTRL_CHARS 2;
dcl-c JOBLOG_OPTION_MSG 4;
dcl-c JOBLOG_OPTION_MSG_HELP 8;
dcl-c JOBLOG_OPTION_SENDER 16;
dcl-c JOBLOG_OPTION_RECEIVER 32;

//  Opens a job log.
dcl-pr JobLog_open like(JobLog_handle_t) extproc('JOBLOG1_JobLog_open');
  i_qJob      likeds(qJob_t) options(*nopass: *omit) const;
  i_options   like(JobLog_options_t) options(*nopass: *omit) const;
  i_direction like(JobLog_direction_t) options(*nopass: *omit) const;
  i_strMsgKey like(JobLog_msgKey_t) options(*nopass: *omit) const;
  i_timeout   int(10) options(*nopass: *omit) const;
end-pr;

//  Closes a given job log.
dcl-pr JobLog_close extproc('JOBLOG1_JobLog_close');
  io_hJobLog like(JobLog_handle_t);
end-pr;

//  Returns cTrue when the list has been opened.
dcl-pr JobLog_isOpen ind extproc('JOBLOG1_JobLog_isOpen');
  i_hJobLog like(JobLog_handle_t) const;
end-pr;

//  Returns cTrue when the list has been completly built.
dcl-pr JobLog_isComplete ind extproc('JOBLOG1_JobLog_isComplete');
  i_hJobLog like(JobLog_handle_t) const;
end-pr;

//  Returns the next job log entry.
dcl-pr JobLog_getEntry ind extproc('JOBLOG1_JobLog_getEntry');
  i_hJobLog     like(JobLog_handle_t) const;
  o_jobLogEntry likeds(JobLog_jobLogEntry_t);
end-pr;

//  Returns the newest job log entry.
dcl-pr JobLog_getNewest ind extproc('JOBLOG1_JobLog_getNewest');
  i_qJob        likeds(qJob_t) options(*omit) const;
  o_jobLogEntry likeds(JobLog_jobLogEntry_t);
end-pr;

//  Returns the oldest job log entry.
dcl-pr JobLog_getOldest ind extproc('JOBLOG1_JobLog_getOldest');
  i_qJob        likeds(qJob_t) options(*omit) const;
  o_jobLogEntry likeds(JobLog_jobLogEntry_t);
end-pr;

//  Returns the message type of a given job log entry.
dcl-pr JobLog_getMessageType char(10) extproc('JOBLOG1_JobLog_getMessageType');
  i_jobLogEntry likeds(JobLog_jobLogEntry_t) const;
end-pr;

//  Returns cTrue if a given handle is NULL, else cFalse.
dcl-pr JobLog_isNull ind extproc('JOBLOG1_JobLog_isNull');
  i_hJobLog like(JobLog_handle_t);
end-pr;

//  Returns a NULL job log handle.
dcl-pr JobLog_null like(JobLog_handle_t) extproc('JOBLOG1_JobLog_null');
end-pr;

dcl-s JobLog_handle_t like(HANDLE_handle_t);
dcl-s JobLog_direction_t char(10);
dcl-s JobLog_msgKey_t char(4);
dcl-s JobLog_options_t int(10);

dcl-ds JobLog_jobLogEntry_t qualified based(pDummy);
  isMsg        ind;
  isMsgHelp    ind;
  isSender     ind;
  isReceiver   ind;
  msgSeverity  int(10);
  msgID        char(7);
  msgType      char(2);
  msgKey       char(4);
  msgFile      char(10);
  msgFLibSpcfd char(10);
  msgFLibUsed  char(10);
  timeSent     timestamp;
  threadId     char(8);
  msgText      varchar(132);
  msgHelp      varchar(3000);
  sender       likeds(JobLog_addresse_t);
  receiver     likeds(JobLog_addresse_t);
  rplcData     varchar(5120);
end-ds;

dcl-ds JobLog_addresse_t qualified based(pDummy);
  job    likeds(qJob_t);
  type   char(1);
  pgm    likeds(qObj_t);
  mod    char(10);
  proc   char(256);
  stmts  likeds(JobLog_stmts_t);
  usrPrf char(10);
end-ds;

dcl-ds JobLog_stmts_t qualified based(pDummy);
  numE    int(10);
  lineNbr char(10) dim(10);
end-ds;

dcl-c JOBLOG_MAX_MSG_TEXT_LEN 132;
dcl-c JOBLOG_MAX_MSG_HELP_LEN 3000;

/copy QBASICS1,PBASICS1                     Tools/400 Runtime Library
/copy QJOBLOG,FDQJOB                        Qualified job name

/endif
