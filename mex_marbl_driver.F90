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
  character(len=320) put_call
  character(len=640) message
  integer status, init_result, nt, str_cnt

  ! Allocatable array for storing MARBL domain information
  ! (layer thickness, interface depth, and layer center depth)
  integer :: nlev
  real*8, allocatable, dimension(:) :: delta_z, zw, zt

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
      ! pack marbl domain information into arrays
      nlev = 5
      allocate(delta_z(nlev), zt(nlev), zw(nlev))
      delta_z = 1.
      zw = (/1., 2., 3., 4., 5./)
      zt = (/0.5, 1.5, 2.5, 3.5, 4.5/)

      ! call init_marbl()
      call mexPrintf('MEX-file note: calling init\n')
      init_result = init_marbl(delta_z, zw, zt, nlev, nt)
      deallocate(delta_z, zw, zt)

      ! Return tracer count (unless init_marbl returned an error)
      if (init_result .eq. 0) then
        ! Return tracer count
        plhs(1) = mxCreateDoubleMatrix(1,1,0)
        y_ptr = mxGetPr(plhs(1))
        size = 1
        nt_r8 = nt
        call mxCopyReal8ToPtr(nt_r8,y_ptr,size)
      else
        call mexPrintf('MEX-file note: initialization failed!\n')
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


