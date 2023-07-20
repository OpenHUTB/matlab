classdef(Abstract)ITransport<handle





%#codegen

    properties(Abstract)

ByteOrder
    end

    properties(Abstract,GetAccess=public,SetAccess=private)


NumBytesAvailable



NumBytesWritten



Connected
    end

    properties(Abstract)



BytesAvailableEventCount



BytesAvailableFcn




BytesWrittenFcn



ErrorOccurredFcn
    end

    methods



        connect(obj);


        disconnect(obj);

















        data=read(varargin);









        write(varargin);


        function obj=ITransport
            coder.allowpcode('plain');
        end
    end
end

