module marbl_interface_wrapper_mod

  use marbl_interface, only : marbl_interface_class

  implicit none
  public
  save

  type(marbl_interface_class) :: marbl_instance

  interface put_setting
    module procedure :: put_setting_without_line_len
    module procedure :: put_setting_with_line_len
  end interface put_setting

  private :: get_return_code
  private :: put_setting_without_line_len
  private :: put_setting_with_line_len

contains

! =============================================================================

  function init_marbl(nt)

    use marbl_kinds_mod, only : r8
    use marbl_constants_mod, only : p5
    use marbl_constants_mod, only : c1

    integer, intent(out) :: nt
    integer :: init_marbl

    ! For now, domain description is hard-coded
    ! But this should be moved up to the driver and passed as arguments
    integer, parameter :: nlev = 5
    real(kind=r8), dimension(nlev) :: delta_z, zw, zt

    integer :: n

    delta_z(:) = c1
    zw(1) = c1
    zt(1) = p5*zw(1)
    do n=2,nlev
      zw(n) = zw(n-1) + delta_z(n-1)
      zt(n) = p5*(zw(n-1) + zw(n))
    end do

    call marbl_instance%init(gcm_num_levels = nlev,                &
                             gcm_num_PAR_subcols = 1,              &
                             gcm_num_elements_surface_forcing = 1, &
                             gcm_delta_z = delta_z,                &
                             gcm_zw = zw,                          &
                             gcm_zt = zt,                          &
                             marbl_tracer_cnt = nt)
    init_marbl = get_return_code()

  end function init_marbl

! =============================================================================

  function shutdown_marbl()

    integer :: shutdown_marbl

    call marbl_instance%shutdown()
    shutdown_marbl = get_return_code()

  end function shutdown_marbl

! =============================================================================

  ! Use this subroutine to print the log when you have access to stdout
  subroutine print_marbl_log()

    use marbl_logging, only : marbl_status_log_entry_type

    type(marbl_status_log_entry_type), pointer :: msg_ptr

    ! Determine number of messages
    msg_ptr => marbl_instance%StatusLog%FullLog
    do while (associated(msg_ptr))
      write(*,"(A)") trim(msg_ptr%LogMessage)
      msg_ptr => msg_ptr%next
    end do

  end subroutine print_marbl_log

! =============================================================================

  ! Use this subroutine to return the log to a fortran driver when you do not
  ! have access to stdout
  subroutine get_marbl_log(log_array, msg_cnt)

    use marbl_logging, only : marbl_status_log_entry_type

    character(len=*), allocatable, intent(out) :: log_array(:)
    integer,                       intent(out) :: msg_cnt

    type(marbl_status_log_entry_type), pointer :: msg_ptr

    ! Determine number of messages
    msg_cnt = 0
    msg_ptr => marbl_instance%StatusLog%FullLog
    do while (associated(msg_ptr))
      msg_cnt = msg_cnt + 1
      msg_ptr => msg_ptr%next
    end do

    ! Allocate memory for messages to return
    allocate(log_array(msg_cnt+1))
    log_array = ''

    ! Copy messages to log_array
    msg_cnt = 0
    msg_ptr => marbl_instance%StatusLog%FullLog
    do while (associated(msg_ptr))
      msg_cnt = msg_cnt + 1
      log_array(msg_cnt) = trim(msg_ptr%LogMessage)
      msg_ptr => msg_ptr%next
    end do

    call marbl_instance%StatusLog%erase()
    marbl_instance%StatusLog%labort_marbl = .false.

  end subroutine get_marbl_log

! =============================================================================

  ! Use this subroutine to print the timer summary when you have access to stdout
  subroutine print_timer_summary()

    integer :: n

    ! Header block of text
    write(*,"(A)") ''
    write(*,"(A)") '-------------'
    write(*,"(A)") 'Timer Summary'
    write(*,"(A)") '-------------'
    write(*,"(A)") ''

    ! Get timers from instance
    do n = 1, marbl_instance%timer_summary%num_timers
      write(*,"(A, ': ', F11.3, ' seconds')") trim(marbl_instance%timer_summary%names(n)),        &
                                              marbl_instance%timer_summary%cumulative_runtimes(n)
    end do

  end subroutine print_timer_summary

! =============================================================================

  ! Use this subroutine to return the log to a fortran driver when you do not
  ! have access to stdout
  subroutine get_timer_summary(timer_array, timer_cnt)

    character(len=*), allocatable, intent(out) :: timer_array(:)
    integer,                       intent(out) :: timer_cnt

    integer :: n

    timer_cnt = marbl_instance%timer_summary%num_timers
    allocate(timer_array(timer_cnt+5))

    ! Header block of text
    write(timer_array(1),"(A)") ''
    write(timer_array(2),"(A)") '-------------'
    write(timer_array(3),"(A)") 'Timer Summary'
    write(timer_array(4),"(A)") '-------------'
    write(timer_array(5),"(A)") ''

    ! Get timers from instance
    do n = 1, timer_cnt
      write(timer_array(n+5),"(A, ': ', F11.3, ' seconds')") trim(marbl_instance%timer_summary%names(n)),        &
                                                             marbl_instance%timer_summary%cumulative_runtimes(n)
    end do

  end subroutine get_timer_summary

! =============================================================================

  function put_setting_without_line_len(line_in) result(put_setting)

    character(len=*), intent(in) :: line_in
    integer :: put_setting

    call marbl_instance%put_setting(line_in)
    put_setting = get_return_code()

  end function put_setting_without_line_len

! =============================================================================

  function put_setting_with_line_len(line_in, line_len) result(put_setting)

    integer,                 intent(in) :: line_len
    character(len=line_len), intent(in) :: line_in
    integer :: put_setting

    call marbl_instance%put_setting(line_in)
    put_setting = get_return_code()

  end function put_setting_with_line_len

! =============================================================================

  function get_return_code()

    integer :: get_return_code

    if (marbl_instance%StatusLog%labort_marbl) then
      get_return_code = -1
    else
      get_return_code = 0
    end if

  end function get_return_code

! =============================================================================

end module marbl_interface_wrapper_mod
