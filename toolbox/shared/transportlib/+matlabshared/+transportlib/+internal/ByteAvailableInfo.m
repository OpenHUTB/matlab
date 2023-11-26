classdef ByteAvailableInfo<handle

    properties
BytesAvailableFcnCount
AbsoluteTime
    end

    methods
        function data=ByteAvailableInfo(count,absolutetime)
            data.BytesAvailableFcnCount=count;
            data.AbsoluteTime=absolutetime;
        end
    end
end