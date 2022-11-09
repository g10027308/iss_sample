//
//  log.c
//  CupsBackend
//
//  Created by gj on 18/7/17.
//
//

#include "log.h"

#include <time.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <stddef.h>
#include <stdarg.h>
#include <dirent.h>
#include <sys/types.h>

FILE *logfp=NULL;
int nCurLogType = 2;

void log_open(char* filename, int nLogType){
    nCurLogType = nLogType;
    logfp=fopen(filename, "a+");
}

void log_event(short type, const char *message, ...){
    time_t secs;
    int error=errno;
    char ctype[8], *timestring;
    cp_string logbuffer;
    va_list ap;
    
    if ((logfp != NULL) && (type & nCurLogType)) {
        (void) time(&secs);
        timestring=ctime(&secs);
        timestring[strlen(timestring)-1]='\0';
        
        if (type == CPERROR)
            snprintf(ctype, 8, "ERROR");
        else if (type == CPSTATUS)
            snprintf(ctype, 8, "STATUS");
        else
            snprintf(ctype, 8, "DEBUG");
        
        va_start(ap, message);
        vsnprintf(logbuffer, BUFSIZE, message, ap);
        va_end(ap);
        
        fprintf(logfp,"%s  [%s] %s\n", timestring, ctype, logbuffer);
        if ((nCurLogType & CPDEBUG) && (type == CPERROR) && error)
            fprintf(logfp,"%s  [DEBUG] ERRNO: %d (%s)\n", timestring, error, strerror(error));
        
        (void) fflush(logfp);
    }
    
    return;
}

void log_close(){
    if (logfp!=NULL)
        (void) fclose(logfp);
}