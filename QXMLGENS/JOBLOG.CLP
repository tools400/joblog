/* -------------------------------------------------------------------------- */
/* JOBLOG     - SCRIPT MEMBER                                                 */
/* Use commands  xmlgenINC (generate text for install pgm)                    */
/*               xmlgenMBR (to define source members                          */
/*               xmlgenCMD (execute qcmdexc at run time                       */
/* Put &TOLIB where you want user selected lib at run time.                   */
   DCL &TOLIB *CHAR 10
/* -------------------------------------------------------------------------- */
/* >>PRE-COMPILER<<                                                           */
/*   >>CRTCMD<<  XMLGEN  XMLSCRIPT(&SM) SCRIPTSRCF(&SL/&SF);                  */
/*   >>IMPORTANT<<                                                            */
/*     >>PARM<<  SRCTOFILE(&LI/QXML);                                         */
/*     >>PARM<<  XMLMBR(*SCRIPT);                                             */
/*     >>PARM<<  ENCODING('ISO-8859-1');                                      */
/*     >>PARM<<  AUTHOR('Thomas Raddatz');                                    */
/*   >>END-IMPORTANT<<                                                        */
/*   >>EXECUTE<<                                                              */
/* >>END-PRE-COMPILER<<                                                       */
/* -------------------------------------------------------------------------- */
             XMLGENINC  XINCLUDE(*YES)

             XMLGENVRS XSRCFILE(QJOBLOG) XSRCLIB(JOBLOGDVP) XSRCMBR(COPYRIGHT)

             XMLGENCND  XMSG('Create sample programs? (YES, NO)') +
                          XVALUES(YES NO) XVAR(&CRTTSTPGM)

             XMLGENSET  XVAR(&SRCFILE) XVALUE(QJOBLOG)

/* ---------------------------------- */
/*  Deploy source member              */
/* ---------------------------------- */
             XMLGENMBR  XMBR(A_INSTALL ) XMBRATR(CLLE ) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(A_README  ) XMBRATR(TXT) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*PGM) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(CLIB      ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(COPYRIGHT ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(FDQJOB    ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(H_SPEC    ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(JOBLOG    ) XMBRATR(MAKSRV) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(JOBLOGT1  ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(JOBLOGT2  ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(JOBLOGT3  ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(JOBLOG1   ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(OPNLSTAPIS) XMBRATR(RPGLE ) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(PJOBLOG   ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(QGYOLJBL  ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(TESTLJBL  ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QJOBLOG   ) XFROMSRCL(JOBLOGDVP) +
                          XTOSRCF(QJOBLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

/* ---------------------------------- */
/*  Create objects                    */
/* ---------------------------------- */
             XMLGENCMD  XCMD(CRTBNDCL PGM(&TOLIB/A_INSTALL) +
                          SRCFILE(&TOLIB/QJOBLOG) SRCMBR(*PGM) +
                          DFTACTGRP(*NO) ACTGRP(*NEW) +
                          DBGVIEW(*LIST)) XDLTSPLF(A_INSTALL)

             XMLGENCMD  XCMD(CALL PGM(&TOLIB/A_INSTALL) +
                             PARM('&TGTRLS' '&SRCFILE' '&TOLIB' '&CRTTSTPGM'))
             XMLGENCMD  XCMD(DLTPGM PGM(&TOLIB/A_INSTALL))

