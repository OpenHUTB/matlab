classdef Serial<matlabshared.transportlib.internal.ITransport&...
    matlabshared.transportlib.internal.ITokenReader&...
    matlabshared.transportlib.internal.IFilterable&...
    coder.ExternalDependency









































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
    end

    properties(Constant,Hidden)


        DefaultBaudRate=9600



        DefaultFlowControl='none'


        DefaultParity='none'


        DefaultStopBits=1


        DefaultDataBits=8



        DefaultByteOrder='little-endian'



        DefaultNativeDataType='uint8'



        DefaultDataFieldName='Data'

    end

    properties(Constant,Access=private)

        DefaultLibExtention=coder.const(feature('GetSharedLibExt'));
        DefaultFileSep=coder.const(filesep);
        DefaultDeviceName='serialdevice';
        DefaultConverterName='serialcoderconverter';
        DefaultOS=coder.const(computer('arch'));
        DefaultMATLABRoot=coder.const(matlabroot);
        DefaultMATLABVersion=coder.const(ver('matlab').Release);
        DefaultPluginRelativePath=coder.const(fullfile('toolbox','shared','seriallib','bin',computer('arch')));
    end

    properties(GetAccess=public,SetAccess=private)

Port
    end

    properties(GetAccess=public,SetAccess=private,Hidden=true)



        IsWriteOnly(1,1)logical{mustBeNonempty}



        IsSharingPort(1,1)logical{mustBeNonempty}



        IsSharingExistingTimeout(1,1)logical{mustBeNonempty}
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


BaudRate



FlowControl



Parity



StopBits


DataBits



ByteOrder



NativeDataType



DataFieldName



CustomConverterPlugIn



        Timeout=matlabshared.seriallib.internal.Serial.DefaultTimeout


        UserData=[]





        SingleCallbackMode=false





        LastCallbackVal=0
    end

    properties(Access=private)


        InputBufferSize=inf




        OutputBufferSize=inf
    end

    properties(Access=public)



        BytesAvailableEventCount=64



BytesAvailableFcn




BytesWrittenFcn



ErrorOccurredFcn
    end

    properties(GetAccess=private,SetAccess=protected)



ReceiveCallbackListener



SendCallbackListener



CustomListener
    end

    properties(Hidden,Dependent)





        AllowPartialReads(1,1)logical{mustBeNonempty}





        WriteAsync(1,1)logical
    end


    methods(Static)
        function name=getDescriptiveName(~)
            name='SERIAL';
        end

        function tf=isSupportedContext(buildCconfig)
            tf=buildCconfig.isMatlabHostTarget();
        end

        function updateBuildInfo(buildInfo,buildConfig)

            [~,~,exeLibExt,libPrefix]=buildConfig.getStdLibInfo();
            pluginPath=fullfile(matlabroot,'toolbox','shared','seriallib','bin',computer('arch'));
            buildInfo.addNonBuildFiles([libPrefix,'serialcoderconverter',exeLibExt],...
            pluginPath,'Serial AsyncIO converter');
            buildInfo.addNonBuildFiles([libPrefix,'serialdevice',exeLibExt],...
            pluginPath,'Serial AsyncIO device plugin');
            buildInfo.addNonBuildFiles([libPrefix,'serialsupport',exeLibExt],...
            pluginPath,'serialsupport library');


            MLBinPath=fullfile(matlabroot,'bin',computer('arch'));

            buildInfo.addNonBuildFiles(['libmwcpp11compat',exeLibExt],...
            MLBinPath,'libmwcpp11compat library (required by serialsupport)');
            buildInfo.addNonBuildFiles([libPrefix,'tamutil',exeLibExt],...
            MLBinPath,'tamutil library (required by serialsupport)');
            buildInfo.addNonBuildFiles(['libmwi18n',exeLibExt],...
            MLBinPath,'libmwi18n library (required by tamutil)');
            buildInfo.addNonBuildFiles(['libmwfoundation_filesystem',exeLibExt],...
            MLBinPath,'libmwfoundation_filesystem library (required by libmwi18n)');
            if(isunix()&&~ismac())
                buildInfo.addNonBuildFiles(['libmwlocale',exeLibExt],...
                MLBinPath,'libmwlocale library (required by libmwfilesystem)');
            end
            buildInfo.addNonBuildFiles(['libmwresource_core',exeLibExt],...
            MLBinPath,'libmwi18n library (required by libmwi18n)');



            function libName=makeBoostLibName(baseName)
                libName=matlabshared.asyncio.internal.coder.API.makeBoostLibName(baseName,MLBinPath,exeLibExt);
            end

            function libName=makeIcuLibName(baseName)
                libName=matlabshared.asyncio.internal.coder.API.makeIcuLibName(baseName,MLBinPath,exeLibExt);
            end

            function libName=makeExpatLibName()
                libName=matlabshared.asyncio.internal.coder.API.makeExpatLibName(MLBinPath,exeLibExt);
            end



            buildInfo.addNonBuildFiles(makeBoostLibName('system'),...
            MLBinPath,'mwboost_system library (required by serialdevice and serialsupport)');
            buildInfo.addNonBuildFiles(makeBoostLibName('chrono'),...
            MLBinPath,'mwboost_chrono library (required by tamutil)');
            buildInfo.addNonBuildFiles(makeBoostLibName('thread'),...
            MLBinPath,'mwboost_thread library (required by tamutil)');
            buildInfo.addNonBuildFiles(makeBoostLibName('filesystem'),...
            MLBinPath,'mwboost_filesystem library (required by libmwi18n)');

            switch computer('arch')
            case 'win64'
                buildInfo.addNonBuildFiles(makeBoostLibName('date_time'),...
                MLBinPath,'mwboost_date_time library (required by tamutil)');
                buildInfo.addNonBuildFiles(makeExpatLibName(),...
                MLBinPath,'libexpat library (required by libmwi18n)');
                buildInfo.addNonBuildFiles(makeIcuLibName('uc'),...
                MLBinPath,'icuuc69 library (required by libmwi18n)');
                buildInfo.addNonBuildFiles(makeIcuLibName('dt'),...
                MLBinPath,'icudt69 library (required by icuuc69)');
                buildInfo.addNonBuildFiles(makeIcuLibName('in'),...
                MLBinPath,'icuin69 library (required by libmwi18n)');
            case 'glnxa64'
                buildInfo.addNonBuildFiles(makeExpatLibName(),...
                MLBinPath,'libexpat library (required by libmwi18n)');
                buildInfo.addNonBuildFiles(makeIcuLibName('uc'),...
                MLBinPath,'icuuc library (required by libmwi18n)');
                buildInfo.addNonBuildFiles(makeIcuLibName('data'),...
                MLBinPath,'icudt library (required by icuuc)');
                buildInfo.addNonBuildFiles(makeIcuLibName('i18n'),...
                MLBinPath,'icuin library (required by libmwi18n)');
            case 'maci64'

                buildInfo.addNonBuildFiles(makeIcuLibName('uc'),...
                MLBinPath,'icuuc library (required by libmwi18n)');
                buildInfo.addNonBuildFiles(makeIcuLibName('data'),...
                MLBinPath,'icudt library (required by icuuc)');
                buildInfo.addNonBuildFiles(makeIcuLibName('i18n'),...
                MLBinPath,'icuin library (required by libmwi18n)');
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
            if strcmp(matlabshared.seriallib.internal.coder.Serial.DefaultOS,'win64')
                deviceFullName=[matlabshared.seriallib.internal.coder.Serial.DefaultDeviceName,matlabshared.seriallib.internal.coder.Serial.DefaultLibExtention];
                converterFullName=[matlabshared.seriallib.internal.coder.Serial.DefaultConverterName,matlabshared.seriallib.internal.coder.Serial.DefaultLibExtention];
            else
                deviceFullName=['libmw',matlabshared.seriallib.internal.coder.Serial.DefaultDeviceName,matlabshared.seriallib.internal.coder.Serial.DefaultLibExtention];
                converterFullName=['libmw',matlabshared.seriallib.internal.coder.Serial.DefaultConverterName,matlabshared.seriallib.internal.coder.Serial.DefaultLibExtention];
            end
            if coder.internal.canUseExtrinsic()







                thisOS=computer('arch');
                thisMLVersion=getfield(ver('matlab'),'Release');
                thisMatlabRoot=blanks(coder.ignoreConst(512));
                thisMatlabRoot=matlabroot;


                if strcmp(thisOS,matlabshared.seriallib.internal.coder.Serial.DefaultOS)...
                    &&strcmp(thisMLVersion,matlabshared.seriallib.internal.coder.Serial.DefaultMATLABVersion)
                    deviceFullPathML=[thisMatlabRoot,matlabshared.seriallib.internal.coder.Serial.DefaultFileSep...
                    ,matlabshared.seriallib.internal.coder.Serial.DefaultPluginRelativePath,matlabshared.seriallib.internal.coder.Serial.DefaultFileSep,deviceFullName];
                    if exist(deviceFullPathML,'file')

                        devicePath=deviceFullPathML;
                    else




                        coder.internal.error('seriallib:serial:CannotFindPlugin');
                        devicePath='';
                    end

                    converterFullPathML=[thisMatlabRoot,matlabshared.seriallib.internal.coder.Serial.DefaultFileSep...
                    ,matlabshared.seriallib.internal.coder.Serial.DefaultPluginRelativePath,matlabshared.seriallib.internal.coder.Serial.DefaultFileSep,converterFullName];
                    if exist(converterFullPathML,'file')

                        converterPath=converterFullPathML;
                    else




                        coder.internal.error('seriallib:serial:CannotFindPlugin');
                        converterPath='';
                    end
                else


                    coder.internal.error('seriallib:serial:WrongMATLABVersion',...
                    matlabshared.seriallib.internal.coder.Serial.DefaultMATLABVersion,...
                    matlabshared.seriallib.internal.coder.Serial.DefaultOS);
                    devicePath='';
                    converterPath='';
                end
            else







                deviceFullPath=matlabshared.asyncio.internal.coder.computeAbsolutePath(deviceFullName);
                if~isempty(deviceFullPath)

                    devicePath=deviceFullPath;
                else


                    deviceFullPathML=matlabshared.asyncio.internal.coder.computeAbsolutePath(...
                    [matlabshared.seriallib.internal.coder.Serial.DefaultMATLABRoot,matlabshared.seriallib.internal.coder.Serial.DefaultFileSep...
                    ,matlabshared.seriallib.internal.coder.Serial.DefaultPluginRelativePath,matlabshared.seriallib.internal.coder.Serial.DefaultFileSep,deviceFullName]);
                    if~isempty(deviceFullPathML)

                        devicePath=deviceFullPathML;
                    else

                        coder.internal.error('seriallib:serial:CannotFindPlugin');
                        devicePath='';
                    end
                end

                converterFullPath=matlabshared.asyncio.internal.coder.computeAbsolutePath(converterFullName);
                if~isempty(converterFullPath)

                    converterPath=converterFullPath;
                else


                    converterFullPathML=matlabshared.asyncio.internal.coder.computeAbsolutePath(...
                    [matlabshared.seriallib.internal.coder.Serial.DefaultMATLABRoot,matlabshared.seriallib.internal.coder.Serial.DefaultFileSep...
                    ,matlabshared.seriallib.internal.coder.Serial.DefaultPluginRelativePath,matlabshared.seriallib.internal.coder.Serial.DefaultFileSep,converterFullName]);
                    if~isempty(converterFullPathML)


                        converterPath=converterFullPathML;
                    else

                        coder.internal.error('seriallib:serial:CannotFindPlugin');
                        converterPath='';
                    end
                end
            end
        end
    end

    methods(Access=public)

        function obj=Serial(varargin)















            coder.allowpcode('plain');
            narginchk(1,inf);


            port=char(varargin{1});


            validateattributes(port,{'char','string'},{'nonempty'},mfilename,'PORT',1)


            obj.Port=port;






            initializeChannel(obj);

            obj.initProperties(varargin);

            obj.NativeDataType=obj.DefaultNativeDataType;
            obj.DataFieldName=obj.DefaultDataFieldName;
        end

        function connect(obj)




















            if(~isempty(obj.AsyncIOChannel)&&obj.AsyncIOChannel.isOpen())
                coder.internal.error('transportlib:transport:alreadyConnectedError');
            end


            openChannel(obj);



            obj.TransportChannel.ByteOrder=obj.ByteOrder;
            obj.TransportChannel.NativeDataType=obj.NativeDataType;
            obj.TransportChannel.DataFieldName=obj.DataFieldName;

        end

        function disconnect(obj)









            terminateChannel(obj);

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

        function data=getTotalBytesWritten(~)


            coder.internal.assert(false,'seriallib:serial:FunctionNotSupportedByCodegen','getTotalBytesWritten');
            data=0;
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



        function flushInput(obj)



            obj.validateConnected();

            obj.AsyncIOChannel.execute(['FlushInput',char(0)]);

            obj.AsyncIOChannel.InputStream.flush();

            obj.TransportChannel.flushUnreadData();
        end

        function flushOutput(obj)



            obj.validateConnected();

            obj.AsyncIOChannel.execute(['FlushOutput',char(0)]);

            obj.AsyncIOChannel.OutputStream.flush();

        end

        function out=getPinStatus(obj)



            obj.validateConnected();

            obj.AsyncIOChannel.execute(['GetPinStatus',char(0)]);


            out.ClearToSend=obj.AsyncIOChannel.getCustomProp('CTS');
            out.DataSetReady=obj.AsyncIOChannel.getCustomProp('DSR');
            out.CarrierDetect=obj.AsyncIOChannel.getCustomProp('CD');
            out.RingIndicator=obj.AsyncIOChannel.getCustomProp('RING');
        end

        function setDTR(obj,state)

            validateattributes(state,{'logical'},{'scalar'},mfilename,'setDTR');


            obj.validateConnected();
            options=struct('BoolVal',state);
            obj.AsyncIOChannel.execute(['SetDtr',char(0)],options);

        end

        function setRTS(obj,state)

            validateattributes(state,{'logical'},{'scalar'},mfilename,'setRTS');


            obj.validateConnected();
            options=struct('BoolVal',state);
            obj.AsyncIOChannel.execute(['SetRts',char(0)],options);

        end



        function data=read(varargin)












































            narginchk(1,3);
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

        function[tokenFound,indices]=peekUntil(obj,token)


















            narginchk(2,2);
            obj.validateConnected();
            [tokenFound,indices]=obj.TransportChannel.peekUntil(token);
        end

        function index=peekBytesFromEnd(~,~,~)
            coder.internal.assert(false,'seriallib:serial:FunctionNotSupportedByCodegen','peekBytesFromEnd');
            index=-1;
        end

        function write(varargin)






























            narginchk(2,3);
            obj=varargin{1};
            obj.validateConnected();
            obj.TransportChannel.write(varargin{2:end});
        end

        function writeAsync(varargin)




































            narginchk(1,3);
            obj=varargin{1};
            obj.validateConnected();
            obj.TransportChannel.writeAsync(varargin{2:end});

        end

        function writeAsyncRaw(obj,dataToWrite)





















            obj.validateConnected();
            obj.TransportChannel.writeAsyncRaw(dataToWrite);

        end
    end


    methods

        function set.BytesAvailableEventCount(~,~)
            coder.internal.assert(false,'seriallib:serial:PropertyNotSupportedByCodegen','BytesAvailableEventCount');
        end

        function set.BytesAvailableFcn(~,~)
            coder.internal.assert(false,'seriallib:serial:PropertyNotSupportedByCodegen','BytesAvailableFcn');
        end

        function set.BytesWrittenFcn(~,~)
            coder.internal.assert(false,'seriallib:serial:PropertyNotSupportedByCodegen','BytesWrittenFcn');
        end

        function set.ErrorOccurredFcn(~,~)
            coder.internal.assert(false,'seriallib:serial:PropertyNotSupportedByCodegen','ErrorOccurredFcn');
        end

        function set.UserData(~,~)
            coder.internal.assert(false,'seriallib:serial:PropertyNotSupportedByCodegen','UserData');
        end

        function value=get.BytesAvailableEventCount(obj)
            coder.internal.assert(false,'seriallib:serial:PropertyNotSupportedByCodegen','BytesAvailableEventCount');

            value=obj.BytesAvailableEventCount;
        end

        function value=get.BytesAvailableFcn(obj)
            coder.internal.assert(false,'seriallib:serial:PropertyNotSupportedByCodegen','BytesAvailableFcn');

            value=obj.BytesAvailableFcn;
        end

        function value=get.BytesWrittenFcn(obj)
            coder.internal.assert(false,'seriallib:serial:PropertyNotSupportedByCodegen','BytesWrittenFcn');

            value=obj.BytesWrittenFcn;
        end

        function value=get.ErrorOccurredFcn(obj)
            coder.internal.assert(false,'seriallib:serial:PropertyNotSupportedByCodegen','ErrorOccurredFcn');

            value=obj.ErrorOccurredFcn;
        end

        function value=get.UserData(obj)
            coder.internal.assert(false,'seriallib:serial:PropertyNotSupportedByCodegen','UserData');

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

            obj.AsyncIOChannel.execute(['GetInitAccessStatus',char(0)]);


            value=obj.AsyncIOChannel.getCustomProp('InitAccess');
        end

        function value=get.Timeout(obj)

            if~obj.IsSharingExistingTimeout
                value=obj.Timeout;
            else




                obj.validateAsyncIOConnected();

                obj.AsyncIOChannel.execute(['GetSharedTimeout',char(0)]);


                value=obj.AsyncIOChannel.getCustomProp('SharedTimeout');
            end
        end

        function obj=set.Timeout(obj,value)%#ok<MCHV2>
            if obj.IsSharingExistingTimeout


                coder.internal.error('seriallib:serial:setExistingSharedTimeoutFailed');
            else

                validateattributes(value,{'numeric'},{'scalar','nonnegative','finite','nonnan'},mfilename,'Timeout');
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

            validateDisconnected(obj);


            validateattributes(value,{'char','string'},{},mfilename,'CustomConverterPlugIn');
            obj.CustomConverterPlugIn=blanks(coder.ignoreConst(0));
            obj.CustomConverterPlugIn=char(value);
        end

        function out=get.BaudRate(obj)
            out=obj.BaudRate;
        end

        function set.BaudRate(obj,value)

            validateattributes(value,{'numeric'},{'scalar','nonnegative','finite','nonnan'},mfilename,'BaudRate');



            if strcmpi(matlabshared.seriallib.internal.coder.Serial.DefaultOS,'glnxa64')
                if~ismember(value,obj.SupportedLinuxBaudRates)
                    coder.internal.error('seriallib:serial:invalidBaudRate',num2str(obj.SupportedLinuxBaudRates));
                end
            end




            if obj.Connected
                options=struct('BaudRate',value);
                obj.AsyncIOChannel.execute(['SetBaudRate',char(0)],options);
            end
            obj.BaudRate=value;
        end

        function out=get.DataBits(obj)
            out=obj.DataBits;
        end

        function set.DataBits(obj,value)

            validateattributes(value,{'numeric'},{'scalar','nonnegative','finite','nonnan'},mfilename,'DataBits');




            if obj.Connected
                options=struct('DataBits',value);
                obj.AsyncIOChannel.execute(['SetDataBits',char(0)],options);
            end
            obj.DataBits=value;
        end

        function out=get.StopBits(obj)
            out=obj.StopBits;
        end

        function set.StopBits(obj,value)

            validateattributes(value,{'numeric'},{'scalar','nonnegative','finite','nonnan'},mfilename,'StopBits');
            if~ismember(value,matlabshared.seriallib.internal.Serial.StopBitsOptions)
                coder.internal.error('seriallib:serial:invalidStopBits');
            end




            if obj.Connected
                options=struct('StopBits',value);
                obj.AsyncIOChannel.execute(['SetStopBits',char(0)],options);
            end
            obj.StopBits=value;
        end

        function out=get.Parity(obj)
            out=obj.Parity;
        end

        function set.Parity(obj,value)


            validateattributes(value,{'char','string'},{'nonempty'},mfilename,'Parity');
            tempValue=char(value);





            validatestring(tempValue,matlabshared.seriallib.internal.Serial.ParityOptions,'SerialSetParity');
            if strncmpi(tempValue,'even',length(tempValue))
                val='even';
            elseif strncmpi(tempValue,'odd',length(tempValue))
                val='odd';
            else
                val='none';
            end




            if obj.Connected %#ok<*MCSUP>
                options=struct('Parity',val);
                obj.AsyncIOChannel.execute(['SetParity',char(0)],options);
            end
            obj.Parity=blanks(coder.ignoreConst(0));
            obj.Parity=val;
        end

        function out=get.FlowControl(obj)
            out=obj.FlowControl;
        end

        function set.FlowControl(obj,value)

            validateattributes(value,{'char','string'},{'nonempty'},mfilename,'FlowControl');
            tempValue=char(value);





            validatestring(tempValue,matlabshared.seriallib.internal.Serial.FlowControlOptions,'SerialSetFlowControl');
            if strncmpi(tempValue,'hardware',length(tempValue))
                val='hardware';
            elseif strncmpi(tempValue,'software',length(tempValue))
                val='software';
            else
                val='none';
            end



            if obj.Connected
                options=struct('FlowControl',val);
                obj.AsyncIOChannel.execute(['SetFlowControl',char(0)],options);
            end
            obj.FlowControl=blanks(coder.ignoreConst(0));
            obj.FlowControl=val;
        end

        function set.ByteOrder(obj,value)

            validateattributes(value,{'char','string'},{'nonempty'},mfilename,'ByteOrder');
            tempValue=char(value);

            obj.TransportChannel.ByteOrder=tempValue;
            obj.ByteOrder=blanks(coder.ignoreConst(0));



            obj.ByteOrder=obj.TransportChannel.ByteOrder;
        end

        function out=get.ByteOrder(obj)

            out=obj.ByteOrder;
        end

        function set.NativeDataType(obj,value)

            validateattributes(value,{'string','char'},{},mfilename,'NativeDataType');
            val=char(value);
            obj.NativeDataType=blanks(coder.ignoreConst(0));
            obj.NativeDataType=val;
            obj.TransportChannel.NativeDataType=val;
        end

        function out=get.NativeDataType(obj)

            out=obj.NativeDataType;
        end

        function set.DataFieldName(obj,value)

            validateattributes(value,{'string','char'},{},mfilename,'DataFieldName');
            val=char(value);
            obj.DataFieldName=blanks(coder.ignoreConst(0));
            obj.DataFieldName=val;
            obj.TransportChannel.DataFieldName=val;
        end

        function out=get.DataFieldName(obj)

            out=obj.DataFieldName;
        end

        function set.InputBufferSize(obj,value)


            validateattributes(value,{'numeric'},{'scalar','nonnegative','nonnan'},mfilename,'INPUTBUFFERSIZE');


            validateDisconnected(obj);

            obj.InputBufferSize=value;
        end

        function set.OutputBufferSize(obj,value)


            validateattributes(value,{'numeric'},{'scalar','nonnegative','nonnan'},mfilename,'OUTPUTBUFFERSIZE');


            validateDisconnected(obj);

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
    end

    methods(Access=private)

        function initProperties(obj,inputs)


            parms=struct(...
            'BaudRate',uint32(0),...
            'DataBits',uint32(0),...
            'Parity',uint32(0),...
            'StopBits',uint32(0),...
            'FlowControl',uint32(0),...
            'ByteOrder',uint32(0),...
            'Timeout',uint32(0),...
            'IsWriteOnly',false,...
            'IsSharingPort',false,...
            'IsSharingExistingTimeout',false);

            popt=struct(...
            'CaseSensitivity',false,...
            'StructExpand',true,...
            'PartialMatching','unique');

            optarg=coder.internal.parseParameterInputs(parms,popt,inputs{2:end});
            obj.BaudRate=coder.internal.getParameterValue(optarg.BaudRate,obj.DefaultBaudRate,inputs{2:end});
            obj.DataBits=coder.internal.getParameterValue(optarg.DataBits,obj.DefaultDataBits,inputs{2:end});
            obj.Parity=coder.internal.getParameterValue(optarg.Parity,obj.DefaultParity,inputs{2:end});
            obj.StopBits=coder.internal.getParameterValue(optarg.StopBits,obj.DefaultStopBits,inputs{2:end});
            obj.FlowControl=coder.internal.getParameterValue(optarg.FlowControl,obj.DefaultFlowControl,inputs{2:end});
            obj.ByteOrder=coder.internal.getParameterValue(optarg.ByteOrder,obj.DefaultByteOrder,inputs{2:end});
            obj.Timeout=coder.internal.getParameterValue(optarg.Timeout,obj.DefaultTimeout,inputs{2:end});
            obj.IsWriteOnly=coder.internal.getParameterValue(optarg.IsWriteOnly,false,inputs{2:end});
            obj.IsSharingPort=coder.internal.getParameterValue(optarg.IsSharingPort,false,inputs{2:end});
            obj.IsSharingExistingTimeout=coder.internal.getParameterValue(optarg.IsSharingExistingTimeout,false,inputs{2:end});
        end

        function initializeChannel(obj)




            options.ServiceName=obj.Port;
            options.BaudRate=obj.DefaultBaudRate;
            options.Parity=obj.DefaultParity;
            options.StopBits=obj.DefaultStopBits;
            options.DataBits=obj.DefaultDataBits;
            options.FlowControl=obj.DefaultFlowControl;









            customPropsExpected.CTS=true;
            customPropsExpected.DSR=true;
            customPropsExpected.CD=true;
            customPropsExpected.RING=true;
            customPropsExpected.InitAccess=true;
            customPropsExpected.SharedTimeout=0;
            customPropsExpected.LatestNumBytesWrittenToDevice=uint64(0);

            [devicePlugin,converterPlugin]=matlabshared.seriallib.internal.coder.Serial.getPluginPath();

            obj.AsyncIOChannel=matlabshared.asyncio.internal.Channel(devicePlugin,...
            converterPlugin,...
            CoderExampleData=zeros(1,1,'uint8'),...
            CountDimensions=[2,2],...
            Options=options,...
            StreamLimits=[obj.InputBufferSize,obj.OutputBufferSize],...
            CustomPropsExpected=customPropsExpected);

            if~obj.IsSharingPort||~obj.IsSharingExistingTimeout




                obj.setAsyncIOChannelTimeout(obj.Timeout);
            end



            obj.TransportChannel=...
            matlabshared.transportlib.internal.asyncIOTransportChannel.AsyncIOTransportChannel(obj.AsyncIOChannel);
            obj.TransportChannel.ByteOrder=obj.DefaultByteOrder;
            obj.TransportChannel.NativeDataType=obj.DefaultNativeDataType;
            obj.TransportChannel.DataFieldName=obj.DefaultDataFieldName;














        end

        function openChannel(obj)




            options.ServiceName=obj.Port;
            options.BaudRate=obj.BaudRate;
            options.Parity=obj.Parity;
            options.StopBits=obj.StopBits;
            options.DataBits=obj.DataBits;
            options.FlowControl=obj.FlowControl;
            options.IsWriteOnly=obj.IsWriteOnly;
            options.IsSharingPort=obj.IsSharingPort;
            options.IsSharingExistingTimeout=obj.IsSharingExistingTimeout;


            obj.AsyncIOChannel.open(options);


            if obj.IsSharingPort&&~obj.IsSharingExistingTimeout&&obj.InitAccess
                obj.setSharedTimeout(obj.Timeout);
            end

            obj.setAsyncIOChannelTimeout(obj.Timeout);
        end

        function terminateChannel(obj)



            if~isempty(obj.AsyncIOChannel)
                obj.AsyncIOChannel.close();
            end
        end

        function setAsyncIOChannelTimeout(obj,value)



            if~isempty(obj.AsyncIOChannel)

                outputStream=obj.AsyncIOChannel.OutputStream;
                inputStream=obj.AsyncIOChannel.InputStream;
                outputStream.Timeout=value;
                inputStream.Timeout=value;
            end
        end

        function setSharedTimeout(obj,value)



            validateattributes(value,{'numeric'},{'scalar','nonnegative','finite','nonnan'},mfilename,'setSharedTimeout');

            obj.validateAsyncIOConnected();

            options.SharedTimeout=value;
            obj.AsyncIOChannel.execute(['SetSharedTimeout',char(0)],options);
        end

        function validateConnected(obj)




            if~obj.Connected
                coder.internal.error('transportlib:transport:invalidConnectionState','serial port');
            end
        end

        function validateAsyncIOConnected(obj)





            if~strcmp(obj.ConnectionStatus,'Connected')
                coder.internal.error('transportlib:transport:invalidConnectionState','serial port');
            end
        end

        function validateDisconnected(obj)




            if obj.Connected
                coder.internal.error('transportlib:transport:cannotSetWhenConnected');
            end
        end

        function onDataReceived(~,~,~)

            coder.internal.assert(false,'seriallib:serial:FunctionNotSupportedByCodegen','onDataReceived');
            return;
        end

        function onDataWritten(~,~,~)

            coder.internal.assert(false,'seriallib:serial:FunctionNotSupportedByCodegen','onDataWritten');
            return;
        end

        function handleCustomEvent(~,~,~)



            coder.internal.assert(false,'seriallib:serial:FunctionNotSupportedByCodegen','handleCustomEvent');
            return;
        end
    end

    methods(Hidden)
        function delete(obj)


            terminateChannel(obj);
        end
    end
end
