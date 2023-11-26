classdef(Abstract)ITokenReader<handle


%#codegen

    properties(Abstract)

        SingleCallbackMode(1,1)logical

        LastCallbackVal(1,1){mustBeInteger}
    end

    methods

        data=readUntil(varargin);

        tokenFound=peekUntil(obj,token);

        data=readRaw(obj,numBytes);

        data=getTotalBytesWritten(obj);
        index=peekBytesFromEnd(obj,lastCallbackIndex,token)



        function obj=ITokenReader
            coder.allowpcode('plain');
        end
    end
end

