module marbl_interface_wrapper_mod

  use marbl_interface, only : marbl_interface_class

  implicit none
  public
  save

  type(marbl_interface_class) :: marbl_instance

contains

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
    if (marbl_instance%StatusLog%labort_marbl) then
      init_marbl = -1
    else
      init_marbl = 1
    end if

  end function init_marbl

end module marbl_interface_wrapper_mod
