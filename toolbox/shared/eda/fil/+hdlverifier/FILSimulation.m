classdef(StrictDefaults)FILSimulation<matlab.System&coder.ExternalDependency %#ok<EMCLS>   






















































%#codegen
%#ok<*EMCA>

    properties(Abstract)


        DUTName;
    end

    properties(Nontunable,SetAccess=protected)




        InputSignals='';
    end

    properties(Nontunable,SetAccess=protected)






        InputBitWidths=0;
    end

    properties(Nontunable,SetAccess=protected)




        OutputSignals='';
    end

    properties(Nontunable,SetAccess=protected)






        OutputBitWidths=0;
    end

    properties(Nontunable)







        OutputDataTypes='fixedpoint';
    end

    properties(Nontunable)






        OutputSigned=false;
    end

    properties(Nontunable)






        OutputFractionLengths=0;
    end

    properties(Nontunable)





        OutputDownsampling=[1,0];
    end

    properties(Nontunable)



        OverclockingFactor=1;
    end

    properties(Nontunable)



        SourceFrameSize=1;
    end

    properties(Nontunable,SetAccess=protected)











        Connection=char('UDP','192.168.0.2','00-0A-35-02-21-8A');
    end

    properties(Nontunable,SetAccess=protected)



        FPGAVendor='';
        FPGATool='';
    end

    properties(Nontunable,SetAccess=protected)



        FPGABoard='';
    end

    properties(Nontunable)



        FPGAProgrammingFile='';
    end

    properties(Nontunable,SetAccess=protected)



        ScanChainPosition=1;
    end

    properties(Nontunable,SetAccess=protected)



        DeviceTree='';
    end

    properties(Nontunable)



        IPAddress='192.168.0.2';
    end

    properties(Nontunable)



        Username='root';
    end

    properties(Nontunable)



        Password='root';
    end

    properties(Nontunable,Hidden)
        testMode=false;
        sendPort='-1';
        recvPort=-1;
        localhost=false;
    end


    properties(Nontunable,Hidden,Access=private)
        InputBitWidthsVec=0;
        InputByteWidthsVec=0;
        InputDataSetByteWidth=0;
        InputDataSetBitWidth=0;
        InputBufferByteWidth=0;

        InputDataTypesVec=0;

        OutputBitWidthsVec=0;
        OutputByteWidthsVec=0;
        OutputDataSetByteWidth=0;
        OutputDataSetBitWidth=0;
        OutputBufferByteWidth=0;

        OutputDataTypesVec=0;
        OutputSignedVec=false;
        OutputFractionLengthsVec=0;
        OutputStorageTypesArray='';

        InputFrameSize=1;
        OutputFrameSize=1;
        Is64BitStorage=true;
        isFramed=false;
    end

    properties(Hidden,Access=private)
        InputBuffer;
        OutputBuffer;

        MAPIClassID;
    end

    properties(Hidden,Constant)
        MAX_STR_SIZE=128;
        LOGICAL_TYPE=0;
        INTEGER_TYPE=1;
        FIXEDPOINT_TYPE=2;
        DOUBLE_TYPE=3;
        SINGLE_TYPE=4;
    end


    methods
        function obj=FILSimulation
            coder.allowpcode('plain');
        end

        function set.InputSignals(obj,val)
            validateattributes(val,{'char'},{},'hdlverifier.FILSimulation','InputSignals');
            if isempty(coder.target)
                obj.InputSignals=obj.setInputSignals(val);
            else
                obj.InputSignals=eml_const(obj.setInputSignals(val));
            end
        end

        function val=get.InputSignals(obj)
            val=deblank(obj.InputSignals);
        end

        function set.InputBitWidths(obj,val)
            validateattributes(val,{'numeric'},{'nonempty','row','integer','nonnegative','real','finite','nonsparse','nonnan','<',2^31},'hdlverifier.FILSimulation','InputBitWidths');
            obj.InputBitWidths=val;
        end

        function set.OutputSignals(obj,val)
            validateattributes(val,{'char'},{},'hdlverifier.FILSimulation','OutputSignals');
            if isempty(coder.target)
                obj.OutputSignals=obj.setOutputSignals(val);
            else
                obj.OutputSignals=eml_const(obj.setOutputSignals(val));
            end
        end

        function val=get.OutputSignals(obj)
            val=deblank(obj.OutputSignals);
        end

        function set.OutputBitWidths(obj,val)
            validateattributes(val,{'numeric'},{'nonempty','row','integer','nonnegative','real','finite','nonsparse','nonnan','<',2^31},'hdlverifier.FILSimulation','OutputBitWidths');
            obj.OutputBitWidths=val;
        end

        function set.OutputDataTypes(obj,val)
            validateattributes(val,{'char'},{'nonempty'},'hdlverifier.FILSimulation','OutputDataTypes');
            if isempty(coder.target)
                obj.OutputDataTypes=obj.setOutputDataTypes(val);
            else
                obj.OutputDataTypes=eml_const(obj.setOutputDataTypes(val));
            end
        end

        function val=get.OutputDataTypes(obj)
            val=deblank(obj.OutputDataTypes);
        end

        function set.OutputSigned(obj,val)
            validateattributes(val,{'logical'},{'nonempty','row'},'hdlverifier.FILSimulation','OutputSigned');
            obj.OutputSigned=val;
        end

        function set.OutputFractionLengths(obj,val)
            validateattributes(val,{'numeric'},{'nonempty','row','integer','real','finite','nonsparse','nonnan','<',2^31,'>=',-2^31},'hdlverifier.FILSimulation','OutputFractionLengths');
            obj.OutputFractionLengths=val;
        end

        function set.OutputDownsampling(obj,val)
            validateattributes(val,{'numeric'},{'nonempty','integer','size',[1,2],'nonnegative','real','finite','nonsparse','nonnan','<',2^31},'hdlverifier.FILSimulation','OutputDownsampling');
            validateattributes(val(1),{'numeric'},{'nonempty','integer','scalar','positive','real','finite','nonsparse','nonnan','<',2^31},'hdlverifier.FILSimulation','OutputDownsampling(1)');
            validateattributes(val(2),{'numeric'},{'nonempty','integer','scalar','nonnegative','real','finite','nonsparse','nonnan','<',val(1)},'hdlverifier.FILSimulation','OutputDownsampling(2)');
            obj.OutputDownsampling=val;
        end

        function set.OverclockingFactor(obj,val)
            validateattributes(val,{'numeric'},{'nonempty','integer','scalar','positive','real','finite','nonsparse','nonnan','<',2^31},'hdlverifier.FILSimulation','OverclockingFactor');
            obj.OverclockingFactor=val;
        end

        function set.SourceFrameSize(obj,val)
            validateattributes(val,{'numeric'},{'nonempty','integer','scalar','positive','real','finite','nonsparse','nonnan','<',2^31},'hdlverifier.FILSimulation','SourceFrameSize');
            obj.SourceFrameSize=val;
        end

        function set.Connection(obj,val)
            validateattributes(val(1,:),{'char'},{'nonempty'},'hdlverifier.FILSimulation','Connection{1} (Type)');
            validatestring(deblank(val(1,:)),{'UDP','PCI Express','JTAG','TCPIP'},'hdlverifier.FILSimulation','Connection{1} (Type)');
            if strncmpi(val(1,:),'U',1)
                if numel(val(:,1))>1
                    validateattributes(val(2,:),{'char'},{'nonempty'},'hdlverifier.FILSimulation','Connection{2} (Board IP Address)');
                end
                if numel(val(:,1))>2
                    validateattributes(val(3,:),{'char'},{'nonempty'},'hdlverifier.FILSimulation','Connection{3} (MAC Address)');
                end
                if numel(val(:,1))>3
                    validateattributes(val(3,:),{'char'},{'nonempty'},'hdlverifier.FILSimulation','Connection{3} (MAC Address)');
                end
                if numel(val(:,1))>4
                    error(message('EDALink:FILSimulation:ConnectionUDP',numel(val(:,1))));
                end
            else
                validateattributes(val(2,:),{'char'},{'nonempty'},'hdlverifier.FILSimulation','Connection{2} (rtIOStream library name)');
                validateattributes(val(3,:),{'char'},{},'hdlverifier.FILSimulation','Connection{3} (rtIOStream initialization parameters)');
            end
            if isempty(coder.target)
                obj.Connection=obj.setConnection(val);
            else
                obj.Connection=eml_const(obj.setConnection(val));
            end
        end

        function val=get.Connection(obj)
            val=deblank(obj.Connection);
        end

        function set.FPGAVendor(obj,val)
            validateattributes(val,{'char'},{},'hdlverifier.FILSimulation','FPGAVendor');
            validatestring(val,{'Xilinx','Altera','Microsemi','Microchip'},'hdlverifier.FILSimulation','FPGAVendor');
            if strcmp(val,'Microsemi')
                obj.FPGAVendor='Microchip';
            else
                obj.FPGAVendor=val;
            end
        end

        function set.FPGABoard(obj,val)
            validateattributes(val,{'char'},{},'hdlverifier.FILSimulation','FPGABoard');
            obj.FPGABoard=val;
        end

        function set.FPGAProgrammingFile(obj,val)
            validateattributes(val,{'char'},{},'hdlverifier.FILSimulation','FPGAProgrammingFile');
            obj.FPGAProgrammingFile=val;
        end

        function set.ScanChainPosition(obj,val)
            validateattributes(val,{'numeric'},{'nonempty','integer','scalar','positive','real','finite','nonsparse','nonnan','<',2^31},'hdlverifier.FILSimulation','ScanChainPosition');
            obj.ScanChainPosition=val;
        end

        function set.testMode(obj,val)
            validateattributes(val,{'logical'},{'nonempty','scalar','nonsparse'},'','testMode');
            obj.testMode=val;
        end

        function set.sendPort(obj,val)
            validateattributes(val,{'char'},{},'hdlverifier.FILSimulation','sendPort');
            obj.sendPort=val;
        end






        function set.localhost(obj,val)
            validateattributes(val,{'logical'},{'nonempty','scalar','nonsparse'},'','localhost');
            obj.localhost=val;
        end


        function programFPGA(obj)



            coder.extrinsic('filProgramFPGA');
            if strcmpi(deblank(obj.Connection(1,:)),'TCPIP')
                boardID=eda.internal.getBoardID(obj.FPGABoard);
                loadBitstream(boardID,obj.FPGAProgrammingFile,obj.DeviceTree,...
                'DeviceAddress',obj.IPAddress,...
                'Username',obj.Username,...
                'Password',obj.Password);
            else
                filProgramFPGA(obj.FPGATool,obj.FPGAProgrammingFile,...
                obj.ScanChainPosition);
            end
        end

        function set.DeviceTree(obj,val)
            validateattributes(val,{'char'},{'nonempty'},'hdlverifier.FILSimulation','DeviceTree');
            obj.DeviceTree=val;
        end

        function set.IPAddress(obj,val)

            if isempty(regexp(val,'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$','match'))
                error(message('EDALink:FILSimulation:IPAddress'));
            end
            obj.IPAddress=val;
        end

        function set.Username(obj,val)
            validateattributes(val,{'char'},{'nonempty'},'hdlverifier.FILSimulation','Username');
            obj.Username=val;
        end

        function set.Password(obj,val)
            validateattributes(val,{'char'},{'nonempty'},'hdlverifier.FILSimulation','Passwword');
            obj.Password=val;
        end

    end

    methods(Access=protected,Hidden)

        function setupInputs(obj,varargin)

            NumInputs=obj.getNumInputs;

            if NumInputs>0
                obj.InputFrameSize=numel(double(varargin{1}));

                if numel(obj.InputBitWidths)>1
                    obj.InputBitWidthsVec=obj.InputBitWidths;
                else
                    obj.InputBitWidthsVec=obj.InputBitWidths*ones(1,NumInputs);
                end

                obj.InputDataTypesVec=obj.setInputDataTypesVec(varargin{:});

                obj.InputDataSetBitWidth=obj.setInputDataSetBitWidth;
                obj.InputDataSetByteWidth=obj.setInputDataSetByteWidth;

                obj.InputByteWidthsVec=obj.setInputByteWidthsVec;
                obj.InputBufferByteWidth=obj.setInputBufferByteWidth;

            else
                obj.InputFrameSize=obj.SourceFrameSize;
                obj.InputDataSetByteWidth=0;
                obj.InputDataSetBitWidth=0;
                obj.InputBufferByteWidth=0;
            end

        end

        function setupOutputs(obj,varargin)

            NumOutputs=obj.getNumOutputs;

            if NumOutputs>0

                if mod(uint32(obj.InputFrameSize*obj.OverclockingFactor),uint32(obj.OutputDownsampling(1)))~=0
                    error(message('EDALink:FILSimulation:OutputFrameSize'));
                end
                obj.OutputFrameSize=obj.InputFrameSize*obj.OverclockingFactor/obj.OutputDownsampling(1);

                if numel(obj.OutputBitWidths)>1
                    obj.OutputBitWidthsVec=obj.OutputBitWidths;
                else
                    obj.OutputBitWidthsVec=obj.OutputBitWidths*ones(1,NumOutputs);
                end

                obj.OutputDataTypesVec=obj.setOutputDataTypesVec;

                if numel(obj.OutputSigned)>1
                    obj.OutputSignedVec=obj.OutputSigned;
                else
                    obj.OutputSignedVec=obj.OutputSigned*ones(1,NumOutputs);
                end

                if numel(obj.OutputFractionLengths)>1
                    obj.OutputFractionLengthsVec=obj.OutputFractionLengths;
                else
                    obj.OutputFractionLengthsVec=obj.OutputFractionLengths*ones(1,NumOutputs);
                end

                for ii=coder.unroll(1:NumOutputs)
                    switch(obj.OutputDataTypesVec(ii))
                    case obj.LOGICAL_TYPE
                        if obj.OutputBitWidthsVec(ii)~=1
                            error(message('EDALink:FILSimulation:OutputBitWidthsLogical',ii,ii,obj.OutputBitWidthsVec(ii)));
                        end
                        if obj.OutputSignedVec(ii)~=false
                            error(message('EDALink:FILSimulation:OutputSignedLogical',ii,ii,obj.OutputSignedVec(ii)));
                        end
                        if obj.OutputFractionLengthsVec(ii)~=0
                            error(message('EDALink:FILSimulation:OutputFractionLengthsLogical',ii,ii,obj.OutputFractionLengthsVec(ii)));
                        end

                    case obj.INTEGER_TYPE
                        if obj.OutputBitWidthsVec(ii)~=8&&...
                            obj.OutputBitWidthsVec(ii)~=16&&...
                            obj.OutputBitWidthsVec(ii)~=32&&...
                            obj.OutputBitWidthsVec(ii)~=64
                            error(message('EDALink:FILSimulation:OutputBitWidthsInteger',ii,ii,obj.OutputBitWidthsVec(ii)));
                        end
                        if obj.OutputFractionLengthsVec(ii)~=0
                            error(message('EDALink:FILSimulation:OutputFractionLengthsInteger',ii,ii,obj.OutputFractionLengthsVec(ii)));
                        end

                    case obj.FIXEDPOINT_TYPE

                    case obj.DOUBLE_TYPE
                        if obj.OutputBitWidthsVec(ii)~=64
                            error(message('EDALink:FILSimulation:OutputBitWidthsDouble',ii,ii,obj.OutputBitWidthsVec(ii)));
                        end
                        if obj.OutputSignedVec(ii)~=false
                            error(message('EDALink:FILSimulation:OutputSignedDouble',ii,ii,obj.OutputSignedVec(ii)));
                        end
                        if obj.OutputFractionLengthsVec(ii)~=0
                            error(message('EDALink:FILSimulation:OutputFractionLengthsDouble',ii,ii,obj.OutputFractionLengthsVec(ii)));
                        end

                    case obj.SINGLE_TYPE
                        if obj.OutputBitWidthsVec(ii)~=32
                            error(message('EDALink:FILSimulation:OutputBitWidthsSingle',ii,ii,obj.OutputBitWidthsVec(ii)));
                        end
                        if obj.OutputSignedVec(ii)~=false
                            error(message('EDALink:FILSimulation:OutputSignedSingle',ii,ii,obj.OutputSignedVec(ii)));
                        end
                        if obj.OutputFractionLengthsVec(ii)~=0
                            error(message('EDALink:FILSimulation:OutputFractionLengthsSingle',ii,ii,obj.OutputFractionLengthsVec(ii)));
                        end

                    otherwise
                        error(message('EDALink:FILSimulation:OutputTypeUnknownInternal',ii));
                    end
                end

                obj.OutputDataSetBitWidth=obj.setOutputDataSetBitWidth;
                obj.OutputDataSetByteWidth=obj.setOutputDataSetByteWidth;

                obj.OutputByteWidthsVec=obj.setOutputByteWidthsVec;
                obj.OutputStorageTypesArray=obj.setOutputStorageTypesArray;
                obj.OutputBufferByteWidth=obj.setOutputBufferByteWidth;

            else
                obj.OutputFrameSize=1;
                obj.OutputDataSetByteWidth=0;
                obj.OutputDataSetBitWidth=0;
                obj.OutputBufferByteWidth=0;
            end

        end

        function setupImpl(obj,varargin)


            obj.Is64BitStorage=~strcmp(computer,'PCWIN');

            setupInputs(obj,varargin{:});
            setupOutputs(obj,varargin{:});

            obj.InputBuffer=zeros(1,obj.InputBufferByteWidth,'uint8');
            obj.OutputBuffer=zeros(1,obj.OutputBufferByteWidth,'uint8');

            NumInputs=obj.getNumInputs;
            NumOutputs=obj.getNumOutputs;

            if obj.InputFrameSize>1||obj.OutputFrameSize>1
                obj.isFramed=true;
            else
                obj.isFramed=false;
            end

            obj.MAPIClassID=filCreate(uint32(NumInputs),uint32(NumOutputs),uint8(obj.testMode));

            connectionStr=deblank(obj.Connection(1,:));

            if strcmpi(connectionStr,'UDP')
                if obj.localhost
                    RemoteURL='127.0.0.1';
                else
                    RemoteURL=deblank(obj.Connection(2,:));
                end
                if strcmpi(obj.sendPort,'-1')
                    RemotePort='50101';
                else
                    RemotePort=obj.sendPort;
                end
                if obj.testMode
                    TimeOut='5';
                else
                    TimeOut='1';
                end
                libName='libmwrtiostreamtcpip';
                libParams=['-protocol UDP -port ',RemotePort,' -hostname ',RemoteURL,' -client 1 -recv_timeout_secs ',TimeOut,' -blocking 1'];
            else
                libName=deblank(obj.Connection(2,:));


                libName=eda.internal.workflow.getRtiostreamLibraryPath(libName);
                libParams=deblank(obj.Connection(3,:));
                if strcmpi(libName,'libmwrtiostream_xjtag')
                    ftd2xxLibPath=matlab.internal.get3pInstallLocation('FTCJTAG.instrset');
                    libParams=sprintf('%s;FTD2XXLIBPath=%s',libParams,ftd2xxLibPath);
                elseif contains(libName,'libmwrtiostream_libiio')
                    libParams=sprintf('ip:%s',obj.IPAddress);
                end
            end
            connDim=size(obj.Connection);
            if(connDim(1)<4)
                protocolParams=uint8('');
            else
                protocolParams=obj.Connection(4,:);
            end

            filSetSimulation(obj.MAPIClassID,int32(obj.InputDataSetBitWidth),int32(obj.InputDataSetByteWidth),...
            int32(obj.OutputDataSetBitWidth),int32(obj.OutputDataSetByteWidth),...
            int32(obj.InputFrameSize),int32(obj.OutputFrameSize),int8(obj.isFramed),...
            uint32(obj.OverclockingFactor),[uint8(connectionStr),0],[uint8(libName),0],[uint8(libParams),0],...
            [uint8(protocolParams),0]);

            for ii=1:NumInputs
                InputName=deblank(obj.InputSignals(ii,:));

                filSetInput(obj.MAPIClassID,uint32(ii-1),uint8(InputName),uint32(obj.InputBitWidthsVec(ii)),...
                uint32(obj.InputByteWidthsVec(ii)),double(obj.InputFrameSize));

            end

            for ii=1:NumOutputs
                OutputName=deblank(obj.OutputSignals(ii,:));

                OutputPhase=obj.OutputDownsampling(2);

                filSetOutput(obj.MAPIClassID,uint32(ii-1),uint8(OutputName),...
                int8(obj.OutputSignedVec(ii)),uint32(obj.OutputBitWidthsVec(ii)),int32(OutputPhase),...
                uint32(obj.OutputByteWidthsVec(ii)),double(obj.OutputFrameSize));
            end


            if strcmpi(connectionStr,'TCPIP')
                setuplibiio;
            end

            filInitialize(obj.MAPIClassID);

            filStart(obj.MAPIClassID);

        end

        function varargout=stepImpl(obj,varargin)

            NumInputs=obj.getNumInputs;
            NumOutputs=obj.getNumOutputs;

            if isempty(coder.target)
                varargout=cell(1,NumOutputs);
            end
            if~isempty(coder.target)&&eml_ambiguous_types
                for ii=1:NumOutputs
                    varargout{ii}=zeros(obj.OutputFrameSize,1);
                end
            else

                StartIndex=1;
                EndIndex=0;
                for ii=1:NumInputs
                    InputSize=obj.InputFrameSize*obj.InputByteWidthsVec(ii);
                    EndIndex=EndIndex+InputSize;
                    switch obj.InputDataTypesVec(ii)
                    case obj.LOGICAL_TYPE
                        obj.InputBuffer(StartIndex:EndIndex)=uint8(varargin{ii})';
                    case obj.INTEGER_TYPE
                        obj.InputBuffer(StartIndex:EndIndex)=typecast(varargin{ii},'uint8')';
                    case obj.FIXEDPOINT_TYPE
                        obj.InputBuffer(StartIndex:EndIndex)=typecast(fi2sim(varargin{ii}),'uint8')';
                    case obj.DOUBLE_TYPE
                        obj.InputBuffer(StartIndex:EndIndex)=typecast(varargin{ii},'uint8')';
                    case obj.SINGLE_TYPE
                        obj.InputBuffer(StartIndex:EndIndex)=typecast(varargin{ii},'uint8')';
                    otherwise
                        error(message('EDALink:FILSimulation:InputTypeUnknownInternal',ii));
                    end
                    StartIndex=StartIndex+InputSize;
                end

                obj.OutputBuffer=filStep(obj.MAPIClassID,obj.InputBuffer,uint32(obj.OutputBufferByteWidth));

                StartIndex=1;
                EndIndex=0;
                for ii=1:NumOutputs
                    OutputSize=obj.OutputFrameSize*obj.OutputByteWidthsVec(ii);
                    EndIndex=EndIndex+OutputSize;
                    switch(obj.OutputDataTypesVec(ii))
                    case obj.LOGICAL_TYPE
                        varargout{ii}=logical(typecast(obj.OutputBuffer(StartIndex:EndIndex),obj.OutputStorageTypesArray(ii,:)))';
                    case obj.INTEGER_TYPE
                        varargout{ii}=typecast(obj.OutputBuffer(StartIndex:EndIndex),obj.OutputStorageTypesArray(ii,:))';
                    case obj.FIXEDPOINT_TYPE
                        if isempty(coder.target)
                            varargout{ii}=embedded.fi.simfi(numerictype(obj.OutputSignedVec(ii),obj.OutputBitWidthsVec(ii),obj.OutputFractionLengthsVec(ii)),...
                            typecast(obj.OutputBuffer(StartIndex:EndIndex),obj.OutputStorageTypesArray(ii,:))');
                        else
                            varargout{ii}=sim2fi(typecast(obj.OutputBuffer(StartIndex:EndIndex),obj.OutputStorageTypesArray(ii,:))',...
                            obj.OutputSignedVec(ii),obj.OutputBitWidthsVec(ii),obj.OutputFractionLengthsVec(ii));
                        end
                    case obj.DOUBLE_TYPE
                        varargout{ii}=typecast(obj.OutputBuffer(StartIndex:EndIndex),'double')';
                    case obj.SINGLE_TYPE
                        varargout{ii}=typecast(obj.OutputBuffer(StartIndex:EndIndex),'single')';

                    otherwise
                        error(message('EDALink:FILSimulation:OutputTypeUnknownInternal',ii));
                    end
                    StartIndex=StartIndex+OutputSize;
                end
            end
        end

        function releaseImpl(obj)
            filTerminate(obj.MAPIClassID);

            filDelete(obj.MAPIClassID);

        end

        function num=getNumInputsImpl(obj)
            if~isempty(obj.InputSignals)
                num=numel(obj.InputSignals(:,1));
            else
                num=0;
            end
        end

        function num=getNumOutputsImpl(obj)
            if~isempty(obj.OutputSignals)
                num=numel(obj.OutputSignals(:,1));
            else
                num=0;
            end
        end

        function validatePropertiesImpl(obj)
            if~isempty(obj.InputSignals)
                if(numel(obj.InputBitWidths)>1)&&(numel(obj.InputBitWidths)~=numel(obj.InputSignals(:,1)))
                    error(message('EDALink:FILSimulation:InputBitWidthsSize',numel(obj.InputBitWidths),numel(obj.InputSignals(:,1))));
                end
            end

            if~isempty(obj.OutputSignals)
                if(numel(obj.OutputBitWidths)>1)&&(numel(obj.OutputBitWidths)~=numel(obj.OutputSignals(:,1)))
                    error(message('EDALink:FILSimulation:OutputBitWidthsSize',numel(obj.OutputBitWidths),numel(obj.OutputSignals(:,1))));
                end
                if(numel(obj.OutputDataTypes(:,1))>1)&&(numel(obj.OutputDataTypes(:,1))~=numel(obj.OutputSignals(:,1)))
                    error(message('EDALink:FILSimulation:OutputDataTypesSize',numel(obj.OutputDataTypes(:,1)),numel(obj.OutputSignals(:,1))));
                end
                if(numel(obj.OutputSigned)>1)&&(numel(obj.OutputSigned)~=numel(obj.OutputSignals(:,1)))
                    error(message('EDALink:FILSimulation:OutputSignedSize',numel(obj.OutputSigned),numel(obj.OutputSignals(:,1))));
                end
                if(numel(obj.OutputFractionLengths)>1)&&(numel(obj.OutputFractionLengths)~=numel(obj.OutputSignals(:,1)))
                    error(message('EDALink:FILSimulation:OutputFractionLengthsSize',numel(obj.OutputFractionLengths),numel(obj.OutputSignals(:,1))));
                end
            end
        end



        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'SourceFrameSize'
                if obj.getNumInputs>0
                    flag=true;
                end
            case 'InputSignals'
                if obj.getNumInputs<1
                    flag=true;
                end
            case 'InputBitWidths'
                if obj.getNumInputs<1
                    flag=true;
                end
            case{'DeviceTree','IPAddress','Username','Password'}
                if~strcmpi(deblank(obj.Connection(1,:)),'TCPIP')
                    flag=true;
                end
            end
        end

        function tmp=setInputSignals(obj,val)
            if isempty(val)
                tmp='';
                return
            end

            strLen=obj.MAX_STR_SIZE-2;
            if isempty(coder.target)
                nbElem=numel(val(:,1));
            else
                nbElem=eml_const(numel(val(:,1)));
            end

            tmp=char(zeros(nbElem,strLen));
            for ii=coder.unroll(1:nbElem)
                if numel(deblank(val(ii,:)))>strLen
                    error(message('EDALink:FILSimulation:InputSignalsArrayLen',ii,numel(deblank(val)),obj.MAX_STR_SIZE-2));
                end
                tmp(ii,1:numel(val(ii,:)))=val(ii,:);
            end
        end

        function tmp=setOutputSignals(obj,val)
            if isempty(val)
                tmp='';
                return
            end

            strLen=obj.MAX_STR_SIZE-2;
            if isempty(coder.target)
                nbElem=numel(val(:,1));
            else
                nbElem=eml_const(numel(val(:,1)));
            end

            tmp=char(zeros(nbElem,strLen));
            for ii=coder.unroll(1:nbElem)
                if numel(deblank(val(ii,:)))>strLen
                    error(message('EDALink:FILSimulation:OutputSignalsArrayLen',ii,numel(deblank(val)),obj.MAX_STR_SIZE-2));
                end
                tmp(ii,1:numel(val(ii,:)))=val(ii,:);
            end
        end

        function tmp=setOutputDataTypes(obj,val)
            strLen=obj.MAX_STR_SIZE-2;
            if isempty(coder.target)
                nbElem=numel(val(:,1));
            else
                nbElem=eml_const(numel(val(:,1)));
            end

            tmp=char(zeros(nbElem,strLen));
            for ii=coder.unroll(1:nbElem)
                if strncmp(val(ii,:),'logical',numel('logical'))
                    tmp(ii,1:numel('logical'))='logical';
                elseif strncmp(val(ii,:),'integer',numel('integer'))
                    tmp(ii,1:numel('integer'))='integer';
                elseif strncmp(val(ii,:),'fixedpoint',numel('fixedpoint'))
                    tmp(ii,1:numel('fixedpoint'))='fixedpoint';
                elseif strncmp(val(ii,:),'double',numel('double'))
                    tmp(ii,1:numel('double'))='double';
                elseif strncmp(val(ii,:),'single',numel('single'))
                    tmp(ii,1:numel('single'))='single';
                else
                    error(message('EDALink:FILSimulation:OutputTypeUnknown',ii));
                end
            end
        end

        function tmp=setInputDataTypesVec(obj,varargin)
            if isempty(coder.target)
                NumInputs=obj.getNumInputs;
            else
                NumInputs=eml_const(obj.getNumInputs);
            end
            tmp=zeros(1,NumInputs);
            if~isempty(coder.target)&&eml_ambiguous_types
                tmp(:)=obj.FIXEDPOINT_TYPE;
            else
                for ii=coder.unroll(1:NumInputs)
                    if~iscolumn(varargin{ii})
                        error(message('EDALink:FILSimulation:InputFrameColumn',ii));
                    end
                    if isa(varargin{ii},'logical')
                        if obj.InputBitWidthsVec(ii)~=1
                            error(message('EDALink:FILSimulation:InputBitWidthsLogical',ii,ii,obj.InputBitWidthsVec(ii)));
                        end
                        tmp(ii)=obj.LOGICAL_TYPE;

                    elseif isa(varargin{ii},'int8')||isa(varargin{ii},'uint8')
                        if obj.InputBitWidthsVec(ii)~=8
                            error(message('EDALink:FILSimulation:InputBitWidthsInteger8',ii,ii,obj.InputBitWidthsVec(ii)));
                        end
                        tmp(ii)=obj.INTEGER_TYPE;

                    elseif isa(varargin{ii},'int16')||isa(varargin{ii},'uint16')
                        if obj.InputBitWidthsVec(ii)~=16
                            error(message('EDALink:FILSimulation:InputBitWidthsInteger16',ii,ii,obj.InputBitWidthsVec(ii)));
                        end
                        tmp(ii)=obj.INTEGER_TYPE;

                    elseif isa(varargin{ii},'int32')||isa(varargin{ii},'uint32')
                        if obj.InputBitWidthsVec(ii)~=32
                            error(message('EDALink:FILSimulation:InputBitWidthsInteger32',ii,ii,obj.InputBitWidthsVec(ii)));
                        end
                        tmp(ii)=obj.INTEGER_TYPE;

                    elseif isa(varargin{ii},'int64')||isa(varargin{ii},'uint64')
                        if obj.InputBitWidthsVec(ii)~=64
                            error(message('EDALink:FILSimulation:InputBitWidthsInteger64',ii,ii,obj.InputBitWidthsVec(ii)));
                        end
                        tmp(ii)=obj.INTEGER_TYPE;

                    elseif isa(varargin{ii},'embedded.fi')
                        if obj.InputBitWidthsVec(ii)~=varargin{ii}.WordLength
                            error(message('EDALink:FILSimulation:InputBitWidthsFxPt',ii,varargin{ii}.WordLength,ii,obj.InputBitWidthsVec(ii)));
                        end
                        tmp(ii)=obj.FIXEDPOINT_TYPE;

                    elseif isa(varargin{ii},'double')
                        if obj.InputBitWidthsVec(ii)~=64
                            error(message('EDALink:FILSimulation:InputBitWidthsDouble',ii,ii,obj.InputBitWidthsVec(ii)));
                        end
                        tmp(ii)=obj.DOUBLE_TYPE;

                    elseif isa(varargin{ii},'single')
                        if obj.InputBitWidthsVec(ii)~=32
                            error(message('EDALink:FILSimulation:InputBitWidthsSingle',ii,ii,obj.InputBitWidthsVec(ii)));
                        end
                        tmp(ii)=obj.SINGLE_TYPE;
                    else
                        error(message('EDALink:FILSimulation:InputTypeUnknown',ii));
                    end
                    if obj.InputFrameSize~=numel(double(varargin{ii}))
                        error(message('EDALink:FILSimulation:InputFrameSize',ii,numel(double(varargin{ii})),obj.InputFrameSize));
                    end
                end
            end
        end

        function tmp=setOutputDataTypesVec(obj)
            if isempty(coder.target)
                NumOutputs=obj.getNumOutputs;
            else
                NumOutputs=eml_const(obj.getNumOutputs);
            end
            tmp=zeros(1,NumOutputs);
            if numel(obj.OutputDataTypes(:,1))==1
                if strncmp(obj.OutputDataTypes(1,:),'logical',numel('logical'))
                    tmp(:)=obj.LOGICAL_TYPE;
                elseif strncmp(obj.OutputDataTypes(1,:),'integer',numel('integer'))
                    tmp(:)=obj.INTEGER_TYPE;
                elseif strncmp(obj.OutputDataTypes(1,:),'fixedpoint',numel('fixedpoint'))
                    tmp(:)=obj.FIXEDPOINT_TYPE;
                elseif strncmp(obj.OutputDataTypes(1,:),'double',numel('double'))
                    tmp(:)=obj.DOUBLE_TYPE;
                elseif strncmp(obj.OutputDataTypes(1,:),'single',numel('single'))
                    tmp(:)=obj.SINGLE_TYPE;
                else
                    error(message('EDALink:FILSimulation:OutputTypeUnknownInternal',1));
                end

            else
                for ii=coder.unroll(1:NumOutputs)
                    if strncmp(obj.OutputDataTypes(ii,:),'logical',numel('logical'))
                        tmp(ii)=obj.LOGICAL_TYPE;
                    elseif strncmp(obj.OutputDataTypes(ii,:),'integer',numel('integer'))
                        tmp(ii)=obj.INTEGER_TYPE;
                    elseif strncmp(obj.OutputDataTypes(ii,:),'fixedpoint',numel('fixedpoint'))
                        tmp(ii)=obj.FIXEDPOINT_TYPE;
                    elseif strncmp(obj.OutputDataTypes(ii,:),'double',numel('double'))
                        tmp(ii)=obj.DOUBLE_TYPE;
                    elseif strncmp(obj.OutputDataTypes(ii,:),'single',numel('single'))
                        tmp(ii)=obj.SINGLE_TYPE;
                    else
                        error(message('EDALink:FILSimulation:OutputTypeUnknownInternal',ii));
                    end
                end
            end
        end

        function tmp=setConnection(obj,val)
            strLen=obj.MAX_STR_SIZE-2;
            tmp=char(zeros(numel(val(:,1)),strLen));
            if strncmpi(val(1,:),'U',1)
                tmp(1,1:numel('UDP'))='UDP';
                if numel(val(:,1))>1
                    tmp(2,1:numel(val(2,:)))=val(2,:);
                end
                if numel(val(:,1))>2
                    tmp(3,1:numel(val(3,:)))=val(3,:);
                end
                if numel(val(:,1))>3
                    tmp(4,1:numel(val(4,:)))=val(4,:);
                end
            else
                tmp=val;
            end
        end

        function tmp=setInputDataSetBitWidth(obj)
            NumInputs=obj.getNumInputs;
            tmp=0;
            for ii=1:NumInputs
                tmp=tmp+obj.InputBitWidthsVec(ii);
            end
        end

        function tmp=setInputDataSetByteWidth(obj)
            NumInputs=obj.getNumInputs;
            tmp=0;
            for ii=1:NumInputs
                ByteWidth=idivide(uint32(obj.InputBitWidthsVec(ii)),uint32(8),'ceil');
                tmp=tmp+double(ByteWidth);
            end
        end

        function tmp=setInputByteWidthsVec(obj)
            NumInputs=obj.getNumInputs;
            tmp=zeros(1,NumInputs);
            for ii=1:NumInputs
                ByteWidth=idivide(uint32(obj.InputBitWidthsVec(ii)),uint32(8),'ceil');
                if ByteWidth>2&&ByteWidth<=4
                    ByteWidth=idivide(uint32(ByteWidth),uint32(4),'ceil')*4;
                elseif ByteWidth>4
                    if obj.InputDataTypesVec(ii)==obj.FIXEDPOINT_TYPE&&~obj.Is64BitStorage
                        ByteWidth=idivide(uint32(ByteWidth),uint32(4),'ceil')*4;
                    else
                        ByteWidth=idivide(uint32(ByteWidth),uint32(8),'ceil')*8;
                    end
                end
                tmp(ii)=double(ByteWidth);
            end
        end

        function tmp=setInputBufferByteWidth(obj)
            NumInputs=obj.getNumInputs;
            tmp=0;
            for ii=1:NumInputs
                ByteWidth=idivide(uint32(obj.InputBitWidthsVec(ii)),uint32(8),'ceil');
                if ByteWidth>2&&ByteWidth<=4
                    ByteWidth=idivide(uint32(ByteWidth),uint32(4),'ceil')*4;
                elseif ByteWidth>4
                    if obj.InputDataTypesVec(ii)==obj.FIXEDPOINT_TYPE&&~obj.Is64BitStorage
                        ByteWidth=idivide(uint32(ByteWidth),uint32(4),'ceil')*4;
                    else
                        ByteWidth=idivide(uint32(ByteWidth),uint32(8),'ceil')*8;
                    end
                end
                tmp=tmp+double(ByteWidth);
            end
            tmp=tmp*obj.InputFrameSize;
        end

        function tmp=setOutputDataSetBitWidth(obj)
            NumOutputs=obj.getNumOutputs;
            tmp=0;
            for ii=1:NumOutputs
                tmp=tmp+obj.OutputBitWidthsVec(ii);
            end
        end

        function tmp=setOutputDataSetByteWidth(obj)
            NumOutputs=obj.getNumOutputs;
            tmp=0;
            for ii=1:NumOutputs
                ByteWidth=idivide(uint32(obj.OutputBitWidthsVec(ii)),uint32(8),'ceil');
                tmp=tmp+double(ByteWidth);
            end
        end

        function tmp=setOutputByteWidthsVec(obj)
            NumOutputs=obj.getNumOutputs;
            tmp=zeros(1,NumOutputs);
            for ii=1:NumOutputs
                ByteWidth=idivide(uint32(obj.OutputBitWidthsVec(ii)),uint32(8),'ceil');
                if ByteWidth>2&&ByteWidth<=4
                    ByteWidth=idivide(uint32(ByteWidth),uint32(4),'ceil')*4;
                elseif ByteWidth>4
                    if obj.OutputDataTypesVec(ii)==obj.FIXEDPOINT_TYPE&&~obj.Is64BitStorage
                        ByteWidth=idivide(uint32(ByteWidth),uint32(4),'ceil')*4;
                    else
                        ByteWidth=idivide(uint32(ByteWidth),uint32(8),'ceil')*8;
                    end
                end
                tmp(ii)=double(ByteWidth);
            end
        end

        function tmp=setOutputStorageTypesArray(obj)
            NumOutputs=obj.getNumOutputs;
            strLen=numel('uint32');
            tmp=char(zeros(NumOutputs,strLen));
            for ii=1:NumOutputs
                ByteWidth=idivide(uint32(obj.OutputBitWidthsVec(ii)),uint32(8),'ceil');
                if obj.OutputSignedVec(ii)
                    if ByteWidth==1
                        tmp(ii,1:numel('int8'))='int8';
                    elseif ByteWidth==2
                        tmp(ii,1:numel('int16'))='int16';
                    elseif ByteWidth>2&&ByteWidth<=4
                        tmp(ii,1:numel('int32'))='int32';
                    elseif ByteWidth>4
                        if obj.OutputDataTypesVec(ii)==obj.FIXEDPOINT_TYPE&&~obj.Is64BitStorage

                            tmp(ii,1:numel('uint32'))='uint32';
                        else
                            tmp(ii,1:numel('int64'))='int64';
                        end
                    end
                else
                    if ByteWidth==1
                        tmp(ii,1:numel('uint8'))='uint8';
                    elseif ByteWidth==2
                        tmp(ii,1:numel('uint16'))='uint16';
                    elseif ByteWidth>2&&ByteWidth<=4
                        tmp(ii,1:numel('uint32'))='uint32';
                    elseif ByteWidth>4
                        if obj.OutputDataTypesVec(ii)==obj.FIXEDPOINT_TYPE&&~obj.Is64BitStorage
                            tmp(ii,1:numel('uint32'))='uint32';
                        else
                            tmp(ii,1:numel('uint64'))='uint64';
                        end
                    end
                end
            end
        end

        function tmp=setOutputBufferByteWidth(obj)
            NumOutputs=obj.getNumOutputs;
            tmp=0;
            for ii=1:NumOutputs
                ByteWidth=idivide(uint32(obj.OutputBitWidthsVec(ii)),uint32(8),'ceil');
                if ByteWidth>2&&ByteWidth<=4
                    ByteWidth=idivide(uint32(ByteWidth),uint32(4),'ceil')*4;
                elseif ByteWidth>4
                    if obj.OutputDataTypesVec(ii)==obj.FIXEDPOINT_TYPE&&~obj.Is64BitStorage
                        ByteWidth=idivide(uint32(ByteWidth),uint32(4),'ceil')*4;
                    else
                        ByteWidth=idivide(uint32(ByteWidth),uint32(8),'ceil')*8;
                    end
                end
                tmp=tmp+double(ByteWidth);
            end
            tmp=tmp*obj.OutputFrameSize;
        end

    end

    methods(Static,Hidden)
        function ret=getAlternateBlock
            ret='fillib/FPGA-in-the-Loop (FIL)';
        end

        function desc=getDescriptionImpl
            desc='FILSimulation';
        end

        function props=getDisplayPropertiesImpl()
            props={'DUTName',...
            'InputSignals',...
            'InputBitWidths',...
            'OutputSignals',...
            'OutputBitWidths',...
            'OutputDataTypes',...
            'OutputSigned',...
            'OutputFractionLengths',...
            'OutputDownsampling',...
            'OverclockingFactor',...
'SourceFrameSize'...
            ,'Connection',...
            'FPGAVendor',...
            'FPGABoard',...
            'FPGAProgrammingFile',...
            'ScanChainPosition',...
            };
        end

    end




    methods(Static)



        function n=getDescriptiveName(~)
            n='FILSimulation';
        end





        function b=isSupportedContext(context)
            b=context.isMatlabHostTarget();
        end


        function updateBuildInfo(buildInfo,context)%#ok<INUSD>



            group='BlockModules';
            bopts=filbuildoptions();


            buildInfo.addIncludePaths(bopts.rtw.includeDirs);


            linkPriority='';
            linkPrecompiled=true;
            linkLinkonly=true;
            buildInfo.addLinkObjects(bopts.rtw.libNames,bopts.rtw.libDirs,linkPriority,...
            linkPrecompiled,linkLinkonly,group);




        end





    end



end

