**free
//===============================================================*
//                                                               *
//  erstellt : 19.05.2013                                        *
//                                                               *
//===============================================================*
//                                                               *
//  Kurzdokumentation :                                          *
//                                                               *
//  Rahmentestprogramm mit Protokollausgabe                      *
//  Thema:                                                       *
//     Job Log API - Example 1                                   *
//                                                               *
//===============================================================*
// >>PRE-COMPILER<<                                              *
//   >>CRTCMD<< CRTRPGMOD    MODULE(&LI/&OB) +                   *
//                           SRCFILE(&SL/&SF) SRCMBR(&SM);       *
//   >>COMPILE<<                                                 *
//     >>PARM<< TRUNCNBR(*NO);                                   *
//     >>PARM<< DBGVIEW(*LIST);                                  *
//     >>PARM<< OPTION(*EVENTF);                                 *
//   >>END-COMPILE<<                                             *
//   >>EXECUTE<<                                                 *
//   >>CMD<<    CRTPGM       PGM(&LI/&OB) +                      *
//                           MODULE(&LI/&OB) +                   *
//                           BNDSRVPGM(*LIBL/BASICS1   +         *
//                                     *LIBL/JOBLOG  ) +         *
//                           DETAIL(*BASIC) +                    *
//                           ACTGRP(*NEW);                       *
// >>END-PRE-COMPILER<<                                          *
//===============================================================*
ctl-opt debug option(*srcstmt: *nodebugio);
ctl-opt decedit('0,') datedit(*DMY.);
ctl-opt datfmt(*iso) timfmt(*iso);
ctl-opt expropts(*resdecpos);
ctl-opt extbinint(*yes);
//===============================================================*
dcl-f QSYSPRT printer(80) usage(*output) oflind(*in70);

// ------------------------------------
//  External Prototypes
// ------------------------------------
/copy QBASICS1,PBASICS1                      SrvPgm: Basics 1

//  Examinee
/copy QJOBLOG,PJOBLOG                        Job Log API

// ------------------------------------
//  Prototypes
// ------------------------------------

dcl-pr PGM_ENTRY_POINT extpgm('JOBLOGT1');
  gi_job char(28) options(*nopass) const;
end-pr;

dcl-pr main extproc('main');
  i_qJob likeds(qJob_t) const;
end-pr;

//  Logs a message to the job log or appends it to a spooled file
dcl-pr logMsg extproc('logMsg');
  i_text varchar(128) options(*nopass) value;
end-pr;

//  Sends a message to QCMD
dcl-pr sndMsg extproc('sndMsg');
  i_text varchar(128) value;
end-pr;

//  Prints a given message to QSYSPRT.
dcl-pr printMsg extproc('printMsg');
  i_text varchar(128) options(*nopass) value;
end-pr;

//===============================================================*
//  Program Entry Point
//===============================================================*
dcl-pi PGM_ENTRY_POINT;
  gi_job char(28) options(*nopass) const;
end-pi;

dcl-s g_s1 int(10);
dcl-s g_s2 int(10);
dcl-ds g_qJob likeds(qJob_t);
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if (%parms() >= %parmnum(gi_job) and gi_job <> '*');
  g_s1 = %scan('/': gi_job: 1);
  g_s2 = %scan('/': gi_job: g_s1+1);
  g_qJob.nbr = %subst(gi_job: 1: g_s1-1);
  g_qJob.user = %subst(gi_job: g_s1+1: g_s2-(g_s1+1));
  g_qJob.name = %subst(gi_job: g_s2+1);
else;
  g_qJob.name = '*';
endif;

main(g_qJob);

if (%open(QSYSPRT));
  close QSYSPRT;
endif;

*inlr = *on;


//===============================================================*
//  *** private ***
//  Logs a message to the job log or appends it to a spooled file
//===============================================================*
dcl-proc logMsg;
  dcl-pi *n;
    i_text varchar(128) options(*nopass) value;
  end-pi;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  if (%parms() >= 1);
    printMsg(i_text);
  // sndMsg(i_text);
  else;
    printMsg('');
  // no output to the job log
  endif;


end-proc;

//===============================================================*
//  *** private ***
//  Sends a message to the caller.
//===============================================================*
dcl-proc sndMsg;
  dcl-pi *n;
    i_text varchar(128) value;
  end-pi;

  //  Return value
  dcl-s pBuffer pointer inz;

  //  Local fields
  dcl-s msgKey char(4) inz;

  dcl-ds qMsgF qualified inz;
    name char(10);
    lib  char(10);
  end-ds;

  dcl-ds errCode qualified inz;
    bytPrv   int(10);
    bytAvl   int(10);
    excID    char(7);
    reserved char(1);
    excDta   char(256);
  end-ds;

  //  Send Program Message (QMHSNDPM) API
  dcl-pr QMHSNDPM extpgm('QMHSNDPM');
    i_msgID      char(7) const;
    i_qMsgF      char(20) const;
    i_msgData    char(32767) options(*varsize) const;
    i_length     int(10) const;
    i_msgType    char(10) const;
    i_callStkE   char(32767) options(*varsize) const;
    i_callStkC   int(10) const;
    o_msgKey     char(4);
    io_ErrCode   char(32767) options(*varsize);
    i_lenStkE    int(10) options(*nopass) const;
    i_callStkEQ  char(20) options(*nopass) const;
    i_wait       int(10) options(*nopass) const;
    i_callStkEDT char(10) options(*nopass) const;
    i_ccsid      int(10) options(*nopass) const;
  end-pr;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  clear qMsgF;
  qMsgF.name = 'QCPFMSG';
  qMsgF.lib  = '*LIBL';
  clear errCode;
  errCode.bytPrv = %size(errCode);
  QMHSNDPM('CPF9897': qMsgF: i_text: %len(i_text): '*INFO'
           : '*CTLBDY': 1
           : msgKey: errCode);

end-proc;

// =====================================================================
//  *** private ***
//  Prints a given message to QSYSPRT.
// =====================================================================
dcl-proc printMsg;
  dcl-pi *n;
    i_text varchar(128) options(*nopass) value;
  end-pi;

  //  Local fields
  dcl-ds lineOutput len(80) inz;
  end-ds;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if (not %open(QSYSPRT));
    open QSYSPRT;
  endif;
  if (%parms() >= 1);
    lineOutput = i_text;
  endif;
  write QSYSPRT lineOutput;
end-proc;

//===============================================================*
//  Main procedure
//===============================================================*
dcl-proc main;
  dcl-pi *n;
    i_qJob likeds(qJob_t) const;
  end-pi;

  //  Helper fields
  dcl-s hJobLog like(JobLog_handle_t);
  dcl-ds jobLogEntry likeds(JobLog_jobLogEntry_t) inz;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  // Retrieve first (oldest) job log entry.
  logMsg('Retrieving first (oldest) job log entry');
  JobLog_getOldest(i_qJob: jobLogEntry);
  logMsg(jobLogEntry.msgID + ' - ' + jobLogEntry.msgText);
  logMsg();

  // Retrieve last (newest) job log entry.
  logMsg('Retrieving last (newest) job log entry');
  JobLog_getNewest(i_qJob: jobLogEntry);
  logMsg(jobLogEntry.msgID + ' - ' + jobLogEntry.msgText);
  logMsg();

  // Open the job log
  logMsg('Retrieving job log entries from newest to oldest entry');
  hJobLog = JobLog_open(i_qJob: JOBLOG_OPTION_MSG +
                                JOBLOG_OPTION_REPLACE_VARS +
                                JOBLOG_OPTION_SENDER);

  if (JobLog_isOpen(hJobLog));
    // Spin through the job log entries from oldest to newest.
    dow (JobLog_getEntry(hJobLog: jobLogEntry));
      logMsg(jobLogEntry.msgID + ': ' +
            %char(jobLogEntry.timeSent) + ' - ' + jobLogEntry.msgText);
    enddo;

    // Close the job log
    JobLog_close(hJobLog);
  endif;

  // Open the job log
  logMsg('Retrieving job log entries from oldest to newest entry');
  hJobLog = JobLog_open(i_qJob: JOBLOG_OPTION_MSG +
                                JOBLOG_OPTION_REPLACE_VARS +
                                JOBLOG_OPTION_SENDER
                              : JOBLOG_NEXT);

  if (JobLog_isOpen(hJobLog));
    // Spin through the job log entries from oldest to newest.
    dow (JobLog_getEntry(hJobLog: jobLogEntry));
      logMsg(jobLogEntry.msgID + ': ' +
             %char(jobLogEntry.timeSent) + ' - ' + jobLogEntry.msgText);
    enddo;

    // Close the job log
    JobLog_close(hJobLog);
  endif;

end-proc;

