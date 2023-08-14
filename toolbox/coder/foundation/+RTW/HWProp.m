classdef HWProp<int32






    enumeration
        BitPerChar(1)
        BitPerShort(2)
        BitPerInt(3)
        BitPerLong(4)
        WordSize(5)
        Endianess(6)
        IntDivRoundTo(7)
        ShiftRightIntArith(8)
        LongLongMode(9)
        BitPerFloat(10)
        BitPerDouble(11)
        BitPerPointer(12)
        BitPerLongLong(13)
        LargestAtomicInteger(14)
        LargestAtomicFloat(15)
        BitPerSizeT(16)
        BitPerPtrDiffT(17)
    end

    methods(Static)


        function params=getHardwareParams()



            params=?RTW.HWProp;
            params={params.EnumerationMemberList.Name};
        end
    end
end

