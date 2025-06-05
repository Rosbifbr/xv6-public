#include "include/types.h"
#include "include/user.h"
#include "include/fcntl.h"

int
main(void)
{
  static char buf[100];
  int fd;

  // Ensure stdin, stdout, stderr are open
  // This is usually done by init, but good practice for a standalone test.
  if((fd = open("console", O_RDWR)) < 0){
    mknod("console", 1, 1);
    fd = open("console", O_RDWR);
  }
  dup(fd);  // stdout
  dup(fd);  // stderr
  if(fd > 2) close(fd);


  while(1){
    printf(1, "$ "); // fd 1 is stdout
    gets(buf, sizeof(buf));
    if(buf[0] == 0) // Handle EOF or empty line
      break;
    printf(1, "%s\n", buf);
  }
  exit();
}
