      *===============================================================*
      *                                                               *
      *  erstellt : 02.12.2019                                        *
      *                                                               *
      *===============================================================*
      *                                                               *
      *  Kurzdokumentation :                                          *
      *                                                               *
      *  Rahmentestprogramm mit Protokollausgabe                      *
      *  Thema:                                                       *
      *     Job Log API - Example 3                                   *
      *                                                               *
      *===============================================================*
      * >>PRE-COMPILER<<                                              *
      *   >>CRTCMD<< CRTRPGMOD    MODULE(&LI/&OB) +                   *
      *                           SRCFILE(&SL/&SF) SRCMBR(&SM);       *
      *   >>COMPILE<<                                                 *
      *     >>PARM<< TRUNCNBR(*NO);                                   *
      *     >>PARM<< DBGVIEW(*LIST);                                  *
      *     >>PARM<< OPTION(*EVENTF);                                 *
      *   >>END-COMPILE<<                                             *
      *   >>EXECUTE<<                                                 *
      *   >>CMD<<    CRTPGM       PGM(&LI/&OB) +                      *
      *                           MODULE(&LI/&OB) +                   *
      *                           BNDSRVPGM(*LIBL/BASICS1   +         *
      *                                     *LIBL/LSTJOB    +         *
      *                                     *LIBL/JOBLOG  ) +         *
      *                           DETAIL(*BASIC) +                    *
      *                           ACTGRP(*NEW);                       *
      * >>END-PRE-COMPILER<<                                          *
      *===============================================================*
     H DEBUG
     H OPTION(*SRCSTMT : *NODEBUGIO)
     H DECEDIT('0,') DATEDIT(*DMY.)
     H DATFMT(*ISO )  TIMFMT(*ISO )
     H EXPROPTS(*RESDECPOS)
     H EXTBININT(*YES)
      *===============================================================*
     FQSYSPRT   O    F   80        PRINTER OFLIND(*in70)
      *
      * ------------------------------------
      *  External Prototypes
      * ------------------------------------
      /COPY QBASICS1,PBASICS1                      SrvPgm: Basics 1
      /COPY QLSTJOB,PLSTJOB                        SrvPgm: List Jobs
      /COPY QLSTJOB,QUSLJOB                        List Job (QUSLJOB) API
      *
      *  Examinee
      /COPY QJOBLOG,PJOBLOG                        Job Log API
      *
      * ------------------------------------
      *  Prototypes
      * ------------------------------------
      *
     D PGM_ENTRY_POINT...
     D                 PR                  extpgm('JOBLOGT3')
     D  gi_job                       28A   const options(*nopass)
      *
     D main...
     D                 PR                         extproc('main')
     D  i_qJob                             const likeds(qJob_t)
      *
      *  Logs a message to the job log or appends it to a spooled file
     D logMsg...
     D                 PR                         extproc('logMsg')
     D  i_text                      128A   value  varying options(*nopass)
      *
      *  Sends a message to QCMD
     D sndMsg...
     D                 PR                         extproc('sndMsg')
     D  i_text                      128A   value  varying
      *
      *  Prints a given message to QSYSPRT.
     D printMsg...
     D                 PR                  extproc('printMsg')
     D  i_text                      128A   value  varying options(*nopass)
      *
      *===============================================================*
      *  Program Entry Point
      *===============================================================*
     D PGM_ENTRY_POINT...
     D                 PI
     D  gi_job                       28A   const options(*nopass)
      *
     D g_s1            s             10i 0
     D g_s2            s             10i 0
     D g_qJob          ds                  likeds(qJob_t)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

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

      /END-FREE
      *
      *===============================================================*
      *  *** private ***
      *  Logs a message to the job log or appends it to a spooled file
      *===============================================================*
     P logMsg...
     P                 B
     D                 PI
     D  i_text                      128A   value  varying options(*nopass)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE


       if (%parms() >= 1);
         printMsg(i_text);
       // sndMsg(i_text);
       else;
         printMsg('');
       // no output to the job log
       endif;

      /END-FREE
      *
     P                 E
      *
      *===============================================================*
      *  *** private ***
      *  Sends a message to the caller.
      *===============================================================*
     P sndMsg...
     P                 B
     D                 PI
     D  i_text                      128A   value  varying
      *
      *  Return value
     D pBuffer         S               *   inz
      *
      *  Local fields
     D msgKey          S              4A                        inz
      *
     D qMsgF           DS                  qualified            inz
     D  name                         10A
     D  lib                          10A
      *
     D errCode         DS                  qualified            inz
     D  bytPrv                       10I 0
     D  bytAvl                       10I 0
     D  excID                         7A
     D  reserved                      1A
     D  excDta                      256A
      *
      *  Send Program Message (QMHSNDPM) API
     D QMHSNDPM        PR                         extpgm('QMHSNDPM')
     D   i_msgID                      7A   const
     D   i_qMsgF                     20A   const
     D   i_msgData                32767A   const  options(*varsize )
     D   i_length                    10I 0 const
     D   i_msgType                   10A   const
     D   i_callStkE               32767A   const  options(*varsize )
     D   i_callStkC                  10I 0 const
     D   o_msgKey                     4A
     D   io_ErrCode               32767A          options(*varsize )
     D   i_lenStkE                   10I 0 const  options(*nopass  )
     D   i_callStkEQ                 20A   const  options(*nopass  )
     D   i_wait                      10I 0 const  options(*nopass  )
     D   i_callStkEDT                10A   const  options(*nopass  )
     D   i_ccsid                     10I 0 const  options(*nopass  )
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE
       clear qMsgF;
       qMsgF.name = 'QCPFMSG';
       qMsgF.lib  = '*LIBL';
       clear errCode;
       errCode.bytPrv = %size(errCode);
       QMHSNDPM('CPF9897': qMsgF: i_text: %len(i_text): '*INFO'
                : '*CTLBDY': 1
                : msgKey: errCode);
      /END-FREE
      *
     P                 E
      *
      * =====================================================================
      *  *** private ***
      *  Prints a given message to QSYSPRT.
      * =====================================================================
     P printMsg...
     P                 B
     D                 PI
     D  i_text                      128A   value  varying options(*nopass)
      *
      *  Local fields
     D lineOutput      DS            80    inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /free
       if (not %open(QSYSPRT));
         open QSYSPRT;
       endif;
       if (%parms() >= 1);
         lineOutput = i_text;
       endif;
       write QSYSPRT lineOutput;
      /end-free
     P                 E
      *
      *===============================================================*
      *  Main procedure
      *===============================================================*
     P main...
     P                 B
     D                 PI
     D  i_qJob                             const likeds(qJob_t)
      *
      *  Helper fields
     D hasJob          s               n
     D hJobs           s                   like(lstJob_handle_t) inz
     D jobl0100        ds                  likeds(jobl0100_t) inz
     D qJob            ds                  likeds(qJob_t) inz
     D hJobLog         s                   like(JobLog_handle_t) inz
     D jobLogEntry     ds                  likeds(JobLog_jobLogEntry_t) inz
     D count           s             10i 0
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

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

      /END-FREE
     P                 E
      *
