classdef(Abstract)UDPBase<matlabshared.transportlib.internal.IFilterable&...
    matlabshared.transportlib.internal.ITestable

    properties(Constant,Hidden)

        DefaultSocketSize=64*1024
        ConverterPlugin=fullfile(toolboxdir(fullfile('shared','networklib','bin',computer('arch'))),'networkmlconverter')
        DevicePlugin=fullfile(toolboxdir(fullfile('shared','networklib','bin',computer('arch'))),'udpdevice')
        AllowedProtocolTypes=struct("IPV4",0,"IPV6",1)

        Mode=struct("Byte",0,"Datagram",1);
        StandardSocketType=1
    end


    properties(Constant)
        DefaultTimeout=10
    end


    properties(Hidden)
        ProtocolType=matlabshared.network.internal.UDPBase.AllowedProtocolTypes.IPV4
    end

    properties(GetAccess=public,SetAccess=protected,Dependent)

ConnectionStatus
    end


    properties
RemoteHost
RemotePort
EnablePortSharing
EnableBroadcast
EnableMulticast
LocalHost
LocalPort
        AddressType='IPV4'
MulticastGroup
        DataFieldName='Data'
        NativeDataType='struct'
CustomConverterPlugIn
        ByteOrder='little-endian'        ErrorOccurredFcn=function_handle.empty();        BytesWrittenFcn=function_handle.empty()        EnableDatagramLoopback(1,1)logical=true        CFIName(1,1)string{mustBeMember(CFIName,["","udpport"])}=""

        IsWriteOnly=false

        EnableSocketSharing=false
    end


    properties(Hidden,Dependent)
        InitAccess(1,1)logical{mustBeNonempty}
    end


    properties(Access=public)
        Timeout=matlabshared.network.internal.UDP.DefaultTimeout

        UserData=[]

        OutputDatagramPacketSize=512
    end

    properties(GetAccess=public,SetAccess=private,Dependent)

NumBytesWritten

Connected
    end


    properties(Access=protected)

ReceiveCallbackListener
SendCallbackListener
CustomListener        ConnectError=struct('Status',false,'Exception',[])
    end


    properties(Access=?matlabshared.transportlib.internal.ITestable,Transient=true)

AsyncIOChannel
TransportChannel
FilterImpl
    end

    properties(GetAccess=public,SetAccess=private,Hidden)
        AllowSettingProperty(1,1)logical=false
    end


    methods

        function set.RemoteHost(obj,value)
            try

                validateDisconnected(obj);


                validateattributes(value,{'char','string'},{'nonempty'},'UDP','REMOTEHOST');
            catch validationException
                throwAsCaller(validationException);
            end

            obj.RemoteHost=value;
        end


        function set.LocalHost(obj,value)
            try

                validateDisconnected(obj);

                validateattributes(value,{'char','string'},{'nonempty'},'UDP','LOCALHOST');

            catch validationException
                throwAsCaller(validationException);
            end

            obj.LocalHost=value;
        end


        function set.RemotePort(obj,value)
            try
                validateDisconnected(obj);

                validateattributes(value,{'numeric'},{'nonempty'},'UDP','REMOTEPORT');
            catch validationException
                throwAsCaller(validationException);
            end
            obj.RemotePort=value;
        end


        function set.LocalPort(obj,value)
            try

                validateDisconnected(obj);

                validateattributes(value,{'numeric'},{'nonempty'},'UDP','LOCALPORT');

            catch validationException
                throwAsCaller(validationException);
            end

            obj.LocalPort=value;
        end


        function set.OutputDatagramPacketSize(obj,value)
            try

                validateattributes(value,{'numeric'},{'scalar','nonnegative','nonnan',...
                '<=',65507},'UDP','OUTPUTDATAGRAMPACKETSIZE');

                validateDisconnected(obj);

            catch validationException
                throwAsCaller(validationException);
            end
            obj.OutputDatagramPacketSize=value;
        end


        function set.EnablePortSharing(obj,value)
            try

                validateDisconnected(obj);

                validateattributes(value,{'logical'},{'nonempty'},'UDP','ENABLEPORTSHARING');

            catch validationException
                throwAsCaller(validationException);
            end

            obj.EnablePortSharing=value;
        end


        function set.IsWriteOnly(obj,value)
            try

                validateDisconnected(obj);


                validateattributes(value,{'logical'},{'nonempty'},'UDP','ISWRITEONLY');

            catch validationException
                throwAsCaller(validationException);
            end

            obj.IsWriteOnly=value;
        end


        function set.EnableSocketSharing(obj,value)
            try

                validateDisconnected(obj);

                validateattributes(value,{'logical'},{'nonempty'},'UDP','ENABLESOCKETSHARING');

            catch validationException
                throwAsCaller(validationException);
            end

            obj.EnableSocketSharing=value;
        end


        function set.EnableDatagramLoopback(obj,value)
            try

                validateDisconnected(obj);

                validateattributes(value,{'logical'},{'nonempty'},'UDP','ENABLEDATAGRAMLOOPBACK');

            catch validationException
                throwAsCaller(validationException);
            end
            obj.EnableDatagramLoopback=value;
        end


        function set.EnableBroadcast(obj,value)
            try

                validateDisconnected(obj);


                validateattributes(value,{'logical'},{'nonempty'},'UDP','ENABLEBROADCAST');

            catch validationException
                throwAsCaller(validationException);
            end

            obj.EnableBroadcast=value;
        end


        function set.AddressType(obj,value)
            try

                validateDisconnected(obj);

                value=validatestring(value,{'IPV4','IPV6'},'UDP','ADDRESSTYPE');

            catch validationException
                throwAsCaller(validationException);
            end

            obj.AddressType=value;
        end


        function set.EnableMulticast(obj,value)
            try

                validateDisconnected(obj);

                validateattributes(value,{'logical'},{'nonempty'},'UDP','ENABLEMULTICAST');

            catch validationException
                throwAsCaller(validationException);
            end

            obj.EnableMulticast=value;
        end


        function set.MulticastGroup(obj,value)
            try

                validateDisconnected(obj);

                validateattributes(value,{'char','string'},{},'UDP','MULTICASTGROUP');

            catch validationException
                throwAsCaller(validationException);
            end

            obj.MulticastGroup=value;
        end


        function set.CustomConverterPlugIn(obj,value)
            try

                validateDisconnected(obj);

                validateattributes(value,{'char','string'},{},'UDP','CUSTOMCONVERTERPLUGIN');

            catch validationException
                throwAsCaller(validationException);
            end

            obj.CustomConverterPlugIn=value;
        end


        function set.Timeout(obj,value)
            try

                validateattributes(value,{'numeric'},{'scalar','nonnegative','finite','nonnan'},'UDP','TIMEOUT');

            catch validationException
                throwAsCaller(validationException);
            end
            obj.setAsyncIOChannelTimeout(value);
            obj.Timeout=value;
        end


        function set.BytesWrittenFcn(obj,val)
            if isempty(val)
                val=function_handle.empty();
            end
            try
                validateattributes(val,{'function_handle'},{},'UDP','BytesWrittenFcn');
            catch ex
                throwAsCaller(ex);
            end
            obj.BytesWrittenFcn=val;
        end


        function set.NativeDataType(obj,val)

            validateattributes(val,{'string','char'},{},'UDP','val',2);
            obj.NativeDataType=val;
            if obj.Connected
                obj.TransportChannel.NativeDataType=val;
            end
        end


        function out=get.NativeDataType(obj)
            out=obj.NativeDataType;
        end


        function set.DataFieldName(obj,val)
            validateattributes(val,{'string','char'},{},'UDP','val',2);
            obj.DataFieldName=val;
            if obj.Connected
                obj.TransportChannel.DataFieldName=val;
            end
        end


        function out=get.DataFieldName(obj)
            out=obj.DataFieldName;
        end


        function value=get.ConnectionStatus(obj)
            if isempty(obj.AsyncIOChannel)||~obj.AsyncIOChannel.isOpen
                value='Disconnected';
            else
                value='Connected';
            end
        end


        function value=get.Connected(obj)
            value=~isempty(obj.TransportChannel)&&...
            obj.TransportChannel.Connected;
        end


        function set.ByteOrder(obj,value)
            value=instrument.internal.stringConversionHelpers.str2char(value);
            validateattributes(value,{'char','string'},{'nonempty'},'UDP','BYTEORDER');
            value=validatestring(value,{'little-endian','big-endian'},"","BYTEORDER");
            obj.ByteOrder=value;
            if obj.Connected %#ok<*MCSUP>
                obj.TransportChannel.ByteOrder=obj.ByteOrder;
            end
        end


        function set.ErrorOccurredFcn(obj,value)
            if isempty(value)
                value=function_handle.empty();
            end
            try
                validateattributes(value,{'function_handle'},{},'UDP','ErrorOccurredFcn');
            catch ex
                throwAsCaller(ex);
            end
            obj.ErrorOccurredFcn=value;
        end


        function value=get.NumBytesWritten(obj)
            try

                obj.validateConnected();
            catch ex
                throwAsCaller(ex);
            end
            value=obj.TransportChannel.NumBytesWritten;
        end


        function value=get.InitAccess(obj)
            obj.validateConnected();
            obj.AsyncIOChannel.execute(['GetInitAccessStatus',char(0)]);
            value=obj.AsyncIOChannel.getCustomProp('InitAccess');
        end


        function obj=UDPBase()

            try
                obj.FilterImpl=matlabshared.transportlib.internal.FilterImpl(obj);
            catch validationException
                throwAsCaller(validationException);
            end
        end


        function connect(obj)
            if~isempty(obj.AsyncIOChannel)&&obj.AsyncIOChannel.isOpen()
                throwAsCaller(MException('network:udp:alreadyConnectedError',...
                message('network:udp:alreadyConnectedError').getString()));
            end

            if obj.EnableMulticast&&isempty(obj.MulticastGroup)
                error(message('network:udp:emptyMulticastGroupError').getString());
            end

            try

                obj.ConnectError.Status=[];
                obj.ConnectError.Exception=[];

                obj.ProtocolType=...
                matlabshared.network.internal.UDPBase.AllowedProtocolTypes.(obj.AddressType);

                initializeChannel(obj);

                if obj.ConnectError.Status
                    throw(obj.ConnectError.Exception);
                end

                obj.TransportChannel=...
                matlabshared.transportlib.internal.asyncIOTransportChannel.AsyncIOTransportChannel(obj.AsyncIOChannel,obj.CFIName);
                obj.TransportChannel.ByteOrder=obj.ByteOrder;
                obj.TransportChannel.NativeDataType=obj.NativeDataType;
                obj.TransportChannel.DataFieldName=obj.DataFieldName;
                if isa(obj,'matlabshared.network.internal.UDPByte')
                    obj.NativeDataType='uint8';
                else
                    obj.NativeDataType='struct';
                end
            catch asyncioError

                if obj.ConnectError.Status
                    throwAsCaller(asyncioError);
                else
                    formattedMessage=strrep(asyncioError.message,'Unexpected exception in plug-in: ','');
                    formattedMessage=strrep(formattedMessage,'''','');
                    throwAsCaller(MException('network:udp:connectFailed',...
                    message('network:udp:connectFailed',formattedMessage).getString()));
                end
            end
        end


        function data=readRaw(obj,count)

            try
                obj.validateConnected();
            catch validationEx
                throwAsCaller(validationEx);
            end

            try
                data=obj.TransportChannel.readRaw(count);
            catch ex
                throwAsCaller(MException('network:udp:receiveFailed',...
                message('network:udp:receiveFailed',ex.message).getString()));
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
                    throwAsCaller(MException('network:udp:sendFailed',...
                    message('network:udp:sendFailed',ex.message).getString()));
                end
            end
        end


        function writeAsync(varargin)

            try
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
                    throwAsCaller(MException('network:udp:sendFailed',...
                    message('network:udp:sendFailed',ex.message).GetString()));
                end
            end
        end


        function numbytes=writeAsyncRaw(obj,dataToWrite)
            numbytes=obj.TransportChannel.writeAsyncRaw(dataToWrite);
        end


        function ex=formatAsyncIOException(~,asyncioError,errorid)
            formattedMessage=strrep(asyncioError.message,'Unexpected exception in plug-in: ','');
            formattedMessage=strrep(formattedMessage,'''','');
            ex=MException(errorid,message(errorid,formattedMessage).getString());
        end


        function terminateChannel(obj)

            if obj.Connected
                obj.flushInput();
                obj.flushOutput();
            end

            if~isempty(obj.AsyncIOChannel)
                obj.AsyncIOChannel.close();
                delete(obj.AsyncIOChannel);
                delete(obj.ReceiveCallbackListener);
                delete(obj.SendCallbackListener);
                obj.AsyncIOChannel=[];
                obj.ReceiveCallbackListener=[];
                obj.SendCallbackListener=[];
                obj.TransportChannel=[];
            end
        end


        function validateDisconnected(obj)

            if obj.Connected&&~obj.AllowSettingProperty
                throwAsCaller(MException(message('transportlib:transport:cannotSetWhenConnected')));
            end
        end


        function validateConnected(obj)

            if~obj.Connected
                throwAsCaller(MException('transportlib:transport:invalidConnectionState',...
                message('transportlib:transport:invalidConnectionState','remote server').getString()));
            end
        end


        function handleCustomEvent(obj,~,eventData)

            errorId=eventData.Data.ErrorID;

            if~isempty(obj.ErrorOccurredFcn)
                obj.ErrorOccurredFcn(obj,...
                matlabshared.transportlib.internal.ErrorInfo(eventData.Data.ErrorID,...
                eventData.Data.ErrorMessage));
            else
                if~isempty(eventData.Data.ErrorMessage)
                    obj.ConnectError.Status=true;
                    obj.ConnectError.Exception=MException(errorId,message(errorId,eventData.Data.ErrorMessage).getString());
                else
                    error(errorId,message(errorId,eventData.Data.ErrorMessage).getString());
                end
            end
        end


        function disconnect(obj)
            terminateChannel(obj);
        end


        function delete(obj)
            obj.FilterImpl=[];
            terminateChannel(obj);
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
                obj.AsyncIOChannel.InputStream.flush();
                obj.TransportChannel.flushUnreadData();
                obj.AsyncIOChannel.execute("ResetTotalElementsWritten",[]);

                obj.LastCallbackVal=0;
            catch asyncioError
                throwAsCaller(obj.formatAsyncIOException(asyncioError,'network:udp:flushInputFailed'));
            end
        end


        function flushOutput(obj)
            obj.validateConnected();
            try
                obj.AsyncIOChannel.OutputStream.flush();
            catch asyncioError
                throwAsCaller(obj.formatAsyncIOException(asyncioError,'network:udp:flushOutputFailed'));
            end
        end


        function setRemoteEndpoint(obj,address,port)

            obj.validateConnected();
            if~strcmp(address,obj.RemoteHost)||port~=obj.RemotePort
                address=instrument.internal.stringConversionHelpers.str2char(address);
                options.RemoteHost=address;
                options.RemotePort=port;
                obj.AsyncIOChannel.execute("SetRemoteEndpoint",options);
                obj.AllowSettingProperty=true;
                obj.RemoteHost=obj.AsyncIOChannel.RemoteHostVal;
                obj.RemotePort=double(obj.AsyncIOChannel.RemotePortVal);
                obj.AllowSettingProperty=false;
            end
        end


        function setMulticast(obj,multicastGroup)

            obj.validateConnected();
            validateattributes(multicastGroup,{'char','string'},{},'UDP','MULTICASTGROUP');
            if~strcmp(multicastGroup,obj.MulticastGroup)
                multicastGroup=instrument.internal.stringConversionHelpers.str2char(multicastGroup);
                options.MulticastGroup=multicastGroup;
                options.EnableMulticast=true;
                obj.AsyncIOChannel.execute("SetMulticast",options);
                obj.AllowSettingProperty=true;
                obj.EnableMulticast=obj.AsyncIOChannel.MulticastVal;
                obj.MulticastGroup=obj.AsyncIOChannel.MulticastGroupVal;
                obj.AllowSettingProperty=false;
            end
        end


        function setEnableLoopback(obj,flag)

            obj.validateConnected();

            validateattributes(flag,{'logical'},{'nonempty'},'UDP','FLAG');

            if flag~=obj.EnableDatagramLoopback
                options.MulticastLoopback=flag;
                obj.AsyncIOChannel.execute("SetEnableLoopback",options);
                obj.AllowSettingProperty=true;
                obj.EnableDatagramLoopback=obj.AsyncIOChannel.MulticastLoopbackVal;
                obj.AllowSettingProperty=false;
            end
        end


        function setEnableBroadcast(obj,flag)

            obj.validateConnected();

            validateattributes(flag,{'logical'},{'nonempty'},'UDP','FLAG');

            if flag~=obj.EnableBroadcast
                options.EnableBroadcast=flag;
                obj.AsyncIOChannel.execute("SetBroadcast",options);
                obj.AllowSettingProperty=true;
                obj.EnableBroadcast=obj.AsyncIOChannel.EnableBroadcastVal;
                obj.AllowSettingProperty=false;
            end
        end


        function resetMulticast(obj)
            obj.validateConnected();

            if obj.EnableMulticast
                obj.AsyncIOChannel.execute("ResetMulticast",[]);
                obj.AllowSettingProperty=true;
                obj.EnableMulticast=obj.AsyncIOChannel.MulticastVal;
                obj.MulticastGroup=obj.AsyncIOChannel.MulticastGroupVal;
                obj.AllowSettingProperty=false;
            end
        end


        function setOutputDatagramPacketSize(obj,value)

            obj.validateConnected();

            validateattributes(value,{'numeric'},{'scalar','nonnegative','nonnan'},'UDP','OUTPUTDATAGRAMPACKETSIZE');
            if value~=obj.OutputDatagramPacketSize
                options.OutputDatagramPacketSize=value;
                obj.AsyncIOChannel.execute("SetOutputDatagramPacketSize",options);
                obj.AllowSettingProperty=true;
                obj.OutputDatagramPacketSize=value;
                obj.AllowSettingProperty=false;
            end
        end
    end


    methods(Access=protected)
        function initializeChannel(obj,varargin)

            narginchk(1,2);
            if nargin==2
                options=varargin{1};
            end
            options.RemoteHost=obj.RemoteHost;
            options.RemotePort=double(obj.RemotePort);
            options.LocalHost=obj.LocalHost;
            options.LocalPort=double(obj.LocalPort);
            options.AddressType=obj.AddressType;
            options.ProtocolType=obj.ProtocolType;
            options.EnableMulticast=obj.EnableMulticast;
            options.MulticastGroup=obj.MulticastGroup;
            options.EnablePortSharing=obj.EnablePortSharing;
            options.EnableBroadcast=obj.EnableBroadcast;
            options.MulticastLoopback=obj.EnableDatagramLoopback;
            options.SocketType=obj.StandardSocketType;
            options.IsWriteOnly=obj.IsWriteOnly;
            options.EnableSocketSharing=obj.EnableSocketSharing;

            if isa(obj,'matlabshared.network.internal.UDPByte')
                options.Mode=obj.Mode.Byte;
            else
                options.Mode=obj.Mode.Datagram;
            end

            if~isempty(obj.CustomConverterPlugIn)
                converterPlugin=obj.CustomConverterPlugIn;
            else
                converterPlugin=obj.ConverterPlugin;
            end
            obj.AsyncIOChannel=matlabshared.asyncio.internal.Channel(obj.DevicePlugin,...
            converterPlugin,...
            Options=options,...
            StreamLimits=[inf,inf]);
            obj.setAsyncIOChannelTimeout(obj.Timeout);
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
            options.ReceiveSize=obj.DefaultSocketSize;
            options.SendSize=obj.DefaultSocketSize;
            obj.AsyncIOChannel.open(options);
            obj.LocalHost=obj.AsyncIOChannel.LocalHostVal;
            obj.LocalPort=double(obj.AsyncIOChannel.LocalPortVal);
            obj.RemoteHost=obj.AsyncIOChannel.RemoteHostVal;
        end


        function p=initProperties(obj,inputs)
            p=inputParser;
            p.PartialMatching=true;
            p.KeepUnmatched=true;
            addParameter(p,'AddressType','IPV4',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            parse(p,inputs{:});

            if strcmpi(p.Results.AddressType,'IPV4')
                addParameter(p,'RemoteHost','127.0.0.1',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
                addParameter(p,'LocalHost','0.0.0.0',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            else
                addParameter(p,'RemoteHost','::1',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
                addParameter(p,'LocalHost','::',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            end
            addParameter(p,'RemotePort',9090,@(x)validateattributes(x,{'numeric'},{'>=',1,'<=',65535,'scalar','nonnegative','finite'}));
            addParameter(p,'LocalPort',0,@(x)validateattributes(x,{'numeric'},{'>=',0,'<=',65535,'scalar','nonnegative','finite'}));
            addParameter(p,'EnableMulticast',false,@(x)validateattributes(x,{'logical'},{'nonempty'}));
            addParameter(p,'MulticastGroup','',@(x)validateattributes(x,{'char','string'},{}));
            addParameter(p,'EnablePortSharing',false,@(x)validateattributes(x,{'logical'},{'nonempty'}));
            addParameter(p,'EnableBroadcast',false,@(x)validateattributes(x,{'logical'},{'nonempty'}));
            addParameter(p,'Timeout',10,@isscalar);
            addParameter(p,'ByteOrder','little-endian',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            addParameter(p,'EnableDatagramLoopback',true,@(x)validateattributes(x,{'logical'},{'nonempty'}));
            addParameter(p,'IsWriteOnly',false,@(x)validateattributes(x,{'logical'},{'nonempty'}));
            addParameter(p,'EnableSocketSharing',false,@(x)validateattributes(x,{'logical'},{'nonempty'}));

            parse(p,inputs{:});
            output=p.Results;
            obj.RemoteHost=output.RemoteHost;
            obj.RemotePort=output.RemotePort;
            obj.LocalHost=output.LocalHost;
            obj.LocalPort=output.LocalPort;
            obj.AddressType=output.AddressType;
            obj.EnableMulticast=output.EnableMulticast;
            obj.MulticastGroup=output.MulticastGroup;
            obj.EnablePortSharing=output.EnablePortSharing;
            obj.EnableBroadcast=output.EnableBroadcast;
            obj.Timeout=output.Timeout;
            obj.EnableDatagramLoopback=output.EnableDatagramLoopback;
            obj.IsWriteOnly=output.IsWriteOnly;
            obj.EnableSocketSharing=output.EnableSocketSharing;
        end


        function setAsyncIOChannelTimeout(obj,value)

            if~isempty(obj.AsyncIOChannel)
                obj.AsyncIOChannel.OutputStream.Timeout=value;
                obj.AsyncIOChannel.InputStream.Timeout=value;
            end
        end
    end


    methods(Hidden)
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


        function s=saveobj(obj)
            s.RemoteHost=obj.RemoteHost;
            s.RemotePort=obj.RemotePort;
            s.LocalHost=obj.LocalHost;
            s.LocalPort=obj.LocalPort;
            s.AddressType=obj.AddressType;
            s.EnableMulticast=obj.EnableMulticast;
            s.MulticastGroup=obj.MulticastGroup;
            s.Timeout=obj.Timeout;
            s.OutputDatagramPacketSize=obj.OutputDatagramPacketSize;
            s.Connected=obj.ConnectionStatus;
            s.ByteOrder=obj.ByteOrder;
            s.EnablePortSharing=obj.EnablePortSharing;
            s.EnableBroadcast=obj.EnableBroadcast;
            s.NativeDataType=obj.NativeDataType;
            s.DataFieldName=obj.DataFieldName;
            s.EnableDatagramLoopback=obj.EnableDatagramLoopback;
            s.IsWriteOnly=obj.IsWriteOnly;
            s.EnableSocketSharing=obj.EnableSocketSharing;
        end
    end


    methods(Static=true,Hidden=true)
        function out=loadobj(out,s)
            out.RemoteHost=s.RemoteHost;
            out.RemotePort=s.RemotePort;
            out.LocalHost=s.LocalHost;
            out.LocalPort=s.LocalPort;
            out.AddressType=s.AddressType;
            out.EnableMulticast=s.EnableMulticast;
            out.MulticastGroup=s.MulticastGroup;
            out.Timeout=s.Timeout;
            out.EnablePortSharing=s.EnablePortSharing;
            out.EnableBroadcast=s.EnableBroadcast;
            out.OutputDatagramPacketSize=s.OutputDatagramPacketSize;
            out.ByteOrder=s.ByteOrder;
            out.NativeDataType=s.NativeDataType;
            out.DataFieldName=s.DataFieldName;
            out.EnableDatagramLoopback=s.EnableDatagramLoopback;
            out.IsWriteOnly=s.IsWriteOnly;
            out.EnableSocketSharing=s.EnableSocketSharing;
        end
    end
end