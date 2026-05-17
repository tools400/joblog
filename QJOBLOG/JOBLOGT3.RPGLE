**free
//===============================================================*
//                                                               *
//  erstellt : 02.12.2019                                        *
//                                                               *
//===============================================================*
//                                                               *
//  Kurzdokumentation :                                          *
//                                                               *
//  Rahmentestprogramm mit Protokollausgabe                      *
//  Thema:                                                       *
//     Job Log API - Example 3                                   *
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
//                                     *LIBL/LSTJOB    +         *
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
/copy QLSTJOB,PLSTJOB                        SrvPgm: List Jobs
/copy QLSTJOB,QUSLJOB                        List Job (QUSLJOB) API

//  Examinee
/copy QJOBLOG,PJOBLOG                        Job Log API

// ------------------------------------
//  Prototypes
// ------------------------------------

dcl-pr PGM_ENTRY_POINT extpgm('JOBLOGT3');
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
  g_qJob.name = 'QZDASOINIT';
  g_qJob.user = '*ALL';
  g_qJob.nbr = '*ALL';
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
  dcl-s hasJob ind;
  dcl-s hJobs like(lstJob_handle_t) inz;
  dcl-ds jobl0100 likeds(jobl0100_t) inz;
  dcl-ds qJob likeds(qJob_t) inz;
  dcl-s hJobLog like(JobLog_handle_t) inz;
  dcl-ds jobLogEntry likeds(JobLog_jobLogEntry_t) inz;
  dcl-s count int(10);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if (f_opnJobLst(i_qJob.name: i_qJob.user: i_qJob.nbr: '*ACTIVE'
  : cLSTJOB_ORDERBY_NONE: hJobs));

  hasJob = f_getFirstJob(hJobs: jobl0100);
  dow (hasJob);

    qJob.name = jobl0100.job;
    qJob.user = jobl0100.user;
    qJob.nbr = jobl0100.nbr;

      // Open the job log asynchronously
      hJobLog = JobLog_open(qJob: JOBLOG_OPTION_MSG +
      JOBLOG_OPTION_REPLACE_VARS +
      JOBLOG_OPTION_SENDER
      : JOBLOG_PREVIOUS
      : *omit
      : 60); // 60 secs timeout

      // ================================================
      //   Do some other lengthy operations ...
      // ================================================

      if (JobLog_isOpen(hJobLog));
      // Spin through the job log entries from oldest to newest.
      count = 0;
      dow (JobLog_getEntry(hJobLog: jobLogEntry));
      count += 1;
      enddo;

        // Close the job log
        JobLog_close(hJobLog);
          endif;

        logMsg(%trim(qJob.nbr)  + '/' +
        %trim(qJob.user) + '/' +
        %trim(qJob.name) + ' count#: ' + %char(count));

      hasJob = f_getNextJob(hJobs: jobl0100);
      enddo;

      f_cloJobLst(hJobs);
      endif;

end-proc;

