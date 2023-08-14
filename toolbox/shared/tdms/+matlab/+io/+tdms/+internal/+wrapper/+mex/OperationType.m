classdef OperationType<int8



    enumeration
        Info(0)
        Read(1)
        Write(2)
        GetFileProperties(3)
        GetChannelGroupProperties(4)
        GetChannelProperties(5)
        SetFileProperties(6)
        SetChannelGroupProperties(7)
        SetChannelProperties(8)
    end
end