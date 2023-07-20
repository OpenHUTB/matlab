classdef ChannelType<double







    enumeration
        Missing(NaN)
        Unspecified(-1)
        FixedLength(0)
        VariableLength(1)
        Master(2)
        VirtualMaster(3)
        Synchronization(4)
        MaximumLength(5)
        VirtualData(6)
    end
end
