      *===============================================================*
      *                                                               *
      *  erstellt : 29.11.2019                                        *
      *                                                               *
      *===============================================================*
      *                                                               *
      *  Kurzdokumentation :                                          *
      *                                                               *
      *  Rahmentestprogramm mit Protokollausgabe                      *
      *  Thema:                                                       *
      *     Job Log API - Example 2                                   *
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
      *
      *  Examinee
      /COPY QJOBLOG,PJOBLOG                        Job Log API
      *
      * ------------------------------------
      *  Prototypes
      * ------------------------------------
      *
     D PGM_ENTRY_POINT...
     D                 PR                  extpgm('JOBLOGT2')
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
         g_qJob.name = '*';
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
     D hJobLog         s                   like(JobLog_handle_t)
     D jobLogEntry     ds                  likeds(JobLog_jobLogEntry_t) inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

       // Open the job log asynchronously
       logMsg('Retrieving job log entries from newest to oldest entry');
       hJobLog = JobLog_open(i_qJob: JOBLOG_OPTION_MSG +
                                     JOBLOG_OPTION_REPLACE_VARS +
                                     JOBLOG_OPTION_SENDER
                                   : JOBLOG_PREVIOUS
                                   : *omit
                                   : 60); // 60 secs timeout

       if (JobLog_isOpen(hJobLog));
         // Spin through the job log entries from oldest to newest.
         dow (JobLog_getEntry(hJobLog: jobLogEntry));
           logMsg(jobLogEntry.msgID + ': ' +
                  %char(jobLogEntry.timeSent) + ' - ' + jobLogEntry.msgText);
         enddo;

         // Close the job log
         JobLog_close(hJobLog);
       endif;

      /END-FREE
     P                 E
      *
