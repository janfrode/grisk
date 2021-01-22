	subroutine slave_program(ndelta, Nhope, Nmax, task, matr1, matr2, 
     &      matr3, matr4, matr5, stat1, stat2, stat3, stat4, stat5, 
     &      stat6, stat7, stat8, stat9, stat10, stat11)

      implicit none
      include "parameter.h"
      include "frontier.h"
c
ccc
c
	integer matr1, matr2, matr3, matr4, matr5
	integer*8 stat1, stat2 
	integer stat3, stat4, stat5, stat6, stat7, stat8, stat9, stat10, stat11

	integer ilist(s,idim)
	integer jlist(s,jdim)
	integer ksmall(jdim)
	integer jount, kount 
c
ccc	Some more declarations
c
	integer i, j, ierror
	integer task, nmax, nhope, ndelta , BestSolution(s)
c
ccc	Frontier stuff
c
c	character*30 fileInput, fileOutput, fileStats
c
ccc	Statistics stuff
c
	double precision n_count,n_good((s-1),2), d_count(s), dp_jount
c
ccc	Timing stuff
c
        real*4 etime 
        real*4 tarray(2), time1, tmin
	real*4 time_total, previous_time
c
ccc	Logical flags
c
	logical full_debug_stats, show_timing_stats, show_task
	parameter (full_debug_stats = .false.)
	parameter (show_timing_stats = .false.)
	parameter (show_task = .false.)

c____________________________________________________________________
c____________________________________________________________________
c
c	INITIALIZATION
c____________________________________________________________________

c____________________________________________________________________
c
ccc	Set up files
c
c	fileInput = 'slave_input.dat'
c	open (unit=F_INPUT,file=fileInput,form='formatted')
c
c	fileOutput = 'slave_output.dat'
c	open (unit=F_OUTPUT,file=fileOutput,form='formatted')
c
c	fileStats = 'slave_stats.dat'
c	open (unit=F_STATS,file=fileStats,form='formatted')
c
c____________________________________________________________________
c
ccc	Read parameters from the input file
c
c	read(F_INPUT,*) ndelta, Nhope, Nmax
c
c	if (show_task) then
c	   write(*,970) 'starting with delta=',ndelta, '   N=(', Nhope, $			'..', Nmax, ' )'
c970	   format(a25, i2, a6, i3, a2, i3, a2)
c	endif

	
c____________________________________________________________________
c____________________________________________________________________
c
c	CALCULATION
c____________________________________________________________________

c
ccc	*** TIMING STARTS ***
c
        time1 = etime(tarray)
c
c
ccc	Build the kjlist
c
        call kjlist(ndelta,kount,ilist,ksmall,jount,jlist)

c
ccc	This is the loop over all possibilities for a given dataset
c

	call nyzvis_s(ndelta,kount,jount,BestSolution,
     &             nhope, nmax, ilist, jlist, task,
     &             n_count, n_good, d_count)

c
ccc	*** TIMING ENDS ***
c
	time1 = etime(tarray) - time1
	tmin = time1/60.0

c____________________________________________________________________
c____________________________________________________________________
c
c	STATISTICS
c____________________________________________________________________

c
ccc	Full debug statistics
c
	if (full_debug_stats) then 
	   dp_jount = jount
	   write (*,*)  '    [Debug statistics slave]'
	   write (*,980)'No. of cand. lattices:',kount**(s-1)*dp_jount
	   write (*,980)'    No. of HNF computed:  ',n_count
	   write (*,980)'    No. of del computed:  ',d_count(s)
	   write (*,*)  '  '
980	   format(' ', a24, f18.0)
	   write(*,*)'                     bad      sing   tot.saving'
	   do i = 2, s-1
	      write (*,997) n_good(i,1), n_good(i,2),(n_good(i,1)
     $			+n_good(i,2)) *kount**(s-i)
997	      format (' ',2x,3f15.0)
	   enddo
	endif 

	if (show_timing_stats) then
	   write (0,*)  '    [Timing statistics slave]'
	   write (0,992) tmin,time1
992	   format (' Elapsed time =',F11.2,' min. =',f11.0,'seconds.')
	endif 
   
c____________________________________________________________________
c
ccc	Save statistics for the master
c
c	write(F_STATS,'(5i5)') (BestSolution(i),i=1,s)

	matr1 = BestSolution(1)
	matr2 = BestSolution(2)
	matr3 = BestSolution(3)
	matr4 = BestSolution(4)
	matr5 = BestSolution(5)

c	write(F_STATS,'(f18.0)') n_count
	stat1 = int(n_count)
c	write(*,'(f18.0)') n_count
c	write(*,'(f18.0)') stat1
c	write(F_STATS,'(f18.0)') d_count(s)
	stat2 = int(d_count(s))
c	write(*,'(f18.0)') d_count(s)
	stat3 = int(n_good(1,1))
	stat4 = int(n_good(1,2))
	stat5 = int(n_good(2,1))
	stat6 = int(n_good(2,2))
	stat7 = int(n_good(3,1))
	stat8 = int(n_good(3,2))
	stat9 = int(n_good(4,1))
	stat10 = int(n_good(4,2))
c	do i=1,s-1 
c	   write(F_STATS,'(2f18.0)') (n_good(i,j),j=1,2)
c	enddo
c	write(F_STATS,'(f18.0)') time1
	stat11 = int(time1)
c
c____________________________________________________________________
c____________________________________________________________________
c
c	close (unit=F_INPUT)
c	close (unit=F_OUTPUT)
c	close (unit=F_STATS) 

	return
	end


