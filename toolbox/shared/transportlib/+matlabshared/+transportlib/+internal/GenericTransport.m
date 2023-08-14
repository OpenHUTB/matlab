classdef GenericTransport<matlabshared.transportlib.internal.ITransport&...
    matlabshared.transportlib.internal.ITokenReader







    properties

        ByteOrder="little-endian"



        BytesAvailableEventCount=64



        BytesAvailableFcn=function_handle.empty()




        BytesWrittenFcn=function_handle.empty()



        ErrorOccurredFcn=function_handle.empty()






        SingleCallbackMode=false






        LastCallbackVal=0


        CustomConverterPlugIn=[]


        NativeDataType='uint8'


        DataFieldName='Data'


UserData



        CFIName(1,1)string
    end

    properties(SetAccess=private)

NumBytesAvailable



NumBytesWritten



Connected
    end

    properties(Dependent)



        AllowPartialReads(1,1)logical
    end

    properties(Access=private)

TransportChannel


AsyncIOChannel
    end

    properties(Dependent)



WriteAsync
    end


    methods
        function value=get.WriteAsync(obj)
            value=obj.TransportChannel.WriteAsync;
        end

        function set.WriteAsync(obj,value)
            obj.TransportChannel.WriteAsync=value;
        end

        function value=get.AllowPartialReads(obj)
            obj.validateConnected();
            value=obj.TransportChannel.AllowPartialReads;
        end

        function set.AllowPartialReads(obj,val)
            obj.validateConnected();
            obj.TransportChannel.AllowPartialReads=val;
        end

        function set.ByteOrder(obj,value)
            value=validatestring(value,["little-endian","big-endian"],mfilename,'ByteOrder');
            obj.ByteOrder=value;
            if obj.Connected %#ok<*MCSUP>
                obj.TransportChannel.ByteOrder=obj.ByteOrder;
            end
        end

        function set.BytesAvailableEventCount(obj,val)
            validateattributes(val,{'numeric'},{'>',0,'integer','scalar','finite','nonnan'},mfilename,'BytesAvailableEventCount');
            obj.BytesAvailableEventCount=val;
        end

        function set.BytesAvailableFcn(obj,val)
            if isempty(val)
                val=function_handle.empty();
            end
            validateattributes(val,{'function_handle'},{},mfilename,'BytesAvailableFcn');


            if~isequal(val,function_handle.empty())
                nargin(val);
            end


            obj.recalculateLastCBValue();
            obj.BytesAvailableFcn=val;
        end

        function set.BytesWrittenFcn(obj,val)
            if isempty(val)
                val=function_handle.empty();
            end
            validateattributes(val,{'function_handle'},{},mfilename,'BytesWrittenFcn');


            if~isequal(val,function_handle.empty())
                nargin(val);
            end
            obj.BytesWrittenFcn=val;
        end

        function set.ErrorOccurredFcn(obj,val)
            if isempty(val)
                val=function_handle.empty();
            end
            validateattributes(val,{'function_handle'},{},mfilename,'ErrorOccurredFcn');


            if~isequal(val,function_handle.empty())
                nargin(val);
            end
            obj.ErrorOccurredFcn=val;
        end

        function value=get.NumBytesAvailable(obj)
            obj.validateConnected();
            value=obj.TransportChannel.NumBytesAvailable;
        end

        function value=get.NumBytesWritten(obj)
            obj.validateConnected();
            value=obj.TransportChannel.NumBytesWritten;
        end

        function value=get.Connected(obj)
            value=~isempty(obj.TransportChannel)&&...
            ~(isempty(obj.AsyncIOChannel)||~obj.AsyncIOChannel.isOpen());
        end

        function set.DataFieldName(obj,val)
            validateattributes(val,{'string','char'},{},mfilename,'val',2);
            obj.DataFieldName=val;
            if obj.Connected
                obj.TransportChannel.DataFieldName=val;
            end
        end

        function set.NativeDataType(obj,val)
            validateattributes(val,{'string','char'},{},mfilename,'val',2);
            obj.NativeDataType=val;
            if obj.Connected
                obj.TransportChannel.NativeDataType=val;
            end
        end
    end


    methods
        function obj=GenericTransport(channel,varargin)


            obj.AsyncIOChannel=channel;
            if~isempty(varargin)




                obj.CFIName=varargin{1}(1);
            end
        end

        function delete(obj)
            obj.disconnect();
            obj.AsyncIOChannel=[];
        end
    end


    methods
        function disconnect(obj)





            try
                obj.TransportChannel=[];
            catch asyncioError
                throwAsCaller(MException(message("transportlib:generic:DisconnectFailed",asyncioError.message)));
            end
        end

        function connect(obj)











            if~obj.AsyncIOChannel.isOpen()
                throwAsCaller(MException(message('transportlib:generic:ChannelClosed')));
            end
            obj.TransportChannel=...
            matlabshared.transportlib.internal.asyncIOTransportChannel.AsyncIOTransportChannel(obj.AsyncIOChannel,obj.CFIName);
            obj.TransportChannel.ByteOrder=obj.ByteOrder;
        end

        function data=getTotalBytesWritten(obj)



            data=[];
            if~isempty(obj.AsyncIOChannel)
                data=obj.AsyncIOChannel.TotalBytesWritten;
            end
        end

        function flushInput(obj)




            obj.AsyncIOChannel.InputStream.flush();


            obj.TransportChannel.flushUnreadData();



            obj.AsyncIOChannel.execute("ResetTotalBytesWritten",[]);


            obj.LastCallbackVal=0;
        end

        function flushOutput(obj)


            obj.AsyncIOChannel.OutputStream.flush();
        end

        function data=read(varargin)









































            try
                narginchk(1,3);
                obj=varargin{1};
                obj.validateConnected();
            catch validationEx
                throwAsCaller(validationEx);
            end

            try
                data=obj.TransportChannel.read(varargin{2:end});
            catch ex



                if obj.AllowPartialReads&&...
                    strcmpi(ex.identifier,'transportlib:transport:timeout')
                    data=[];
                    return
                end

                if~isempty(ex.cause)
                    throwAsCaller(ex.cause{1});
                else
                    throwAsCaller(MException('transportlib:generic:ReadFailed',...
                    message('transportlib:generic:ReadFailed',ex.message).getString()));
                end
            end
        end

        function data=readUntil(varargin)






















            try
                narginchk(2,3);
                obj=varargin{1};
                obj.validateConnected();
            catch validationEx
                throwAsCaller(validationEx);
            end

            try
                data=obj.TransportChannel.readUntil(varargin{2:end});
            catch ex
                throwAsCaller(MException('transportlib:generic:ReadFailed',...
                message('transportlib:generic:ReadFailed',ex.message).getString()));
            end
        end

        function data=readRaw(obj,numBytes)





















            try
                data=obj.TransportChannel.readRaw(numBytes);
            catch ex
                throwAsCaller(MException('transportlib:generic:ReadFailed',...
                message('transportlib:generic:ReadFailed',ex.message).getString()));
            end
        end

        function tokenFound=peekUntil(obj,token)

















            try
                narginchk(2,2);
                obj.validateConnected();
            catch validationEx
                throwAsCaller(validationEx);
            end

            try
                tokenFound=obj.TransportChannel.peekUntil(token);
            catch ex
                throwAsCaller(MException('transportlib:generic:PeekFailed',...
                message('transportlib:generic:PeekFailed',ex.message).getString()));
            end
        end

        function index=peekBytesFromEnd(obj,lastCallbackIndex,token)





















            try
                narginchk(3,3);
                obj.validateConnected();
            catch validationEx
                throwAsCaller(validationEx);
            end

            try
                index=obj.TransportChannel.peekBytesFromEnd(lastCallbackIndex,token);
            catch ex
                throwAsCaller(MException('transportlib:generic:PeekFailed',...
                message('transportlib:generic:PeekFailed',ex.message).getString()));
            end
        end

        function write(varargin)




























            try
                narginchk(2,3);
                obj=varargin{1};
                obj.validateConnected();
            catch validationEx
                throwAsCaller(validationEx);
            end

            try
                obj.TransportChannel.write(varargin{2:end});
            catch ex
                if~isempty(ex.cause)
                    throwAsCaller(ex.cause{1});
                else
                    throwAsCaller(MException('transportlib:generic:WriteFailed',...
                    message('transportlib:generic:WriteFailed',ex.message)));
                end
            end
        end

        function writeAsync(varargin)
































            try
                narginchk(1,3);
                obj=varargin{1};
                obj.validateConnected();
            catch validationEx
                throwAsCaller(validationEx);
            end

            try
                obj.TransportChannel.writeAsync(varargin{2:end});
            catch ex
                if~isempty(ex.cause)
                    throwAsCaller(ex.cause{1});
                else
                    throwAsCaller(MException('transportlib:generic:WriteFailed',...
                    message('transportlib:generic:WriteFailed',ex.message)));
                end
            end
        end

        function writeAsyncRaw(obj,dataToWrite)
















            try
                obj.validateConnected();
            catch validationEx
                throwAsCaller(validationEx);
            end

            try
                obj.TransportChannel.writeAsyncRaw(dataToWrite);
            catch ex
                if~isempty(ex.cause)
                    throwAsCaller(ex.cause{1});
                else
                    throwAsCaller(MException('transportlib:generic:WriteFailed',...
                    message('transportlib:generic:WriteFailed',ex.message)));
                end
            end
        end
    end

    methods(Access={?matlabshared.transportlib.internal.client.EventHandler})
        function val=getChannel(obj)


            val=obj.AsyncIOChannel;
        end
    end

    methods(Access=private)
        function recalculateLastCBValue(obj)





            if obj.Connected
                obj.LastCallbackVal=...
                obj.AsyncIOChannel.TotalBytesWritten-obj.NumBytesAvailable;
            else
                obj.LastCallbackVal=0;
            end
        end

        function validateConnected(obj)




            if~obj.Connected
                throwAsCaller(MException(...
                message('transportlib:generic:InvalidConnectionState')));
            end
        end

        function validateDisconnected(obj)




            if obj.Connected
                throwAsCaller(MException(message('transportlib:generic:CannotSetWhenConnected')));
            end
        end
    end
end