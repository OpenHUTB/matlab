classdef(Hidden=true,TunablesDetermineInactiveStatus)ConstellationDiagram<matlabshared.scopes.WebScopeSystem
























































































































%#function comm.webscope.ConstellationDiagram
%#function matlabshared.scopes.WebScopeSystem
%#function matlabshared.scopes.WebWindow
%#function matlabshared.scopes.WebStreamingSource
%#function utils.getDefaultWebWindowPosition
%#function utils.logicalToOnOff

    properties(Nontunable,Dependent)




        NumInputPorts{mustBeInteger,mustBeNumeric,mustBeFinite,mustBePositive,mustBeLessThanOrEqual(NumInputPorts,20)};
    end
    properties(Dependent)





        SamplesPerSymbol;





        SampleOffset;










        SymbolsToDisplaySource;





        SymbolsToDisplay;






        ReferenceConstellation;







        ChannelNames;



        Title(:,:)char;



        ReferenceMarker;



        ReferenceColor;




MeasurementInterval





        EVMNormalization;






        ColorFading;




EnableMeasurements




        XLimits;




        YLimits;



        XLabel(:,:)char;



        YLabel(:,:)char;




        ShowReferenceConstellation;



        ShowLegend;



        ShowTrajectory;



        ShowGrid;




        ShowTicks;
    end

    properties(Access=private,Hidden)
        MeasurementMode=false;
        ScopeLocked=false;
        MaxFrameSize=1;
    end
    properties(Hidden,Dependent)

        ExpandToolstrip;

        DefaultLegendLabel;

        HasToolstrip;

        HasStatusbar;
    end
    properties(Hidden)

        Tag='';

        Specification;

        Style;
    end
    properties(Constant,Hidden)
        EVMNormalizationSet=matlab.system.StringSet({'Average constellation power','Peak constellation power'});
        ReferenceMarkerValues=matlab.system.StringSet({'+','o','.','*','x','square','diamond',...
        'v','^','<','>','pentagram','hexagram'});
        SymbolsToDisplaySourceSet=matlab.system.StringSet({'Input frame length','Property'});
        ChannLim=20;
    end



    methods


        function this=ConstellationDiagram(varargin)


            this@matlabshared.scopes.WebScopeSystem('TimeBased',true,...
            'Name','Constellation Diagram',...
            'Position',uiscopes.getDefaultPosition([600,600]));
            spec=this.getScopeSpecification();
            msg=this.MessageHandler;
            this.Specification=spec;
            this.Specification.MessageHandler=msg;
            this.MessageHandler.Specification=spec;
            this.Specification.Name='Constellation Diagram';
            this.Specification.Position=uiscopes.getDefaultPosition([600,600]);


            setProperties(this,nargin,varargin{:},'NumInputPorts');

            this.NeedsTimedBuffer=false;
            this.LastWriteTime=tic;
        end


        function set.Title(this,value)

            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','Title');
            setPropertyValue(this.Specification,'Title',value);
        end
        function value=get.Title(this)
            value=getPropertyValue(this.Specification,'Title');
        end

        function set.XLabel(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','XLabel');
            setPropertyValue(this.Specification,'XLabel',value);
        end
        function value=get.XLabel(this)
            value=getPropertyValue(this.Specification,'XLabel');
        end

        function set.YLabel(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','YLabel');
            setPropertyValue(this.Specification,'YLabel',value);
        end
        function value=get.YLabel(this)
            value=getPropertyValue(this.Specification,'YLabel');
        end

        function set.XLimits(this,value)

            if~all(isnumeric(value))||~all(isfinite(value))||...
                numel(value)~=2||value(1)>=value(2)
                this.error(...
                'comm:ConstellationDiagramWebScope:InvalidXYLimits','XLimits');
            end
            setPropertyValue(this.Specification,'XLimits',value);
        end
        function value=get.XLimits(this)
            value=getPropertyValue(this.Specification,'XLimits');
        end

        function set.YLimits(this,value)

            if~all(isnumeric(value))||~all(isfinite(value))||...
                numel(value)~=2||value(1)>=value(2)
                this.error(...
                'comm:ConstellationDiagramWebScope:InvalidXYLimits','YLimits');
            end
            setPropertyValue(this.Specification,'YLimits',value);
        end
        function value=get.YLimits(this)
            value=getPropertyValue(this.Specification,'YLimits');
        end

        function set.SamplesPerSymbol(this,value)
            validateattributes(value,...
            {'numeric'},{'integer','scalar','>',0},'','SamplesPerSymbol');
            if isLocked(this)&&(value<=this.SampleOffset)
                this.error(...
                'comm:ConstellationDiagramWebScope:InvalidSamplesPerSymbol');
            end
            setPropertyValue(this.Specification,'SamplesPerSymbol',value);
        end
        function value=get.SamplesPerSymbol(this)
            value=getPropertyValue(this.Specification,'SamplesPerSymbol');
        end

        function set.SampleOffset(this,value)
            validateattributes(value,...
            {'numeric'},{'integer','scalar','>=',0},'','SampleOffset');
            if isLocked(this)&&(value>=this.SamplesPerSymbol)
                this.error(...
                'comm:ConstellationDiagramWebScope:InvalidSampleOffset');
            end
            setPropertyValue(this.Specification,'SampleOffset',value);
        end
        function value=get.SampleOffset(this)
            value=getPropertyValue(this.Specification,'SampleOffset');
        end

        function set.SymbolsToDisplaySource(this,value)
            if strcmp(value,'Input frame length')
                value=true;
            else
                value=false;
            end
            setPropertyValue(this.Specification,'SymbolsToDisplaySource',value);
        end
        function value=get.SymbolsToDisplaySource(this)
            value=getPropertyValue(this.Specification,'SymbolsToDisplaySource');
        end

        function set.SymbolsToDisplay(this,value)
            validateattributes(value,...
            {'numeric'},{'integer','scalar','>',0},'','SymbolsToDisplay');
            if strcmp(this.SymbolsToDisplaySource,'Property')
                setPropertyValue(this.Specification,'SymbolsToDisplay',value);
            end
        end
        function value=get.SymbolsToDisplay(this)
            value=getPropertyValue(this.Specification,'SymbolsToDisplay');
        end

        function set.ReferenceConstellation(this,value)
            if~isempty(value)
                if~iscell(value)
                    tempValue={value};
                else
                    tempValue=value;
                end
                for idx=1:numel(tempValue)
                    try
                        validateattributes(tempValue{idx},...
                        {'numeric'},{'finite','vector'},'','ReferenceConstellation')
                    catch
                        this.error(...
                        'comm:ConstellationDiagramWebScope:InvalidReferenceConstellationDefined');
                    end
                end
            end
            if this.MeasurementMode&&isempty(value)
                this.error(...
                'comm:ConstellationDiagramWebScope:InvalidReferenceConstellation');
            end
            setPropertyValue(this.Specification,'ReferenceConstellation',value);
            this.Specification.UpdateReferenceConstellation();
        end
        function value=get.ReferenceConstellation(this)
            value=getPropertyValue(this.Specification,'ReferenceConstellation');
            if iscell(value)&&numel(value)==1
                value=value{1};
            end
        end

        function set.ReferenceMarker(this,value)
            if~isempty(value)
                if~iscell(value)
                    value=cellstr(value);
                end
                for idx=1:numel(value)

                    value{idx}=validatestring(value{idx},this.ReferenceMarkerValues.getAllowedValues());

                    if~this.isMarkerValid(value{idx})
                        this.error(message('MATLAB:system:StringSet:InvalidValue',...
                        value{idx},'ReferenceMarker',...
                        string(join(this.ReferenceMarkerValues.getAllowedValues(),'", "'))));
                    end
                end
            else

                this.error(message('MATLAB:system:StringSet:InvalidValue',...
                value,'ReferenceMarker',...
                string(join(this.ReferenceMarkerValues.getAllowedValues(),'", "'))));
            end
            setPropertyValue(this.Specification,'ReferenceMarker',value);
        end
        function value=get.ReferenceMarker(this)
            value=getPropertyValue(this.Specification,'ReferenceMarker');
            if iscell(value)&&numel(value)==1
                value=value{1};
            end
        end

        function set.ReferenceColor(this,value)
            if~isempty(value)
                if~iscell(value)
                    [nRows,nCols]=size(value);
                    if nRows>1

                        tempValue=cell(size(nRows));
                        for row=1:nRows
                            tempValue{row}=value(row,:);
                        end
                    elseif nRows==1&&nCols>3

                        idx=1;
                        tempValue=cell(1,nCols/3);
                        col=1;
                        while col<nCols
                            tempValue{idx}=value(1,col:col+2);
                            idx=idx+1;
                            col=col+3;
                        end
                    else
                        tempValue={value};
                    end
                else
                    tempValue=value;
                end
                for idx=1:numel(tempValue)
                    validateattributes(tempValue{idx},...
                    {'numeric'},{'finite','real','numel',3,'>=',0,'<=',1},'','ReferenceColor');
                end
            else

                validateattributes(value,...
                {'numeric'},{'finite','real','numel',3,'>=',0,'<=',1},'','ReferenceColor');
            end
            setPropertyValue(this.Specification,'ReferenceColor',tempValue);
        end
        function value=get.ReferenceColor(this)
            value=getPropertyValue(this.Specification,'ReferenceColor');
            if iscell(value)&&numel(value)==1
                value=value{1};
            end
        end

        function set.ShowReferenceConstellation(this,value)
            validateattributes(value,{'logical','double'},{},'','ShowReferenceConstellation');
            if isnumeric(value)
                value=value>0;
            end
            setPropertyValue(this.Specification,'ShowReferenceConstellation',value);
        end
        function value=get.ShowReferenceConstellation(this)
            value=getPropertyValue(this.Specification,'ShowReferenceConstellation');
        end

        function set.ShowGrid(this,value)
            validateattributes(value,{'logical','double'},{},'','ShowGrid');
            if isnumeric(value)
                value=value>0;
            end
            setPropertyValue(this.Specification,'ShowGrid',value);
        end
        function value=get.ShowGrid(this)
            value=getPropertyValue(this.Specification,'ShowGrid');
        end

        function set.ShowLegend(this,value)
            validateattributes(value,{'logical','double'},{},'','ShowLegend');
            if isnumeric(value)
                value=value>0;
            end
            setPropertyValue(this.Specification,'ShowLegend',value);
        end
        function value=get.ShowLegend(this)
            value=getPropertyValue(this.Specification,'ShowLegend');
        end

        function set.NumInputPorts(this,value)
            try
                validateattributes(value,...
                {'numeric'},{'integer','scalar','>=',1,'<=',20},'','NumInputPorts');
            catch
                this.error(...
                'comm:ConstellationDiagramWebScope:InvalidNumInputPorts');
            end
            tempNumInputPorts=this.Specification.NumInputPorts;
            this.NumInputs=value;
            setPropertyValue(this.Specification,'NumInputPorts',value);
            if value~=tempNumInputPorts
                this.Specification.UpdateReferenceConstellation();

                this.MessageHandler.setReferenceConstellation(this.Specification.ReferenceConstellation);
            end
        end
        function value=get.NumInputPorts(this)
            value=getPropertyValue(this.Specification,'NumInputPorts');
        end


        function set.ChannelNames(this,value)

            if(~isstring(value)&&~iscellstr(value)&&~iscell(value))||isempty(value)||~isvector(value)
                this.error(...
                'comm:ConstellationDiagramWebScope:InvalidChannelNames');
            end
            value=cellstr(value);
            setPropertyValue(this.Specification,'ChannelNames',value);
        end
        function value=get.ChannelNames(this)
            value=getPropertyValue(this.Specification,'ChannelNames');
        end

        function set.ShowTrajectory(this,value)
            validateattributes(value,{'logical','double'},{},'','ShowTrajectory');
            if isnumeric(value)
                value=value>0;
            end
            setPropertyValue(this.Specification,'ShowTrajectory',value);
        end
        function value=get.ShowTrajectory(this)
            value=getPropertyValue(this.Specification,'ShowTrajectory');
        end

        function set.ColorFading(this,value)
            validateattributes(value,{'logical','double'},{},'','ColorFading');
            if isnumeric(value)
                value=value>0;
            end
            setPropertyValue(this.Specification,'ColorFading',value);
        end
        function value=get.ColorFading(this)
            value=getPropertyValue(this.Specification,'ColorFading');
        end

        function set.EnableMeasurements(this,value)
            validateattributes(value,{'logical','double'},...
            {'scalar','real'},'','EnableMeasurements');
            if isnumeric(value)
                value=value>0;
            end
            this.MeasurementMode=value;
            setPropertyValue(this.Specification,'EnableMeasurements',value);
        end
        function value=get.EnableMeasurements(this)
            value=getPropertyValue(this.Specification,'EnableMeasurements');
        end

        function set.MeasurementInterval(this,value)
            if comm.internal.utilities.isCharOrStringScalar(value)
                str=validatestring(value,{'All displays','Current display'});

                setPropertyValue(this.Specification,'MeasurementInterval',str);

            else
                validateattributes(value,...
                {'numeric'},{'nonnan','integer','scalar','>',0},...
                '','MeasurementInterval');
                setPropertyValue(this.Specification,'MeasurementInterval',value);
            end
        end
        function value=get.MeasurementInterval(this)
            value=getPropertyValue(this.Specification,'MeasurementInterval');
            if isempty(value)
                value=[];
            elseif~any(strcmp(value,{'Current display','All displays'}))
                if~isnumeric(value)
                    value=uiservices.evaluate(value);
                end
            end
        end

        function set.EVMNormalization(this,value)
            if strcmp(value,'Average constellation power')||strcmp(value,'AvePower')
                valueID='AvePower';
            elseif strcmp(value,'Peak constellation power')||strcmp(value,'PeakPower')
                valueID='PeakPower';
            else
                this.error(...
                'comm:commmeasurements:InvalidEVMNormalization');
            end
            setPropertyValue(this.Specification,'EVMNormalization',valueID);
        end
        function value=get.EVMNormalization(this)
            value=getPropertyValue(this.Specification,'EVMNormalization');
            if strcmp(value,'AvePower')
                value='Average constellation power';
            elseif strcmp(value,'PeakPower')
                value='Peak constellation power';
            end
        end

        function set.ShowTicks(this,value)
            validateattributes(value,{'logical','double'},{},'','ShowTicks');
            setPropertyValue(this.Specification,'ShowTicks',value);
        end
        function value=get.ShowTicks(this)
            value=getPropertyValue(this.Specification,'ShowTicks');
        end


        function set.HasToolstrip(this,value)
            this.Specification.HasToolstrip=value;
        end
        function value=get.HasToolstrip(this)
            value=this.Specification.HasToolstrip;
        end


        function set.HasStatusbar(this,value)
            this.Specification.HasStatusbar=value;
        end
        function value=get.HasStatusbar(this)
            value=this.Specification.HasStatusbar;
        end


        function set.ExpandToolstrip(this,value)
            setPropertyValue(this.Specification,'ExpandToolstrip',value)
        end
        function value=get.ExpandToolstrip(this)
            value=getPropertyValue(this.Specification,'ExpandToolstrip');
        end


        function show(this)



            this.HideCalled=false;
            show@matlabshared.scopes.WebWindow(this);

            this.WebScopeCOSI.WebWindow=this.WebWindowObject;
            matlabshared.application.waitfor(this.MessageHandler,'OpenComplete',true,'Timeout',10);
        end
    end

    methods(Hidden)

        function varargout=generateScript(this)


            if nargout>0
                varargout{1}=this.Specification.generateScript();
            else
                this.Specification.generateScript();
            end
        end

        function forceSynchronous(this)
            t=this.LastWriteTime;
            timeToWait=double(this.MaxFrameSize).^(2/3)/220;
            if timeToWait<0.250
                timeToWait=0.250;
            end
            while toc(t)<timeToWait
            end
        end
    end

    methods(Access=public,Hidden)

        function str=getQueryString(this,varargin)


            str=getQueryString@matlabshared.scopes.WebStreamingSource(this,...
            'Toolstrip',uiservices.logicalToOnOff(this.HasToolstrip),...
            'Statusbar',uiservices.logicalToOnOff(this.HasStatusbar),...
            varargin{:});
        end

        function flag=needsTimedBuffer(this)
            flag=this.NeedsTimedBuffer;
        end
    end

    methods(Access=protected)

        function h=getMessageHandler(~)
            h=comm.webscopes.internal.ConstellationDiagramMessageHandler;
        end

        function isTimeBased=isTimeBased(~)
            isTimeBased=true;
        end

        function spec=getScopeSpecification(~)
            spec=comm.webscopes.internal.ConstellationDiagramScopeSpecification;
        end

        function flag=isInputSizeMutableImpl(~,~)
            flag=false;
        end

        function n=getNumInputsImpl(this)
            if(this.NumInputs~=this.Specification.NumInputPorts)
                this.NumInputs=this.Specification.NumInputPorts;
            end
            n=this.NumInputs;
        end

        function setupImpl(this,varargin)
            refConValue=this.ReferenceConstellation;
            if~iscell(refConValue)
                refConValue={refConValue};
            end

            if this.NumInputPorts>numel(refConValue)
                this.Specification.UpdateReferenceConstellation();

                this.MessageHandler.setReferenceConstellation(this.Specification.ReferenceConstellation);
            end
            this.Specification.updateInputDataInfo(varargin{:});
            setupImpl@matlabshared.scopes.WebScopeSystem(this,varargin{:});
        end

        function updateImpl(this,varargin)
            if(this.ScopeLocked&&this.Specification.IsDataTypeChanged(varargin{:}))

                for idx=1:numel(varargin)
                    varargin{idx}=complex(varargin{idx});
                end
            end
            this.ScopeLocked=true;
            this.Specification.ActualData=varargin{:};
            [this.MaxFrameSize,dim]=cellfun(@size,varargin);
            this.MaxFrameSize=max([this.MaxFrameSize,dim]);
            updateImpl@matlabshared.scopes.WebScopeSystem(this,varargin{:});
            this.LastWriteTime=tic;
        end

        function value=getFilterImpls(~)
            value={'webscope_datastorage_filter','CD_transform_filter','CD_measurements_data_filter'};
        end

        function value=getDataProcessingStrategy(~)
            value='CD_data_trajectory_strategy';
        end

        function optionList=addFilterProperties(this,optionList)
            optionList.showTrajectory=this.ShowTrajectory;
            optionList.samplesPerSymbol=int32(this.SamplesPerSymbol);
            optionList.sampleOffset=int32(this.SampleOffset);
            optionList.symbolsToDisplay=int32(this.SymbolsToDisplay);
            optionList.symbolsToDisplaySource=this.Specification.getUISymbolsToDisplaySourceValue();

            if ischar(this.MeasurementInterval)||isstring(this.MeasurementInterval)
                optionList.measurementInterval=convertCharsToStrings(this.MeasurementInterval);
            else
                optionList.measurementInterval=int2str(this.MeasurementInterval);
            end
            optionList.evmNormalization=this.EVMNormalization;
            [updateReferenceConstelaltion,updateRefNumRows]=this.Specification.getReferenceConstellation();
            optionList.referenceConstellation=updateReferenceConstelaltion;
            optionList.refNumRows=updateRefNumRows;
            optionList.enableMeasurements=this.EnableMeasurements;
            optionList.measurementChannel=int32(0);
            optionList.measurementSignal=int32(0);
            optionList.startID=int32(zeros(this.NumInputPorts,1))';
            optionList.endID=int32(zeros(this.NumInputPorts,1))';
        end


        function resetImpl(this)





            if(this.ScopeLocked)
                resetImpl@matlabshared.scopes.WebScopeSystem(this);
                this.MessageHandler.reset();
            end
        end


        function validateInputsImpl(obj,varargin)

            channels=varargin{:};

            if~ismatrix(channels)
                obj.error(...
                'MATLAB:system:inputDimsMoreThanTwo',class(obj));
            end
            numChannels=sum(cellfun(@(x)size(x,2),varargin));
            if numChannels>obj.ChannLim
                obj.error(...
                'comm:ConstellationDiagramWebScope:TooManyInputChannels',obj.ChannLim);
            end
            obj.Specification.NumChannels=numChannels;
            if(obj.SamplesPerSymbol<=obj.SampleOffset)
                obj.error('comm:ConstellationDiagramWebScope:InvalidSamplesPerSymbol');
            end
            obj.checkSamplesVsSymbols(varargin{:});
        end
        function options=addStreamingOptions(~,options)


            options.bufferLength=Inf;
        end
        function S=saveObjectImpl(obj)
            S=saveObjectImpl@matlabshared.scopes.WebWindowSystemScope(obj);
            S.Name=obj.Name;
            S.Visible=obj.isVisible;
            S.Position=obj.Position;
            S.class=class(obj);
            S.MessageHandler=obj.MessageHandler.toStruct();
            S.Specification=obj.Specification.toStruct();
            S.Style=obj.Specification.Style.toStruct();
            S.HideCalled=obj.HideCalled;

            S.Visible=obj.isVisible;
            S.NumInputPorts=obj.NumInputPorts;
        end

        function loadObjectImpl(obj,S_load,wasLocked)
            if isfield(S_load,'MessageHandler')
                S=S_load;
            else
                S.class=comm.ConstellationDiagram;
                if isfield(S_load,'ScopeConfiguration')
                    cfg.ScopeConfig=S_load.ScopeConfiguration.CurrentConfiguration.findChild('Type','Visuals').PropertySet;
                    cfg.Position=S_load.ScopeConfiguration.Position;
                    if(cfg.Position(1,3)==460&&cfg.Position(1,4)==460)
                        cfg.Position=uiscopes.getDefaultPosition([600,600]);
                    end
                    cfg.Name=S_load.Name;
                    cfg.Visible=S_load.Visible;
                    cfg.NumInputPorts=S_load.NumInputPorts;
                else
                    cfg.ScopeConfig=[];
                    cfg.Name='';
                    cfg.Visible=false;
                    cfg.NumInputPorts=1;
                    cfg.Position=uiscopes.getDefaultPosition([600,600]);
                end
                scopeCfg=cfg.ScopeConfig;
                S.isPhaseOffset=any(strcmp(scopeCfg.PropertyNames,'PhaseOffset'));
                propNames=intersect(cfg.ScopeConfig.PropertyNames,...
                comm.webscopes.ConstellationDiagram.getValidPropNames);
                legacyPropNames=setdiff(cfg.ScopeConfig.PropertyNames,propNames);


                for idx=1:numel(propNames)
                    propName=propNames{idx};
                    if strcmpi(propName,'ReferenceConstellation')
                        [refCon,~,~]=uiservices.evaluate(scopeCfg.getValue(propNames{idx}));
                        if isempty(refCon)
                            S.Specification.(propNames{idx})=scopeCfg.getValue(propNames{idx});
                        else
                            S.Specification.(propNames{idx})=refCon;
                        end
                        S.AveragePower=1;
                        S.PhaseOffset=pi/8;
                        S.ConstellationNormalization='AveragePower';
                        S.MinDistance=2;
                        S.PeakPower=1;
                    elseif strcmpi(propName,'ReferenceMarker')
                        [refMarker,~,~]=uiservices.evaluate(scopeCfg.getValue(propNames{idx}));
                        if isempty(refMarker)
                            S.Specification.(propNames{idx})=scopeCfg.getValue(propNames{idx});
                        else
                            S.Specification.(propNames{idx})=refMarker;
                        end
                    elseif strcmpi(propName,'ReferenceColor')
                        [refColor,~,~]=uiservices.evaluate(scopeCfg.getValue(propNames{idx}));
                        S.Specification.(propNames{idx})=refColor;
                    elseif any(strcmpi(propName,{'SamplesPerSymbol','SampleOffset','SymbolsToDisplay'}))
                        S.Specification.(propNames{idx})=str2double(scopeCfg.getValue(propNames{idx}));
                    else
                        S.Specification.(propNames{idx})=scopeCfg.getValue(propNames{idx});
                    end
                end
                S.Specification.ShowReferenceConstellation=1;
                for idx=1:numel(legacyPropNames)
                    S.Specification.XLimits=[-1.375,1.375];
                    S.Specification.YLimits=[-1.375,1.375];
                    propName=legacyPropNames{idx};
                    switch propName
                    case 'MinYLim'
                        S.Specification.YLimits(1)=str2double(scopeCfg.getValue("MinYLim"));
                    case 'MaxYLim'
                        S.Specification.YLimits(2)=str2double(scopeCfg.getValue("MaxYLim"));
                    case 'MinXLim'
                        S.Specification.XLimits(1)=str2double(scopeCfg.getValue("MinXLim"));
                    case 'MaxXLim'
                        S.Specification.XLimits(2)=str2double(scopeCfg.getValue("MaxXLim"));
                    case 'Legend'
                        S.Specification.ShowLegend=scopeCfg.getValue(legacyPropNames{idx});
                    case 'Trajectory'
                        S.Specification.ShowTrajectory=scopeCfg.getValue("Trajectory");
                    case 'Grid'
                        S.Specification.ShowGrid=scopeCfg.getValue("Grid");
                    case 'SymbolsToDisplayFromInput'
                        S.Specification.SymbolsToDisplaySource=scopeCfg.getValue("SymbolsToDisplayFromInput");
                    case 'LastShowRefConstellation'
                        S.Specification.ShowReferenceConstellation=scopeCfg.getValue("LastShowRefConstellation");
                    case 'ShowRefConstellation'
                        S.Specification.ShowReferenceConstellation=logical(scopeCfg.getValue("ShowRefConstellation"));
                    case 'MeasurementMode'
                        S.Specification.EnableMeasurements=scopeCfg.getValue("MeasurementMode");
                    case 'AveragePower'
                        [avgPower,~,~]=uiservices.evaluate(scopeCfg.getValue("AveragePower"));
                        if isempty(avgPower)
                            S.AveragePower=scopeCfg.getValue("AveragePower");
                        else
                            S.AveragePower=avgPower;
                        end
                    case 'PhaseOffset'
                        [phOffset,~,~]=uiservices.evaluate(scopeCfg.getValue("PhaseOffset"));
                        if isempty(phOffset)
                            S.PhaseOffset=scopeCfg.getValue("PhaseOffset");
                        else
                            S.PhaseOffset=phOffset;
                        end
                    case 'ConstellationNormalization'
                        [constellationNorm,~,~]=uiservices.evaluate(scopeCfg.getValue("ConstellationNormalization"));
                        if isempty(constellationNorm)
                            S.ConstellationNormalization=scopeCfg.getValue("ConstellationNormalization");
                        else
                            S.ConstellationNormalization=constellationNorm;
                        end
                    case 'MinDistance'
                        [minD,~,~]=uiservices.evaluate(scopeCfg.getValue("MinDistance"));
                        if isempty(minD)
                            S.MinDistance=scopeCfg.getValue("MinDistance");
                        else
                            S.MinDistance=minD;
                        end
                    case 'PeakPower'
                        [pkPower,~,~]=uiservices.evaluate(scopeCfg.getValue("PeakPower"));
                        if isempty(pkPower)
                            S.PeakPower=scopeCfg.getValue("PeakPower");
                        else
                            S.PeakPower=pkPower;
                        end
                    end
                end

                if isfield(S.Specification,"ReferenceConstellation")
                    S.Specification.ReferenceConstellation=comm.webscopes.ConstellationDiagram.calcReferenceConstellation(S);
                end

                S.Specification.NumInputPorts=cfg.NumInputPorts;
                S.NumInputPorts=cfg.NumInputPorts;

                S.Visible=utils.onOffToLogical(cfg.Visible);

                S.Name=cfg.Name;

                S.Position=cfg.Position;

                S.MessageHandler.GraphicalSettings=[];
                S.MessageHandler.ClientSettings=[];
                S.MessageHandler.CallMethodCache={};
                S.MessageHandler.InputIds=cellstr(matlab.lang.internal.uuid(1,S.Specification.NumInputPorts));
                S.MessageHandler.GraphicalSettingsStale=false;
                S.MessageHandler.ClientSettingsStale=false;
            end
            loadObjectImpl@matlabshared.scopes.WebWindowSystemScope(obj,S,wasLocked);
            obj.Name=S.Name;

            obj.Position=S.Position;
            obj.NumInputPorts=S.NumInputPorts;
            obj.MessageHandler.fromStruct(S.MessageHandler);
            obj.Specification.fromStruct(S.Specification);
            if(isfield(S,'Style'))
                obj.Specification.Style.fromStruct(S.Style);
            end

            if S.Visible
                obj.show;
            end
        end
        function releaseImpl(this)
            this.ScopeLocked=false;
            releaseImpl@matlabshared.scopes.WebScopeSystem(this);
            matlabshared.application.waitfor(this.MessageHandler,'StopComplete',true,'Timeout',10);
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'SymbolsToDisplay'
                flag=~strcmp(obj.SymbolsToDisplaySource,'Property');
            case{'ReferenceConstellation','ReferenceColor','ReferenceMarker'}
                flag=~obj.ShowReferenceConstellation;
            case{'MeasurementInterval','EVMNormalization'}
                flag=~obj.EnableMeasurements;
            end
        end

    end



    methods(Static,Hidden)


        function error(id,varargin)
            ME=MException(message(id,varargin{:}));
            throwAsCaller(ME);
        end

        function fevalHandler(action,clientId,varargin)
            import dsp.webscopes.internal.*;
            switch action
            case 'showHelp'
                mapFileLocation=fullfile(docroot,'toolbox','comm','comm.map');
                helpview(mapFileLocation,varargin{1});
            case 'copyDisplay'
                BaseWebScope.copyDisplay(clientId,varargin{1});
            case 'printDisplay'
                BaseWebScope.printDisplay(clientId,varargin{1});
            case 'printPreviewDisplay'
                comm.webscopes.ConstellationDiagram.printPreviewDisplay(clientId);
            case 'logMessage'
                fprintf('%s\n',varargin{1});
            end
        end

        function propNames=getValidPropNames(~)


            propNames={'SamplesPerSymbol',...
            'SampleOffset',...
            'SymbolsToDisplaySource',...
            'SymbolsToDisplay',...
            'ReferenceConstellation',...
            'ReferenceMarker',...
            'ReferenceColor',...
            'ShowReferenceConstellation',...
            'EnableMeasurements',...
            'MeasurementInterval',...
            'EVMNormalization',...
            'NumInputPorts',...
            'PlotType',...
            'ShowTrajectory',...
            'ShowTicks',...
            'ColorFading',...
            'Title',...
            'XLabel',...
            'YLabel',...
            'YLimits',...
            'XLimits',...
            'ShowGrid',...
            'ShowLegend',...
            'ChannelNames'};
        end

        function refCon=calcReferenceConstellation(S)

            if~iscell(S.Specification.ReferenceConstellation)
                inputRefCon={S.Specification.ReferenceConstellation};
            else
                inputRefCon=S.Specification.ReferenceConstellation;
            end
            refCon=cell(size(inputRefCon));
            errID=cell(size(inputRefCon));
            for idx=1:numel(inputRefCon)
                currentInputRefCon=inputRefCon{idx};
                cdMessageHandler=comm.webscopes.internal.ConstellationDiagramMessageHandler;
                if cdMessageHandler.refConIsPreset(cdMessageHandler,currentInputRefCon)

                    if iscell(S.AveragePower)&&numel(S.AveragePower)>=idx
                        refConPower=S.AveragePower{idx};
                    else
                        refConPower=S.AveragePower;
                    end
                    if ischar(refConPower)
                        [refConPower,currentErrID]=uiservices.evaluate(refConPower);
                        if~isempty(currentErrID)
                            refConPower=S.AveragePower;
                        end
                    end

                    if iscell(S.PhaseOffset)&&numel(S.PhaseOffset)>=idx
                        refConOffset=S.PhaseOffset{idx};
                    else
                        refConOffset=S.PhaseOffset;
                    end
                    if ischar(refConOffset)
                        [refConOffset,currentErrID]=uiservices.evaluate(refConOffset);
                        if~isempty(currentErrID)
                            refConOffset=S.PhaseOffset;
                        end
                    end

                    if any(strcmp(currentInputRefCon,{'BPSK',getString(message('comm:ConstellationVisual:BPSK'))}))


                        refCon(idx)={refConPower*constellation(comm.BPSKModulator('PhaseOffset',refConOffset)).'};

                    elseif any(strcmp(currentInputRefCon,{'QPSK',getString(message('comm:ConstellationVisual:QPSK'))}))
                        if(~S.isPhaseOffset)
                            refConOffset=pi/4;
                        end

                        refCon(idx)={refConPower*constellation(comm.QPSKModulator('PhaseOffset',refConOffset)).'};

                    elseif any(strcmp(currentInputRefCon,{'8-PSK',getString(message('comm:ConstellationVisual:PSK8'))}))
                        if(~S.isPhaseOffset)
                            refConOffset=pi/8;
                        end

                        refCon(idx)={refConPower*constellation(comm.PSKModulator('PhaseOffset',refConOffset)).'};

                    else
                        if any(strcmp(currentInputRefCon,{'16-QAM',getString(message('comm:ConstellationVisual:QAM16'))}))

                            modulationOrder=16;
                        elseif any(strcmp(currentInputRefCon,{'64-QAM',getString(message('comm:ConstellationVisual:QAM64'))}))

                            modulationOrder=64;
                        elseif any(strcmp(currentInputRefCon,{'256-QAM',getString(message('comm:ConstellationVisual:QAM256'))}))

                            modulationOrder=256;
                        end

                        if iscell(S.ConstellationNormalization)&&numel(S.ConstellationNormalization)>=idx
                            normalizationMethod=S.ConstellationNormalization{idx};
                        else
                            normalizationMethod=S.ConstellationNormalization;
                        end
                        if strcmp(normalizationMethod,'MinDistance')
                            if iscell(S.MinDistance)&&numel(S.MinDistance)>=idx
                                minDistance=S.MinDistance{idx};
                            else
                                minDistance=S.MinDistance;
                            end
                            if ischar(minDistance)
                                [minDistance,currentErrID]=uiservices.evaluate(minDistance);
                                if~isempty(currentErrID)
                                    minDistance=2;
                                end
                            end
                        elseif strcmp(normalizationMethod,'AveragePower')

                            minDistance=comm.internal.qam.minDistanceForAvgPower(refConPower,modulationOrder);

                        elseif strcmp(normalizationMethod,'PeakPower')

                            if iscell(S.PeakPower)&&numel(S.PeakPower)>=idx
                                peakPower=S.PeakPower{idx};
                            else
                                peakPower=S.PeakPower;
                            end
                            if ischar(peakPower)
                                [peakPower,currentErrID]=uiservices.evaluate(peakPower);
                                if~isempty(currentErrID)
                                    peakPower=1;
                                end
                            end
                            minDistance=comm.internal.qam.minDistanceForPeakPower(peakPower,modulationOrder);
                        end
                        refCon(idx)={(minDistance/2).*exp(1i*refConOffset).*qammod((0:modulationOrder-1),modulationOrder,'bin')};
                    end
                else

                    if isa(currentInputRefCon,'double')
                        currentRefCon=currentInputRefCon;
                        currenterrID='';
                    else
                        [currentRefCon,currentErrID]=uiservices.evaluate(currentInputRefCon);
                        if~isempty(currentErrID)
                            currentRefCon={[0.7071+0.7071i,-0.7071+0.7071i,-0.7071-0.7071i,0.7070-0.7071i]};
                        end
                    end
                    refCon{idx}=currentRefCon;
                    errID{idx}=currenterrID;
                end
            end
        end
    end



    methods(Static,Access=protected)
        function groups=getPropertyGroupsImpl
            main=matlab.system.display.Section(...
            'TitleSource','Auto',...
            'PropertyList',{'Name','ShowTrajectory','ShowReferenceConstellation','EnableMeasurements','NumInputPorts'});

            mainGroup=matlab.system.display.SectionGroup(...
            'TitleSource','Auto',...
            'Sections',main);

            symbolSection=matlab.system.display.Section(...
            'PropertyList',{'SamplesPerSymbol','SampleOffset','SymbolsToDisplaySource','SymbolsToDisplay'});

            symbolGroup=matlab.system.display.SectionGroup(...
            'Title',getString(message('comm:ConstellationDiagram:SymbolTitle')),...
            'Sections',symbolSection);
            symbolGroup.IncludeInShortDisplay=true;

            displaySection=matlab.system.display.Section(...
            'PropertyList',{'ColorFading','XLimits','YLimits','XLabel','YLabel','Title','ShowLegend','ChannelNames','ShowGrid','ShowTicks','Position'});

            displayGroup=matlab.system.display.SectionGroup(...
            'Title',getString(message('comm:ConstellationDiagram:DisplayTitle')),...
            'Sections',displaySection);

            measurementsSection=matlab.system.display.Section(...
            'PropertyList',{'MeasurementInterval','EVMNormalization'});

            measurementsGroup=matlab.system.display.SectionGroup(...
            'Title',getString(message('comm:ConstellationDiagram:MeasurementsTitle')),...
            'Sections',measurementsSection);

            refConstellationSection=matlab.system.display.Section(...
            'PropertyList',{'ReferenceConstellation','ReferenceColor','ReferenceMarker'});

            refConstellationGroup=matlab.system.display.SectionGroup(...
            'Title',getString(message('comm:ConstellationDiagram:RefConTitle')),...
            'Sections',refConstellationSection);

            groups=[mainGroup,symbolGroup,displayGroup,refConstellationGroup,measurementsGroup];
        end

        function printPreviewDisplay(clientId)
            import dsp.webscopes.internal.*;
            webWindow=BaseWebScope.getWebWindowFromClientID(clientId);
            if isempty(webWindow)
                return;
            end
            fig=comm.webscopes.ConstellationDiagram.prepareWebWindowForSharing(webWindow,'print');

            BaseWebScope.publishMessage(clientId,'onPrePrintPreview',true);
            if~comm.webscopes.ConstellationDiagram.isMATLABOnline()

                printpreview(fig);
            else

                desiredName='ConstellationDiagram';
                uniqueName=comm.webscopes.ConstellationDiagram.getUniqueFileName(desiredName);
                print(uniqueName,'-dpdf');
            end
            delete(fig);

            BaseWebScope.publishMessage(clientId,'onPostPrintPreview',true);
        end



        function fig=prepareWebWindowForSharing(webWindow,action)
            screenshot=flipud(getScreenshot(webWindow));
            pos=webWindow.Position;
            fig=figure(...
            'HandleVisibility',uiservices.logicalToOnOff(strcmpi(action,'copy')),...
            'Visible','off',...
            'Position',pos);
            a=axes(...
            'Parent',fig,...
            'Position',[0,0,1,1]);

            img=image(...
            'Parent',a,...
            'CData',screenshot);

            xLim=a.XLim;
            yLim=a.YLim;

            img.XData=[1,xLim(2)-1];
            img.YData=[1,yLim(2)-1];
        end


        function flag=isMATLABOnline(~)

            flag=matlab.internal.environment.context.isMATLABOnline||...
            matlab.ui.internal.desktop.isMOTW;
        end

        function uniqueName=getUniqueFileName(desiredName)


            dirPDFFiles=dir('./*.pdf');
            existingPDFNames={''};
            if~isempty(dirPDFFiles)
                existingPDFNames={dirPDFFiles.name};

                existingPDFNames=regexprep(existingPDFNames,'.pdf','');
            end
            uniqueName=matlab.lang.makeUniqueStrings(desiredName,existingPDFNames);
        end
    end



    methods(Access=private)

        function valid=isMarkerValid(obj,value)
            validMarkers=obj.ReferenceMarkerValues.getAllowedValues();
            valid=false;
            for i=1:length(validMarkers)
                if strcmp(value,validMarkers(i))
                    valid=true;
                    break;
                end
            end
        end
        function checkSamplesVsSymbols(obj,varargin)



            symbolsToDisplaySource=obj.Specification.getUISymbolsToDisplaySourceValue();
            sps=obj.Specification.SamplesPerSymbol;
            if symbolsToDisplaySource
                for idx=1:numel(varargin)
                    maxDims=size(varargin{idx});
                    ratio=maxDims(1)/sps;
                    if floor(ratio)~=ratio
                        obj.error('comm:ConstellationDiagramWebScope:FrameLengthNotDivisibleSysObj');
                        break;
                    end
                end
            end
        end
    end
end
