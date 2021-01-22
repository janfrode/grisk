      SUBROUTINE kjlist(ndelta,kount,ilist,ksmall,
     $  jount,jlist)
cts
cts Started cleaning up this routine with the ultimate goal of making
cts it run for general dimension, s. Things needed to be done is:
cts    -Get ride of the spaghetti code
cts    -Make the 'list' variables 2-dimensional as the second letter
cts     in i?list and j?list only refer to the physical dimension.
cts
      include "parameter.h"
      integer nix(10)
      COMMON nix
      integer ndelta, jount, kount
      integer  ilist(s,idim)
      integer  jlist(s,jdim)
      integer  ksmall(jdim)
cts
cts     local variables
cts
      integer npnt(s), ntmp, ndia
      integer i, iii, jj, jjjj, kk
      logical big, debug
c updated to kjlist march 15, 1996. Requires additional
c five integer vectors in calling sequence of calling program.
c  This subroutine uses some clever coding, due to Newman, to
c  construct the Kount list and store it.
c
      debug = .false.
      ndia = ndelta
      kount = 0
c  original had ndia = O and included all interior points
      DO jjjj = 1,s-1
        npnt(jjjj) = 0
      enddo      
      npnt(s) = ndelta
cts
cts big loop
cts
   20 CONTINUE
      i = s
      kount = kount + 1
      if (kount.gt.idim) then
         write(*,*) 'dimension of ilist   = ',idim
         write(*,*) 'You are now at element= ',kount
      endif
      do jjjj = 1,s
        ilist(jjjj,kount) = npnt(jjjj)
      enddo
      if (debug) write(*,*)(npnt(jjjj),jjjj=1,s)
   40 CONTINUE
      IF (npnt(1).GE.ndia) THEN
        ndia = ndia + 1
        IF (ndia.le.ndelta) then       
          do jjjj = 1,s-1
             npnt(jjjj) = 0
          enddo
          npnt(s) = ndia
        endif
      ELSE
        IF (npnt(i).NE.0) THEN
          npnt(i-1) = npnt(i-1) + 1
          ntmp = npnt(i) - 1
          npnt(i) = 0
          npnt(s) = ntmp
        ELSE
          i = i - 1
          GO TO 40
        END IF
      END IF
      if (ndia.le.ndelta) GO TO 20
c
c  now construct j-list
c
      jount = 0
      jj = 0
      do kk = 1, kount
        big = .true.
	do jjjj = 1,s-1
          IF (ilist(jjjj,kk).LT.ilist(jjjj+1,kk)) big = .false.
	enddo
        if (big) then
          jj = jj + 1
          do jjjj=1,s 
            jlist(jjjj,jj) = ilist(jjjj,kk)
	  enddo
          ksmall(jj) = kk
        endif
      enddo
      jount = jj
c
c **** CODECHECK (START) nix(4) ****
c
      IF (nix(4).ge.1000) then
        WRITE (6,*) 'jount =',jount
        DO 90 iii = 1,jount
          nix(4) = nix(4) - 1
          IF (nix(4).LT.1000) GO TO 90
          IF (nix(4).NE.0) PRINT 9000,iii,ksmall(iii),jlist(1,iii),
     &      jlist(2,iii),jlist(3,iii),jlist(4,iii)
          IF (nix(4).GT.0) nix(4) = nix(4) - 1
   90   CONTINUE
      endif
c **** CODECHECK (END) nix(4) ****
c
c
      RETURN
 9000 FORMAT ('iii, ksmall, jlist',i5,i5,i5,3i3)
      END

