classdef ATIScopeConfiguration<matlab.mixin.CustomDisplay








    properties(AbortSet,Dependent)


        OpenAtSimulationStart;

        Visible;

ShowGrid

ShowTicks

ColorBarLabel

AngleLabel

Title

AngleOffset

AngleResolution

TimeSpanSource

TimeSpan

TimeResolutionSource

TimeResolution

TimeLabel

Name

Position
    end

    properties(AbortSet,Dependent,Hidden)

ExpandToolstrip
    end

    properties(Access=private)

        BlockHandle=-1;
    end

    properties(Constant,Hidden)
        TimeResolutionSourceSet={'Auto','Property'};
        TimeSpanSourceSet={'Auto','Property'};
    end



    methods

        function this=ATIScopeConfiguration(blkHandle)
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


        function this=set.ExpandToolstrip(this,value)
            validateattributes(value,{'logical','numeric'},{},'','ExpandToolstrip');
            set_param(this.BlockHandle,'ExpandToolstrip',utils.logicalToOnOff(value));
        end
        function value=get.ExpandToolstrip(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'ExpandToolstrip'));
        end



        function this=set.ShowGrid(this,value)
            validateattributes(value,{'logical','numeric'},{},'','ShowGrid');
            set_param(this.BlockHandle,'ShowGrid',utils.logicalToOnOff(value));
        end
        function value=get.ShowGrid(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'ShowGrid'));
        end


        function this=set.ShowTicks(this,value)
            validateattributes(value,{'logical','numeric'},{},'','ShowTicks');
            set_param(this.BlockHandle,'ShowTicks',utils.logicalToOnOff(value));
        end
        function value=get.ShowTicks(this)
            value=utils.onOffToLogical(get_param(this.BlockHandle,'ShowTicks'));
        end


        function this=set.AngleLabel(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','AngleLabel');
            set_param(this.BlockHandle,'AngleLabel',value);
        end
        function value=get.AngleLabel(this)
            value=get_param(this.BlockHandle,'AngleLabel');
        end


        function this=set.ColorBarLabel(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','ColorBarLabel');
            set_param(this.BlockHandle,'ColorbarLabel',value);
        end
        function value=get.ColorBarLabel(this)
            value=get_param(this.BlockHandle,'ColorbarLabel');
        end


        function this=set.Title(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','Title');
            set_param(this.BlockHandle,'Title',value);
        end
        function value=get.Title(this)
            value=get_param(this.BlockHandle,'Title');
        end


        function this=set.AngleOffset(this,strValue)
            this.errorForNonTunableParam('AngleOffset');
            [value,varUndefined]=evaluateString(this,strValue,'AngleOffset');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','scalar'},'','AngleOffset');
            end
            set_param(this.BlockHandle,'AngleOffset',num2str(value));
        end
        function value=get.AngleOffset(this)
            value=evalin('base',get_param(this.BlockHandle,'AngleOffset'));
        end


        function this=set.AngleResolution(this,strValue)
            this.errorForNonTunableParam('AngleResolution');
            [value,varUndefined]=evaluateString(this,strValue,'AngleResolution');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','AngleResolution');
            end
            set_param(this.BlockHandle,'AngleResolution',num2str(value));
        end
        function value=get.AngleResolution(this)
            value=evalin('base',get_param(this.BlockHandle,'AngleResolution'));
        end


        function this=set.TimeSpanSource(this,value)
            value=convertStringsToChars(value);
            value=this.validateEnum(value,'TimeSpanSource',this.TimeSpanSourceSet);
            set_param(this.BlockHandle,'TimeSpanSource',value);
        end
        function value=get.TimeSpanSource(this)
            value=get_param(this.BlockHandle,'TimeSpanSource');
        end


        function this=set.TimeSpan(this,strValue)
            this.errorForNonTunableParam('TimeSpan');
            [value,varUndefined]=evaluateString(this,strValue,'TimeSpan');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','scalar'},'','TimeSpan');
            end
            set_param(this.BlockHandle,'TimeSpan',num2str(value));
        end
        function value=get.TimeSpan(this)
            value=evalin('base',get_param(this.BlockHandle,'TimeSpan'));
        end


        function this=set.TimeResolutionSource(this,value)
            value=convertStringsToChars(value);
            value=this.validateEnum(value,'TimeResolutionSource',this.TimeResolutionSourceSet);
            set_param(this.BlockHandle,'TimeResolutionSource',value);
        end
        function value=get.TimeResolutionSource(this)
            value=get_param(this.BlockHandle,'TimeResolutionSource');
        end


        function this=set.TimeResolution(this,strValue)
            this.errorForNonTunableParam('TimeResolution');
            [value,varUndefined]=evaluateString(this,strValue,'TimeResolution');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','TimeResolution');
            end
            set_param(this.BlockHandle,'TimeResolution',num2str(value));
        end
        function value=get.TimeResolution(this)
            value=evalin('base',get_param(this.BlockHandle,'TimeResolution'));
        end


        function this=set.TimeLabel(this,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','TimeLabel');
            set_param(this.BlockHandle,'TimeLabel',value);
        end
        function value=get.TimeLabel(this)
            value=get_param(this.BlockHandle,'TimeLabel');
        end

        function props=getDisplayProperties(this)
            props=getPropertyGroups(this);
        end
    end



    methods(Access=private)

        function b=isSimulationRunning(this)

            simstatus=get_param(bdroot(this.BlockHandle),'SimulationStatus');
            b=~any(strcmpi(simstatus,{'stopped','initializing'}));
        end

        function errorForNonTunableParam(this,paramName)

            if isSimulationRunning(this)

                msgthis=message('Spcuilib:configuration:PropertyNotTunable',...
                paramName,getBlockName(this));
                throwAsCaller(MException(msgthis));
            end
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
            [value,~,errStr]=this.evaluateVariable(strValue);
            errorOccured=~isempty(errStr);
            if~isempty(errStr)
                [errStr,errId]=utils.message('EvaluateUndefinedVariable',strValue);
                throw(MException(errId,errStr));
            end
        end

        function webwindow=getWebWindow(this)

            modelHandle=get_param(get_param(this.BlockHandle,'Parent'),'Handle');
            allBlocks=matlabshared.scopes.WebScope.getAllInstancesForType(modelHandle,'ATIScopeBlock');


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
    end



    methods(Access=protected)

        function groups=getPropertyGroups(this)

            mainProps=getValidDisplayProperties(this,{'AngleOffset',...
            'AngleResolution',...
            'TimeSpanSource',...
            'TimeSpan',...
            'TimeResolutionSource',...
            'TimeResolution'});

            visualizationProps=getValidDisplayProperties(this,{'Name',...
            'Position',...
            'Title',...
            'TimeLabel',...
            'AngleLabel',...
            'ColorBarLabel',...
            'ShowGrid',...
            'ShowTicks',...
            'OpenAtSimulationStart',...
            'Visible'});
            mainGroup=matlab.mixin.util.PropertyGroup(mainProps,'');
            visualizationGroup=matlab.mixin.util.PropertyGroup(visualizationProps,'');

            groups=[mainGroup,visualizationGroup];
        end
        function validProps=getValidDisplayProperties(this,props)
            validProps={};
            for idx=1:numel(props)
                if~isInactiveProperty(this,props{idx})
                    validProps=[validProps,props{idx}];%#ok<AGROW>
                end
            end
        end


        function flag=isInactiveProperty(this,propName)
            flag=false;
            switch propName
            case 'TimeSpan'
                flag=strcmpi(this.TimeSpanSource,'Auto');
            case 'TimeResolution'
                flag=strcmpi(this.TimeResolutionSource,'Auto');
            end
        end
    end



    methods(Static)
        function value=validateEnum(value,propName,validValues)
            validateattributes(value,{'char'},{},'',propName);
            ind=find(ismember(lower(validValues),lower(value))==1,1);
            if isempty(ind)
                msgthis=message('phased:slintensitywebscopes:InvalidEnumValue',propName,strjoin(validValues,', '));
                throwAsCaller(MException(msgthis))
            end

            value=validValues{ind};
        end
    end
end