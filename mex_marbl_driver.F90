#include "fintrf.h"

subroutine mexFunction(nlhs, plhs, nrhs, prhs)

  use marbl_interface_wrapper_mod

  implicit none

  ! mexFunction arguments:
  mwPointer plhs(*), prhs(*)
  integer nlhs, nrhs

  ! Function declarations:
  integer*4 mxGetString
  mwPointer mxGetPr
  mwPointer mxCreateDoubleMatrix
  integer mxIsNumeric
  mwPointer mxGetM, mxGetN

  ! Pointers to input/output mxArrays:
  mwPointer x_ptr, y_ptr

  ! Array information:
  mwPointer mrows, ncols
  mwSize size, maxbuf
  parameter(maxbuf=80)

  ! Arguments for computational routine:
  real*8  x_input, y_output, nt_r8
  character(len=80) marbl_phase
  character(len=160) message
  integer status, init_result, nt, str_cnt

  ! Allocatable array for storing MARBL log
  character(len=512), allocatable :: str_array(:)
  integer :: str_ind

  if (nrhs .eq. 0) then
    call mexPrintf('Need to include phase argument!\n')
    return
  end if

  size = 80
  status = mxGetString(prhs(1), marbl_phase, maxbuf)
  select case (trim(marbl_phase))
    case ('init')
      call mexPrintf('MEX-file note: calling init\n')
      ! Call the computational subroutine.
      init_result = init_marbl(nt)
      if (init_result .ne. 0) then
        call mexPrintf('MEX-file note: initialization failed!\n')
      else
        ! Return tracer count
        plhs(1) = mxCreateDoubleMatrix(1,1,0)
        y_ptr = mxGetPr(plhs(1))
        size = 1
        nt_r8 = nt
        call mxCopyReal8ToPtr(nt_r8,y_ptr,size)
      end if
#if 0
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
    case ('print log')
      call get_marbl_log(str_array, str_cnt)
      if (allocated(str_array)) then
        do str_ind = 1, str_cnt+1
          call mexPrintf(trim(str_array(str_ind)))
          call mexPrintf("\n")
        end do
        deallocate(str_array)
      else
        call mexPrintf('Mex-file note: error retrieving MARBL log\n')
      end if

    case ('print timers')
      call get_timer_summary(str_array, str_cnt)
      if (allocated(str_array)) then
        do str_ind = 1, str_cnt+5
          call mexPrintf(trim(str_array(str_ind)))
          call mexPrintf("\n")
        end do
        deallocate(str_array)
      else
        call mexPrintf('Mex-file note: error retrieving MARBL timers\n')
      end if

    case DEFAULT
      write(message, '(3A)') 'Unknown phase: ', trim(marbl_phase), '\n'
      call mexPrintf(message)
  end select

  return

end subroutine mexFunction


