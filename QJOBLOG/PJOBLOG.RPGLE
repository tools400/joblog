      /IF NOT DEFINED(PJOBLOG)
      /DEFINE PJOBLOG
      *
      *  Parameter values of JobLog_open(), i_direction:
     D JOBLOG_NEXT...
     D                 c                   '*NEXT'
     D JOBLOG_PREVIOUS...
     D                 c                   '*PRV'
      *
      *  Parameter values of JobLog_open(), i_options:
     D JOBLOG_OPTION_REPLACE_VARS...
     D                 c                   1
     D JOBLOG_OPTION_RETURN_CTRL_CHARS...
     D                 c                   2
     D JOBLOG_OPTION_MSG...
     D                 c                   4
     D JOBLOG_OPTION_MSG_HELP...
     D                 c                   8
     D JOBLOG_OPTION_SENDER...
     D                 c                   16
     D JOBLOG_OPTION_RECEIVER...
     D                 c                   32
      *
      *  Opens a job log.
     D JobLog_open...
     D                 PR                         like(JobLog_handle_t)
     D                                     extproc('JOBLOG1_+
     D                                     JobLog_open+
     D                                     ')
     D  i_qJob                             const  likeds(qJob_t)
     D                                            options(*nopass: *omit)
     D  i_options                          const  like(JobLog_options_t)
     D                                            options(*nopass: *omit)
     D  i_direction                        const  like(JobLog_direction_t)
     D                                            options(*nopass: *omit)
     D  i_strMsgKey                        const  like(JobLog_msgKey_t)
     D                                            options(*nopass: *omit)
     D  i_timeout                    10i 0 const  options(*nopass: *omit)
      *
      *  Closes a given job log.
     D JobLog_close...
     D                 PR
     D                                     extproc('JOBLOG1_+
     D                                     JobLog_close+
     D                                     ')
     D  io_hJobLog                                like(JobLog_handle_t)
      *
      *  Returns cTrue when the list has been opened.
     D JobLog_isOpen...
     D                 PR              n
     D                                     extproc('JOBLOG1_+
     D                                     JobLog_isOpen+
     D                                     ')
     D  i_hJobLog                          const  like(JobLog_handle_t)
      *
      *  Returns cTrue when the list has been completly built.
     D JobLog_isComplete...
     D                 PR              n
     D                                     extproc('JOBLOG1_+
     D                                     JobLog_isComplete+
     D                                     ')
     D  i_hJobLog                          const  like(JobLog_handle_t)
      *
      *  Returns the next job log entry.
     D JobLog_getEntry...
     D                 PR              n
     D                                     extproc('JOBLOG1_+
     D                                     JobLog_getEntry+
     D                                     ')
     D  i_hJobLog                          const  like(JobLog_handle_t)
     D  o_jobLogEntry                             likeds(JobLog_jobLogEntry_t)
      *
      *  Returns the newest job log entry.
     D JobLog_getNewest...
     D                 PR              n
     D                                     extproc('JOBLOG1_+
     D                                     JobLog_getNewest+
     D                                     ')
     D  i_qJob                             const  likeds(qJob_t)
     D                                            options(*omit)
     D  o_jobLogEntry                             likeds(JobLog_jobLogEntry_t)
      *
      *  Returns the oldest job log entry.
     D JobLog_getOldest...
     D                 PR              n
     D                                     extproc('JOBLOG1_+
     D                                     JobLog_getOldest+
     D                                     ')
     D  i_qJob                             const  likeds(qJob_t)
     D                                            options(*omit)
     D  o_jobLogEntry                             likeds(JobLog_jobLogEntry_t)
      *
      *  Returns the message type of a given job log entry.
     D JobLog_getMessageType...
     D                 PR            10a
     D                                     extproc('JOBLOG1_+
     D                                     JobLog_getMessageType+
     D                                     ')
     D  i_jobLogEntry                      const  likeds(JobLog_jobLogEntry_t)
      *
      *  Returns cTrue if a given handle is NULL, else cFalse.
     D JobLog_isNull...
     D                 PR              N
     D                                     extproc('JOBLOG1_+
     D                                     JobLog_isNull+
     D                                     ')
     D  i_hJobLog                                 like(JobLog_handle_t)
      *
      *  Returns a NULL job log handle.
     D JobLog_null...
     D                 PR                         like(JobLog_handle_t)
     D                                     extproc('JOBLOG1_+
     D                                     JobLog_null+
     D                                     ')
      *
     D JobLog_handle_t...
     D                 s                   like(HANDLE_handle_t)
     D JobLog_direction_t...
     D                 s             10a
     D JobLog_msgKey_t...
     D                 s              4a
     D JobLog_options_t...
     D                 s             10i 0
      *
     D JobLog_jobLogEntry_t...
     D                 ds                  qualified based(pDummy)
     D  isMsg                          n
     D  isMsgHelp                      n
     D  isSender                       n
     D  isReceiver                     n
     D  msgSeverity                  10I 0
     D  msgID                         7A
     D  msgType                       2A
     D  msgKey                        4A
     D  msgFile                      10A
     D  msgFLibSpcfd                 10A
     D  msgFLibUsed                  10A
     D  timeSent                       Z
     D  threadId                      8A
     D  msgText                     132a   varying
     D  msgHelp                    3000a   varying
     D  sender                             likeds(JobLog_addresse_t)
     D  receiver                           likeds(JobLog_addresse_t)
     D  rplcData                   5120a   varying
      *
     D JobLog_addresse_t...
     D                 DS                  qualified based(pDummy)
     D  job                                likeds(qJob_t)
     D  type                          1a
     D  pgm                                likeds(qObj_t)
     D  mod                          10a
     D  proc                        256a
     D  stmts                              likeds(JobLog_stmts_t)
     D  usrPrf                       10a
      *
     D JobLog_stmts_t...
     D                 DS                  qualified based(pDummy)
     D  numE                         10i 0
     D  lineNbr                      10a   dim(10)
      *
     D JOBLOG_MAX_MSG_TEXT_LEN...
     D                 c                   132
     D JOBLOG_MAX_MSG_HELP_LEN...
     D                 c                   3000
      *
      /COPY QBASICS1,PBASICS1                     Tools/400 Runtime Library
      /COPY QJOBLOG,FDQJOB                        Qualified job name
      *
      /ENDIF
