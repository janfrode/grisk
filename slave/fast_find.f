        subroutine fast_find (b, d_return, d_target)
c
ccc     This routine is for arbitray dimension s 
ccc     It finds whether or not a a lattice, defined by b in hnf, 
ccc     has a degree less or equal to d_target.
ccc     On return d_return = -1 if the degree is larger than
ccc     d_target, d_return = d_target in the case where the degree
ccc     is exactly d_target. If 0< d_return < d_target than the
ccc     actual degree is less or equal to d_return.
c
        include 'parameter.h'
        integer*8 b(s,s)
        integer d_target, d_return
c
ccc Local variables
c
        integer deg_this, ps0, i, ind
       integer low(s), up(0:s), p(0:s), lambda(s), d_act(0:s)
	   integer*8 tmp(s)
        logical debug
        parameter (debug = .false.)
c
ccc
c
        d_return = -1
        do deg_this = 1,d_target
	  ind = 1
          low(1) = 0          
          up(1) = deg_this		
	  p(1) = low(1) - 1
          tmp(1) = p(1)
          d_act(0) = 0
10	  if (ind.ge.1) then
             p(ind) = p(ind) + 1
             tmp(ind) = tmp(ind)+1
             d_act(ind) = d_act(ind-1) + abs(p(ind))
             if (ind.eq.s) then
                if (d_act(s-1).eq.0) then
                  d_act(s) = b(s,s)
                  p(s) = b(s,s)
                else
                  ps0 = lambda(1)*b(1,s)
                  do i = 2,s-1
                     ps0 = ps0 + lambda(i)*b(i,s)
                  enddo
                  lambda(s) = nint(-real(ps0)/b(s,s))         
	          p(s) = ps0 + lambda(s)*b(s,s)
                  d_act(s) = d_act(s-1) + abs(p(s))
                endif
                if (d_act(s).lt.d_target) then
                  d_return = d_act(s)
                  return
                elseif (d_act(s).eq.d_target) then
                  d_return = d_target
                endif
                ind = ind -1  
	      else
	        if (mod(tmp(ind),b(ind,ind)).eq.0) then
                  lambda(ind) = tmp(ind)/b(ind,ind)
                  ind = ind + 1
                  if (ind.lt.s) then 
                    low(ind) = -up(ind-1) + abs(p(ind-1))
                    up(ind) = up(ind-1) - abs(p(ind-1))
                    p(ind) = low(ind) - 1
                    tmp(ind) = p(ind)
                    do i = 1,ind-1
                       tmp(ind) = tmp(ind) - lambda(i)*b(i,ind)
                    enddo
                  else
                    if (d_act(ind-1).gt.d_target) then 
                       up(s) = 1
                       p(s) = 1
                    else
                       up(s) = 1
                       p(s) = 0
                    endif
                  endif
	        endif
              endif
20	      if (p(ind).ge.up(ind).and.ind.ge.1) then
                ind = ind - 1
                goto 20
              endif
              goto 10
	    endif
          enddo             
          return
          end
