classdef UDPRead<ioplayback.base.udp&ioplayback.internal.BlockSampleTime&...
    ioplayback.system.mixin.Event








%#codegen


    properties(Nontunable)

        LocalPort=25000;

        DataLength=1;

        DataType='uint8';

        ByteOrder='BigEndian';

        ReceiveBufferSize=-1;

        BlockingTime=0;


        OutputVarSizeSignal(1,1)logical=false;

        OutputStatus(1,1)logical=false;

        HideEventLines(1,1)logical=true;


        EventID='UDPRECV'
    end

    properties(Transient,Hidden)
        DataTypeSet=matlab.system.StringSet({'uint8','int8','uint16','int16','uint32','int32','single','double'});%#ok<*STRSET>
        ByteOrderSet=matlab.system.StringSet({'BigEndian','LittleEndian'});
    end

    properties(Nontunable,Hidden)
        Logo='Generic';
    end

    properties(Access=private)
TimeTick
DataTick
    end

    methods
        function obj=UDPRead(varargin)
            coder.allowpcode('plain');
            obj@ioplayback.base.udp(varargin{:});
            setProperties(obj,nargin,varargin{:});

            obj.DataFileFormat='Raw-TimeStamp';
            obj.DataTypeWarningasError=0;
        end

        function set.ReceiveBufferSize(obj,value)
            if value~=-1
                validateattributes(value,{'numeric'},...
                {'scalar','integer','>=',128,'<=',intmax('int32')},'','Receive buffer size');
            end
            obj.ReceiveBufferSize=value;
        end

        function set.BlockingTime(obj,value)
            validateattributes(value,{'double'},...
            {'scalar','nonnegative','nonnan'},'','BlockingTime');
            obj.BlockingTime=value;
        end



        function set.LocalPort(obj,value)

            validateattributes(value,{'numeric'},{'integer','nonnan','finite','nonempty','scalar','>',0,'<=',65535},'','Local port');

            obj.LocalPort=value;
        end

        function set.DataLength(obj,value)

            validateattributes(value,{'numeric'},{'integer','nonnan','finite','nonempty','scalar','>',0},'','Maximum data length (elements)');

            obj.DataLength=value;
        end
    end

    methods(Access=protected)
        function setupImpl(obj,varargin)
            coder.extrinsic('gcbh');
            coder.extrinsic('soc.internal.connectivity.getTaskNameForFcnCallSubs');
            coder.extrinsic('matlab.lang.makeValidName');
            coder.extrinsic('num2str');
            if~obj.HideEventLines
                pollFcn='MW_UDPRead_Poll';
                pollFcnArg=matlab.lang.makeValidName(['ptr_udpread_',num2str(obj.LocalPort)]);
                eventName=[obj.EventID,'_',num2str(obj.LocalPort)];
            else
                pollFcn='';
                pollFcnArg='';
                eventName=obj.EventID;
            end

            if ioplayback.base.target

                if isequal(obj.SimulationOutput,'From input port')
                    validateattributes(varargin{1},{obj.DataType},...
                    {'size',[obj.DataLength,1]},'UDPRead','input');
                else
                    obj.DataFileFormat='TimeStamp';
                    obj.SignalInfo.Name='UDP_Read';
                    obj.SignalInfo.Dimensions=[obj.DataLength,1];
                    obj.SignalInfo.DataType=obj.DataType;
                    obj.SignalInfo.IsComplex=false;
                    setupImpl@ioplayback.SourceSystem(obj);
                    if isequal(obj.SimulationOutput,'From recorded file')
                        setup(obj.Reader,1);
                    end
                end


                try %#ok<EMTC>
                    if isinf(obj.BlockingTime)
                        events=struct('EventID',eventName,...
                        'CommType','pull',...
                        'TaskFcnPollCmd',pollFcn,...
                        'TaskFcnPollCmdArg',pollFcnArg,...
                        'IOBlockHandle',gcb);
                    else
                        events=struct('EventID',eventName,...
                        'CommType','pull');
                    end
                    soc.registerBlock(obj,events);
                catch ME
                    disp(ME.message)
                end
                obj.TimeTick=0;
                obj.DataTick=0;
            else

                setReceiveBufferSize(obj,obj.ReceiveBufferSize);
                setTransmitBufferSize(obj,-1);
                setNetworkByteOrder(obj,obj.ByteOrder);
                initTimeOut(obj,obj.BlockingTime);


                open(obj,obj.LocalPort);
                if~obj.HideEventLines&&isinf(obj.BlockingTime)
                    ptrName=coder.const(char(pollFcnArg));
                    coder.ceval("extern void *"+ptrName+"; //");
                    coder.ceval(ptrName+" = (void *)",obj.MW_UDP_HANDLE);
                end
            end
        end

        function varargout=stepImpl(obj,varargin)
            if ioplayback.base.target
                status=coder.nullcopy(int32(0));
                if isequal(obj.SimulationOutput,'From input port')
                    data=varargin{1};
                    dataSize=numel(data);
                    if(obj.OutputVarSizeSignal)&&(dataSize>obj.DataLength)
                        data=data(1:obj.DataLength);
                    end
                else
                    if obj.OutputVarSizeSignal
                        data=stepImpl@ioplayback.SourceSystem(obj);
                        if numel(data)>obj.DataLength
                            data=data(1:obj.DataLength);
                        end
                    else
                        data=zeros([obj.DataLength,1],obj.DataType);
                        tmp=stepImpl@ioplayback.SourceSystem(obj);
                        dataSize=min(obj.DataLength,numel(tmp));
                        for k=1:dataSize
                            data(k)=tmp(k);
                        end
                    end
                    obj.DataTick=obj.DataTick+1;
                end

                varargout{1}=data;
                AvlDataLengthLoc=uint32(numel(data));
            else

                AvlDataLengthLoc=checkNumberOfAvailableData(obj,obj.DataLength,obj.DataType);
                AvlDataLengthLoc=min(AvlDataLengthLoc,uint32(obj.DataLength));

                if obj.OutputVarSizeSignal
                    [varargout{1},status]=read(obj,AvlDataLengthLoc,obj.DataType);
                else
                    data=coder.nullcopy(zeros(obj.DataLength,1,obj.DataType));
                    [data(1:AvlDataLengthLoc),status]=read(obj,AvlDataLengthLoc,obj.DataType);
                    varargout{1}=data;
                end
            end

            if nargout>1
                if~obj.OutputVarSizeSignal
                    varargout{2}=AvlDataLengthLoc;
                end
                if obj.OutputStatus
                    varargout{nargout}=status;
                end
            end
        end

        function releaseImpl(obj)
            if ioplayback.base.target
                releaseImpl@ioplayback.SourceSystem(obj);
            else
                close(obj);
            end
        end

        function validatePropertiesImpl(obj)
            coder.internal.errorIf(obj.DataLength>floor(65507/ioplayback.base.ByteOrder.getNumberOfBytes(obj.DataType)),...
            'ioplayback:general:UDPIncorrectNumel',obj.DataLength,obj.DataType);
        end

        function flag=isInputSizeMutableImpl(obj,idx)
            if obj.OutputVarSizeSignal&&(idx==1)
                flag=true;
            else
                flag=false;
            end
        end

        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end

        function flag=isInputDataTypeMutableImpl(~,~)
            flag=false;
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=isInactivePropertyImpl@ioplayback.SourceSystem(obj,prop);
            switch prop
            case 'OutputStatus'
                flag=true;
            case 'ByteOrder'
                flag=isequal(obj.DataType,'uint8')||isequal(obj.DataType,'int8');
            end
        end

        function num=getNumOutputsImpl(obj)
            num=2-obj.OutputVarSizeSignal+obj.OutputStatus;
        end

        function varargout=getOutputNamesImpl(obj)
            varargout{1}='data';
            if~obj.OutputVarSizeSignal
                varargout{2}='length';
            end
            if obj.OutputStatus
                varargout{getNumOutputsImpl(obj)}='status';
            end
        end

        function varargout=getOutputSizeImpl(obj)
            varargout{1}=[obj.DataLength,1];
            if~obj.OutputVarSizeSignal
                varargout{2}=[1,1];
            end
            if obj.OutputStatus
                varargout{getNumOutputsImpl(obj)}=[1,1];
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout{1}=obj.DataType;
            if~obj.OutputVarSizeSignal
                varargout{2}='uint32';
            end
            if obj.OutputStatus
                varargout{getNumOutputsImpl(obj)}='int32';
            end
        end

        function varargout=isOutputComplexImpl(obj)
            varargout{1}=false;
            if~obj.OutputVarSizeSignal
                varargout{2}=false;
            end
            if obj.OutputStatus
                varargout{getNumOutputsImpl(obj)}=false;
            end
        end

        function varargout=isOutputFixedSizeImpl(obj)
            if obj.OutputVarSizeSignal
                varargout{1}=false;
            else
                varargout{1}=true;
                varargout{2}=true;
            end
            if obj.OutputStatus
                varargout{getNumOutputsImpl(obj)}=true;
            end
        end

        function num=getNumInputsImpl(obj)

            if~isequal(obj.SimulationOutput,'From input port')
                num=0;
            else
                num=1;
            end
        end

        function varargout=getInputNamesImpl(obj)
            if isequal(obj.SimulationOutput,'From input port')
                varargout{1}='data';
            else
                varargout=[];
            end
        end

        function sts=getSampleTimeImpl(obj)
            sts=getSampleTimeImpl@ioplayback.internal.BlockSampleTime(obj);
        end
    end

    methods(Access=protected)
        function maskDisplayCmds=getMaskDisplayImpl(obj)
            inport_label=[];
            num=getNumInputsImpl(obj);
            if num>0
                inputs=cell(1,num);
                [inputs{1:num}]=getInputNamesImpl(obj);
                for i=1:num
                    inport_label=[inport_label,'port_label(''input'',',num2str(i),',''',inputs{i},''');',newline];%#ok<AGROW>
                end
            end

            outport_label=[];
            num=getNumOutputsImpl(obj);
            if num>0
                outputs=cell(1,num);
                [outputs{1:num}]=getOutputNamesImpl(obj);
                for i=1:num
                    outport_label=[outport_label,'port_label(''output'',',num2str(i),',''',outputs{i},''');',newline];%#ok<AGROW>
                end
            end

            portname=['sprintf(''Port: %s'',''',num2str(obj.LocalPort),''')'];
            maskDisplayCmds=[...
            ['color(''white'');',newline]...
            ,['plot([100,100,100,100],[100,100,100,100]);',newline]...
            ,['plot([0,0,0,0],[0,0,0,0]);',newline]...
            ,['color(''blue'');',newline]...
            ,['text(99, 92, ''',obj.Logo,''', ''horizontalAlignment'', ''right'');',newline]...
            ,['color(''black'');',newline]...
            ,['text(50, 30,','[',portname,'],''texmode'',''off'',''horizontalAlignment'',''center'',''verticalAlignment'',''middle'');',newline],...
            inport_label,...
            outport_label,...
            ];
        end
    end


    methods
        function y=readData(obj,ds)
            y=0;
            if isempty(coder.target)
                if nargin<2
                    ds=RecordedData(obj.DatasetName);
                end
                dataFile=getDataFile(ds,obj.SourceName);
                fid=fopen(dataFile,'r');
                if fid<0
                    error(message('ioplayback:general:CannotOpenFile'));
                end
                y=timeseries(obj.SourceName);
                dt=zeros([obj.DataLength,1],obj.DataType);
                while~feof(fid)
                    ts=fread(fid,1,'*double');
                    if isempty(ts)
                        break;
                    end
                    s=fread(fid,1,'*uint16');
                    data=typecast(fread(fid,s,'*uint8'),obj.DataType);
                    dt(1:s)=data;
                    dt(s+1:end)=nan;
                    y=addsample(y,'Data',dt,'Time',ts);
                end
                fclose(fid);
            end
        end

        function checkDataFile(obj,dataFile)%#ok<INUSD>
            if isempty(coder.target)





            end
        end

        function event=getNextEvent(obj,eventID,currentTime)
            if isequal(obj.SimulationOutput,'From input port')||isequal(obj.SimulationOutput,'Zeros')

                event=[];
                return;
            end


            event.ID=eventID;
            if obj.SampleTime>0



                event.Time=round((currentTime+obj.SampleTime)/obj.SampleTime)*obj.SampleTime;
                obj.TimeTick=obj.TimeTick+1;
            else


                ts=readTimestamp(obj.Reader);
                if isempty(ts)
                    event=[];
                else
                    event.Time=ts;
                end
            end
        end
    end

    methods(Static,Access=protected)
        function simMode=getSimulateUsingImpl

            simMode="Interpreted execution";
        end

        function flag=showSimulateUsingImpl

            flag=false;
        end

        function header=getHeaderImpl()
            header=matlab.system.display.Header(mfilename('class'),...
            'ShowSourceLink',false,...
            'Title','UDP Read',...
            'Text',['Receive UDP packets from another UDP host on an Internet network.',newline,newline...
            ,'The Data port outputs the received UDP packet as a one-dimensional array. The Length port outputs size of received packet. The Maximum data length (elements) parameter specifies the maximum size of packet allowed at the Data port.',newline,newline...
            ,'The block receives a UDP packet on an IP port specified in the Local port parameter. The sending UDP host must send UDP packets to the Local port specified.',newline]);
        end

        function[groups,PropertyList]=getPropertyGroupsImpl

            LocalPortProp=matlab.system.display.internal.Property('LocalPort','Description','Local port');

            ReceiveBufferSizeProp=matlab.system.display.internal.Property('ReceiveBufferSize','Description','Receive buffer size (bytes)');

            ByteOrderProp=matlab.system.display.internal.Property('ByteOrder','Description','Byte order');

            BlockingTimeProp=matlab.system.display.internal.Property('BlockingTime','Description','Blocking time (seconds)');

            OutputVarSizeSignalProp=matlab.system.display.internal.Property('OutputVarSizeSignal','Description','Output variable-size signal');

            DataLengthProp=matlab.system.display.internal.Property('DataLength','Description','Maximum data length (elements)');

            DataTypeProp=matlab.system.display.internal.Property('DataType','Description','Data type');

            OutputStatusProp=matlab.system.display.internal.Property('OutputStatus','Description','Enable status output port');

            SampleTimeProp=matlab.system.display.internal.Property('SampleTime','Description','Sample time');

            HideEventLinesProp=matlab.system.display.internal.Property('HideEventLines','Description','Hide event lines','IsGraphical',false);


            PropertyListOut{1}=LocalPortProp;
            PropertyListOut{end+1}=DataLengthProp;
            PropertyListOut{end+1}=DataTypeProp;
            PropertyListOut{end+1}=ByteOrderProp;
            PropertyListOut{end+1}=ReceiveBufferSizeProp;
            PropertyListOut{end+1}=BlockingTimeProp;
            PropertyListOut{end+1}=OutputVarSizeSignalProp;
            PropertyListOut{end+1}=OutputStatusProp;
            PropertyListOut{end+1}=SampleTimeProp;
            PropertyListOut{end+1}=HideEventLinesProp;


            Group=matlab.system.display.SectionGroup(...
            'Title','Main',...
            'PropertyList',PropertyListOut);


            SimPropertyList=ioplayback.SourceSystem.getPropertyGroupsList;

            EventIDProp=matlab.system.display.internal.Property('EventID','Description','Data available event');
            SimPropertyList.PropertyList{end+1}=EventIDProp;
            groups=[Group,SimPropertyList];


            if nargout>1
                PropertyList=PropertyListOut;
            end
        end
    end
end


