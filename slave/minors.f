
	subroutine minors(B,bm,ierr)
        implicit none
	include "parameter.h"
	integer B(s,s), bm(s), ierr
c
ccc	Local variables
c
	integer lda
        parameter (lda = s-1)
	integer i,j,k, det, flag, sign, ksign
	integer*8 cf(lda,lda)
	logical lequal
c
ccc     Find the different minors and their determinant
c
        ksign = 1-2*mod(1+s,2)
	flag = -1
	do k = 1,s
          do j = 1,k-1
             do i = 1,s-1
                cf(i,j) = b(i,j)
             enddo
          enddo
          do j = k+1,s
             do i = 1,s-1
                cf(i,j-1) = b(i,j)
             enddo 
          enddo
          call entire_hnf (s-1,cf, sign,flag,ierr)
          bm(k) = cf(1,1)
          do i = 2,s-1
            bm(k) = bm(k)*cf(i,i)
          enddo
          bm(k) = sign*bm(k)
          ksign = -ksign
        enddo
        return
        end
