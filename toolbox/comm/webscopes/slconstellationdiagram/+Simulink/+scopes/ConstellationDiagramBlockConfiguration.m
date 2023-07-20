classdef ConstellationDiagramBlockConfiguration








    properties(AbortSet,Dependent)
Name
Position
NumInputPorts
SamplesPerSymbol
SampleOffset
SymbolsToDisplaySource
SymbolsToDisplay
ReferenceConstellation
ReferenceMarker
ReferenceColor
ShowReferenceConstellation
ShowGrid
ShowLegend
ChannelNames
ShowTrajectory
ColorFading
Title
XLimits
YLimits
XLabel
YLabel
EnableMeasurements
MeasurementInterval
EVMNormalization
MaximizeAxes

        OpenAtSimulationStart;

        Visible;
    end

    properties(AbortSet,Dependent,Hidden)

        FrameBasedProcessing;

ExpandToolstrip
    end

    properties(Access=private)

        BlockHandle=-1;
        DefaultRefConstellationValue=[0.7071+0.7071i,-0.7071+0.7071i,-0.7071-0.7071i,0.7070-0.7071i];
        pNumPorts=1;
    end

    properties(Hidden)
        currentReferenceConstellation={};
        tempClientID;
        MeasurementChannel=0;
        MeasurementSignal=0;
        MeasurementPortChannel=0;
    end

    properties(Constant,Hidden)
        EVMNormalizationSet={'Average constellation power','Peak constellation power'};
        ReferenceMarkerSet={'+','o','*','.','x','square','diamond',...
        'v','^','<','>','pentagram','hexagram'};
        SymbolsToDisplaySourceSet={'Input frame length','Property'};

        MaximizeAxesSet={'Auto','On','Off'};
        ChannLim=20;
    end



    properties(Hidden,Dependent)
        FigPos;
        figTitle;
        sampPerSymb;
        offsetEye;
        numTraces;
        numNewFrames;
        LineMarkers;
        LineColors;
        LineStyles;
        fading;
        AxisGrid;
        xMin;
        xMax;
        yMin;
        yMax;
        inphaseLabel;
        quadratureLabel;
        OpenScopeAtSimStart;

        IsCacheReferenceConstellation;
    end



    methods

        function this=ConstellationDiagramBlockConfiguration(blkHandle)
            this.BlockHandle=blkHandle;
        end


        function this=set.Name(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','Name');
            set_param(this.BlockHandle,'Name',value);
        end
        function value=get.Name(this)
            value=get_param(this.BlockHandle,'Name');
        end

        function this=set.Position(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','Position');
            set_param(this.BlockHandle,'WindowPosition',value);
        end
        function value=get.Position(this)
            value=str2num(get_param(this.BlockHandle,'WindowPosition'));%#ok<ST2NM>
            if isempty(value)


                value=utils.getDefaultWebWindowPosition([600,600]);
            end
        end


        function this=set.NumInputPorts(this,strValue)
            this.errorForNonTunableParam('NumInputPorts');
            [rvalue,errorID,errorStr]=evaluateVariable(this,strValue);
            if~isempty(errorID)
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'NumInputPorts',this.Name,errorStr);
                throwAsCaller(MException(msgObj));
            elseif~isnumeric(rvalue)
                errorStr=getString(message('comm:ConstellationVisual:InvalidVariableForNumberOfInputPorts',value));
                msgObj=message('Spcuilib:configuration:InvalidSetting',...
                'NumInputPorts',this.Name,errorStr);
                throwAsCaller(MException(msgObj));
            end
            validateattributes(rvalue,{'numeric'},{'real','finite','positive','scalar','>=',1,'<=',20},'','NumInputPorts');
            this.pNumPorts=rvalue;
            this.ReferenceConstellation=this.updateReferenceConstellaltionValues(this.ReferenceConstellation,rvalue);
            set_param(this.BlockHandle,'NumInputPorts',num2str(rvalue));
        end
        function value=get.NumInputPorts(this)
            value=get_param(this.BlockHandle,'NumInputPorts');
            if~isnumeric(value)
                try
                    value=num2str(utils.evaluate(value));
                catch
                end
            end
        end


        function this=set.SamplesPerSymbol(this,strValue)
            [value,variableUndefined]=evaluateString(this,strValue,'SamplesPerSymbol');
            if~variableUndefined


                validateattributes(value,...
                {'numeric'},{'integer','scalar'},'','SamplesPerSymbol');

                if value<=eval(this.SampleOffset)
                    error(message('comm:ConstellationVisual:InvalidSamplesPerSymbol'));
                end
            end
            set_param(this.BlockHandle,'SamplesPerSymbol',strValue);
        end
        function value=get.SamplesPerSymbol(this)
            value=get_param(this.BlockHandle,'SamplesPerSymbol');
            if~isnumeric(value)
                try
                    value=num2str(utils.evaluate(value));
                catch
                    try
                        value=num2str(this.evaluateString(value,'SamplesPerSymbol'));
                    catch
                    end
                end
            end
        end


        function this=set.SampleOffset(this,strValue)
            [value,variableUndefined]=evaluateString(this,strValue,'SampleOffset');
            if~variableUndefined


                validateattributes(value,...
                {'numeric'},{'integer','scalar','>=',0},'','SampleOffset');
                if value>=str2num(this.SamplesPerSymbol)
                    error(message('comm:ConstellationVisual:InvalidSampleOffset'));
                end
            end
            set_param(this.BlockHandle,'SampleOffset',strValue);
        end
        function value=get.SampleOffset(this)
            value=get_param(this.BlockHandle,'SampleOffset');
            if~isnumeric(value)
                try
                    value=num2str(utils.evaluate(value));
                catch
                    try
                        value=num2str(this.evaluateString(value,'SamplesPerSymbol'));
                    catch
                    end
                end
            end
        end


        function this=set.SymbolsToDisplaySource(this,strValue)
            value=convertStringsToChars(strValue);
            value=this.validateEnum(value,'SymbolsToDisplaySource',this.SymbolsToDisplaySourceSet);
            set_param(this.BlockHandle,'SymbolsToDisplaySource',value);
        end
        function value=get.SymbolsToDisplaySource(this)

            value=get_param(this.BlockHandle,'SymbolsToDisplaySource');
        end


        function this=set.SymbolsToDisplay(this,strValue)
            if strcmp(get_param(this.BlockHandle,'SymbolsToDisplaySource'),'Property')
                [value,variableUndefined]=evaluateString(this,strValue,'SymbolsToDisplay');
                if~variableUndefined
                    validateattributes(value,...
                    {'numeric'},{'integer','scalar','>',0},'','SymbolsToDisplay');
                end
                set_param(this.BlockHandle,'SymbolsToDisplay',strValue);
            else
                warning(message('MATLAB:system:nonRelevantProperty','SymbolsToDisplay'));
            end
        end
        function value=get.SymbolsToDisplay(this)
            value=get_param(this.BlockHandle,'SymbolsToDisplay');
            if~isnumeric(value)
                try
                    value=num2str(utils.evaluate(value));
                catch
                    try
                        value=num2str(this.evaluateString(value,'SamplesPerSymbol'));
                    catch
                    end
                end
            end
        end


        function this=set.ReferenceConstellation(this,strValue)
            if isempty(strValue)



                set_param(this.BlockHandle,'ReferenceConstellation',[]);
                return;
            end
            if(isstring(strValue)||ischar(strValue))
                set_param(this.BlockHandle,'ReferenceConstellation',strValue);
                value=strValue;
                this.IsCacheReferenceConstellation=false;
            else
                value=strValue;
                if~iscell(value)
                    tempValue={value};
                else
                    tempValue=value;
                end
                for idx=1:numel(tempValue)
                    try
                        if ischar(tempValue{idx})
                            [refValue,~,~]=uiservices.evaluate(tempValue{idx});
                            if iscell(refValue)
                                tempValue{idx}=refValue{:};
                            else
                                tempValue{idx}=refValue;
                            end
                        end
                        validateattributes(tempValue{idx},...
                        {'numeric'},{'finite','vector'},'','ReferenceConstellation');
                        tempValue{idx}=reshape(tempValue{idx},1,max(size(tempValue{idx})));
                    catch
                        msgthis=message(...
                        'comm:ConstellationDiagramBlock:InvalidReferenceConstellationDefined',get_param(this.BlockHandle,'Name'));
                        throwAsCaller(MException(msgthis));
                    end
                end
                try
                    value=cellfun(@num2str,tempValue,'un',0);
                    value=jsonencode(value);
                catch
                end
                if(numel(tempValue)>1)


                    value=regexprep(value,{'["','"]','","'},{'{[',']}',']['});
                else
                    value=regexprep(value,{'["','"]','","'},{'[',']',']['});
                end
                set_param(this.BlockHandle,'ReferenceConstellation',value);
                this.IsCacheReferenceConstellation=false;
            end
            if this.EnableMeasurements&&isempty(value)
                msgthis=message(...
                'comm:ConstellationDiagramWebScope:InvalidReferenceConstellation');
                throwAsCaller(MException(msgthis));
            end
        end
        function value=get.ReferenceConstellation(this)
            strVal=get_param(this.BlockHandle,'ReferenceConstellation');
            value=regexprep(strVal,...
            {',','''',']','[',' +','{','}',']['},{'','"','"]','["',',','[',']','],['});
            graSettings=get_param(this.BlockHandle,'Graphicalsettings');
            if~isempty(graSettings)&&numel(this.currentReferenceConstellation)==0
                jsonDecodegraSettings=jsondecode(graSettings);
                if isfield(jsonDecodegraSettings,'ReferenceConstellation')
                    this.currentReferenceConstellation=jsonDecodegraSettings.ReferenceConstellation;
                end
            end
            if this.IsCacheReferenceConstellation&&numel(this.currentReferenceConstellation)>0&&numel(this.currentReferenceConstellation)==str2double(this.NumInputPorts)
                refValue={};
                for idx=1:numel(this.currentReferenceConstellation)
                    if iscell(this.currentReferenceConstellation)
                        currentRefValue=this.currentReferenceConstellation{idx};
                    else
                        currentRefValue=this.currentReferenceConstellation(idx);
                    end
                    try
                        ref=comm.scopes.getActualRefCon('base',currentRefValue,this.tempClientID);
                    catch
                        if strcmpi(currentRefValue.ReferenceConstellation,'customReferenceConstellation')
                            ref=evaluateVariable(this,currentRefValue.RefConstellationValue);
                        end
                    end
                    if iscell(ref)
                        ref=cell2mat(ref);
                    end
                    refValue{idx}=ref;
                end
                if length(refValue)==1
                    value=refValue{1};
                else
                    value=refValue;
                end
            elseif(contains(value,["PSK","QAM"],"IgnoreCase",true))
                strVal=convertStringsToChars(strVal);
                value=Simulink.scopes.getActualRefConFromPreset(['{''',strVal,'''}'],"none","none","none","none","none",false);
            else

                try
                    value=jsondecode(value).';
                    if~iscellstr(value)&&iscell(value)
                        value=cellfun(@cell2mat,value,'un',0);
                    end
                    tempValue=cellfun(@str2num,value,'un',0);
                    if(iscell(tempValue)&&isempty(tempValue{1})||isempty(tempValue))
                        throw(MException('',''))
                    end
                    value=cellfun(@str2num,value,'un',0);


                    this.pNumPorts=str2double(this.NumInputPorts);
                    [ref,isNumRefChanged]=this.updateReferenceConstellaltionValues(value,this.pNumPorts);
                    if(isNumRefChanged)
                        this.ReferenceConstellation=ref;
                    end
                    value=this.ReferenceConstellation;
                    if(iscell(value)&&isempty(value{1})||isempty(value))
                        throw(MException('',''))
                    end
                catch ex
                    if ischar(value)
                        [strvalue,~]=evaluateString(this,value,'ReferenceConstellation');
                        if isempty(strvalue)
                            [strvalue,~]=evaluateString(this,strVal,'ReferenceConstellation');
                        end
                        if~isempty(strvalue)



                            this.pNumPorts=str2double(this.NumInputPorts);
                            value=this.updateReferenceConstellaltionValues(strvalue,this.pNumPorts);
                        end
                    elseif(iscell(value)&&isempty(value{1})||isempty(value))&&ischar(strVal)
                        [strvalue,~]=evaluateString(this,strVal,'ReferenceConstellation');
                        if~isempty(strvalue)



                            this.pNumPorts=str2double(this.NumInputPorts);
                            value=this.updateReferenceConstellaltionValues(strvalue,this.pNumPorts);
                        end
                    end
                end
                if length(value)==1

                    value=value{1};
                end
            end
        end


        function this=set.ReferenceMarker(this,value)
            if~isempty(value)
                if~iscell(value)
                    value=cellstr(value);
                end
                for idx=1:numel(value)
                    validateattributes(value{idx},{'char'},{},'','ReferenceMarker');
                    value{idx}=this.validateEnum(value{idx},'ReferenceMarker',this.ReferenceMarkerSet);
                end
                if(numel(value)>1)
                    try
                        value=jsonencode(value);
                        value=regexprep(value,{'["','"]'},{'{"','"}'});
                    catch
                    end
                else
                    value=value{1};
                end
                set_param(this.BlockHandle,'ReferenceMarker',value);
            end
        end
        function value=get.ReferenceMarker(this)
            value=regexprep(get_param(this.BlockHandle,'ReferenceMarker'),...
            {'''''','{','}'},{'"','[',']'});

            try
                value=jsondecode(value).';
            catch
            end
            if iscell(value)&&length(value)==1

                value=value{1};
            end
        end


        function this=set.ReferenceColor(this,value)
            if~isempty(value)
                retrivedValue=cell(1,0);
                if(isstring(value)||ischar(value))
                    [retrivedValue,~]=evaluateString(this,value,'ReferenceColor');
                end
                if isempty(retrivedValue)
                    retrivedValue=value;
                end
                if~iscell(retrivedValue)
                    retrivedValue={retrivedValue};
                end
                for idx=1:numel(retrivedValue)
                    validateattributes(retrivedValue{idx},...
                    {'numeric'},{'>=',0,'<=',1,'size',[1,3]},'','ReferenceColor');
                    retrivedValue{idx}=reshape(retrivedValue{idx},1,max(size(retrivedValue{idx})));
                end
                try
                    value=cellfun(@num2str,retrivedValue,'un',0);
                    value=jsonencode(value);
                catch
                end
                if(numel(retrivedValue)>1)
                    value=regexprep(value,{'["','"]','","'},{'{[',']}','],['});
                else
                    value=regexprep(value,{'["','"]','","'},{'[',']','],['});
                end
                set_param(this.BlockHandle,'ReferenceColor',value);
            end
        end
        function value=get.ReferenceColor(this)
            value=regexprep(get_param(this.BlockHandle,'ReferenceColor'),...
            {',','''',']','[',' +','{','}',']['},{'','"','"]','["',',','[',']','],['});

            try
                value=jsondecode(value).';
                if iscell(value)&&~iscellstr(value)
                    value=cellfun(@cell2mat,value,'un',0);
                end
                value=cellfun(@str2num,value,'un',0);
            catch
            end
            if length(value)==1

                value=value{1};
            end
        end


        function this=set.ShowReferenceConstellation(this,value)
            validateattributes(value,{'logical','numeric'},{},'','ShowReferenceConstellation');
            set_param(this.BlockHandle,...
            'ShowReferenceConstellation',utils.logicalToOnOff(value));
        end
        function value=get.ShowReferenceConstellation(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'ShowReferenceConstellation'));
        end


        function this=set.ShowTrajectory(this,value)
            validateattributes(value,{'logical','numeric'},{},'','ShowTrajectory');
            set_param(this.BlockHandle,'ShowTrajectory',utils.logicalToOnOff(value));
        end
        function value=get.ShowTrajectory(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'ShowTrajectory'));
        end


        function this=set.ShowGrid(this,value)
            validateattributes(value,{'logical','numeric'},{},'','ShowGrid');
            set_param(this.BlockHandle,'ShowGrid',utils.logicalToOnOff(value));
        end
        function value=get.ShowGrid(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'ShowGrid'));
        end


        function this=set.ShowLegend(this,value)
            validateattributes(value,{'logical','numeric'},{},'','ShowLegend');
            set_param(this.BlockHandle,'ShowLegend',utils.logicalToOnOff(value));
        end
        function value=get.ShowLegend(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'ShowLegend'));
        end


        function this=set.ChannelNames(this,value)
            if~iscell(value)||(~isempty(value)&&(~isvector(value)||~iscellstr(cellstr(value))))
                throwAsCaller(MException(message('comm:ConstellationDiagramWebScope:InvalidChannelNames')));
            end
            try
                value=jsonencode(value);
            catch
            end
            set_param(this.BlockHandle,'ChannelNames',regexprep(value,{'["','"]'},{'{"','"}'}));
        end
        function value=get.ChannelNames(this)


            value=regexprep(get_param(this.BlockHandle,'ChannelNames'),...
            {'''','{"','"}'},{'"','["','"]'});

            try
                value=jsondecode(value).';
            catch
            end
            if isempty(value)

                value={''};
            end
        end

        function this=set.ColorFading(this,value)
            validateattributes(value,{'logical','double'},{},'','ColorFading');
            if isnumeric(value)
                value=value>0;
            end
            set_param(this.BlockHandle,'ColorFading',utils.logicalToOnOff(value));
        end
        function value=get.ColorFading(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'ColorFading'));
        end



        function this=set.Title(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','Title');
            set_param(this.BlockHandle,'Title',value);
        end
        function value=get.Title(this)
            value=get_param(this.BlockHandle,'Title');
        end


        function this=set.XLabel(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','XLabel');
            set_param(this.BlockHandle,'XLabel',value);
        end
        function value=get.XLabel(this)
            value=get_param(this.BlockHandle,'XLabel');
        end


        function this=set.YLabel(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','YLabel');
            set_param(this.BlockHandle,'YLabel',value);
        end
        function value=get.YLabel(this)
            value=get_param(this.BlockHandle,'YLabel');
        end


        function this=set.XLimits(this,value)
            if~all(isnumeric(value))||~all(isfinite(value))||...
                numel(value)~=2||value(1)>=value(2)
                msgthis=message('comm:ConstellationDiagramWebScope:InvalidXYLimits','XLimits');
                throwAsCaller(MException(msgthis));
            end
            set_param(this.BlockHandle,'XLimits',['[',num2str(value(1)),',',num2str(value(2)),']']);
        end
        function value=get.XLimits(this)
            value=str2num(get_param(this.BlockHandle,'XLimits'));%#ok<ST2NM>
        end


        function this=set.YLimits(this,value)
            if~all(isnumeric(value))||~all(isfinite(value))||...
                numel(value)~=2||value(1)>=value(2)
                msgthis=message('comm:ConstellationDiagramWebScope:InvalidXYLimits','YLimits');
                throwAsCaller(MException(msgthis));
            end
            set_param(this.BlockHandle,'YLimits',['[',num2str(value(1)),',',num2str(value(2)),']']);
        end
        function value=get.YLimits(this)
            value=str2num(get_param(this.BlockHandle,'YLimits'));%#ok<ST2NM>
        end


        function this=set.EnableMeasurements(this,value)
            validateattributes(value,{'logical','double'},...
            {'scalar','real'},'','EnableMeasurements');
            if isnumeric(value)
                value=value>0;
            end

            set_param(this.BlockHandle,'EnableMeasurements',utils.logicalToOnOff(value));
        end
        function value=get.EnableMeasurements(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'EnableMeasurements'));
        end


        function this=set.MeasurementInterval(this,strValue)
            if isnan(str2double(strValue))&&comm.internal.utilities.isCharOrStringScalar(strValue)
                str=validatestring(strValue,{'All displays','Current display'});

                set_param(this.BlockHandle,'MeasurementInterval',str);

            else
                [value,variableUndefined]=evaluateString(this,strValue,'MeasurementInterval');
                if~variableUndefined
                    validateattributes(value,...
                    {'numeric'},{'nonnan','integer','scalar','>',0},...
                    '','MeasurementInterval');
                end
                set_param(this.BlockHandle,'MeasurementInterval',strValue);
            end
        end
        function value=get.MeasurementInterval(this)
            value=get_param(this.BlockHandle,'MeasurementInterval');
            if isempty(value)
                value=[];
            elseif~any(strcmp(value,{'Current display','All displays'}))
                if~isnumeric(value)
                    try
                        value=num2str(utils.evaluate(value));
                    catch
                        try
                            value=num2str(this.evaluateString(value,'MeasurementInterval'));
                        catch
                        end
                    end
                end
            end
        end


        function this=set.EVMNormalization(this,strValue)
            value=convertStringsToChars(strValue);
            value=this.validateEnum(value,'EVMNormalization',this.EVMNormalizationSet);
            set_param(this.BlockHandle,'EVMNormalization',value);








            set_param(this.BlockHandle,'EVMNormalization',value);
        end
        function value=get.EVMNormalization(this)
            value=get_param(this.BlockHandle,'EVMNormalization');





        end


        function this=set.MaximizeAxes(this,value)
            value=convertStringsToChars(value);
            value=this.validateEnum(value,'MaximizeAxes',this.MaximizeAxesSet);
            set_param(this.BlockHandle,'MaximizeAxes',value);
        end
        function value=get.MaximizeAxes(this)
            value=get_param(this.BlockHandle,'MaximizeAxes');
        end


        function this=set.OpenAtSimulationStart(this,value)
            validateattributes(value,{'logical','numeric'},{},'','OpenAtSimulationStart');
            set_param(this.BlockHandle,'OpenAtSimulationStart',utils.logicalToOnOff(value));
        end
        function value=get.OpenAtSimulationStart(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'OpenAtSimulationStart'));
        end


        function this=set.Visible(this,value)
            validateattributes(value,{'logical','numeric'},{},'','Visible');
            set_param(this.BlockHandle,'Visible',utils.logicalToOnOff(value));
        end
        function value=get.Visible(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'Visible'));
        end


        function this=set.FrameBasedProcessing(this,value)
            validateattributes(value,{'logical','numeric'},{},'','FrameBasedProcessing');
            set_param(this.BlockHandle,'FrameBasedProcessing',utils.logicalToOnOff(value));
        end
        function value=get.FrameBasedProcessing(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'FrameBasedProcessing'));
        end


        function this=set.ExpandToolstrip(this,value)
            validateattributes(value,{'logical','numeric'},{},'','ExpandToolstrip');
            set_param(this.BlockHandle,'ExpandToolstrip',utils.logicalToOnOff(value));
        end
        function value=get.ExpandToolstrip(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'ExpandToolstrip'));
        end


        function this=set.IsCacheReferenceConstellation(this,value)
            validateattributes(value,{'logical','numeric'},{},'','IsCacheReferenceConstellation');
            set_param(this.BlockHandle,'IsCacheReferenceConstellation',utils.logicalToOnOff(value));
        end
        function value=get.IsCacheReferenceConstellation(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'IsCacheReferenceConstellation'));
        end


        function value=get.MeasurementPortChannel(this)
            value=get_param(this.BlockHandle,'MeasurementPortChannel');
            value=str2double(value);
        end


        function value=get.MeasurementSignal(this)
            value=get_param(this.BlockHandle,'MeasurementSignal');
            value=str2double(value);
        end


        function value=get.MeasurementChannel(this)
            value=get_param(this.BlockHandle,'MeasurementChannel');
            value=str2double(value);
        end




        function setScopeParameter(obj,propertyName,value)
            if comm.internal.utilities.isCharOrStringScalar(value)
                datatype='string';
            elseif isnumeric(value)
                value=mat2str(value);
                datatype='string';
            elseif iscell(value)
                datatype='cell';
            elseif isstruct(value)
                datatype='struct';
            else
                datatype='bool';
            end
            set_param(obj.BlockHandle,propertyName,value);
        end

        function value=getParameter(obj,parameterName)
            value=get_param(obj.BlockHandle,parameterName);
        end

        function obj=set.FigPos(obj,strValue)

            ind=strfind(strValue,'%');
            if~isempty(ind)
                strValue=strValue(1:ind-1);
            end
            pos=obj.evaluateVariable(strValue);



            length=min(pos(3),pos(4));
            pos(3)=length;
            pos(4)=length;
            obj.Position=pos;


            obj.ShowReferenceConstellation=false;
        end

        function value=get.FigPos(obj)
            value=sprintf('[%s]',num2str(obj.Position));
            value=strrep(value,'  ',' ');
        end

        function obj=set.figTitle(obj,strValue)
            value=convertStringsToChars(strValue);
            validateattributes(value,{'char'},{},'','Title');
            set_param(this.BlockHandle,'Title',value);
        end

        function value=get.figTitle(obj)
            value=getParameter(obj,'figTitle');
        end

        function obj=set.sampPerSymb(obj,strValue)
            setScopeParameter(obj,'SamplesPerSymbol',strValue);
        end

        function value=get.sampPerSymb(obj)
            value=getParameter(obj,'SamplesPerSymbol');
        end

        function obj=set.offsetEye(obj,strValue)
            setScopeParameter(obj,'SampleOffset',strValue);
        end

        function value=get.offsetEye(obj)
            value=getParameter(obj,'SampleOffset');
        end

        function obj=set.numTraces(obj,strValue)

            setScopeParameter(obj,'SymbolsToDisplaySource','Property');
            setScopeParameter(obj,'SymbolsToDisplay',strValue);
        end

        function value=get.numTraces(obj)
            value=getParameter(obj,'SymbolsToDisplay');
        end

        function obj=set.numNewFrames(obj,value)%#ok<INUSD>

        end

        function value=get.numNewFrames(obj)%#ok<MANU>
            value='';
        end

        function obj=set.LineMarkers(obj,strValue)
            setScopeParameter(obj,'Marker',strValue);
        end

        function value=get.LineMarkers(obj)
            value=getParameter(obj,'Marker');
        end

        function obj=set.LineColors(obj,strValue)
            setScopeParameter(obj,'LineColor',strValue);
        end

        function value=get.LineColors(obj)
            value=getParameter(obj,'LineColor');
        end

        function obj=set.LineStyles(obj,strValue)
            setScopeParameter(obj,'LineStyle',strValue);
        end

        function value=get.LineStyles(obj)
            value=getParameter(obj,'LineStyle');
        end

        function obj=set.fading(obj,strValue)
            if strcmp(strValue,'on')
                setScopeParameter(obj,'ColorFading',true);
            else
                setScopeParameter(obj,'ColorFading',false);
            end
        end

        function value=get.fading(obj)
            if getParameter(obj,'ColorFading')
                value='on';
            else
                value='off';
            end
        end

        function obj=set.AxisGrid(obj,strValue)
            if strcmp(strValue,'on')
                setScopeParameter(obj,'ShowGrid',true);
            else
                setScopeParameter(obj,'ShowGrid',false);
            end
        end

        function value=get.AxisGrid(obj)
            if getParameter(obj,'ShowGrid')
                value='on';
            else
                value='off';
            end
        end

        function obj=set.xMin(obj,strValue)
            setScopeParameter(obj,'MinXLim',strValue);
        end

        function value=get.xMin(obj)
            value=getParameter(obj,'MinXLim');
        end

        function obj=set.xMax(obj,strValue)
            setScopeParameter(obj,'MaxXLim',strValue);
        end

        function value=get.xMax(obj)
            value=getParameter(obj,'MaxXLim');
        end

        function obj=set.yMin(obj,strValue)
            setScopeParameter(obj,'MinYLim',strValue);
        end

        function value=get.yMin(obj)
            value=getParameter(obj,'MinYLim');
        end

        function obj=set.yMax(obj,strValue)
            setScopeParameter(obj,'MaxYLim',strValue);
        end

        function value=get.yMax(obj)
            value=getParameter(obj,'MaxYLim');
        end

        function obj=set.inphaseLabel(obj,strValue)
            setScopeParameter(obj,'XLabel',strValue);
        end

        function value=get.inphaseLabel(obj)
            value=getParameter(obj,'XLabel');
        end

        function obj=set.quadratureLabel(obj,strValue)
            setScopeParameter(obj,'YLabel',strValue);
        end

        function value=get.quadratureLabel(obj)
            value=getParameter(obj,'YLabel');
        end
    end



    methods(Access=private)

        function b=isSimulationRunning(this)

            simstatus=get_param(bdroot(this.BlockHandle),'SimulationStatus');
            b=~any(strcmpi(simstatus,{'stopped','initializing'}));
        end

        function name=getBlockName(this)
            blockObj=get_param(this.BlockHandle,'Object');
            name=blockObj.getFullName;
        end

        function[value,errorID,errorMessage]=evaluateVariable(this,variableName)






            try
                value=slResolve(variableName,bdroot(getBlockName(this)));
                errorID='';
                errorMessage='';
            catch ME %#ok<NASGU>
                try
                    value=slResolve(variableName,getBlockName(this));
                    errorID='';
                    errorMessage='';
                catch ME1
                    if ischar(variableName)||(isstring(variableName)&&isscalar(variableName))
                        [value,errorID,errorMessage]=utils.evaluate(variableName);
                    else
                        value=variableName;
                        errorID=ME1.identifier;
                        errorMessage=ME1.message;
                    end
                end
            end
        end

        function[value,errorOccured]=evaluateString(this,strValue,propName)
            validateattributes(strValue,{'char'},{},'',propName);
            errorOccured=false;
            isSourceRunning=this.isSimulationRunning;
            [value,~,errStr]=this.evaluateVariable(strValue);
            if~isempty(errStr)
                errorOccured=true;
                if isSourceRunning



                    [errStr,errId]=utils.message('EvaluateUndefinedVariable',strValue);
                    throw(MException(errId,errStr));
                end
            end
        end

        function errorForNonTunableParam(this,paramName)

            if isSimulationRunning(this)

                msgthis=message('Spcuilib:configuration:PropertyNotTunable',...
                paramName,getBlockName(this));
                throwAsCaller(MException(msgthis));
            end
        end
    end




    methods(Static,Hidden)
        function[refValue,isNumRefChanged]=updateReferenceConstellaltionValues(refValue,numInputPorts)
            isNumRefChanged=false;
            if~iscell(refValue)
                refValue={refValue};
            end
            currentRefValue=numel(refValue);
            if numInputPorts>currentRefValue
                defaultRefValue=[0.7071+0.7071i,-0.7071+0.7071i,-0.7071-0.7071i,0.7070-0.7071i];
                for idx=currentRefValue+1:numInputPorts
                    refValue{idx}=defaultRefValue;
                end
                isNumRefChanged=true;
            elseif numInputPorts~=currentRefValue
                temp=cell(size(numInputPorts));
                for idx=1:numInputPorts
                    temp{idx}=refValue{idx};
                end
                refValue=temp;
                isNumRefChanged=true;
            end
        end

        function value=validateEnum(value,propName,validValues)
            validateattributes(value,{'char'},{},'',propName);
            ind=find(ismember(lower(validValues),lower(value))==1,1);
            if isempty(ind)
                msgthis=message('comm:ConstellationDiagramBlock:InvalidEnumValue',propName,strjoin(validValues,', '));
                throwAsCaller(MException(msgthis))
            end

            value=validValues{ind};
        end
        function val=getBoolFromLogical(logical)
            val='false';
            if(logical)
                val='true';
            end
        end
    end



    methods(Hidden)

        function str=toScopeSpecificationString(this)






            import dsp.webscopes.style.*;
            dispParamsStr=displayParamsToSpecString(this);
            scopeParamsStr=scopeParamsToSpecString(this);
            measParamsStr=measurementsParamsToSpecString(this);

            graphicalSettingsStruct=getGraphicalSettingsStruct(this);
            figureColor=[0.16,0.16,0.16];
            if isfield(graphicalSettingsStruct,'Style')
                styleSettingsStruct=graphicalSettingsStruct.Style;
                if~isempty(styleSettingsStruct)

                    if isfield(styleSettingsStruct,'BackgroundColor')
                        if~strcmp(class(styleSettingsStruct.BackgroundColor),'double')
                            axesBackgroundColor=regexprep(regexprep(styleSettingsStruct.BackgroundColor,'[',''),']','').';
                            figureColor=axesBackgroundColor.';
                        else
                            figureColor=styleSettingsStruct.BackgroundColor.';
                        end
                    end
                end
            end
            openAtMdlStart='false';
            if this.OpenAtSimulationStart
                openAtMdlStart='true';
            end

            str=...
            ['comm.scopes.ConstellationDiagramBlockCfg(''CurrentConfiguration'', extmgr.ConfigurationSet('...
            ,'extmgr.Configuration(''Core'',''General UI'',true,''FigureColor'',[',num2str(figureColor),']),'...
            ,'extmgr.Configuration(''Visuals'',''Constellation'',true,'...
            ,dispParamsStr...
...
            ,scopeParamsStr,'),'...
            ,measParamsStr,'),'...
            ,'''Position'',[',num2str(this.Position),'],'...
            ,'''VisibleAtModelOpen'',''',get_param(this.BlockHandle,'Visible'),''','...
            ,'''OpenAtMdlStart'',',openAtMdlStart,')'];
        end
        function dispParamsStr=displayParamsToSpecString(this)

            yLim=this.YLimits;
            xLim=this.XLimits;

            showLegend=this.getBoolFromLogical(this.ShowLegend);
            showTrajectory=this.getBoolFromLogical(this.ShowTrajectory);
            showGrid=this.getBoolFromLogical(this.ShowGrid);
            showReferenceConstellation=this.getBoolFromLogical(this.ShowReferenceConstellation);
            colorFading=this.getBoolFromLogical(this.ColorFading);
            styleParamsStr=styleParamsToSpecString(this);
            dispParamsStr=['''MinYLim'',''',num2str(yLim(1)),''','...
            ,'''MaxYLim'',''',num2str(yLim(2)),''','...
            ,'''MinXLim'',''',num2str(xLim(1)),''','...
            ,'''MaxXLim'',''',num2str(xLim(2)),''','...
            ,'''Title'',''',this.Title,''','...
            ,'''XLabel'',''',this.XLabel,''','...
            ,'''YLabel'',''',this.YLabel,''','...
            ,'''SamplesPerSymbol'',''',this.SamplesPerSymbol,''','...
            ,'''SampleOffset'',''',this.SampleOffset,''','...
            ,'''ColorFading'',',colorFading,','...
            ,'''Legend'',',showLegend,','...
            ,'''Trajectory'',',showTrajectory,','...
            ,'''Grid'',',showGrid,','...
            ,'''ShowRefConstellation'',',showReferenceConstellation,','...
            ,'''MeasurementMode'',',this.getBoolFromLogical(this.EnableMeasurements),','...
            ,styleParamsStr];
        end
        function propValue=visualToEVMPropValue(this)
            switch this.EVMNormalization
            case 'Average constellation power'
                propValue='AvePower';
            case 'Peak constellation power'
                propValue='PeakPower';
            end
        end
        function channelNamesStr=getChannelNamesStr(this,numDispLines)


            if~iscell(this.ChannelNames)
                channelNames={this.ChannelNames};
            else
                channelNames=this.ChannelNames;
            end
            channelLength=numel(channelNames);
            if numDispLines>channelLength
                for i=channelLength:numDispLines
                    channelNames{i}='';
                end
            elseif numDispLines<channelLength
                channelNames=channelNames{1:numDispLines};
            end

            channelNamesStr=[];
            for idx=1:numel(channelNames)
                delim=',';
                if(idx==numel(channelNames))
                    delim=[];
                end
                channelNamesStr=[channelNamesStr,'''',channelNames{idx},'''',delim];%#ok<AGROW>
            end

            channelNamesStr=['{',channelNamesStr,'}'];
        end

        function scopeParamsStr=scopeParamsToSpecString(this)

            if~iscell(this.ChannelNames)
                channelNames={this.ChannelNames};
            else
                channelNames=this.ChannelNames;
            end
            channelLength=numel(channelNames);
            channelNamesStr=getChannelNamesStr(this,channelLength);
            if~iscell(this.ReferenceMarker)
                RefMarkerVal={this.ReferenceMarker};
            else
                RefMarkerVal=this.ReferenceMarker;
            end
            refMarkerStr=[];
            for idx=1:numel(RefMarkerVal)
                delim=''',''';
                if(idx==numel(RefMarkerVal))
                    delim=[];
                end
                refMarkerStr=[refMarkerStr,'''',RefMarkerVal{idx},'''',delim];%#ok<AGROW>
            end


            refMarkerStr=RefMarkerVal{1};
            if~iscell(this.ReferenceColor)
                RefColorVal={this.ReferenceColor};
            else
                RefColorVal=this.ReferenceColor;
            end
            refColorStr=[];
            for idx=1:numel(RefColorVal)
                delim=''',''';
                if(idx==numel(RefColorVal))
                    delim=[];
                end
                refColorStr=[refColorStr,'[',num2str(RefColorVal{idx}),']',delim];%#ok<AGROW>
            end
            refColorStr=regexprep(refColorStr,{'''[',']'''},{'[',']'});
            refColorStr=['{',refColorStr,'}'];

            symToDispSource=['''SymbolsToDisplayFromInput''',',','false'];
            if strcmpi(this.SymbolsToDisplaySource,'Input frame length')
                symToDispSource=['''SymbolsToDisplayFromInput''',',','true'];
            end
            RefDlgPrmStr=RefConstParamsToSpecString(this);

            scopeParamsStr=[


            '''SymbolsToDisplay'',''',this.SymbolsToDisplay,''','...
            ,'',symToDispSource,','...
            ,'''MeasurementInterval'',''',this.MeasurementInterval,''','...
            ,'''EVMNormalization'',''',visualToEVMPropValue(this),''','...
            ,'''UserDefinedChannelNames'',',channelNamesStr,','...
            ,'',RefDlgPrmStr,','...
            ,'''MaximizeAxes'',''',this.MaximizeAxes,''''
            ];
        end
        function measParamsStr=measurementsParamsToSpecString(this)


            measParamsStr='extmgr.Configuration(''Tools'',''Measurements'',true';

            if this.EnableMeasurements
                measParamsStr=[measParamsStr,',''Measurements'',struct(''signalquality'',struct(''SettingsPanelOpen'',1,'...
                ,'''MeasurementsPanelOpen'',1))'...
                ];
            end
            measParamsStr=[measParamsStr,')'];
        end

        function RefDlgPrmStr=RefConstParamsToSpecString(this)
            graphicalSettingsStruct=getGraphicalSettingsStruct(this);
            isRefValueCustom=true;
            if isfield(graphicalSettingsStruct,'ReferenceConstellation')
                RefConstStruct=graphicalSettingsStruct.ReferenceConstellation;
                if isstruct(RefConstStruct)
                    if numel(RefConstStruct)==1
                        RefConstStruct={RefConstStruct};
                    else
                        for pidx=1:numel(RefConstStruct)
                            RefConstcellStruct{pidx}=RefConstStruct(pidx);
                        end
                        RefConstStruct=RefConstcellStruct;
                    end
                end
                isRefValueCustom=any(strcmp(cellfun(@(x)x.ReferenceConstellation,RefConstStruct,'UniformOutput',false),'Custom'));
            end
            RefDlgPrmStr=[];
            if(isRefValueCustom)
                if~iscell(this.ReferenceConstellation)
                    refConVal={this.ReferenceConstellation};
                else
                    refConVal=this.ReferenceConstellation;
                end
                refConStr=[];
                for idx=1:numel(refConVal)
                    delim=',';
                    if(idx==numel(refConVal))
                        delim=[];
                    end
                    refConStr=[refConStr,'[',num2str(refConVal{idx}),']',delim];%#ok<AGROW>
                end
                refConStr=['{',refConStr,'}'];

                avgPowerDefault='1';
                phaseOffDefault='0';
                RefDlgPrmStr=[
                '''NumInputPorts'',''',num2str(numel(refConVal)),''','...
                ,'''ReferenceConstellation'',''',refConStr,''','...
                ,'''AveragePower'',',avgPowerDefault,','...
                ,'''PhaseOffset'',',phaseOffDefault...
                ];
            else
                refConVal=cellfun(@(x)x.RefConstellationValue,RefConstStruct,'UniformOutput',false);
                refConPreset=cellfun(@(x)x.ReferenceConstellation,RefConstStruct,'UniformOutput',false);
                refConStr=[];

                PhaseOffsetVal=cellfun(@(x)x.ReferencePhaseOffSet,RefConstStruct,'UniformOutput',false);
                phaseOffStr=[];

                constNormStr=[];

                avgPowerVal='1';
                avgPowerStr=[];

                peakPowerVal='1';
                peakPowerStr=[];

                minDistanceVal='2';
                minDisStr=[];

                for idx=1:numel(refConVal)

                    constNormVal='AveragePower';
                    NormParamValue='1';
                    delim=',';
                    if(idx==numel(refConVal))
                        delim=[];
                    end
                    if strcmp(refConPreset{idx},'Custom')
                        refConStr=[refConStr,'[',num2str(refConVal{idx}),']',delim];%#ok<AGROW>
                    else
                        refConStr=[refConStr,'''''',(refConPreset{idx}),'''''',delim];%#ok<AGROW>
                    end
                    phaseOffStr=[phaseOffStr,'''''',num2str(PhaseOffsetVal{idx}),'''''',delim];%#ok<AGROW>

                    if isfield(RefConstStruct{idx},'ConstellationNormalization')
                        constNormVal=strrep(RefConstStruct{idx}.ConstellationNormalization,'MinimumDistance','MinDistance');
                    end
                    NormParamValue=['''''',num2str(RefConstStruct{idx}.AverageReferencePower),''''''];

                    if strcmp(constNormVal,'MinDistance')
                        minDistanceVal=NormParamValue;
                    elseif strcmp(constNormVal,'PeakPower')
                        peakPowerVal=NormParamValue;
                    elseif strcmp(constNormVal,'AveragePower')
                        avgPowerVal=NormParamValue;
                    end

                    constNormStr=[constNormStr,'''''',constNormVal,'''''',delim];
                    minDisStr=[minDisStr,minDistanceVal,delim];
                    peakPowerStr=[peakPowerStr,peakPowerVal,delim];
                    avgPowerStr=[avgPowerStr,avgPowerVal,delim];
                end
                if numel(refConVal)>1
                    refConStr=['''{',refConStr,'}'''];
                    phaseOffStr=['{',phaseOffStr,'}'];
                    constNormStr=['''{',constNormStr,'}'''];
                    avgPowerStr=['{',avgPowerStr,'}'];
                    minDisStr=['{',minDisStr,'}'];
                    peakPowerStr=['{',peakPowerStr,'}'];
                else
                    refConStr=regexprep(refConStr,'''''','''');
                    constNormStr=regexprep(constNormStr,'''''','''');
                    phaseOffStr=regexprep(phaseOffStr,'''''','');
                    avgPowerStr=regexprep(avgPowerStr,'''''','');
                    minDisStr=regexprep(minDisStr,'''''','');
                    peakPowerStr=regexprep(peakPowerStr,'''''','');

                end

                RefDlgPrmStr=[
                '''NumInputPorts'',''',num2str(numel(refConVal)),''','...
                ,'''ReferenceConstellation'',',refConStr,','...
                ,'''AveragePower'',''',avgPowerStr,''','...
                ,'''PhaseOffset'',''',phaseOffStr,''','...
                ,'''ConstellationNormalization'',',constNormStr,','...
                ,'''MinDistance'',''',minDisStr,''','...
                ,'''PeakPower'',''',peakPowerStr,''''...
                ];
            end
        end

        function styleParamsStr=styleParamsToSpecString(this)
            graphicalSettingsStruct=getGraphicalSettingsStruct(this);
            styleParamsStr=[];
            axesParamStr=[];
            if isfield(graphicalSettingsStruct,'Style')
                styleSettingsStruct=graphicalSettingsStruct.Style;

                if~strcmp(class(styleSettingsStruct.AxesColor),'double')
                    axesColor=regexprep(regexprep(styleSettingsStruct.AxesColor,'[',''),']','').';
                    axesColor=axesColor.';
                else
                    axesColor=styleSettingsStruct.AxesColor.';
                end
                if~strcmp(class(styleSettingsStruct.LabelsColor),'double')
                    axesTickColor=regexprep(regexprep(styleSettingsStruct.LabelsColor,'[',''),']','').';
                    axesTickColor=axesTickColor.';
                else
                    axesTickColor=styleSettingsStruct.LabelsColor.';
                end

                if~strcmp(class(styleSettingsStruct.BackgroundColor),'double')
                    axesBackgroundColor=regexprep(regexprep(styleSettingsStruct.BackgroundColor,'[',''),']','').';
                    axesBackgroundColor=axesBackgroundColor.';
                else
                    axesBackgroundColor=styleSettingsStruct.BackgroundColor.';
                end
                axesParamStr=['struct(''Color'',[',num2str(axesColor),'],'...
                ,'''XColor'',[',num2str(axesTickColor),'],'...
                ,'''YColor'',[',num2str(axesTickColor),'],'...
                ,'''ZColor'',[',num2str(axesTickColor),'],'...
                ,'''BackgroundColor'',[',num2str(axesBackgroundColor),'])'];
                styleParamsStr=[styleParamsStr...
                ,'''AxesProperties'',',axesParamStr];

                if~isempty(styleSettingsStruct)

                    numLines=0;
                    if isfield(styleSettingsStruct,'LineStyle')

                        numLines=numel(styleSettingsStruct.IsRefLine);
                        k=1:numLines;
                        lineIndices=k(~styleSettingsStruct.IsRefLine);
                        refIndices=k(styleSettingsStruct.IsRefLine);
                    end


                    [lineParamsStr,lineColorStr,lineStyleStr,lineWidthStr,lineMarkerStr]=deal([]);
                    trajLineStyleStr='{''-''}';
                    trajLineColorStr=['[',num2str([1.0000,1.0000,0.0667]),']'];

                    delim=',';
                    colorOrder=utils.getColorOrder([0,0,0]);
                    color=colorOrder(1,:);refColor=[1,0,0];
                    style='-';refMarker='+';
                    width=1.5;refWidth=0.5;
                    marker='.';
                    if~isempty(lineIndices)
                        for lIdx=lineIndices

                            if lIdx==lineIndices(end)
                                delim='';
                            end
                            color=colorOrder(lIdx,:);
                            if isfield(styleSettingsStruct,'LineColor')
                                if(isa(styleSettingsStruct.LineColor,'cell'))
                                    color=styleSettingsStruct.LineColor{lIdx};
                                else
                                    color=styleSettingsStruct.LineColor(lIdx,:);
                                end
                            end
                            lineColorStr=[lineColorStr,'[',num2str(color),']',delim];

                            if isfield(styleSettingsStruct,'LineStyle')
                                if isa(styleSettingsStruct.LineStyle,'cell')
                                    style=styleSettingsStruct.LineStyle{lIdx};
                                else
                                    style=styleSettingsStruct.LineStyle(lIdx);
                                end
                            end
                            lineStyleStr=[lineStyleStr,'''',style,'''',delim];


                            if isfield(styleSettingsStruct,'LineWidth')
                                if isa(styleSettingsStruct.LineWidth,'cell')
                                    width=styleSettingsStruct.LineWidth{lIdx};
                                else
                                    width=styleSettingsStruct.LineWidth(lIdx);

                                end

                            end
                            lineWidthStr=[lineWidthStr,num2str(width),delim];

                            if isfield(styleSettingsStruct,'Marker')
                                if isa(styleSettingsStruct.Marker,'cell')
                                    marker=styleSettingsStruct.Marker{lIdx};
                                else
                                    marker=styleSettingsStruct.Marker(lIdx);
                                end
                            end
                            lineMarkerStr=[lineMarkerStr,'''',marker,'''',delim];
                        end

                        lineColorStr=['{',lineColorStr,'}'];
                        lineStyleStr=strrep(lineStyleStr,'NONE','none');
                        lineStyleStr=['{',lineStyleStr,'}'];
                        lineWidthStr=['{',lineWidthStr,'}'];
                        lineMarkerStr=['{',lineMarkerStr,'}'];
                        displayNameStr=getChannelNamesStr(this,numel(lineIndices));
                        lineParamsStr=['struct(''DisplayName'',',displayNameStr,','...
                        ,'''Color'',',lineColorStr,','...
                        ,'''LineStyle'',',lineStyleStr,','...
                        ,'''LineWidth'',',lineWidthStr,','...
                        ,'''Visible'',''on'','...
                        ,'''MarkerSize'',',num2str(6),','...
                        ,'''MarkerEdgeColor'',''auto'','...
                        ,'''MarkerFaceColor'',''none'','...
                        ,'''Marker'',',lineMarkerStr,')'...
                        ];
                        styleParamsStr=[styleParamsStr,','...
                        ,'''LineProperties'',',lineParamsStr];
                    end

                    [refLineColorStr,refLineStyleStr,refLineWidthStr,refLineMarkerStr]=deal([]);
                    for rIdx=refIndices
                        if rIdx==refIndices(end)
                            delim='';
                        else
                            delim=',';
                        end

                        if isfield(styleSettingsStruct,'LineColor')
                            if(isa(styleSettingsStruct.LineColor,'cell'))
                                refColor=styleSettingsStruct.LineColor{rIdx};
                            else
                                refColor=styleSettingsStruct.LineColor(rIdx,:);
                            end
                        end
                        refLineColorStr=[refLineColorStr,'[',num2str(refColor),']',delim];

                        if isfield(styleSettingsStruct,'LineStyle')
                            if isa(styleSettingsStruct.LineStyle,'cell')
                                style=styleSettingsStruct.LineStyle{rIdx};
                            else
                                style=styleSettingsStruct.LineStyle(rIdx);
                            end
                        end
                        refLineStyleStr=[refLineStyleStr,'''',style,'''',delim];


                        if isfield(styleSettingsStruct,'LineWidth')
                            if isa(styleSettingsStruct.LineWidth,'cell')
                                refWidth=styleSettingsStruct.LineWidth{rIdx};
                            else
                                refWidth=styleSettingsStruct.LineWidth(rIdx);

                            end
                        end
                        refLineWidthStr=[refLineWidthStr,num2str(refWidth),delim];

                        if isfield(styleSettingsStruct,'Marker')
                            if isa(styleSettingsStruct.Marker,'cell')
                                refMarker=styleSettingsStruct.Marker{rIdx};
                            else
                                refMarker=styleSettingsStruct.Marker(rIdx);
                            end
                        end
                        refLineMarkerStr=[refLineMarkerStr,'''',refMarker,'''',delim];

                    end
                    if this.ShowTrajectory
                        delim=',';
                        nTrajLines=numel(lineIndices)-numel(refIndices);
                        if nTrajLines>0
                            trajLineColorStr=lineColorStr;
                            trajLineStyleStr=lineStyleStr;
                            for idx=1:nTrajLines
                                if(idx==nTrajLines)
                                    delim='';
                                end


                                refLineColorStr=[refLineColorStr,',[',num2str(refColor),']',delim];
                                refLineMarkerStr=[refLineMarkerStr,',''',refMarker,'''',delim];
                                refLineWidthStr=[refLineWidthStr,',',num2str(refWidth),delim];
                            end
                        end
                    end
                    if~isempty(refLineColorStr)
                        refLineColorStr=['{',refLineColorStr,'}'];
                    else
                        refLineColorStr=['{','[1  0  0]','}'];
                    end
                    refLineWidthStr=['{',refLineWidthStr,'}'];
                    if~isempty(refLineMarkerStr)
                        refLineMarkerStr=['{',refLineMarkerStr,'}'];
                    else
                        refLineMarkerStr=['{','''','+','''','}'];
                    end
                    auxLinePropStr=['struct(''LineColor'',',trajLineColorStr,','...
                    ,'''LineStyle'',',trajLineStyleStr,','...
                    ,'''TrajLineWidth'',',num2str(0.5),','...
                    ,'''RefConStyle'',',refLineMarkerStr,','...
                    ,'''RefConSize'', ',num2str(6),','...
                    ,'''RefConColor'',',refLineColorStr,','...
                    ,'''RefConLineWidth'',',refLineWidthStr,')'...
                    ];
                    styleParamsStr=[styleParamsStr,','...
                    ,'''AuxLineProperties'',',auxLinePropStr,','...
                    ,'''ReferenceMarker'',''',regexprep(refLineMarkerStr,'''',''''''),''','...
                    ,'''ReferenceColor'',''',refLineColorStr,''','];
                end
            end
        end

        function settings=getGraphicalSettingsStruct(this)


            graphicalSettings=get_param(this.BlockHandle,'GraphicalSettings');

            if isempty(graphicalSettings)
                settings=struct([]);
            else
                graphicalSettings=strrep(graphicalSettings,'''','"');
                settings=jsondecode(graphicalSettings);
                if isfield(settings,'GraphicalSettings')
                    settings=settings.GraphicalSettings;
                end
            end
        end
    end
end

