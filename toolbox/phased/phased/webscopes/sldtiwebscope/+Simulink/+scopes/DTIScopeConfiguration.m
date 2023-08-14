classdef DTIScopeConfiguration








    properties(AbortSet,Dependent)


        OpenAtSimulationStart;

        Visible;

ShowGrid

ShowTicks

ColorBarLabel

DopplerOutput

OperatingFrequency

PropagationSpeed

Title

DopplerOffset

DopplerResolution

TimeSpan

TimeResolution

TimeLabel

Name

Position
    end

    properties(AbortSet,Dependent,Hidden)

ExpandToolstrip
    end

    properties(Constant,Hidden)
        DopplerOutputSet={'Frequency','Speed'};
    end

    properties(Access=private)

        BlockHandle=-1;
    end




    methods

        function this=DTIScopeConfiguration(blkHandle)
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
            value=str2num(get_param(this.BlockHandle,'WindowPosition'));
            if isempty(value)


                value=utils.getDefaultWebWindowPosition([600,600]);
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


        function this=set.DopplerOutput(this,value)
            value=convertStringsToChars(value);
            value=this.validateEnum(value,'DopplerOutput',this.DopplerOutputSet);
            set_param(this.BlockHandle,'DopplerOutput',value);
        end
        function value=get.DopplerOutput(this)
            value=get_param(this.BlockHandle,'DopplerOutput');
        end


        function this=set.PropagationSpeed(this,value)
            this.errorForNonTunableParam('PropagationSpeed');
            [value,varUndefined]=evaluateString(this,value,'PropagationSpeed');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','PropagationSpeed');
            end
            set_param(this.BlockHandle,'PropagationSpeed',num2str(value));
        end
        function value=get.PropagationSpeed(this)
            value=evalin('base',get_param(this.BlockHandle,'PropagationSpeed'));
        end


        function this=set.OperatingFrequency(this,value)
            this.errorForNonTunableParam('OperatingFrequency');
            [value,varUndefined]=evaluateString(this,value,'OperatingFrequency');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','OperatingFrequency');
            end
            set_param(this.BlockHandle,'OperatingFrequency',num2str(value));
        end
        function value=get.OperatingFrequency(this)
            value=evalin('base',get_param(this.BlockHandle,'OperatingFrequency'));
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


        function this=set.DopplerOffset(this,strValue)
            this.errorForNonTunableParam('DopplerOffset');
            [value,varUndefined]=evaluateString(this,strValue,'DopplerOffset');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','scalar'},'','DopplerOffset');
            end
            set_param(this.BlockHandle,'DopplerOffset',num2str(value));
        end
        function value=get.DopplerOffset(this)
            value=evalin('base',get_param(this.BlockHandle,'DopplerOffset'));
        end


        function this=set.DopplerResolution(this,strValue)
            this.errorForNonTunableParam('DopplerResolution');
            [value,varUndefined]=evaluateString(this,strValue,'DopplerResolution');
            if~varUndefined
                validateattributes(value,{'numeric'},{'real','finite','positive','scalar'},'','DopplerResolution');
            end
            set_param(this.BlockHandle,'DopplerResolution',num2str(value));
        end
        function value=get.DopplerResolution(this)
            value=evalin('base',get_param(this.BlockHandle,'DopplerResolution'));
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