classdef HDLCosimulation<matlab.system.SFunSystem
















































    properties(Nontunable)


        HDLSimulator='ModelSim or Xcelium';




        InputSignals='';




        OutputSignals='';





        OutputDataTypes='';






        OutputSigned=false;






        OutputFractionLengths=0;






        TCLPreSimulationCommand='';





        TCLPostSimulationCommand='';




        PreRunTime={0,'ns'};







        Connection={'SharedMemory'};





        SampleTime={10,'ns'};
    end

    properties(Constant,Hidden)
        PortDefault='4449';
    end

    properties(Nontunable)



        FrameBasedProcessing=false;
    end

    methods
        function obj=HDLCosimulation(varargin)
            obj@matlab.system.SFunSystem('mhdlcosim');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);




            stack=dbstack();
            simIdx=find(cellfun(@(x)(strcmp(x,'HDLSimulator')),varargin(1:2:end)));
            callerIsVivadoSysObj=length(stack)>1&&strcmp(stack(2).name,'VivadoHDLCosimulation.VivadoHDLCosimulation');
            if simIdx
                hdlSimArg=varargin{simIdx+1};
            else
                hdlSimArg='';
            end
            isNotOk=~callerIsVivadoSysObj&&strcmp(hdlSimArg,'Vivado Simulator');
            if(isNotOk)
                error('To create a System object for use with Vivado Simulator call hdlcosim(''HDLSimulator'',''Vivado Simulator'') or use ''hdlverfier.VivadoHDLCosimulation''.');
            end
        end

        function set.HDLSimulator(obj,val)
            validateattributes(val,{'char','string'},{'nonempty'},'','HDLSimulator');


            okvals={'ModelSim','Xcelium','Vivado Simulator','ModelSim or Xcelium'};
            if~any(strcmp(val,okvals))
                error('Expected HDLSimulator to match one of these values:\n%s',sprintf('''%s'' ',okvals{:}));
            end

            obj.HDLSimulator=val;
        end

        function set.InputSignals(obj,val)
            validateattributes(val,{'cell','char','string'},{},'','InputSignals');
            if iscell(val)
                if~isempty(val)
                    for ii=1:length(val)
                        validateattributes(val{ii},{'char','string'},{'nonempty'},'',['InputSignals{',num2str(ii),'}']);
                    end
                end
            end
            obj.InputSignals=val;
        end

        function set.OutputSignals(obj,val)
            validateattributes(val,{'cell','char','string'},{},'','OutputSignals');
            if iscell(val)
                if~isempty(val)
                    for ii=1:length(val)
                        validateattributes(val{ii},{'char','string'},{'nonempty'},'',['OutputSignals{',num2str(ii),'}']);
                    end
                end
            end
            obj.OutputSignals=val;
        end

        function set.OutputDataTypes(obj,val)
            validateattributes(val,{'cell','char','string'},{},'','OutputDataTypes');
            if iscell(val)
                for ii=1:numel(val)
                    validateattributes(val{ii},{'char','string'},{'nonempty'},'',['OutputDataTypes{',num2str(ii),'}']);
                    if~any(strcmp(val{ii},{'fixedpoint','double','single'}))
                        error(message('HDLLink:HDLCosim:OutputDataTypesUnknown'));
                    end
                end
            elseif~isempty(val)
                validateattributes(val,{'char','string'},'','OutputDataTypes');
                if~any(strcmp(val,{'fixedpoint','double','single'}))
                    error(message('HDLLink:HDLCosim:OutputDataTypesUnknown'));
                end
            end
            obj.OutputDataTypes=val;
        end

        function set.OutputSigned(obj,val)
            validateattributes(val,{'logical'},{'nonempty','row'},'','OutputSigned');
            obj.OutputSigned=val;
        end

        function set.OutputFractionLengths(obj,val)
            validateattributes(val,{'numeric'},{'nonempty','row','integer','real','finite','nonsparse','nonnan','<',2^31,'>=',-2^31},'','OutputFractionLengths');
            obj.OutputFractionLengths=val;
        end

        function set.TCLPreSimulationCommand(obj,val)
            validateattributes(val,{'char','string'},{},'','TCLPreSimulationCommand');
            obj.TCLPreSimulationCommand=val;
        end

        function set.TCLPostSimulationCommand(obj,val)
            validateattributes(val,{'char','string'},{},'','TCLPostSimulationCommand');
            obj.TCLPostSimulationCommand=val;
        end

        function set.PreRunTime(obj,val)
            validateattributes(val,{'cell'},{'nonempty','size',[1,2]},'','PreRunTime');
            validateattributes(val{1},{'numeric'},{'scalar','real','nonnegative','finite','nonsparse','nonnan','<',2^64},'','PreRunTime{1} (Delay)');
            validateattributes(val{2},{'char','string'},{'nonempty'},'','PreRunTime{2} (Unit)');
            validatestring(val{2},{'fs','ps','ns','us','ms','s'},'','PreRunTime{2} (Unit)');
            if strncmpi(val{2},'f',1)
                val{2}='fs';
            elseif strncmpi(val{2},'p',1)
                val{2}='ps';
            elseif strncmpi(val{2},'n',1)
                val{2}='ns';
            elseif strncmpi(val{2},'u',1)
                val{2}='us';
            elseif strncmpi(val{2},'m',1)
                val{2}='ms';
            else
                val{2}='s';
            end
            obj.PreRunTime=val;
        end

        function set.Connection(obj,val)
            validateattributes(val,{'cell'},{'nonempty','row'},'','Connection');
            validateattributes(val{1},{'char','string'},{'nonempty'},'','Connection{1} (Type)');
            validatestring(val{1},{'SharedMemory','Socket'},'','Connection{1} (Type)');
            if strncmpi(val{1},'So',2)
                val{1}='Socket';
            else
                val{1}='SharedMemory';
            end
            if strcmp(val{1},'Socket')
                if numel(val)>1
                    validateattributes(val{2},{'numeric'},{'scalar','integer','real','nonnegative','nonsparse','finite','nonnan','<',65536},'','Connection{2} (Port)');
                end
                if numel(val)>2
                    validateattributes(val{3},{'char','string'},{},'','Connection{3} (HostName)');
                end
                if numel(val)>3
                    error(message('HDLLink:HDLCosim:ConnectionSocketArg'));
                end
            else
                if numel(val)>1
                    error(message('HDLLink:HDLCosim:ConnectionSharedArg'));
                end
            end

            obj.Connection=val;
        end

        function set.FrameBasedProcessing(obj,val)
            warning(message('HDLLink:HDLCosim:FrameBasedProcessingDeprecated'));
            validateattributes(val,{'logical'},{'scalar','nonempty'},'','FrameBasedProcessing');
            obj.FrameBasedProcessing=val;
        end

        function set.SampleTime(obj,val)
            validateattributes(val,{'cell'},{'nonempty','size',[1,2]},'','SampleTime');
            validateattributes(val{1},{'numeric'},{'scalar','real','nonnegative','finite','nonsparse','nonnan','<',2^64},'','SampleTime{1} (HW Sampling Period)');
            validateattributes(val{2},{'char','string'},{'nonempty'},'','SampleTime{2} (Unit)');
            validatestring(val{2},{'fs','ps','ns','us','ms','s'},'','SampleTime{2} (Unit)');
            if strncmpi(val{2},'f',1)
                val{2}='fs';
            elseif strncmpi(val{2},'p',1)
                val{2}='ps';
            elseif strncmpi(val{2},'n',1)
                val{2}='ns';
            elseif strncmpi(val{2},'u',1)
                val{2}='us';
            elseif strncmpi(val{2},'m',1)
                val{2}='ms';
            else
                val{2}='s';
            end
            obj.SampleTime=val;
        end

    end

    methods(Hidden)
        function compParams=getCompParameters(obj)
            InportNames=double.empty;
            if~isempty(obj.InputSignals)
                if iscell(obj.InputSignals)
                    for ii=1:length(obj.InputSignals)
                        if ii==1
                            InportNames=sprintf('%s',obj.InputSignals{ii});
                        else
                            InportNames=sprintf('%s;%s',InportNames,obj.InputSignals{ii});
                        end
                    end
                else
                    InportNames=sprintf('%s',obj.InputSignals);
                end
            end

            OutportNames=double.empty;
            OutSampleTimes=double.empty;
            OutDataTypes=double.empty;
            OutRadixPts=double.empty;

            if iscell(obj.OutputDataTypes)
                tmpOutputDataTypes=obj.OutputDataTypes;
            else
                tmpOutputDataTypes={obj.OutputDataTypes};
            end


            if l_getParamNum(tmpOutputDataTypes)==1
                tmpOutputDataTypes=repmat(tmpOutputDataTypes,1,l_getParamNum(obj.OutputSignals));
            end

            if~isempty(obj.OutputSignals)
                if iscell(obj.OutputSignals)
                    for ii=1:length(obj.OutputSignals)
                        if ii==1
                            OutportNames=sprintf('%s',obj.OutputSignals{ii});
                        else
                            OutportNames=sprintf('%s;%s',OutportNames,obj.OutputSignals{ii});
                        end
                        OutSampleTimes(ii)=1.0;
                        if numel(obj.OutputSigned)>1
                            OutDataTypes(ii)=l_getDataTypeEnum(tmpOutputDataTypes{ii},obj.OutputSigned(ii));
                        else
                            OutDataTypes(ii)=l_getDataTypeEnum(tmpOutputDataTypes{ii},obj.OutputSigned);
                        end
                        if numel(obj.OutputFractionLengths)>1
                            OutRadixPts(ii)=cast(obj.OutputFractionLengths(ii),'double');
                        else
                            OutRadixPts(ii)=cast(obj.OutputFractionLengths,'double');
                        end
                    end
                else
                    OutportNames=sprintf('%s',obj.OutputSignals);
                    OutSampleTimes=1.0;
                    OutDataTypes=cast(obj.OutputSigned,'double');
                    OutRadixPts=cast(obj.OutputFractionLengths,'double');
                end
            end

            if(strcmp(obj.Connection{1},'SharedMemory'))
                SharedMemory=1;
                PortString='';
                HostName='';
            else
                SharedMemory=0;
                PortString=obj.PortDefault;
                HostName='';
                if numel(obj.Connection)>1
                    PortString=num2str(obj.Connection{2});
                end
                if numel(obj.Connection)>2
                    HostName=obj.Connection{3};
                end
            end

            if(strcmp(HostName,''))
                ModelSimRunning=1;
            else
                ModelSimRunning=0;
            end

            AllowDirectFeedThrough=1.0;

            PreRunTimeDelay=obj.PreRunTime{1};

            if strcmp(obj.PreRunTime{2},'fs')
                PreRunTimeUnit=1;
            elseif strcmp(obj.PreRunTime{2},'ps')
                PreRunTimeUnit=2;
            elseif strcmp(obj.PreRunTime{2},'ns')
                PreRunTimeUnit=3;
            elseif strcmp(obj.PreRunTime{2},'us')
                PreRunTimeUnit=4;
            elseif strcmp(obj.PreRunTime{2},'ms')
                PreRunTimeUnit=5;
            else
                PreRunTimeUnit=6;
            end

            TimingScaleFactor=obj.SampleTime{1};

            if strcmp(obj.SampleTime{2},'fs')
                TimingMode=2;
            elseif strcmp(obj.SampleTime{2},'ps')
                TimingMode=3;
            elseif strcmp(obj.SampleTime{2},'ns')
                TimingMode=4;
            elseif strcmp(obj.SampleTime{2},'us')
                TimingMode=5;
            elseif strcmp(obj.SampleTime{2},'ms')
                TimingMode=6;
            else
                TimingMode=7;
            end

            compParams={...
            InportNames,...
            OutportNames,...
            double.empty,...
            double.empty,...
            obj.TCLPreSimulationCommand,...
            obj.TCLPostSimulationCommand,...
            OutSampleTimes,...
            OutDataTypes,...
            OutRadixPts,...
            double.empty,...
            double.empty,...
            ModelSimRunning,...
            SharedMemory,...
            PortString,...
            HostName,...
            TimingMode,...
            TimingScaleFactor,...
            1,...
            AllowDirectFeedThrough,...
            0,...
            PreRunTimeDelay,...
            PreRunTimeUnit,...
            };
        end

        function setParameters(obj)
            compParams=obj.getCompParameters();
            obj.compSetParameters(compParams);
        end
    end

    methods(Access=protected)
        function validatePropertiesImpl(obj)
            if~isempty(obj.OutputDataTypes)


                if(l_getParamNum(obj.OutputDataTypes)>1)&&(l_getParamNum(obj.OutputDataTypes)~=l_getParamNum(obj.OutputSignals))
                    error(message('HDLLink:HDLCosim:OutputDataTypesSize',l_getDataNum(obj.OutputDataTypes),l_getDataNum(obj.OutputSignals)));
                end
            end

            if(numel(obj.OutputSigned)>1)&&(numel(obj.OutputSigned)~=numel(obj.OutputSignals)&&(numel(obj.OutputSignals)>0))
                error(message('HDLLink:HDLCosim:OutputSignedSize',numel(obj.OutputSigned),numel(obj.OutputSignals)));
            end

            if(numel(obj.OutputFractionLengths)>1)&&(numel(obj.OutputFractionLengths)~=numel(obj.OutputSignals)&&(numel(obj.OutputSignals)>0))
                error(message('HDLLink:HDLCosim:OutputFractionLengthsSize',numel(obj.OutputFractionLengths),numel(obj.OutputSignals)));
            end
        end

        function validateInputsImpl(~,varargin)
            if nargin>1
                if~iscolumn(varargin{1})
                    error(message('HDLLink:HDLCosim:FrameColumn'));
                end
            end
        end

        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end

        function flag=isInputSizeMutableImpl(~,~)
            flag=false;
        end
    end

    methods(Static,Hidden)
        function ret=getAlternateBlock
            ret='modelsimlib/HDL Cosimulation';
        end

        function desc=getDescriptionImpl
            desc='HDLCosimulation';
        end

        function props=getDisplayPropertiesImpl()
            props={'InputSignals',...
            'OutputSignals',...
            'OutputSigned',...
            'OutputDataTypes',...
            'OutputFractionLengths',...
            'TCLPreSimulationCommand',...
            'TCLPostSimulationCommand',...
            'PreRunTime',...
            'Connection',...
...
            'SampleTime'};
        end

        function b=generatesCode
            b=false;
        end
    end

end

function dataTypeEnum=l_getDataTypeEnum(dataType,sign)
    switch dataType
    case 'double'
        dataTypeEnum=2;
    case 'single'
        dataTypeEnum=3;
    otherwise
        dataTypeEnum=cast(sign,'double');
    end
end

function r=l_getParamNum(data)
    if ischar(data)
        r=1;
    else
        r=numel(data);
    end
end
