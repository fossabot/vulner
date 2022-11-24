#include "dietfeatures.h"
#include "dietdirent.h"
#include <unistd.h>
#include <dirent.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include "syscalls.h"

#ifndef __NR_getdents64
#define WANT_LARGEFILE_BACKCOMPAT
#endif

#ifndef WANT_LARGEFILE_BACKCOMPAT
struct dirent64* readdir64(DIR *d) {
  struct linux_dirent64 *ld = d->num ? (struct linux_dirent64*)(d->buf+d->cur) : NULL;
  if (!d->num || (d->cur += ld->d_reclen)>=d->num) {
    int res=getdents64(d->fd,(struct linux_dirent64*)d->buf, __DIRSTREAM_BUF_SIZE-1);
    if (res<=0) return 0;
    d->num=res; d->cur=0; d->is_64=1;
  }
  /* \todo: ensure that dirent64 and linux_dirent64 are compatible */
  return (struct dirent64*)(d->buf+d->cur);
}
#else
struct dirent64* readdir64(DIR *d) {
#ifdef __NR_getdents64
  static int trygetdents64=1;
#endif
  static struct dirent64 d64;
#ifdef __NR_getdents64
again:
  if (!trygetdents64) {
#endif
    struct linux_dirent *ld = d->num ? (struct linux_dirent*)(d->buf+d->cur) : NULL;
    if (!d->num || (d->cur += ld->d_reclen)>=d->num) {
      int res=getdents(d->fd,(struct linux_dirent*)d->buf, __DIRSTREAM_BUF_SIZE-1);
      if (res<=0) return 0;
      d->num=res; d->cur=0;d->is_64=0;
      ld=(struct linux_dirent*)(d->buf+d->cur);
    }
    d64.d_ino=ld->d_ino;
    d64.d_off=ld->d_off;
    d64.d_reclen=ld->d_reclen;
    strcpy(d64.d_name,ld->d_name);
    d64.d_type=0;	/* is this correct? */
    return &d64;
#ifdef __NR_getdents64
  }
  {
  struct linux_dirent64 *ld = d->num ? (struct linux_dirent64*)(d->buf+d->cur) : NULL;
  if (!d->num || (d->cur += ld->d_reclen)>=d->num) {
    int res=getdents64(d->fd,(struct linux_dirent64*)d->buf,__DIRSTREAM_BUF_SIZE);
    if (res<=0) {
      if (errno==ENOSYS) {
	trygetdents64=0;
	goto again;
      }
      return 0;
    }
    d->num=res; d->cur=0; d->is_64=1;
  }
  }
  /* \todo: ensure that dirent64 and linux_dirent64 are compatible */
  return (struct dirent64*)(d->buf+d->cur);
#endif
}
#endif
