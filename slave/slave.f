
c____________________________________________________________________
c____________________________________________________________________
c       
c       SLAVE
c____________________________________________________________________
c       

	subroutine nyzvis_s (ndelta, kount, jount, BestSolution, 
     $       nhope, nmax, ilist, jlist, task,
     $       n_count, n_good, d_count)

	implicit none
        include "parameter.h"
	include "frontier.h"
c       
cts This routine is modifies nyzvis94. It doesn't try to find
cts simple combination of all the s rows, but only on the s-1
cts rows. Instead it does the fast update of the determinant using
cts the fact that the different last rows is introduced one by one
cts in a given order.
c       
ccc Subroutine parameters
c       
	integer ndelta, kount, jount, BestSolution(s)
        integer nhope, nmax, jlist(s,jdim), ilist (s,idim)
        double precision n_count, d_count(s), n_good((s-1),2)
c       
ccc     local variables
c       
	integer i, j, task, N, row, deg, Nbest, ptn(s)
        integer sign, sign_start, test_deg, flag_deg, ierr
	integer B(s,s), bm(s)
	integer*8 BH(s,s)
	integer*8 printcount
	logical solution_found

c____________________________________________________________________
c       
ccc	Common initialization
c       
        n_count = 0.d0
		d_count(s) = 0.d0
        do i = 1,s-1
           n_good(i,1)  = 0.d0
           d_count(i) = 0.d0
           n_good(i,2)  = 0.d0
        enddo
c       
ccc	Slave initialization
c       
        flag_deg = 1
        if (mod(s,2).eq.1) then
           sign_start = 1
        else
           sign_start = -1
        endif
	do i=1, s
	   ptn(i) = 1
	   BestSolution(i) = -1
	enddo

	Nbest = Nmax + 1
	solution_found = .false.
c____________________________________________________________________
c       
ccc	Get some work (get task number => build pointer vector)
c       
cjfm	read (F_INPUT,*) task
        ptn(1) = 1 + int ( float(task) / float(kount) )
        ptn(2) = 1 + mod ( task, kount )

c____________________________________________________________________
c       
ccc	building up a generator matrix
c       
   	row = 1
60	if (row.eq.1) then
	   do j = 1, s
 	      b(1,j) = jlist(j,ptn(1))
	      bh(1,j) = b(1,j)
           enddo
	else
           do j = 1,s 
              b(row,j) = ilist(j,ptn(row))
	      bh(row,j) = b(row,j)
           enddo
           b(row,s+2-row) = -b(row,s+2-row)
           bh(row,s+2-row) = -bh(row,s+2-row)
c       
ccc	Added a new row. Check if some obvious combinations of the
ccc	rows selected so far will lead to a low degree lattices. 
ccc	In which case no further investigation is needed. 
c       
           if (row.lt.s) then
              do i = 1, row-1
                 test_deg = 0
                 do j = 1,s
                    test_deg = test_deg + abs(b(i,j) - b(row,j))
                 enddo
                 if (test_deg .lt. ndelta) then
                    n_good(row,1) = n_good(row,1) +1 
                    goto 90
                 endif
                 test_deg = 0
                 do j = 1,s
                    test_deg = test_deg + abs(b(i,j) + b(row,j))
                 enddo
                 if (test_deg .lt. ndelta) then
                    n_good(row,2) = n_good(row,2) +1 
                    goto 90
                 endif
              enddo
           endif
   	endif

        if (row.lt.s) then
           if (row.eq.s-1) call minors (b,bm,ierr)
           row = row+1
           goto 60
	endif
c____________________________________________________________________
c       
ccc	We have a matrix. Now check if it's good
c       
        n_count = n_count + 1
        sign = sign_start
        N = 0
        do j = 1,s
           N = N+sign*b(s,j)*bm(j)
           sign = -sign
        enddo
        N = abs(N)

        if (N.le.nmax.and.n.ge.nhope) then
           d_count(s) = d_count(s) + 1
           do j = 1,s
              bh(1,j) = b(1,j)
           enddo
           do i = 2,s
              do j = 1,s
                 bh(i,j) = b(i,j)
              enddo
              call fast_hnf(s,BH,i,flag_deg,ierr)
           enddo
           call fast_find ( BH, deg, ndelta)
	else
	   goto 90
	endif
c____________________________________________________________________
c       
ccc	Have we found a solution?
c       
80	if ( deg.eq.ndelta ) then
	   solution_found = .true.

	   if (N.le.Nbest) then
	      Nbest = N
	      Nmax = Nbest - 1
c Looks like f90:
c         BestSolution = ptn
c Lets make a loop instead
        do i=1, s
            BestSolution(i) = ptn(i)
        enddo

	   endif

	   call ShowResult (ptn, ndelta, N, b, bh)
	endif

c____________________________________________________________________
c       
ccc 	Find which lattice is the next to check
c       
90	if (row.gt.2) then
c          WRITE(*,'(f18.0)') n_count,'[A'
c          WRITE(*,*) n_count,'[A'
c          if (mod(int(n_count),10000) .eq. 0 ) WRITE(*,*) n_count,'[A'
           if (mod(int(n_count),50000) .eq. 0 ) then
			   printcount = int(n_count)
			   WRITE(*,*) printcount,'[A'
		   endif
		   if (ptn(row).lt. kount) then
              ptn(row) = ptn(row) +1
              goto 60
           else
              do i = row,s
                 ptn(i) = 1
              enddo
              row = row - 1
   	      goto 90
           endif
 	endif

c____________________________________________________________________
c       
ccc	Task completed: answer found?
c       
	if (solution_found) then
cjfm	   write (F_OUTPUT,*) Nbest, .false. ! Success
	   nmax = Nbest
	else
cjfm	   write (F_OUTPUT,*) -1, .true. ! Failure
	   nmax = -1
        endif
 	
       ! NOTE: Only the first value is used by the master
       !	The second is needed for the Frontier framework

	return
	end


c____________________________________________________________________
c____________________________________________________________________
c

	subroutine ShowResult(ptn, ndelta, N, b, bh)
	implicit none
	include "parameter.h"

	integer N, ndelta, B(s,s), ptn(s)
	integer*8 BH(s,s)
	double precision dp_rho
	integer ndet, fak, i, j


	! Show pointer vector
	!
	write(*,*) '   '
        write(*,'(a7, 8i6)') 'Found:',(ptn(i),i=1,s)

	! Show N, delta and rho
	!
        ndet = 1
	fak = 1
        dp_rho = 1.d0
        do i=1,s
	   fak = fak*i
           ndet = ndet * bh(i,i)
           dp_rho = dp_rho*ndelta
        enddo
        dp_rho = (dp_rho/ndet)/fak
        write(*,990)'N =',ndet,'   delta = ',ndelta,
     &			'  rho =',dp_rho
990   	format ('  ',a5,i8,a12,i5,a8,f10.5)

	! Show the resulting matrix
	!	    
        do i = 1,s
           write(*,991) (b(i,j),j=1,s)
        enddo
        write(*,*)
        do i = 1,s
           write(*,991) (bh(i,j),j=1,s)
        enddo
991	format (' ',6i8)

	return
	end
