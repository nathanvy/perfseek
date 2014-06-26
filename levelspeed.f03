!to do:  test this against Holtzauge's solver

! It is assumed that the flow field will exhibit parabolic
!characteristic behaviour and so necessitates a time-marching
!solution of the entire problem domain.  Which is fine because
!this is going to be a rather crude performance estimate anyways,
!and will not involve grid-mesh generation around a defined
!boundary (i.e. no space-marching).  
! Rather, since we're only doing what amounts to a SWAG
!of the performance qualities, the aircraft is abstracted away into 
!a sort of arbitrary body having the required aerodynamic
!properties.  Users wanting a solution of the fluid flows over a
!given part of a defined model or grid/mesh should investigate
!traditional CFD suites such as Ansys Fluent or OpenFOAM. -nvy

subroutine levelspeed (T0, RHO0, P0, GAMMA, MOLARMASSAIR, HEATRATIO, GASCONSTANT, G, S, oswald, wingspan, Cd0, &
     diameter, Clmax, Cprop, gearratio, Mplim, Cmprop, enginespeed, HPbrake, altitude, n, &
     weight, HP2WATTS, pi) bind(c, name='c_levelspeed')
  use,intrinsic :: iso_c_binding
  implicit none
  real(c_double), intent(in):: T0, RHO0, P0, GAMMA, MOLARMASSAIR, HEATRATIO, GASCONSTANT, G
  real(c_double), intent(in):: S, oswald, wingspan, Cd0, diameter, Clmax, Cprop, gearratio
  real(c_double), intent(in):: Mplim, Cmprop, enginespeed, HPbrake, altitude, n, weight
  real(c_double), intent(in):: HP2WATTS, pi
  
  real(c_double) :: Tambient, Pexponent, Pambient, mach, rho, Texhaust, Cl, Cd, drag, X, Y
  real(c_double) :: vtrue=100, Mprop, thrust, etamax, a, time=0, timestep=1, m, Pbrake, h
  integer :: iterations=0
  
  !     write(*,*) "Please enter the altitude in feet, load factor, weight in pounds, and engine rated power at altitude in horsepower:"
  !     read(*,*) h, n, weight, Pbrake
  
  write(*,*) "Setting up preliminaries..."
  !conversions, imperial units are for retards
  h = altitude * 0.3048
  Pbrake = HPbrake * HP2WATTS
  m = weight * 4.448 / G
  
  !initials
  Tambient = T0 - GAMMA*h
  Pexponent = (MOLARMASSAIR * G) / (GASCONSTANT * GAMMA)
  Pambient = P0 * ( 1 - (GAMMA*h/T0) )**Pexponent
  mach = sqrt( HEATRATIO * GASCONSTANT * Tambient / MOLARMASSAIR )
  rho = RHO0*(Pambient/P0)*(T0/Tambient)
  Texhaust = Pbrake * 0.0005 !yep we're fudging it
  
  !to do: move these to subroutines
  Cl = n*m*g / (0.5*rho*S*(vtrue**2))
  Cd = Cd0 + 0.068*Cl !Kaero = 0.068 for this aircraft
  drag = 0.5*rho*Cd*S*(vtrue**2)
  X = (vtrue**3)*0.5*pi*rho*(diameter**2)/Pbrake
  Y = sqrt( (X/3)**3 + (X/2)**2)
  etamax = ( (X/2) + Y )**(1/3) + ( (X/2) - Y )**(1/3) !yuck
  Mprop = (1/mach)*sqrt(vtrue**2 + (pi*diameter*enginespeed*gearratio)**2)
  thrust = Cprop*(etamax - etacl(Mprop, Mplim, Cmprop))*(Pbrake/vtrue) + Texhaust
  a = (thrust - drag)/m
  
  write(*,*) "Done.  Iterating..."
  
  do while (abs(a) > 0.1)
     vtrue = vtrue + (a*timestep)
     a = Texcess(vtrue)
     time = time + timestep
     iterations = iterations + 1
     
  end do
  write(*,*) "Done.  Solution converged after", iterations, "iterations."
  
  write(*,*) "Max speed at this altitude estimated as:", vtrue, "m/s"
  
contains
  
  !excess thrust
  real function Texcess(vtrue)
    use,intrinsic::iso_c_binding
    implicit none
    real(c_double), intent(in) :: vtrue
    Cl = n*m*g / (0.5*rho*S*(vtrue**2))
    Cd = Cd0 + 0.068*Cl !Kaero = 0.068 for this aircraft
    drag = 0.5*rho*Cd*S*(vtrue**2)     
    X = (vtrue**3)*0.5*pi*rho*(diameter**2)/Pbrake
    Y = sqrt( (X/3)**3 + (X/2)**2)
    etamax = ( (X/2) + Y )**(1/3) + ( (X/2) - Y )**(1/3) !yuck
    Mprop = (1/mach)*sqrt(vtrue**2 + (pi*diameter*enginespeed*gearratio)**2)
    thrust = Cprop*(etamax - etacl(Mprop, Mplim, Cmprop))*(Pbrake/vtrue) + Texhaust
    !write(*,*) drag, thrust, mprop, etamax, etacl(Mprop, Mplim, Cmprop)
    Texcess = (thrust - drag)/m
  end function Texcess
  
  !prop-tip compressibility loss
  real function etacl(Mprop, Mplim, Cmprop)
    use,intrinsic::iso_c_binding
    implicit none
    real(c_double), intent(in) :: Mprop, Mplim, Cmprop
    if(Mprop > Mplim) then
       etacl = Cmprop * (Mprop - Mplim)
    else
       etacl = 0
    end if
  end function etacl
end subroutine levelspeed
