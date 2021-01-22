
	subroutine entire_hnf(s, B, sign, flag,ierror)
c
ccc 	This routine takes a row*s integer matrix where the
ccc	row-1 first rows are in hnf and manipulate the last
ccc	row to get it all in hnf.
c
	integer s
	integer*8 B(s,s)
	integer ierror
c
ccc	local parameters
c
	integer i,j, hcf, lamda, mu, k, multy
	integer gcd, flag, tmp, row, sign
	integer*8 pivot
c
ccc
c
        sign = 1
        ierror = 0
        do row = 2,s
	 do i = 1, row-1
10         if (b(row,i)*b(i,i).ne.0) then
              if (abs(b(row,i)).lt.abs(b(i,i))) then
                 pivot = b(i,i)/b(row,i)
                 do j = i,s
                   b(i,j) = b(i,j) - pivot*b(row,j)
                 enddo
              else
                 pivot = b(row,i)/b(i,i)
                 do j = i,s
                   b(row,j) = b(row,j) - pivot*b(i,j)
                 enddo
              endif
              goto 10
           endif
c
ccc We've made a zero. If neccesary swap to have it in b(row,i)
c
           if (b(i,i).eq.0) then
              do j = i,s
                 tmp = b(i,j)
                 b(i,j) = b(row,j)
                 b(row,j) = tmp
              enddo
              sign = -sign
           endif
         enddo
        enddo
c
ccc If 'flag' is non-negative then
ccc Make sure the diagonal elements are non-negative
c
        if (flag.ge.0) then
         do i = 1,s
           if (b(i,i).lt.0) then
              do j = i,s
                 b(i,j) = -b(i,j)
              enddo
           elseif(b(i,i).eq.0) then
              ierror = -1
              return
           endif
         enddo
c
ccc	Now the matrix is upper triangular, only if flag > 0 continue
ccc	making all b(i,j) between 0, b(j,j) 
c
         if (flag.gt.0.and.ierror.eq.0) then
          do j = 2,s
             do i = 1,j-1  
                if (b(i,j).lt.0) then
                   multy = -b(i,j)/b(j,j)
                   if (mod(b(i,j),b(j,j)).ne.0) multy = multy + 1
                elseif(b(i,j).ge.b(j,j)) then
                   multy = -b(i,j)/b(j,j)
	        else
	           multy = 0
                endif
                do k = j,s
                   b(i,k) = b(i,k) + multy*b(j,k)
                enddo
             enddo
           enddo
         endif
        endif
	return
	end



