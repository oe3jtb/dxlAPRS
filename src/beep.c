#include <sys/ioctl.h>
#include <stdio.h>
#include <linux/kd.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <signal.h>


int cbell(int hz, int ms)
{
  int fd;
  int ret;
  int pid;
  char arg1[20];
  char arg2[20];
  char arg3[20];
  char arg4[20];

  ret=-2;
  fd=open("/dev/tty0", O_WRONLY);
  if (fd<0) fd=open("/dev/vc/0", O_WRONLY);
  if (fd<0) fd=open("/dev/console", O_WRONLY);

#ifndef MACOS
  /* Not supported on MacOS */

  if (fd>=0) {
    if (ioctl(fd, KIOCSOUND, 1193180/hz)>=0) {
      usleep(ms*1000); 
      ioctl(fd, KIOCSOUND, 0);
      ret=0;
    }
    close(fd);
  } 
#endif
#ifdef MACOS
  close(fd);
#endif

#ifdef USEBEEP
  if (ret<0) {
    strncpy(arg1,"-f",3);
    strncpy(arg3,"-l",3);
    snprintf(arg2, sizeof(arg2), "%d", hz);
    snprintf(arg4, sizeof(arg2), "%d", ms);

    signal(SIGCHLD, SIG_IGN);
    pid = fork();
    if (pid==0L) {                                           /* child */
      execlp("beep", "beep", arg1, arg2, arg3, arg4, NULL);  /* if program starts child terminates */
      printf("%s\n", "install and make tool 'beep' running for this user");
      exit(-1);
    }
    ret=0;                                                              /* parent */
  }
#endif

  return ret;
}







