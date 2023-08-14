classdef ctle<serdes.CTLE&serdes.internal.serdesquicksimulation.SERDESElement



    methods
        function obj=ctle(varargin)
            obj@serdes.internal.serdesquicksimulation.SERDESElement(varargin{:});
        end



        function value=get.myGPZ(obj)
            if isempty(obj.myGPZ)
                obj.myGPZ=obj.GPZ;
            end
            value=obj.myGPZ;
        end
        function set.myGPZ(obj,value)
            if~obj.isWorkspaceVariable(value)
                if~obj.isParameterWorkspaceValuesRestored&&ischar(value)

                    actualValue=obj.myGPZ;
                else
                    actualValue=value;
                end
            else
                actualValue=evalin('base',value);
            end
            obj.testGPZ(actualValue);

            if obj.isParameterWorkspaceValuesRestored
                obj.GPZ=actualValue;
            end
            index=find(strcmpi(obj.ParameterNames,'GPZ'));
            if index>=1
                obj.ParameterValues{index}=actualValue;
                obj.ParameterWorkspaceValues{index}='';
            end

            obj.myGPZ=value;
            index=find(strcmpi(obj.ParameterNames,'myGPZ'));
            if index>=1
                obj.ParameterValues{index}=value;
            end
            obj.setWorkspaceVariableValue('myGPZ',value);
        end
        function testGPZ(obj,value)

            h=matlabshared.application.IgnoreWarnings;
            h.RethrowWarning=false;


            warning1='';
            warning2='';
            try

                a=serdes.CTLE('Specification','GPZ Matrix','GPZ',value);
                [warning1,~]=lastwarn;
                if~isempty(warning1)
                    obj.showWarning(warning1);
                end


                step(a,0);
                [warning2,~]=lastwarn;
                if~isempty(warning2)&&~strcmpi(warning1,warning2)
                    obj.showWarning(warning2);
                end
            catch ex
                [warning3,~]=lastwarn;
                if~isempty(warning3)&&~strcmpi(warning1,warning3)&&~strcmpi(warning2,warning3)
                    obj.showWarning(warning3);
                end
                delete(h);
                rethrow(ex);
            end
            delete(h);
        end
        function showWarning(~,str)
            if~isempty(str)

                opts=struct('WindowStyle','modal','Interpreter','tex');
                h=warndlg(str,'Warning',opts);
                uiwait(h);
            end
        end
        function isValid=isValidGPZWorkspaceVariable(obj,workspaceParamName)
            if~isempty(workspaceParamName)&&~isnumeric(workspaceParamName)
                w=evalin('base','whos');
                isValid=ismember(workspaceParamName,{w(:).name})&&...
                ~isempty(evalin('base',workspaceParamName));
                if isValid
                    actualValue=evalin('base',workspaceParamName);
                    try
                        obj.testGPZ(actualValue);
                    catch
                        isValid=false;
                    end
                end
            else
                isValid=false;
            end
        end

        function setIsLastEdited(obj,elements)
            if~isempty(elements)
                for i=1:length(elements)
                    if isa(elements{i},'serdes.CTLE')
                        elements{i}.IsLastEdited=false;
                    end
                end
            end
            obj.IsLastEdited=true;
        end
    end

    properties
myGPZ


        CTLEFitterButton='@ctlefitter';
    end

    properties(Hidden)
        IsLastEdited=false;
    end

    properties(Constant,Access=protected)
        HeaderDescription=getString(message('serdes:serdesdesigner:CtleHdrDesc'));
    end
    properties(Constant,Hidden)
        DefaultName='CTLE';
    end

    properties(Constant,Hidden)
        CTLEFitterButton_NameInGUI=getString(message('serdes:serdessystem:CTLEFitterButton_NameInGUI'));
        CTLEFitterButton_ToolTip=getString(message('serdes:serdessystem:CTLEFitterButton_ToolTip'));
    end

    methods(Hidden,Access=protected)
        function out=localClone(in)
            out=serdes.internal.apps.serdesdesigner.ctle;
            copyProperties(in,out)
        end
    end
end

