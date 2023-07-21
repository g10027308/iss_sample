//
//  log.h
//  CupsBackend
//
//  Created by gj on 18/7/17.
//
//

#ifndef log_h
#define log_h

#include <stdio.h>

#define CPERROR         1
#define CPSTATUS        2
#define CPDEBUG         4

void log_open(char* filename, int nLogType);

void log_event(short type, const char *message, ...);

void log_close(void);

#endif /* log_h */
