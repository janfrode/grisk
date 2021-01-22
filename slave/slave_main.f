		program slave_program
	implicit none
        include "parameter.h"
	include "frontier.h"
c
ccc
c
	integer ilist(s,idim)
	integer jlist(s,jdim)
	integer ksmall(jdim)
	integer jount, kount 
c
ccc	Some more declarations
c
	integer i, j, ierror
	integer nmax, nhope, ndelta, BestSolution(s)
c
ccc	Frontier stuff
c
	character*30 fileInput, fileOutput, fileStats
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
	fileInput = 'slave_input.dat'
	open (unit=F_INPUT,file=fileInput,form='formatted')

	fileOutput = 'slave_output.dat'
	open (unit=F_OUTPUT,file=fileOutput,form='formatted')

	fileStats = 'slave_stats.dat'
	open (unit=F_STATS,file=fileStats,form='formatted')

c____________________________________________________________________
c
ccc	Read parameters from the input file
c
	read(F_INPUT,*) ndelta, Nhope, Nmax

	if (show_task) then
	   write(*,970) 'starting with delta=',ndelta, '   N=(', Nhope, 
     $			'..', Nmax, ' )'
970	   format(a25, i2, a6, i3, a2, i3, a2)
	endif

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
ccc	Build the kjlist
c
        call kjlist(ndelta,kount,ilist,ksmall,jount,jlist)

c
ccc	This is the loop over all possibilities for a given dataset
c
	call nyzvis_s(ndelta,kount,jount,BestSolution,
     &             nhope, nmax, ilist, jlist, 
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
	write(F_STATS,'(5i5)') (BestSolution(i),i=1,s)
	write(F_STATS,'(f18.0)') n_count
	write(F_STATS,'(f18.0)') d_count(s)
	do i=1,s-1 
	   write(F_STATS,'(2f18.0)') (n_good(i,j),j=1,2)
	enddo
	write(F_STATS,'(f18.0)') time1

c____________________________________________________________________
c____________________________________________________________________
c
	close (unit=F_INPUT)
	close (unit=F_OUTPUT)
	close (unit=F_STATS) 

	end


