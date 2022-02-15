! Unit test for the gdt2gds call in NCEPLIBS-g2
!
! 02-15-2022 Brian Curtis
program test_gdt2gds
    implicit none

    ! Section 3.
    integer, parameter :: igdstmplen = 19
    integer, parameter :: idefnum = 0
    integer, parameter :: ndata = 4
    ! See https://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_doc/grib2_sect3.shtml
    integer :: igds(5) = (/ 0, ndata, 0, 0, 0/)
    ! See https://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_doc/grib2_temp3-0.shtml
    integer :: igdstmpl(igdstmplen) = (/ 0, 1, 1, 1, 1, 1, 1, 2, 2, 0, 0, 45, 91, 0, 55, 101, 5, 5, 0 /)
    integer :: ideflist(idefnum)
    integer :: kgds, igrid, iret

    call gdt2gds(igds, igdstmpl, idefnum, ideflist, kgds, igrid, iret)

    if (iret .ne. 0) stop 3
    print *, 'kgds, igrid: ', kgds, igrid
end program test_gdt2gds