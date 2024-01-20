classdef TCPClient<matlabshared.transportlib.internal.ITransport&...
    matlabshared.transportlib.internal.ITokenReader&...
    matlabshared.transportlib.internal.IFilterable&...
    coder.ExternalDependency

%#codegen

    properties(Constant,Hidden)

        DefaultSocketSize=64*1024
        ConverterPlugin=coder.const(fullfile(toolboxdir(fullfile('shared','networklib','bin',computer('arch'))),'networkcoderconverter'));
        DevicePlugin=coder.const(fullfile(toolboxdir(fullfile('shared','networklib','bin',computer('arch'))),'tcpclientdevice'));
    end


    properties(Constant,Access=private)
        DefaultLibExtention=coder.const(feature('GetSharedLibExt'));
        DefaultFileSep=coder.const(filesep);
        DefaultDeviceName='tcpclientdevice';
        DefaultConverterName='networkcoderconverter';
        DefaultOS=coder.const(computer('arch'));
        DefaultMATLABRoot=coder.const(matlabroot);
        DefaultMATLABVersion=coder.const(ver('matlab').Release);
        DefaultPluginRelativePath=coder.const(fullfile('toolbox','shared','networklib','bin',computer('arch')));
    end


    properties(Dependent)

WriteAsync
    end


    methods(Static)
        function name=getDescriptiveName(~)
            name='TCPCLIENT';
        end


        function tf=isSupportedContext(buildConfig)
            tf=buildConfig.isMatlabHostTarget();
        end


        function updateBuildInfo(buildInfo,buildConfig)
            [~,~,exeLibExt,libPrefix]=buildConfig.getStdLibInfo();
            pluginPath=fullfile(matlabroot,'toolbox','shared','networklib','bin',computer('arch'));
            buildInfo.addNonBuildFiles([libPrefix,'networkcoderconverter',exeLibExt],...
            pluginPath,'TCPClient AsyncIO converter');
            buildInfo.addNonBuildFiles([libPrefix,'tcpclientdevice',exeLibExt],...
            pluginPath,'TCPClient AsyncIO device plugin');
            buildInfo.addNonBuildFiles([libPrefix,'networksupport',exeLibExt],...
            pluginPath,'networksupport library');
            MLBinPath=fullfile(matlabroot,'bin',computer('arch'));



            function libName=makeBoostLibName(baseName)
                libName=matlabshared.asyncio.internal.coder.API.makeBoostLibName(baseName,MLBinPath,exeLibExt);
            end

            buildInfo.addNonBuildFiles(makeBoostLibName('system'),...
            MLBinPath,'mwboost_system library (required by networksupport and tcpclientdevice)');
            switch computer('arch')
            case 'win64'
                buildInfo.addNonBuildFiles(makeBoostLibName('date_time'),...
                MLBinPath,'mwboost_date_time library (required by networksupport)');
            case{'glnxa64','maci64'}
                buildInfo.addNonBuildFiles([libPrefix,'cpp11compat',exeLibExt],...
                MLBinPath,'libmwcpp11compat library (required by networkcoderconverter and tcpclientdevice)');
            end
        end
    end


    methods(Access=private,Static)
        function[devicePath,converterPath]=getPluginPath()
            coder.extrinsic('matlabroot');
            coder.extrinsic('ver');
            coder.extrinsic('getfield');
            coder.extrinsic('exist');
            coder.varsize('devicePath',[],[0,1]);
            coder.varsize('converterPath',[],[0,1]);

            if strcmp(matlabshared.network.internal.coder.TCPClient.DefaultOS,'win64')
                libPrefix='';
            else
                libPrefix='libmw';
            end
            deviceFullName=[libPrefix,matlabshared.network.internal.coder.TCPClient.DefaultDeviceName,matlabshared.network.internal.coder.TCPClient.DefaultLibExtention];
            converterFullName=[libPrefix,matlabshared.network.internal.coder.TCPClient.DefaultConverterName,matlabshared.network.internal.coder.TCPClient.DefaultLibExtention];
            if coder.internal.canUseExtrinsic()

                thisOS=computer('arch');
                thisMLVersion=getfield(ver('matlab'),'Release');
                thisMatlabRoot=blanks(coder.ignoreConst(512));
                thisMatlabRoot=matlabroot;

                if strcmp(thisOS,matlabshared.network.internal.coder.TCPClient.DefaultOS)...
                    &&strcmp(thisMLVersion,matlabshared.network.internal.coder.TCPClient.DefaultMATLABVersion)
                    deviceFullPathML=[thisMatlabRoot,matlabshared.network.internal.coder.TCPClient.DefaultFileSep...
                    ,matlabshared.network.internal.coder.TCPClient.DefaultPluginRelativePath,matlabshared.network.internal.coder.TCPClient.DefaultFileSep,deviceFullName];
                    if exist(deviceFullPathML,'file')

                        devicePath=deviceFullPathML;
                    else
                        coder.internal.error('network:tcpclient:CannotFindPlugin');
                        devicePath='';
                    end
                    converterFullPathML=[thisMatlabRoot,matlabshared.network.internal.coder.TCPClient.DefaultFileSep...
                    ,matlabshared.network.internal.coder.TCPClient.DefaultPluginRelativePath,matlabshared.network.internal.coder.TCPClient.DefaultFileSep,converterFullName];
                    if exist(converterFullPathML,'file')

                        converterPath=converterFullPathML;
                    else
                        coder.internal.error('network:tcpclient:CannotFindPlugin');
                        converterPath='';
                    end
                else
                    coder.internal.error('network:tcpclient:WrongMATLABVersion',...
                    matlabshared.network.internal.coder.TCPClient.DefaultMATLABVersion,...
                    matlabshared.network.internal.coder.TCPClient.DefaultOS);
                    devicePath='';
                    converterPath='';
                end
            else
                deviceFullPath=matlabshared.asyncio.internal.coder.computeAbsolutePath(deviceFullName);
                if~isempty(deviceFullPath)

                    devicePath=deviceFullPath;
                else
                    deviceFullPathML=matlabshared.asyncio.internal.coder.computeAbsolutePath(...
                    [matlabshared.network.internal.coder.TCPClient.DefaultMATLABRoot,matlabshared.network.internal.coder.TCPClient.DefaultFileSep...
                    ,matlabshared.network.internal.coder.TCPClient.DefaultPluginRelativePath,matlabshared.network.internal.coder.TCPClient.DefaultFileSep,deviceFullName]);
                    if~isempty(deviceFullPathML)

                        devicePath=deviceFullPathML;
                    else

                        coder.internal.error('network:tcpclient:CannotFindPlugin');
                        devicePath='';
                    end
                end
                converterFullPath=matlabshared.asyncio.internal.coder.computeAbsolutePath(converterFullName);
                if~isempty(converterFullPath)

                    converterPath=converterFullPath;
                else
                    converterFullPathML=matlabshared.asyncio.internal.coder.computeAbsolutePath(...
                    [matlabshared.network.internal.coder.TCPClient.DefaultMATLABRoot,matlabshared.network.internal.coder.TCPClient.DefaultFileSep...
                    ,matlabshared.network.internal.coder.TCPClient.DefaultPluginRelativePath,matlabshared.network.internal.coder.TCPClient.DefaultFileSep,converterFullName]);
                    if~isempty(converterFullPathML)
                        converterPath=converterFullPathML;
                    else

                        coder.internal.error('network:tcpclient:CannotFindPlugin');
                        converterPath='';
                    end
                end
            end
        end
    end


    properties(Constant)
        DefaultTimeout=10
        DefaultConnectTimeout=inf
        DefaultTransferDelay=true
    end

    properties(GetAccess=public,SetAccess=private,Dependent)
        ConnectionStatus;
    end

    properties(GetAccess=public,SetAccess=protected)
RemoteHost
RemotePort
    end

    properties(GetAccess=public,SetAccess=private,Hidden=true)
IsWriteOnly
IsSharingPort
    end


    properties(Hidden,Dependent)
        InitAccess(1,1)logical{mustBeNonempty}
    end


    properties(Access=public)        Timeout=matlabshared.network.internal.TCPClient.DefaultTimeout
        ConnectTimeout=matlabshared.network.internal.TCPClient.DefaultConnectTimeout
UserData
    end


    properties(Access=private)
        InputBufferSize=inf
        OutputBufferSize=inf
    end

    properties(GetAccess=private,SetAccess=private)

ReceiveCallbackListener
SendCallbackListener
CustomListener
    end

    properties(Access=private,Transient=true)
AsyncIOChannel
TransportChannel
FilterImpl
    end


    properties        TransferDelay(1,1)logical=matlabshared.network.internal.TCPClient.DefaultTransferDelay
    end


    properties(GetAccess=public,SetAccess=private,Dependent)

NumBytesAvailable
NumBytesWritten
Connected
    end


    properties(Access=public)
        BytesAvailableEventCount=0
        BytesAvailableFcn=[]
        BytesWrittenFcn=[]
        ErrorOccurredFcn=[]
ByteOrder
NativeDataType
DataFieldName
CustomConverterPlugIn
    end


    properties
        SingleCallbackMode=false
        LastCallbackVal=0
    end


    methods
        function value=get.WriteAsync(obj)
            value=obj.TransportChannel.WriteAsync;
        end


        function set.WriteAsync(obj,value)
            obj.TransportChannel.WriteAsync=value;
        end


        function value=get.ConnectionStatus(obj)
            if isempty(obj.AsyncIOChannel)||~obj.AsyncIOChannel.isOpen()
                value='Disconnected';
            else
                value='Connected';
            end
        end


        function value=get.InitAccess(obj)
            obj.validateConnected();            obj.AsyncIOChannel.execute(['GetInitAccessStatus',char(0)]);
            value=obj.AsyncIOChannel.getCustomProp('InitAccess');
        end


        function value=get.BytesAvailable(obj)
            value=obj.NumBytesAvailable;
        end


        function obj=set.Timeout(obj,value)%#ok<MCHV2>

            validateattributes(value,{'numeric'},{'scalar','nonnegative','finite','nonnan'},'TCPClient','TIMEOUT');
            obj.setAsyncIOChannelTimeout(value);
            obj.Timeout=value;
        end


        function set.ConnectTimeout(obj,value)

            validateattributes(value,{'numeric'},{'scalar','>=',1,'nonnan'},'TCPClient','CONNECTTIMEOUT');

            validateDisconnected(obj);

            obj.ConnectTimeout=value;
        end


        function set.InputBufferSize(obj,value)

            validateattributes(value,{'numeric'},{'scalar','nonnegative','nonnan'},'TCPClient','INPUTBUFFERSIZE');
            validateDisconnected(obj);
            obj.InputBufferSize=value;
        end


        function set.OutputBufferSize(obj,value)

            validateattributes(value,{'numeric'},{'scalar','nonnegative','nonnan'},'TCPClient','OUTPUTBUFFERSIZE');
            validateDisconnected(obj);
            obj.OutputBufferSize=value;
        end


        function set.BytesAvailableEventCount(~,~)
            coder.internal.assert(false,'network:tcpclient:PropertyNotSupportedByCodegen','BytesAvailableEventCount');
        end


        function set.BytesAvailableFcn(~,~)
            coder.internal.assert(false,'network:tcpclient:PropertyNotSupportedByCodegen','BytesAvailableFcn');
        end


        function set.BytesWrittenFcn(~,~)
            coder.internal.assert(false,'network:tcpclient:PropertyNotSupportedByCodegen','BytesWrittenFcn');
        end


        function set.ErrorOccurredFcn(~,~)
            coder.internal.assert(false,'network:tcpclient:PropertyNotSupportedByCodegen','ErrorOccurredFcn');
        end


        function set.CustomConverterPlugIn(obj,value)
            validateDisconnected(obj);

            validateattributes(value,{'char','string'},{},'TCPClient','CUSTOMCONVERTERPLUGIN');

            obj.CustomConverterPlugIn=value;
        end


        function set.UserData(~,~)
            coder.internal.assert(false,'network:tcpclient:PropertyNotSupportedByCodegen','UserData');
        end


        function value=get.BytesAvailableEventCount(obj)
            coder.internal.assert(false,'network:tcpclient:PropertyNotSupportedByCodegen','BytesAvailableEventCount');

            value=obj.BytesAvailableEventCount;
        end


        function value=get.BytesAvailableFcn(obj)
            coder.internal.assert(false,'network:tcpclient:PropertyNotSupportedByCodegen','BytesAvailableFcn');

            value=obj.BytesAvailableFcn;
        end


        function value=get.BytesWrittenFcn(obj)
            coder.internal.error('network:tcpclient:PropertyNotSupportedByCodegen','BytesWrittenFcn');

            value=obj.BytesWrittenFcn;
        end

        function value=get.ErrorOccurredFcn(obj)
            coder.internal.assert(false,'network:tcpclient:PropertyNotSupportedByCodegen','ErrorOccurredFcn');

            value=obj.ErrorOccurredFcn;
        end


        function value=get.UserData(obj)
            coder.internal.assert(false,'network:tcpclient:PropertyNotSupportedByCodegen','UserData');

            value=obj.UserData;
        end


        function value=get.NumBytesAvailable(obj)

            obj.validateConnected();
            value=obj.TransportChannel.NumBytesAvailable;
        end


        function value=get.NumBytesWritten(obj)

            obj.validateConnected();
            value=obj.TransportChannel.NumBytesWritten;
        end


        function set.ByteOrder(obj,val)

            validateattributes(val,{'char','string'},{'nonempty'},mfilename,'ByteOrder');
            value=char(val);
            obj.TransportChannel.ByteOrder=value;%#ok<MCSUP>
            obj.ByteOrder=blanks(coder.ignoreConst(0));
            obj.ByteOrder=obj.TransportChannel.ByteOrder;%#ok<MCSUP>
        end


        function out=get.ByteOrder(obj)
            out=obj.ByteOrder;
        end


        function set.NativeDataType(obj,val)

            validateattributes(val,{'string','char'},{},mfilename,'val',2);
            obj.NativeDataType=blanks(coder.ignoreConst(0));
            obj.NativeDataType=val;
            obj.TransportChannel.NativeDataType=val;%#ok<MCSUP>
        end


        function out=get.NativeDataType(obj)
            out=obj.NativeDataType;
        end


        function set.DataFieldName(obj,val)

            validateattributes(val,{'string','char'},{},mfilename,'val',2);
            obj.DataFieldName=blanks(coder.ignoreConst(0));
            obj.DataFieldName=val;
            obj.TransportChannel.DataFieldName=val;%#ok<MCSUP>
        end


        function out=get.DataFieldName(obj)
            out=obj.DataFieldName;
        end


        function value=get.Connected(obj)
            value=~isempty(obj.TransportChannel)&&...
            obj.TransportChannel.Connected;
        end


        function value=get.TransferDelay(obj)
            if~obj.Connected
                value=obj.TransferDelay;
            else
                value=obj.AsyncIOChannel.getCustomProp('TransferDelay');
            end
        end


        function set.TransferDelay(obj,value)
            obj.validateDisconnected();
            obj.TransferDelay=value;
        end
    end


    methods(Access=public)

        function obj=TCPClient(hostName,portNumber,varargin)

            coder.allowpcode('plain');
            hostName=char(hostName);
            validateattributes(hostName,{'char'},{'nonempty'},'TCPClient','HOSTNAME',1)

            validateattributes(portNumber,{'numeric'},{'>=',1,'<=',65535,'scalar','nonnegative','finite'},'TCPClient','PORTNUMBER',2)


            obj.RemoteHost=hostName;
            obj.RemotePort=portNumber;

            initializeChannel(obj);

            obj.initProperties(varargin);

            obj.ByteOrder='little-endian';
            obj.NativeDataType='uint8';
            obj.DataFieldName='Data';

        end


        function connect(obj)
            if(~isempty(obj.AsyncIOChannel)&&obj.AsyncIOChannel.isOpen())
                coder.internal.error('network:tcpclient:alreadyConnectedError');
            end

            openChannel(obj);
        end


        function disconnect(obj)
            terminateChannel(obj);
        end


        function data=getTotalBytesWritten(~)
            coder.internal.assert(false,'network:tcpclient:FunctionNotSupportedByCodegen','getTotalBytesWritten');
            data=0;
        end


        function tuneInputFilter(obj,options)
            narginchk(2,2);

            obj.validateConnected();
            obj.AsyncIOChannel.InputStream.tuneFilters(options);
        end


        function tuneOutputFilter(obj,options)
            narginchk(2,2);

            obj.validateConnected();

            obj.AsyncIOChannel.OutputStream.tuneFilters(options);

        end


        function addInputFilter(obj,filter,options)

            narginchk(3,3);
            obj.FilterImpl.addInputFilter(filter,options);
        end


        function removeInputFilter(obj,filter)
            narginchk(2,2);
            obj.FilterImpl.removeInputFilter(filter);
        end


        function addOutputFilter(obj,filter,options)

            narginchk(3,3);
            obj.FilterImpl.addOutputFilter(filter,options);
        end


        function removeOutputFilter(obj,filter)

            narginchk(2,2);
            obj.FilterImpl.removeOutputFilter(filter);
        end

        function[inputFilters,inputFilterOptions]=getInputFilters(obj)
            [inputFilters,inputFilterOptions]=obj.FilterImpl.getInputFilters();
        end

        function[outputFilters,outputFilterOptions]=getOutputFilters(obj)
            [outputFilters,outputFilterOptions]=obj.FilterImpl.getOutputFilters();
        end


        function data=read(varargin)
            obj=varargin{1};
            obj.validateConnected();
            data=obj.TransportChannel.read(varargin{2:end});

        end


        function data=readUntil(varargin)

            narginchk(2,3);
            obj=varargin{1};
            obj.validateConnected();
            data=obj.TransportChannel.readUntil(varargin{2:end});
        end


        function data=readRaw(obj,numBytes)
            data=obj.TransportChannel.readRaw(numBytes);

        end


        function tokenFound=peekUntil(obj,token)

            narginchk(2,2);
            obj.validateConnected();
            tokenFound=obj.TransportChannel.peekUntil(token);
        end


        function write(varargin)
            narginchk(2,3);
            obj=varargin{1};
            obj.validateConnected();
            obj.TransportChannel.write(varargin{2:end});
        end


        function writeAsync(varargin)
            obj=varargin{1};
            obj.validateConnected();
            obj.TransportChannel.writeAsync(varargin{2:end});

        end


        function numbytes=writeAsyncRaw(obj,dataToWrite)
            numbytes=obj.TransportChannel.writeAsyncRaw(dataToWrite);
        end


        function flushInput(obj)
            obj.validateConnected();
            obj.AsyncIOChannel.InputStream.flush();

            obj.TransportChannel.flushUnreadData();
        end


        function flushOutput(obj)
            obj.validateConnected();
            obj.AsyncIOChannel.OutputStream.flush();
        end


        function index=peekBytesFromEnd(~,~,~)
            coder.internal.assert(false,'network:tcpclient:FunctionNotSupportedByCodegen','peekBytesFromEnd');
            index=-1;
        end
    end


    methods(Access=private)
        function initProperties(obj,inputs)
            parms=struct(...
            'IsWriteOnly',false,...
            'IsSharingPort',false);

            popt=struct(...
            'CaseSensitivity',false,...
            'StructExpand',true,...
            'PartialMatching','unique');

            optarg=coder.internal.parseParameterInputs(parms,popt,inputs{:});
            obj.IsWriteOnly=coder.internal.getParameterValue(optarg.IsWriteOnly,false,inputs{:});
            obj.IsSharingPort=coder.internal.getParameterValue(optarg.IsSharingPort,false,inputs{:});
        end


        function initializeChannel(obj)

            options.HostName=obj.RemoteHost;
            options.ServiceName=sprintf('%u',uint32(obj.RemotePort));
            [devicePlugin,converterPlugin]=matlabshared.network.internal.coder.TCPClient.getPluginPath();
            customPropsExpected.InitAccess=true;
            customPropsExpected.TransferDelay=true;
            customPropsExpected.LatestNumBytesWrittenToDevice=uint64(0);
            obj.AsyncIOChannel=matlabshared.asyncio.internal.Channel(devicePlugin,...
            converterPlugin,...
            CoderExampleData=zeros(1,1,'uint8'),...
            CountDimensions=[2,2],...
            Options=options,...
            StreamLimits=[obj.InputBufferSize,obj.OutputBufferSize],...
            CustomPropsExpected=customPropsExpected);

            obj.TransportChannel=...
            matlabshared.transportlib.internal.asyncIOTransportChannel.coder.AsyncIOTransportChannel(obj.AsyncIOChannel);

        end


        function openChannel(obj)
            options.HostName=obj.RemoteHost;
            options.ServiceName=sprintf('%u',uint32(obj.RemotePort));
            options.ReceiveSize=obj.DefaultSocketSize;
            options.SendSize=obj.DefaultSocketSize;
            options.ConnectTimeout=obj.ConnectTimeout;
            options.IsWriteOnly=obj.IsWriteOnly;
            options.IsSharingPort=obj.IsSharingPort;
            options.TransferDelay=obj.TransferDelay;

            obj.AsyncIOChannel.open(options);

        end


        function setAsyncIOChannelTimeout(obj,value)

            if~isempty(obj.AsyncIOChannel)
                outputStream=obj.AsyncIOChannel.OutputStream;
                outputStream.Timeout=value;
                inputStream=obj.AsyncIOChannel.InputStream;
                inputStream.Timeout=value;
            end
        end


        function terminateChannel(obj)

            if(~isempty(obj.AsyncIOChannel))
                obj.AsyncIOChannel.close();
            end
        end


        function validateDisconnected(obj)
            if obj.Connected
                coder.internal.error('transportlib:transport:cannotSetWhenConnected');
            end
        end


        function validateConnected(obj)

            if~obj.Connected
                coder.internal.error('transportlib:transport:invalidConnectionState','remote server');
            end
        end


        function onDataReceived(~,~,~)
            coder.internal.assert(false,'network:tcpclient:FunctionNotSupportedByCodegen','onDataReceived');
            return;
        end


        function onDataWritten(~,~,~)
            coder.internal.assert(false,'network:tcpclient:FunctionNotSupportedByCodegen','onDataWritten');
            return;
        end


        function handleCustomEvent(~,~,~)
            coder.internal.assert(false,'network:tcpclient:FunctionNotSupportedByCodegen','handleCustomEvent');
            return;
        end
    end


    methods(Hidden)

        function delete(obj)
            terminateChannel(obj);
        end
    end


    properties(Hidden,GetAccess=public,SetAccess=private,Dependent)

BytesAvailable
    end


    methods(Hidden)

        function data=receive(obj,size,precision)

            data=obj.read(size,precision);
        end

        function[data,errorStr]=receiveRaw(obj,numBytes)

            data=obj.readRaw(numBytes);
            errorStr='';
        end


        function send(obj,data)
            obj.write(data);
        end


        function sendAsync(obj,dataToWrite)
            obj.writeAsync(dataToWrite);
        end

        function[numBytes,errorStr]=sendRawAsync(obj,dataToWrite)
            numBytes=obj.writeAsyncRaw(dataToWrite);
            errorStr='';
        end
    end

end
