#include "fintrf.h"

subroutine mexFunction(nlhs, plhs, nrhs, prhs)

  use marbl_interface_wrapper_mod
  use iso_c_binding

  implicit none

  ! mexFunction arguments:
  mwPointer plhs(*), prhs(*)
  integer nlhs, nrhs

  ! Function declarations:
  integer*4 mxGetString
  mwPointer mxCreateString
  mwPointer mxGetPr
  mwPointer mxCreateDoubleMatrix
  integer mxIsNumeric
  mwPointer mxGetM, mxGetN
  mwPointer string_return(1)
  integer mexCallMATLAB

  ! Pointers to input/output mxArrays:
  mwPointer x_ptr, y_ptr

  ! Array information:
  mwPointer mrows, ncols
  mwSize size, maxbuf
  parameter(maxbuf=80)

  ! Arguments for string array
  integer, parameter :: max_log_entry_cnt = 601
  integer, parameter :: max_str_len = max_log_entry_cnt*char_len
  ! Arguments for computational routine:
  real*8  x_input, y_output, nt_r8
  character(len=80) marbl_phase
  character(len=char_len) put_call
  character(len=char_len) message
  character(len=max_str_len) log_as_single_string
  integer status, init_result, nt, str_cnt, n

  ! Allocatable array for storing MARBL domain information
  ! (layer thickness, interface depth, and layer center depth)
  integer :: nlev
  real*8, allocatable, dimension(:) :: delta_z, zw, zt

  ! Allocatable array for storing MARBL log
  character(len=char_len), pointer  :: str_array(:)
  type(c_ptr)                       :: str_array_ptr
  integer :: str_ind

  if (nrhs .eq. 0) then
    call mexPrintf('Need to include phase argument!\n')
    return
  end if

  size = 80
  status = mxGetString(prhs(1), marbl_phase, maxbuf)
  select case (trim(marbl_phase))
    case ('put setting')
      call mexPrintf('MEX-file note: calling put_setting()\n')
      if (nrhs .eq. 1) then
        call mexPrintf('Need to include a variable to put!\n')
        return
      end if
      status = mxGetString(prhs(2), put_call, maxbuf)
      write(message, "(3A)") '  Setting: ', trim(put_call), '\n'
      call mexPrintf(trim(message))
      status = put_setting(put_call)
      if (status .ne. 0) &
        call mexPrintf('Error calling put_setting()')
    case ('init')
      ! Did user provide proper inputs?
      if (nrhs .ne. 4) then
        call MexPrintf("'init' requires 3 additional arguments: delta_z, zw, zt")
        return
      end if

      ! pull arrays out of prhs
      ! (for now we trust user to passing 1-d arrays with same size
      nlev = mxGetM(prhs(2))
      allocate(delta_z(nlev), zt(nlev), zw(nlev))

      ! prhs(2) -> delta_z
      x_ptr = mxGetPr(prhs(2))
      call mxCopyPtrToReal8(x_ptr, delta_z, nlev)

      ! prhs(3) -> zw
      x_ptr = mxGetPr(prhs(3))
      call mxCopyPtrToReal8(x_ptr, zw, nlev)

      ! prhs(4) -> zt
      x_ptr = mxGetPr(prhs(4))
      call mxCopyPtrToReal8(x_ptr, zt, nlev)

      ! call init_marbl()
      call mexPrintf('MEX-file note: calling init\n')
      init_result = init_marbl(delta_z, zw, zt, nlev, nt)
      deallocate(delta_z, zw, zt)

      ! Return tracer count and status log contents (unless init_marbl returned an error)
      if (init_result .eq. 0) then
        ! Return log (as a char_len x str_cnt array
        call get_marbl_log(str_array_ptr, str_cnt)
        allocate(str_array(str_cnt))
        call c_f_pointer(str_array_ptr, str_array, shape=[str_cnt])
        if (str_cnt .ge. max_log_entry_cnt) then
          write(message, "(A,I0,A,I0,A)") "Log has ", str_cnt, &
                         " entries, which exceeds max  length. Returning first ", &
                         max_log_entry_cnt-1, " entries."
          str_cnt = max_log_entry_cnt-1
        end if
        log_as_single_string = ''
        do n=1, str_cnt
          write(log_as_single_string, "(2A)") log_as_single_string(:(n-1)*char_len), &
                                              trim(str_array(n))
        end do
        deallocate(str_array)
        n = str_cnt*char_len + 1
        ! Need to pad the array to avoid getting matlab gibberish when printing
        log_as_single_string(n:n) = '.'
        string_return(1) = mxCreateString(log_as_single_string)
        call mxSetM(string_return(1), char_len)
        call mxSetN(string_return(1), str_cnt)
        n = mexCallMATLAB(1, plhs, 1, string_return, 'transpose')
        call mxDestroyArray(string_return(1))

        ! Also return tracer count
        plhs(2) = mxCreateDoubleMatrix(1,1,0)
        y_ptr = mxGetPr(plhs(2))
        size = 1
        nt_r8 = nt
        call mxCopyReal8ToPtr(nt_r8,y_ptr,size)

      else
        call mexPrintf('MEX-file note: initialization failed!\n')
      end if
#if 0
    case ('print log')
      call get_marbl_log(str_array_ptr, str_cnt)
      allocate(str_array(str_cnt))
      call c_f_pointer(str_array_ptr, str_array, shape=[str_cnt])
      do str_ind = 1, str_cnt+1
        write(message, "(I0,3A)") str_ind, ') ', trim(str_array(str_ind)), '\n'
        call mexPrintf(trim(message))
      end do
      write(message, "(2A)") str_array(333), '\n'
      call mexPrintf(trim(message))

    case ('surface')
      if (compute_marbl_surface_fluxes(y_output) .ne. 0) then
        call mexPrintf('Mex-file note: error computing surface fluxes\n')
      else
        plhs(1) = mxCreateDoubleMatrix(1,1,0)
        y_ptr = mxGetPr(plhs(1))
        size = 1
        call mxCopyReal8ToPtr(y_output,y_ptr,size)
      end if
    case ('interior')
      if (compute_marbl_interior_tendencies(y_output) .ne. 0) then
        call mexPrintf('Mex-file note: error computing interior tendencies\n')
      else
        plhs(1) = mxCreateDoubleMatrix(1,1,0)
        y_ptr = mxGetPr(plhs(1))
        size = 1
        call mxCopyReal8ToPtr(y_output,y_ptr,size)
      end if
#endif
    case ('shutdown')
      call mexPrintf('MEX-file note: shutting down\n')
      if (shutdown_marbl() .ne. 0) then
        call mexPrintf('Mex-file note: error shutting down MARBL\n')
      end if
#if 0
    case ('print timers')
      call get_timer_summary(str_array, str_cnt)
      do str_ind = 1, str_cnt+5
        call mexPrintf(trim(str_array(str_ind)))
        call mexPrintf("\n")
      end do
      deallocate(str_array)
#endif
    case DEFAULT
      write(message, '(3A)') 'Unknown phase: ', trim(marbl_phase), '\n'
      call mexPrintf(message)
  end select

  return

end subroutine mexFunction


