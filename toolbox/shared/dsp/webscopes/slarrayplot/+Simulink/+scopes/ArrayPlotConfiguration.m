classdef ArrayPlotConfiguration








    properties(AbortSet,Dependent)

        NumInputPorts;

        XDataMode;

        SampleIncrement;

        XOffset;

        CustomXData;

        XScale;

        YScale;

        PlotType;

        AxesScaling;


        AxesScalingNumUpdates;

        Name;

        Position;

        MaximizeAxes;

        PlotAsMagnitudePhase;

        Title;

        XLabel;

        YLabel;

        YLimits;

        ShowGrid;

        ShowLegend;

        ChannelNames;

        OpenAtSimulationStart;

        Visible;
    end

    properties(AbortSet,Dependent,Hidden)

        FrameBasedProcessing;

ExpandToolstrip


GraphicalSettings
    end

    properties(Access=private)

        BlockHandle=-1;
    end

    properties(Constant,Hidden)
        XDataModeSet={'Sample increment and X-offset','Custom'};
        XScaleSet={'Linear','Log'};
        YScaleSet={'Linear','Log'};
        PlotTypeSet={'Stem','Line','Stairs'};
        AxesScalingSet={'Auto','Updates','Manual','OnceAtStop'};
        MaximizeAxesSet={'Auto','On','Off'};
    end



    methods

        function this=ArrayPlotConfiguration(blkHandle)
            this.BlockHandle=blkHandle;
        end


        function this=set.NumInputPorts(this,strValue)
            this.errorForNonTunableParam('NumInputPorts');
            [rvalue,errorID,errorStr]=evaluateVariable(this,strValue);
            if~isempty(errorID)
                msgObj=message('shared_dspwebscopes:slarrayplot:invalidSetting',...
                'NumInputPorts',this.Name,errorStr);
                throwAsCaller(MException(msgObj));
            elseif~isnumeric(rvalue)
                errorStr=getString(message('shared_dspwebscopes:slarrayplot:invalidVariableForNumberOfInputPorts',value));
                msgObj=message('shared_dspwebscopes:slarrayplot:invalidSetting',...
                'NumInputPorts',this.Name,errorStr);
                throwAsCaller(MException(msgObj));
            end
            validateattributes(rvalue,{'numeric'},{'real','finite','positive','scalar','>=',1,'<=',96},'','NumInputPorts');
            set_param(this.BlockHandle,'NumInputPorts',num2str(rvalue));
        end
        function value=get.NumInputPorts(this)
            value=get_param(this.BlockHandle,'NumInputPorts');
        end

        function this=set.XDataMode(this,value)
            this.errorForNonTunableParam('XDataMode');
            value=this.validateEnum('XDataMode',value);

            if strcmp(this.XScale,'Log')
                if strcmp(value,'Sample increment and X-offset')
                    [offsetVal,errId]=evaluateVariable(this,this.XOffset);
                    if isempty(errId)&&offsetVal<0
                        msgObj=message('shared_dspwebscopes:arrayplot:invalidXScaleXOffsetCombinationProperty');
                        throwAsCaller(MException(msgObj));
                    end
                elseif strcmp(value,'Custom')
                    [customXVal,errId]=evaluateVariable(this,this.CustomXData);
                    if isempty(errId)&&~isempty(customXVal)&&any(customXVal<0)
                        msgObj=message('shared_dspwebscopes:arrayplot:invalidXScaleCustomXDataCombinationProperty');
                        throwAsCaller(MException(msgObj));
                    end
                end
            end
            set_param(this.BlockHandle,'XDataMode',value);
        end
        function value=get.XDataMode(this)
            value=get_param(this.BlockHandle,'XDataMode');
        end


        function this=set.SampleIncrement(this,strValue)
            [value,varUndefined]=evaluateString(this,strValue,'SampleIncrement');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','SampleIncrement');
            end
            set_param(this.BlockHandle,'SampleIncrement',strValue);
        end
        function value=get.SampleIncrement(this)
            value=get_param(this.BlockHandle,'SampleIncrement');
        end


        function this=set.XOffset(this,strValue)
            [value,varUndefined]=evaluateString(this,strValue,'XOffset');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','scalar'},'','XOffset');
                if value<0&&strcmp(this.XScale,'Log')
                    msgObj=message('shared_dspwebscopes:arrayplot:invalidXOffset');
                    throwAsCaller(MException(msgObj));
                end
            end
            set_param(this.BlockHandle,'XOffset',strValue);
        end
        function value=get.XOffset(this)
            value=get_param(this.BlockHandle,'XOffset');
        end


        function this=set.CustomXData(this,strValue)
            [value,variableUndefined]=evaluateString(this,strValue,'CustomXData');
            if~variableUndefined&&~isempty(value)
                validateattributes(value,{'numeric'},{'vector','real','finite','increasing'},'','CustomXData');
                if strcmp(this.XScale,'Log')&&any(value<0)
                    msgObj=message('shared_dspwebscopes:arrayplot:invalidCustomXDataWithLogScale');
                    throwAsCaller(MException(msgObj));
                end
            end
            set_param(this.BlockHandle,'CustomXData',strValue);
        end
        function value=get.CustomXData(this)
            value=get_param(this.BlockHandle,'CustomXData');
        end


        function this=set.XScale(this,value)
            value=this.validateEnum('XScale',value);
            if strcmp(value,'Log')
                if strcmp(this.XDataMode,'Sample increment and X-offset')
                    [offsetVal,errId]=evaluateVariable(this,this.XOffset);
                    if isempty(errId)&&offsetVal<0
                        msgObj=message('shared_dspwebscopes:arrayplot:invalidXScale');
                        throwAsCaller(MException(msgObj));
                    end
                elseif strcmp(this.XDataMode,'Custom')
                    [customXVal,errId]=evaluateVariable(this,this.CustomXData);
                    if isempty(errId)&&~isempty(customXVal)&&any(customXVal<0)
                        msgObj=message('shared_dspwebscopes:arrayplot:invalidXScaleWithCustomXData');
                        throwAsCaller(MException(msgObj));
                    end
                end
            end
            set_param(this.BlockHandle,'XScale',value);
        end
        function value=get.XScale(this)
            value=get_param(this.BlockHandle,'XScale');
        end


        function this=set.YScale(this,value)
            value=this.validateEnum('YScale',value);
            set_param(this.BlockHandle,'YScale',value);
        end
        function value=get.YScale(this)
            value=get_param(this.BlockHandle,'YScale');
        end


        function this=set.PlotType(this,value)
            value=this.validateEnum('PlotType',value);
            set_param(this.BlockHandle,'PlotType',value);
        end
        function value=get.PlotType(this)
            value=get_param(this.BlockHandle,'PlotType');
        end


        function this=set.AxesScaling(this,value)
            value=this.validateEnum('AxesScaling',value);
            set_param(this.BlockHandle,'AxesScaling',value);
        end
        function value=get.AxesScaling(this)
            value=get_param(this.BlockHandle,'AxesScaling');
        end


        function this=set.AxesScalingNumUpdates(this,strValue)
            [value,varUndefined]=evaluateString(this,strValue,'AxesScalingNumUpdates');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','AxesScalingNumUpdates');
            end
            set_param(this.BlockHandle,'AxesScalingNumUpdates',strValue);
        end
        function value=get.AxesScalingNumUpdates(this)
            value=get_param(this.BlockHandle,'AxesScalingNumUpdates');
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
            set_param(this.BlockHandle,'WindowPosition',num2str(value));
        end
        function value=get.Position(this)
            if this.Visible&&isWebWindowValid(this)


                webwindow=getWebWindow(this);
                value=webwindow.Position;
            else
                value=str2num(get_param(this.BlockHandle,'WindowPosition'));%#ok<ST2NM>
                if isempty(value)


                    value=utils.getDefaultWebWindowPosition([800,500]);
                end
            end
        end


        function this=set.MaximizeAxes(this,value)
            value=this.validateEnum('MaximizeAxes',value);
            set_param(this.BlockHandle,'MaximizeAxes',value);
        end
        function value=get.MaximizeAxes(this)
            value=get_param(this.BlockHandle,'MaximizeAxes');
        end


        function this=set.PlotAsMagnitudePhase(this,value)
            validateattributes(value,{'logical','numeric'},{},'','PlotAsMagnitudePhase');
            set_param(this.BlockHandle,'PlotAsMagnitudePhase',utils.logicalToOnOff(value));
        end
        function value=get.PlotAsMagnitudePhase(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'PlotAsMagnitudePhase'));
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


        function this=set.YLimits(this,value)
            if~all(isnumeric(value))||~all(isfinite(value))||...
                numel(value)~=2||value(1)>=value(2)
                msgObj=message('shared_dspwebscopes:arrayplot:invalidYLimits');
                throwAsCaller(MException(msgObj));
            end
            this.AxesScaling='Manual';
            set_param(this.BlockHandle,'YLimits',['[',num2str(value(1)),',',num2str(value(2)),']']);
        end
        function value=get.YLimits(this)
            value=str2num(get_param(this.BlockHandle,'YLimits'));%#ok<ST2NM>
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
            validateattributes(value,{'string','cell'},{'vector'},'','ChannelNames');
            if(~isempty(value)&&(~isvector(value)||~iscellstr(cellstr(value))))
                msgObj=message('shared_dspwebscopes:arrayplot:invalidChannelNames');
                throwAsCaller(MException(msgObj));
            end
            value=cellstr(value);
            set_param(this.BlockHandle,'ChannelNames',jsonencode(value));
        end
        function value=get.ChannelNames(this)


            value=strrep(get_param(this.BlockHandle,'ChannelNames'),'''','"');

            value=jsondecode(value).';
            if isempty(value)

                value={''};
            end
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
            validateattributes(value,{'logical','numeric'},{},'','FrameBasedProcessing');
            set_param(this.BlockHandle,'ExpandToolstrip',utils.logicalToOnOff(value));
        end
        function value=get.ExpandToolstrip(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'FrameBasedProcessing'));
        end


        function value=get.GraphicalSettings(this)
            value=strrep(get_param(this.BlockHandle,'GraphicalSettings'),'''','"');

            value=jsondecode(value);
        end
    end



    methods(Hidden)

        function evalAndSetNumInputPorts(this,numInputPorts)
            if~isempty(numInputPorts)&&ischar(numInputPorts)





                numInputPortsVal=str2num(numInputPorts);%#ok<ST2NM>
                if isempty(numInputPortsVal)





                    if~isvarname(numInputPorts)
                        utils.errorHandler(getString(message('Spcuilib:scopes:InvalidVariableName',numInputPorts)));
                        return
                    end
                    try
                        numInputPortsVal=evalVarInMdlOrBaseWS(this,numInputPorts);
                    catch meNotUsed %#ok<NASGU>
                        utils.errorHandler(getString(message('Spcuilib:scopes:VariableNotFound',numInputPorts)));
                        return
                    end
                    if~isnumeric(numInputPortsVal)
                        utils.errorHandler(getString(message('shared_dspwebscopes:slarrayplot:invalidVariableForNumberOfInputPorts',numInputPorts)));
                        return
                    end
                end

                try
                    set_param(this.BlockHandle,'NumInputPorts',num2str(double(numInputPortsVal)));
                catch ME
                    utils.errorHandler(ME.message);
                end
            end
        end
    end



    methods(Access=private)

        function b=isSimulationRunning(this)

            simstatus=get_param(bdroot(this.BlockHandle),'SimulationStatus');
            b=~any(strcmpi(simstatus,{'stopped','initializing'}));
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

                msgObj=message('shared_dspwebscopes:slarrayplot:propertyNotTunable',...
                paramName,this.Name);
                throwAsCaller(MException(msgObj));
            end
        end

        function webwindow=getWebWindow(this)

            modelHandle=get_param(get_param(this.BlockHandle,'Parent'),'Handle');
            allBlocks=matlabshared.scopes.WebScope.getAllInstancesForType(modelHandle,'ArrayPlot');


            for bIdx=1:numel(allBlocks)
                if strcmp(allBlocks{bIdx}.Name,this.Name)
                    webwindow=allBlocks{bIdx}.WebWindow;
                    break;
                end
            end
        end

        function valid=isWebWindowValid(this)

            webwindow=getWebWindow(this);
            valid=isvalid(webwindow);
            if~isempty(webwindow)&&valid
                valid=webwindow.isWindowValid;
            end
        end

        function value=validateEnum(this,propName,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'',propName);

            validValues=getPropertySet(this,propName);
            ind=find(ismember(lower(validValues),lower(value))==1,1);
            if isempty(ind)
                validValuesStr=propertySetToStringList(this,validValues);
                dsp.webscopes.internal.BaseWebScope.localError('invalidEnumValue',value,propName,validValuesStr);
            end

            value=validValues{ind};
        end

        function set=getPropertySet(this,propName)
            set=this.([propName,'Set']);
        end

        function list=propertySetToStringList(~,set)
            set=string(set);
            list='';
            for i=1:numel(set)
                list=[list,newline,'    ','''',char(set(i)),''''];%#ok<AGROW>
            end
        end
    end
end
