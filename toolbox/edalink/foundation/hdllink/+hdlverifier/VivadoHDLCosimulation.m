classdef VivadoHDLCosimulation<hdlverifier.HDLCosimulation&matlab.system.SFunSystem












































    properties(Nontunable)







        ClockResetSignals='';






        ClockResetTypes='';








        ClockResetTimes=cell(1,2);









        XSIData=createXsiData();

        FallingClockPaths='';
        FallingClockPeriods=[];
        RisingClockPaths='';
        RisingClockPeriods=[];
    end

    methods
        function obj=VivadoHDLCosimulation(varargin)
            simIdx=find(cellfun(@(x)(strcmp(x,'HDLSimulator')),varargin(1:2:end)));
            if isempty(simIdx)
                varargin{end+1}='HDLSimulator';
                varargin{end+1}='Vivado Simulator';
            else
                hdlSim=varargin{simIdx+1};
                if~strcmp(hdlSim,'Vivado Simulator')
                    error('You can only use this System object with Vivado Simulator, but HDLSimulator was set to ''%s''.',hdlSim);
                end
            end
            obj@hdlverifier.HDLCosimulation(varargin{:});
            obj@matlab.system.SFunSystem('mhdlcosimxsi');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
        end

        function set.ClockResetSignals(obj,val)
            validateattributes(val,{'cell','char','string'},{},'','ClockResetSignals');
            if iscell(val)
                if~isempty(val)
                    for ii=1:length(val)
                        validateattributes(val{ii},{'char','string'},{'nonempty'},'',['ClockResetSignals{',num2str(ii),'}']);
                    end
                end
            end
            obj.ClockResetSignals=val;
        end

        function set.ClockResetTypes(obj,val)
            validateattributes(val,{'cell','char','string'},{},'','ClockResetTypes');
            strVals=hdllinkddg.ClockResetRowSource.getStrValues('edge');
            if iscell(val)
                for ii=1:numel(val)
                    validateattributes(val{ii},{'char','string'},{'nonempty'},'',['ClockResetTypes{',num2str(ii),'}']);
                    if~any(strcmp(val{ii},strVals))
                        error(message('HDLLink:HDLCosim:ClockResetTypesUnknown',sprintf('%s ',strVals{:})));
                    end
                end
            elseif~isempty(val)
                validateattributes(val,{'char','string'},'','ClockResetTypes');
                if~any(strcmp(val,strVals))
                    error(message('HDLLink:HDLCosim:ClockResetTypesUnknown',sprintf('%s ',strVals{:})));
                end
            end
            obj.ClockResetTypes=val;
        end


        function set.ClockResetTimes(obj,val)
            if obj.isDefaultTimeUnitPair(val)

            elseif obj.isScalarTimeUnitPair(val)
                val=obj.validateTimeUnitPair(val);
            else
                if iscell(val)
                    for idx=1:length(val)
                        val{idx}=obj.validateTimeUnitPair(val{idx});
                    end
                else
                    error('Expect ClockResetTimes to be a cell array of time-unit pairs.');
                end
            end
            obj.ClockResetTimes=val;
        end


        function tf=isDefaultTimeUnitPair(~,val)
            tf1=iscell(val)&&all(size(val)==[1,2])&&all(cellfun(@(x)(isempty(x)),val));
            tf2=isempty(val);
            tf=tf1||tf2;
        end
        function tf=isScalarTimeUnitPair(~,val)
            tf=iscell(val)&&all(size(val)==[1,2])&&isscalar(val{1})&&ischar(val{2});
        end
        function val=validateTimeUnitPair(~,val)
            validateattributes(val,{'cell'},{'nonempty','size',[1,2]},'','ClockResetTimes');
            validateattributes(val{1},{'numeric'},{'scalar','real','nonnegative','finite','nonsparse','nonnan','<',2^64},'','ClockResetTimes{1} (period/duration)');
            validateattributes(val{2},{'char','string'},{'nonempty'},'','ClockResetTimes{2} (Unit)');
            validatestring(val{2},{'fs','ps','ns','us','ms','s'},'','ClockResetTimes{2} (Unit)');
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
        end
    end
    methods(Hidden)
        function setParameters(obj)
            compParams=obj.getCompParameters();


...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...




            sfcnCRS=double.empty;
            if~isempty(obj.ClockResetSignals)
                if iscell(obj.ClockResetSignals)
                    sfcnCRS=sprintf('%s;',obj.ClockResetSignals{:});
                    sfcnCRS=sfcnCRS(1:end-1);
                else
                    sfcnCRS=obj.ClockResetSignals;
                end
            end

            if~isempty(obj.ClockResetTypes)
                sfcnCRTy=cell2mat(cellfun(@(x)(hdllinkddg.ClockResetRowSource.convertPropValue('edge',x)),obj.ClockResetTypes,'UniformOutput',false));
            else
                sfcnCRTy=obj.ClockResetTypes;
            end

            sfcnCRTi=double.empty;
            objCRTi=obj.ClockResetTimes;
            if obj.isDefaultTimeUnitPair(objCRTi)

            else
                if obj.isScalarTimeUnitPair(objCRTi)
                    objCRTi={objCRTi};
                end
                for crtime=objCRTi
                    time=crtime{1}{1};
                    unit=crtime{1}{2};
                    hdltime=time*10^(CosimWizardPkg.CosimWizardData.precStrToExp(['1',unit]));
                    sfcnCRTi=[sfcnCRTi,hdltime];%#ok<AGROW> 
                end
            end

            compParams{end+1}=sfcnCRS;
            compParams{end+1}=sfcnCRTy;
            compParams{end+1}=sfcnCRTi;
            compParams{end+1}=obj.XSIData;
            obj.compSetParameters(compParams);
        end
    end
    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={'InputSignals',...
            'OutputSignals',...
            'OutputSigned',...
            'OutputDataTypes',...
            'OutputFractionLengths',...
            'ClockResetSignals',...
            'ClockResetTypes',...
            'ClockResetTimes',...
            'PreRunTime',...
            'SampleTime',...
'XSIData'...
            };





        end
    end

end