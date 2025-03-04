!> @file
!> @brief This Fortran module extract or store arbitrary size values
!> between packed bit string and unpacked array.
!> @author Stephen Gilbert @date 2004-04-27

!> This subrountine is to extract arbitrary size values from a
!> packed bit string, right justifying each value in the unpacked
!> array without skip and interations.
!>
!> This should be used when input array IN has only one element. If IN
!> has more elements, use G2_SBYTESC().
!>
!> @param[in] IN Array input.
!> @param[out] IOUT Unpacked array output.
!> @param[in] ISKIP Initial number of bits to skip.
!> @param[in] NBYTE Number of bits of each integer in IN to take.
!>
!> @author Stephen Gilbert @date 2004-04-27
subroutine g2_gbytec(in, iout, iskip, nbyte)
    implicit none

    character*1, intent(in) :: in(*)
    integer, intent(inout) :: iout(*)
    integer, intent(in) :: iskip, nbyte
    call g2_gbytesc(in, iout, iskip, nbyte, 0, 1)
    return
end subroutine g2_gbytec

!> This subrountine is to put arbitrary size values into a packed bit
!> string, taking the low order bits from each value in the unpacked
!> array without skip and interation.
!>
!> This should be used when input array IN has only one element. If IN
!> has more elements, use G2_SBYTESC().
!>
!> @param[out] OUT packed array output
!> @param[in] IN unpacked array input
!> @param[in] ISKIP initial number of bits to skip
!> @param[in] NBYTE Number of bits of each integer in OUT to fill.
!>
!> @author Stephen Gilbert @date 2004-04-27
subroutine g2_sbytec(out, in, iskip, nbyte)
    implicit none

    character*1, intent(inout) :: out(*)
    integer, intent(in) :: in(*)
    integer, intent(in) :: iskip, nbyte
    call g2_sbytesc(out, in, iskip, nbyte, 0, 1)
    return
end subroutine g2_sbytec

!> This subrountine is to extract arbitrary size values from a
!> packed bit string, right justifying each value in the unpacked
!> array with skip and interation options.
!>
!> @param[in] IN array input
!> @param[out] IOUT unpacked array output
!> @param[in] ISKIP initial number of bits to skip
!> @param[in] NBYTE Number of bits of each integer in IN to take.
!> @param[in] NSKIP Additional number of bits to skip on each iteration.
!> @param[in] N Number of integers to extract.
!>
!> @author Stephen Gilbert @date 2004-04-27
subroutine g2_gbytesc(in, iout, iskip, nbyte, nskip, n)
    implicit none

    character*1, intent(in) :: in(*)
    integer, intent(out) :: iout(*)
    integer, intent(in) :: iskip, nbyte, nskip, n
    integer :: tbit, bitcnt
    integer, parameter :: ones(8) = (/ 1, 3, 7, 15, 31, 63, 127, 255 /)

    ! implicit none additions
    integer :: nbit, i, index, ibit, itmp
    integer, external :: mova2i

    !     nbit is the start position of the field in bits
    nbit = iskip
    do i = 1, n
        bitcnt = nbyte
        index = nbit / 8 + 1
        ibit = mod(nbit, 8)
        nbit = nbit + nbyte + nskip

        !        first byte
        tbit = min(bitcnt, 8 - ibit)
        itmp = iand(mova2i(in(index)), ones(8 - ibit))
        if (tbit .ne. 8 - ibit) itmp = ishft(itmp, tbit - 8 + ibit)
        index = index + 1
        bitcnt = bitcnt - tbit

        !        now transfer whole bytes
        do while (bitcnt .ge. 8)
            itmp = ior(ishft(itmp,8), mova2i(in(index)))
            bitcnt = bitcnt - 8
            index = index + 1
        enddo

        !        get data from last byte
        if (bitcnt .gt. 0) then
            itmp = ior(ishft(itmp, bitcnt), iand(ishft(mova2i(in(index)), &
                - (8 - bitcnt)), ones(bitcnt)))
        endif

        iout(i) = itmp
    enddo

    return
end subroutine g2_gbytesc

!> This subrountine is to put arbitrary size values into a packed bit
!> string, taking the low order bits from each value in the unpacked
!> array with skip and interation options.
!>
!> @param[out] OUT Packed array output.
!> @param[in] IN Unpacked array input.
!> @param[in] ISKIP Initial number of bits to skip.
!> @param[in] NBYTE Number of bits of each integer in OUT to fill.
!> @param[in] NSKIP Additional number of bits to skip on each iteration.
!> @param[in] N Number of iterations.
!>
!> @author Stephen Gilbert @date 2004-04-27
subroutine g2_sbytesc(out, in, iskip, nbyte, nskip, n)
    implicit none

    character*1, intent(out) :: out(*)
    integer, intent(in) :: in(n)
    integer :: bitcnt, tbit
    integer, parameter :: ones(8)=(/ 1,  3,  7, 15, 31, 63,127,255/)

    !implicit none additions
    integer, intent(in) :: iskip, nbyte, nskip, n
    integer :: nbit, i, itmp, index, ibit, imask, itmp2, itmp3
    integer, external :: mova2i

    !     number bits from zero to ...
    !     nbit is the last bit of the field to be filled

    nbit = iskip + nbyte - 1
    do i = 1, n
        itmp = in(i)
        bitcnt = nbyte
        index = nbit / 8 + 1
        ibit = mod(nbit, 8)
        nbit = nbit + nbyte + nskip

        !        make byte aligned
        if (ibit .ne. 7) then
            tbit = min(bitcnt, ibit + 1)
            imask = ishft(ones(tbit), 7 - ibit)
            itmp2 = iand(ishft(itmp, 7 - ibit),imask)
            itmp3 = iand(mova2i(out(index)), 255 - imask)
            out(index) = char(ior(itmp2, itmp3))
            bitcnt = bitcnt - tbit
            itmp = ishft(itmp, -tbit)
            index = index - 1
        endif

        !        now byte aligned

        !        do by bytes
        do while (bitcnt .ge. 8)
            out(index) = char(iand(itmp, 255))
            itmp = ishft(itmp, -8)
            bitcnt = bitcnt - 8
            index = index - 1
        enddo

        !        do last byte

        if (bitcnt .gt. 0) then
            itmp2 = iand(itmp, ones(bitcnt))
            itmp3 = iand(mova2i(out(index)), 255 - ones(bitcnt))
            out(index) = char(ior(itmp2, itmp3))
        endif
    enddo

    return
end subroutine g2_sbytesc
