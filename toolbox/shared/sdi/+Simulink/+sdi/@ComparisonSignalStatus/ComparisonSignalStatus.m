classdef(Sealed)ComparisonSignalStatus<uint8



    enumeration
        OutOfTolerance(0)
        WithinTolerance(1)
        Unaligned(2)
        Unknown(3)
        Pending(4)
        Processing(5)
        UnitsMismatch(6)
        Empty(7)
        Canceled(8)
        EmptySynced(9)
        DataTypeMismatch(10)
        StartStopMismatch(11)
        TimeMismatch(12)
        Unsupported(13)
    end
end
