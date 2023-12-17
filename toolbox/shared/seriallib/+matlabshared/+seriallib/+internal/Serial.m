classdef Serial<matlabshared.transportlib.internal.ITransport&...
    matlabshared.transportlib.internal.ITokenReader&...
    matlabshared.transportlib.internal.IFilterable

%#codegen

    properties(Constant,Hidden)

        FlowControlOptions={'none','hardware','software'}
        ParityOptions={'none','even','odd'}
        StopBitsOptions=[1,1.5,2]
        SupportedLinuxBaudRates=[50,75,110,134,150,200,300,600,1200,1800...
        ,2400,4800,9600,19200,38400,57600,115200,230400,460800...
        ,500000,576000,921600,1000000,1152000,1500000,2000000...
        ,2500000,3000000,3500000,4000000]
    end

    properties(Access=protected,Transient=true)


AsyncIOChannel



TransportChannel



FilterImpl
    end

    properties(Constant)

        DefaultTimeout=10



        DefaultBytesAvailableEventCount=64
    end

    properties(GetAccess=public,SetAccess=private)

Port
    end

    properties(GetAccess=public,SetAccess=private,Hidden=true)



IsWriteOnly



IsSharingPort



IsSharingExistingTimeout
    end

    properties(Hidden,Dependent)














        InitAccess(1,1)logical{mustBeNonempty}
    end

    properties(GetAccess=public,SetAccess=private,Dependent)

NumBytesAvailable



NumBytesWritten


ConnectionStatus


Connected
    end

    properties(Access=public)


        BaudRate=9600



        FlowControl='none'



        Parity='none'



        StopBits=1


        DataBits=8



        ByteOrder='little-endian'



        NativeDataType='uint8'



        DataFieldName='Data'



CustomConverterPlugIn



        InputBufferSize=inf




        OutputBufferSize=inf



        Timeout=matlabshared.seriallib.internal.Serial.DefaultTimeout


        UserData=[]







        SingleCallbackMode=false



        LastCallbackVal=0
    end

    properties(Access=public)



        BytesAvailableEventCount=...
        matlabshared.seriallib.internal.Serial.DefaultBytesAvailableEventCount



        BytesAvailableFcn=function_handle.empty()




        BytesWrittenFcn=function_handle.empty()



        ErrorOccurredFcn=function_handle.empty()
    end

    properties(GetAccess=private,SetAccess=protected)



ReceiveCallbackListener



SendCallbackListener



CustomListener
    end

    properties(Hidden,Dependent)




        AllowPartialReads(1,1)logical{mustBeNonempty}





        WriteComplete(1,1)logical





WriteAsync
    end

    methods(Static)
        function name=matlabCodegenRedirect(~)


            name='matlabshared.seriallib.internal.coder.Serial';
        end
    end

    methods(Access=public)

        function obj=Serial(varargin)








            narginchk(1,inf);


            port=instrument.internal.stringConversionHelpers.str2char(varargin{1});

            try %#ok<*EMTC>

                validateattributes(port,{'char','string'},{'nonempty'},mfilename,'PORT',1)


                obj.Port=port;

                inputs=varargin(2:end);
                obj.initProperties(inputs);


                obj.FilterImpl=matlabshared.transportlib.internal.FilterImpl(obj);

            catch validationException
                throwAsCaller(validationException);
            end

        end

        function connect(obj)




















            if(~isempty(obj.AsyncIOChannel)&&obj.AsyncIOChannel.isOpen())
                throwAsCaller(MException(message('transportlib:transport:alreadyConnectedError')));
            end

            try

                initializeChannel(obj);



                obj.TransportChannel=...
                matlabshared.transportlib.internal.asyncIOTransportChannel.AsyncIOTransportChannel(obj.AsyncIOChannel);
                obj.TransportChannel.ByteOrder=obj.ByteOrder;
                obj.TransportChannel.NativeDataType=obj.NativeDataType;
                obj.TransportChannel.DataFieldName=obj.DataFieldName;
            catch asyncioError
                errText=string(message('seriallib:serial:connectFailed').getString);



                if~strcmpi(asyncioError.message,'')&&~ismac&&isunix
                    errText=string(asyncioError.message);
                end
                throwAsCaller(MException('seriallib:serial:connectFailed',errText));
            end
        end

        function disconnect(obj)









            try
                terminateChannel(obj);
            catch asyncioError
                throwAsCaller(obj.formatAsyncIOException(asyncioError,'seriallib:serial:disconnectFailed'));
            end
        end


        function tuneInputFilter(obj,options)



            narginchk(2,2);

            obj.validateConnected();
            try
                obj.AsyncIOChannel.InputStream.tuneFilters(options);
            catch asyncioError
                throwAsCaller(obj.formatAsyncIOException(asyncioError,'transportlib:filter:tuneInputFilterError'));
            end
        end

        function tuneOutputFilter(obj,options)



            narginchk(2,2);

            obj.validateConnected();
            try
                obj.AsyncIOChannel.OutputStream.tuneFilters(options);
            catch asyncioError
                throwAsCaller(obj.formatAsyncIOException(asyncioError,'transportlib:filter:tuneOutputFilterError'));
            end
        end

        function data=getTotalBytesWritten(obj)


            data=[];
            if~isempty(obj.AsyncIOChannel)
                data=obj.AsyncIOChannel.TotalBytesWritten;
            end
        end

        function addInputFilter(obj,filter,options)





            narginchk(3,3);
            try
                obj.FilterImpl.addInputFilter(filter,options);
            catch filterError
                throwAsCaller(obj.formatAsyncIOException(filterError,'transportlib:filter:addInputFilterError'));
            end
        end

        function removeInputFilter(obj,filter)





            narginchk(2,2);
            try
                obj.FilterImpl.removeInputFilter(filter);
            catch filterError
                throwAsCaller(obj.formatAsyncIOException(filterError,'transportlib:filter:removeInputFilterError'));
            end
        end

        function addOutputFilter(obj,filter,options)





            narginchk(3,3);
            try
                obj.FilterImpl.addOutputFilter(filter,options);
            catch filterError
                throwAsCaller(obj.formatAsyncIOException(filterError,'transportlib:filter:addOutputFilterError'));
            end
        end

        function removeOutputFilter(obj,filter)





            narginchk(2,2);
            try
                obj.FilterImpl.removeOutputFilter(filter);
            catch filterError
                throwAsCaller(obj.formatAsyncIOException(filterError,'transportlib:filter:removeOutputFilterError'));
            end
        end

        function[inputFilters,inputFilterOptions]=getInputFilters(obj)









            [inputFilters,inputFilterOptions]=obj.FilterImpl.getInputFilters();
        end

        function[outputFilters,outputFilterOptions]=getOutputFilters(obj)









            [outputFilters,outputFilterOptions]=obj.FilterImpl.getOutputFilters();
        end



        function flushInput(obj)



            obj.validateConnected();
            try

                obj.AsyncIOChannel.execute("FlushInput");

                obj.AsyncIOChannel.InputStream.flush();

                obj.TransportChannel.flushUnreadData();

                obj.LastCallbackVal=0;
            catch asyncioError
                throwAsCaller(obj.formatAsyncIOException(asyncioError,'seriallib:serial:flushInputFailed'));
            end
        end

        function flushOutput(obj)



            obj.validateConnected();
            try

                obj.AsyncIOChannel.execute("FlushOutput");

                obj.AsyncIOChannel.OutputStream.flush();
            catch asyncioError
                throwAsCaller(obj.formatAsyncIOException(asyncioError,'seriallib:serial:flushOutputFailed'));
            end
        end

        function serialbreak(obj)



            obj.validateConnected();
            try

                obj.AsyncIOChannel.execute("SerialBreak");
            catch asyncioError
                throwAsCaller(obj.formatAsyncIOException(asyncioError,'seriallib:serial:serialBreakFailed'));
            end
        end

        function out=getPinStatus(obj)



            obj.validateConnected();

            try
                options=[];
                obj.AsyncIOChannel.execute("GetPinStatus",options);
            catch ex
                throwAsCaller(obj.formatAsyncIOException(ex,'seriallib:serial:getPinStatusFailed'));
            end


            out.ClearToSend=obj.AsyncIOChannel.CTS;
            out.DataSetReady=obj.AsyncIOChannel.DSR;
            out.CarrierDetect=obj.AsyncIOChannel.CD;
            out.RingIndicator=obj.AsyncIOChannel.RING;
        end

        function setDTR(obj,state)

            try
                validateattributes(state,{'logical'},{'scalar'},mfilename,'setDTR');
            catch validateEx
                throwAsCaller(validateEx);
            end


            obj.validateConnected();

            try
                options.BoolVal=state;
                obj.AsyncIOChannel.execute("SetDtr",options);
            catch ex
                throwAsCaller(obj.formatAsyncIOException(ex,'seriallib:serial:setDTRFailed'));
            end
        end

        function setRTS(obj,state)

            try
                validateattributes(state,{'logical'},{'scalar'},mfilename,'setRTS');
            catch validateEx
                throwAsCaller(validateEx);
            end


            obj.validateConnected();

            try
                options.BoolVal=state;
                obj.AsyncIOChannel.execute("SetRts",options);
            catch ex
                throwAsCaller(obj.formatAsyncIOException(ex,'seriallib:serial:setRTSFailed'));
            end
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
                    throwAsCaller(MException('seriallib:serial:readFailed',...
                    message('seriallib:serial:readFailed',ex.message).getString()));
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
                throwAsCaller(MException('seriallib:serial:readFailed',...
                message('seriallib:serial:readFailed',ex.message).getString()));
            end
        end

        function data=readRaw(obj,numBytes)




















            try
                data=obj.TransportChannel.readRaw(numBytes);
            catch ex
                throwAsCaller(MException('seriallib:serial:readFailed',...
                message('seriallib:serial:readFailed',ex.message).getString()));
            end
        end

        function[tokenFound,indices]=peekUntil(obj,token)


















            try
                narginchk(2,2);
                obj.validateConnected();
            catch validationEx
                throwAsCaller(validationEx);
            end

            try
                [tokenFound,indices]=obj.TransportChannel.peekUntil(token);
            catch ex
                throwAsCaller(MException('seriallib:serial:peekFailed',...
                message('seriallib:serial:peekFailed',ex.message).getString()));
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
                throwAsCaller(MException('seriallib:serial:peekFailed',...
                message('seriallib:serial:peekFailed',ex.message).getString()));
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
                    throwAsCaller(MException('seriallib:serial:writeFailed',...
                    message('seriallib:serial:writeFailed',ex.message)));
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
                    throwAsCaller(MException('seriallib:serial:writeFailed',...
                    message('seriallib:serial:writeFailed',ex.message)));
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
                    throwAsCaller(MException('seriallib:serial:writeFailed',...
                    message('seriallib:serial:writeFailed',ex.message)));
                end
            end
        end
    end


    methods

        function set.BytesAvailableEventCount(obj,val)
            try
                validateattributes(val,{'numeric'},{'>',0,'integer','scalar','finite','nonnan'},mfilename,'BytesAvailableEventCount');
            catch ex
                throwAsCaller(ex);
            end
            obj.BytesAvailableEventCount=val;
        end

        function set.BytesAvailableFcn(obj,val)
            if isempty(val)
                val=function_handle.empty();
            end
            try
                validateattributes(val,{'function_handle'},{},mfilename,'BytesAvailableFcn');


                if~isequal(val,function_handle.empty())
                    nargin(val);
                end
            catch ex
                throwAsCaller(ex);
            end


            obj.recalculateLastCBValue();
            obj.BytesAvailableFcn=val;
        end

        function set.BytesWrittenFcn(obj,val)
            if isempty(val)
                val=function_handle.empty();
            end
            try
                validateattributes(val,{'function_handle'},{},mfilename,'BytesWrittenFcn');


                if~isequal(val,function_handle.empty())
                    nargin(val);
                end
            catch ex
                throwAsCaller(ex);
            end
            obj.BytesWrittenFcn=val;
        end

        function set.ErrorOccurredFcn(obj,val)
            if isempty(val)
                val=function_handle.empty();
            end
            try
                validateattributes(val,{'function_handle'},{},mfilename,'ErrorOccurredFcn');


                if~isequal(val,function_handle.empty())
                    nargin(val);
                end
            catch ex
                throwAsCaller(ex);
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

        function value=get.ConnectionStatus(obj)
            if(isempty(obj.AsyncIOChannel)||~obj.AsyncIOChannel.isOpen())
                value='Disconnected';
            else
                value='Connected';
            end
        end

        function value=get.InitAccess(obj)







            obj.validateAsyncIOConnected();

            try
                options=[];
                obj.AsyncIOChannel.execute("GetInitAccessStatus",options);
            catch ex
                throwAsCaller(obj.formatAsyncIOException(ex,'seriallib:serial:getInitAccessStatusFailed'));
            end


            value=obj.AsyncIOChannel.InitAccess;
        end

        function value=get.Timeout(obj)

            if~obj.IsSharingExistingTimeout
                value=obj.Timeout;
            else




                obj.validateAsyncIOConnected();

                try
                    options=[];
                    obj.AsyncIOChannel.execute("GetSharedTimeout",options);
                catch ex
                    throwAsCaller(obj.formatAsyncIOException(ex,'seriallib:serial:getInitAccessStatusFailed'));
                end


                value=obj.AsyncIOChannel.SharedTimeout;
            end
        end

        function obj=set.Timeout(obj,value)%#ok<MCHV2>
            if obj.IsSharingExistingTimeout


                error(message('seriallib:serial:setExistingSharedTimeoutFailed'));
            else
                try

                    validateattributes(value,{'numeric'},{'scalar','nonnegative','finite',...
                    'nonzero','nonempty'},mfilename,'Timeout');
                catch validationException
                    throwAsCaller(validationException);
                end
                obj.setAsyncIOChannelTimeout(value);
                obj.Timeout=value;











            end
        end

        function set.WriteAsync(obj,state)
            obj.TransportChannel.WriteAsync=state;
        end

        function value=get.WriteAsync(obj)
            value=obj.TransportChannel.WriteAsync;
        end

        function set.CustomConverterPlugIn(obj,value)
            try

                validateDisconnected(obj);


                validateattributes(value,{'char','string'},{},mfilename,'CustomConverterPlugIn');

            catch validationException
                throwAsCaller(validationException);
            end

            obj.CustomConverterPlugIn=value;
        end

        function out=get.BaudRate(obj)
            out=obj.BaudRate;
        end

        function set.BaudRate(obj,value)
            try

                validateattributes(value,{'numeric'},{'scalar','nonnegative','finite',...
                'nonzero','integer'},mfilename,'BaudRate');


                if isunix&&~ismac
                    if~ismember(value,obj.SupportedLinuxBaudRates)
                        validRates=regexprep(num2str(obj.SupportedLinuxBaudRates),' +',', ');
                        throw(MException(message('seriallib:serial:invalidBaudRate',validRates)));
                    end
                end
            catch validateEx
                throwAsCaller(validateEx);
            end




            if obj.Connected
                try
                    options.BaudRate=value;
                    obj.AsyncIOChannel.execute("SetBaudRate",options);
                catch ex
                    throwAsCaller(obj.formatAsyncIOException(ex,'seriallib:serial:setBaudRateFailed'));
                end
            end
            obj.BaudRate=value;
        end

        function out=get.DataBits(obj)
            out=obj.DataBits;
        end

        function set.DataBits(obj,value)
            try

                validateattributes(value,{'numeric'},{'scalar','nonnegative','finite',...
                'nonzero','integer'},mfilename,'DataBits');
            catch validateEx
                throwAsCaller(validateEx);
            end




            if obj.Connected
                try
                    options.DataBits=value;
                    obj.AsyncIOChannel.execute("SetDataBits",options);
                catch ex
                    throwAsCaller(obj.formatAsyncIOException(ex,'seriallib:serial:setDataBitsFailed'));
                end
            end
            obj.DataBits=value;
        end

        function out=get.StopBits(obj)
            out=obj.StopBits;
        end

        function set.StopBits(obj,value)
            try

                validateattributes(value,{'numeric'},{'scalar','nonnegative','finite','nonnan'},mfilename,'StopBits');
                if~ismember(value,matlabshared.seriallib.internal.Serial.StopBitsOptions)
                    throw(MException(message('seriallib:serial:invalidStopBits')));
                end
            catch ex
                throwAsCaller(ex);
            end




            if obj.Connected
                try
                    options.StopBits=value;
                    obj.AsyncIOChannel.execute("SetStopBits",options);
                catch ex
                    throwAsCaller(obj.formatAsyncIOException(ex,'seriallib:serial:setStopBitsFailed'));
                end
            end
            obj.StopBits=value;
        end

        function out=get.Parity(obj)
            out=obj.Parity;
        end

        function set.Parity(obj,value)
            try

                value=instrument.internal.stringConversionHelpers.str2char(value);
                validateattributes(value,{'char','string'},{'nonempty'},mfilename,'Parity');
                value=validatestring(value,matlabshared.seriallib.internal.Serial.ParityOptions);
            catch validateEx
                throwAsCaller(validateEx);
            end




            if obj.Connected %#ok<*MCSUP>
                try
                    options.Parity=value;
                    obj.AsyncIOChannel.execute("SetParity",options);
                catch ex
                    throwAsCaller(obj.formatAsyncIOException(ex,'seriallib:serial:setParityFailed'));
                end
            end
            obj.Parity=value;
        end

        function out=get.FlowControl(obj)
            out=obj.FlowControl;
        end

        function set.FlowControl(obj,value)
            try

                value=instrument.internal.stringConversionHelpers.str2char(value);
                validateattributes(value,{'char','string'},{'nonempty'},mfilename,'FlowControl');
                value=validatestring(value,matlabshared.seriallib.internal.Serial.FlowControlOptions);
            catch validateEx
                throwAsCaller(validateEx);
            end




            if obj.Connected
                try
                    options.FlowControl=value;
                    obj.AsyncIOChannel.execute("SetFlowControl",options);
                catch ex
                    throwAsCaller(obj.formatAsyncIOException(ex,'seriallib:serial:setFlowControlFailed'));
                end
            end
            obj.FlowControl=value;
        end

        function set.ByteOrder(obj,value)

            value=instrument.internal.stringConversionHelpers.str2char(value);
            validateattributes(value,{'char','string'},{'nonempty'},mfilename,'ByteOrder');
            value=validatestring(value,{'little-endian','big-endian'});
            obj.ByteOrder=value;
            if obj.Connected
                obj.TransportChannel.ByteOrder=obj.ByteOrder;
            end
        end

        function out=get.ByteOrder(obj)

            out=obj.ByteOrder;
        end

        function set.NativeDataType(obj,val)

            validateattributes(val,{'string','char'},{},mfilename,'val',2);
            obj.NativeDataType=val;
            if obj.Connected
                obj.TransportChannel.NativeDataType=val;
            end
        end

        function out=get.NativeDataType(obj)

            out=obj.NativeDataType;
        end

        function set.DataFieldName(obj,val)

            validateattributes(val,{'string','char'},{},mfilename,'val',2);
            obj.DataFieldName=val;
            if obj.Connected
                obj.TransportChannel.DataFieldName=val;
            end
        end

        function out=get.DataFieldName(obj)

            out=obj.DataFieldName;
        end

        function set.InputBufferSize(obj,value)
            try

                validateattributes(value,{'numeric'},{'scalar','nonnegative','nonnan'},mfilename,'INPUTBUFFERSIZE');


                validateDisconnected(obj);

            catch validationException
                throwAsCaller(validationException);
            end

            obj.InputBufferSize=value;
        end

        function set.OutputBufferSize(obj,value)
            try

                validateattributes(value,{'numeric'},{'scalar','nonnegative','nonnan'},mfilename,'OUTPUTBUFFERSIZE');


                validateDisconnected(obj);

            catch validationException
                throwAsCaller(validationException);
            end

            obj.OutputBufferSize=value;
        end

        function value=get.AllowPartialReads(obj)

            obj.validateConnected();
            value=obj.TransportChannel.AllowPartialReads;
        end

        function set.AllowPartialReads(obj,val)

            obj.validateConnected();
            obj.TransportChannel.AllowPartialReads=val;
        end

        function value=get.WriteComplete(obj)
            value=obj.AsyncIOChannel.WriteComplete;
        end
    end

    methods(Access=private)

        function initProperties(obj,inputs)


            p=inputParser;
            p.PartialMatching=true;
            addParameter(p,'BaudRate',9600,@isscalar);
            addParameter(p,'DataBits',8,@isscalar);
            addParameter(p,'Parity','none',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            addParameter(p,'StopBits',1,@isscalar);
            addParameter(p,'FlowControl','none',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            addParameter(p,'ByteOrder','little-endian',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            addParameter(p,'Timeout',10,@isscalar);
            addParameter(p,'IsWriteOnly',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
            addParameter(p,'IsSharingPort',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
            addParameter(p,'IsSharingExistingTimeout',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
            parse(p,inputs{:});
            output=p.Results;

            obj.BaudRate=output.BaudRate;
            obj.DataBits=output.DataBits;
            obj.Parity=output.Parity;
            obj.StopBits=output.StopBits;
            obj.FlowControl=output.FlowControl;
            obj.ByteOrder=output.ByteOrder;
            obj.Timeout=output.Timeout;
            obj.IsWriteOnly=output.IsWriteOnly;
            obj.IsSharingPort=output.IsSharingPort;
            obj.IsSharingExistingTimeout=output.IsSharingExistingTimeout;
        end

        function initializeChannel(obj)




            options.ServiceName=obj.Port;
            options.BaudRate=obj.BaudRate;
            options.Parity=obj.Parity;
            options.StopBits=obj.StopBits;
            options.DataBits=obj.DataBits;
            options.FlowControl=obj.FlowControl;
            options.IsWriteOnly=obj.IsWriteOnly;
            options.IsSharingPort=obj.IsSharingPort;
            options.IsSharingExistingTimeout=obj.IsSharingExistingTimeout;


            fullpathToSelf=which('matlabshared.seriallib.internal.Serial');
            pathStr=fileparts(fullpathToSelf);
            pluginDir=fullfile(pathStr,'..','..','..','bin',computer('arch'));

            devicePlugin=fullfile(pluginDir,'serialdevice');

            if~isempty(obj.CustomConverterPlugIn)
                converterPlugin=obj.CustomConverterPlugIn;
            else
                converterPlugin=fullfile(pluginDir,'serialmlconverter');
            end


            obj.AsyncIOChannel=matlabshared.asyncio.internal.Channel(devicePlugin,...
            converterPlugin,...
            Options=options,...
            StreamLimits=[obj.InputBufferSize,obj.OutputBufferSize]);

            if~obj.IsSharingPort||~obj.IsSharingExistingTimeout




                obj.setAsyncIOChannelTimeout(obj.Timeout);
            end



            obj.ReceiveCallbackListener=event.listener(...
            obj.AsyncIOChannel.InputStream,...
            'DataWritten',...
            @obj.onDataReceived);



            obj.SendCallbackListener=event.listener(...
            obj.AsyncIOChannel.OutputStream,...
            'DataRead',...
            @obj.onDataWritten);

            obj.CustomListener=addlistener(obj.AsyncIOChannel,...
            'Custom',...
            @obj.handleCustomEvent);


            [inputFilters,inputFilterOptions]=obj.FilterImpl.getInputFilters();
            [outputFilters,outputFilterOptions]=obj.FilterImpl.getOutputFilters();


            for i=1:length(inputFilters)
                obj.AsyncIOChannel.InputStream.addFilter(inputFilters{i},inputFilterOptions{i});
            end
            for i=1:length(outputFilters)
                obj.AsyncIOChannel.OutputStream.addFilter(outputFilters{i},outputFilterOptions{i});
            end


            obj.AsyncIOChannel.open(options);



            if obj.IsSharingPort
                if obj.IsSharingExistingTimeout


                    obj.setAsyncIOChannelTimeout(obj.Timeout);
                else
                    if obj.InitAccess



                        obj.setSharedTimeout(obj.Timeout);
                    end
                end
            end
        end

        function terminateChannel(obj)



            if~isempty(obj.AsyncIOChannel)
                obj.AsyncIOChannel.close();
                delete(obj.AsyncIOChannel);
                delete(obj.ReceiveCallbackListener);
                delete(obj.SendCallbackListener);
                delete(obj.CustomListener);
                obj.TransportChannel=[];
                obj.AsyncIOChannel=[];
                obj.ReceiveCallbackListener=[];
                obj.SendCallbackListener=[];
                obj.CustomListener=[];
            end
        end

        function setAsyncIOChannelTimeout(obj,value)



            if~isempty(obj.AsyncIOChannel)

                obj.AsyncIOChannel.OutputStream.Timeout=value;
                obj.AsyncIOChannel.InputStream.Timeout=value;
            end
        end

        function setSharedTimeout(obj,value)



            validateattributes(value,{'numeric'},{'scalar','nonnegative','finite','nonnan'},mfilename,'setSharedTimeout');

            obj.validateAsyncIOConnected();

            try
                options.SharedTimeout=value;
                obj.AsyncIOChannel.execute("SetSharedTimeout",options);
            catch ex
                throwAsCaller(obj.formatAsyncIOException(ex,'seriallib:serial:setSharedTimeoutFailed'));
            end
        end

        function ex=formatAsyncIOException(~,asyncioError,errorid)





            formattedMessage=strrep(asyncioError.message,'Unexpected exception in plug-in: ','');

            formattedMessage=strrep(formattedMessage,'''','');

            ex=MException(errorid,message(errorid,formattedMessage).getString());
        end

        function validateConnected(obj)




            if~obj.Connected
                throwAsCaller(MException('transportlib:transport:invalidConnectionState',...
                message('transportlib:transport:invalidConnectionState','serial port').getString()));
            end
        end

        function validateAsyncIOConnected(obj)





            if~strcmp(obj.ConnectionStatus,'Connected')
                throwAsCaller(MException('transportlib:transport:invalidConnectionState',...
                message('transportlib:transport:invalidConnectionState','serial port').getString()));
            end
        end

        function validateDisconnected(obj)




            if obj.Connected
                throwAsCaller(MException(message('transportlib:transport:cannotSetWhenConnected')));
            end
        end

        function onDataReceived(obj,~,~)

            if isempty(obj.BytesAvailableFcn)
                return;
            end


            if obj.SingleCallbackMode
                obj.BytesAvailableFcn(obj,...
                matlabshared.transportlib.internal.DataAvailableInfo(obj.BytesAvailableEventCount));

            else


                deltaFromLastCallback=obj.AsyncIOChannel.TotalBytesWritten-obj.LastCallbackVal;





                numCallbacks=floor(double(deltaFromLastCallback)/double(obj.BytesAvailableEventCount));

                for idx=1:numCallbacks
                    if isempty(obj.BytesAvailableFcn)
                        break
                    end
                    obj.BytesAvailableFcn(obj,...
                    matlabshared.transportlib.internal.DataAvailableInfo(obj.BytesAvailableEventCount));
                end




                obj.LastCallbackVal=obj.LastCallbackVal+...
                numCallbacks*obj.BytesAvailableEventCount;
            end
        end

        function onDataWritten(obj,~,~)

            if isempty(obj.BytesWrittenFcn)
                return;
            end



            space=obj.AsyncIOChannel.OutputStream.SpaceAvailable;
            if space>0
                obj.BytesWrittenFcn(obj,...
                matlabshared.transportlib.internal.DataWrittenInfo(space));
            end
        end

        function handleCustomEvent(obj,~,eventData)










            if~isvalid(obj)
                return
            end

            if strcmpi(eventData.Data.ErrorID,'seriallib:serial:lostConnectionState')
                obj.CustomListener.Enabled=false;
                obj.terminateChannel();
            end

            if~isempty(obj.ErrorOccurredFcn)
                obj.ErrorOccurredFcn(obj,...
                matlabshared.transportlib.internal.ErrorInfo(eventData.Data.ErrorID,...
                eventData.Data.ErrorMessage));
            else
                error(eventData.Data.ErrorID,message(eventData.Data.ErrorID,eventData.Data.ErrorMessage).getString());
            end
        end

        function recalculateLastCBValue(obj)








            if~isempty(obj.AsyncIOChannel)&&obj.Connected
                obj.LastCallbackVal=...
                obj.AsyncIOChannel.TotalBytesWritten-obj.NumBytesAvailable;
            else
                obj.LastCallbackVal=0;
            end
        end
    end

    methods(Static=true,Hidden=true)
        function out=loadobj(s)




            out=[];
            if isstruct(s)
                out=matlabshared.seriallib.internal.Serial(s.Port);
                out.Timeout=s.Timeout;
                out.InputBufferSize=s.InputBufferSize;
                out.OutputBufferSize=s.OutputBufferSize;
                out.ByteOrder=s.ByteOrder;
                out.Port=s.Port;
                out.BaudRate=s.BaudRate;
                out.FlowControl=s.FlowControl;
                out.Parity=s.Parity;
                out.StopBits=s.StopBits;
                out.DataBits=s.DataBits;
                out.IsWriteOnly=s.IsWriteOnly;
                out.IsSharingPort=s.IsSharingPort;
                out.IsSharingExistingTimeout=s.IsSharingExistingTimeout;
                if isfield(s,'NativeDataType')
                    out.NativeDataType=s.NativeDataType;
                end
                if isfield(s,'DataFieldName')
                    out.DataFieldName=s.DataFieldName;
                end

                if strcmpi(s.ConnectionStatus,'Connected')
                    try
                        out.connect();
                    catch connectFailed



                        warning('seriallib:serial:connectFailed','%s',connectFailed.message);
                    end
                end
            end
        end
    end

    methods(Hidden)

        function s=saveobj(obj)

            s.Port=obj.Port;
            s.BaudRate=obj.BaudRate;
            s.FlowControl=obj.FlowControl;
            s.Parity=obj.Parity;
            s.StopBits=obj.StopBits;
            s.DataBits=obj.DataBits;
            s.Timeout=obj.Timeout;
            s.InputBufferSize=obj.InputBufferSize;
            s.OutputBufferSize=obj.OutputBufferSize;
            s.ConnectionStatus=obj.ConnectionStatus;
            s.ByteOrder=obj.ByteOrder;
            s.NativeDataType=obj.NativeDataType;
            s.DataFieldName=obj.DataFieldName;
            s.IsWriteOnly=obj.IsWriteOnly;
            s.IsSharingPort=obj.IsSharingPort;
            s.IsSharingExistingTimeout=obj.IsSharingExistingTimeout;
        end

        function delete(obj)


            obj.FilterImpl=[];
            terminateChannel(obj);
        end
    end
end
