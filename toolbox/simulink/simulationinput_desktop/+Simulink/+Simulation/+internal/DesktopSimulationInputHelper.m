classdef DesktopSimulationInputHelper<Simulink.Simulation.internal.SimulationInputHelper




    properties(Constant,Access=private)
        VariableWorkspaceAndContextParser=getVariableWorkspaceAndContextParser()
    end

    methods(Static)
        function validateVariable(~,~)
        end

        function newValue=modifyVariableValue(varName,varValue,varExpr,exprValue)%#ok
            if isa(varValue,'Simulink.Parameter')&&...
                ~isa(exprValue,'Simulink.Parameter')
                [prefix,remain]=strtok(varExpr,'{.(');
                firstField=extractFirstField(remain);


                if~isprop(varValue,firstField)
                    varExpr=prefix+".Value"+remain;
                end
            end
            evalc(varName+"= varValue");
            evalc(varExpr+"= exprValue");
            evalc("newValue = "+varName);
        end

        function[varValue,varWasResolved]=getVariableValue(modelName,varName,varargin)
            varName=convertStringsToChars(varName);
            p=Simulink.Simulation.internal.DesktopSimulationInputHelper.VariableWorkspaceAndContextParser;
            parse(p,varargin{:});

            varWorkspace=p.Results.Workspace;

            switch varWorkspace
            case 'global-workspace'

                load_system(modelName);

                location=slprivate('getVariableLocation',modelName,varName);
                [location,~,~,~,~]=...
                slprivate('parseLocation',modelName,...
                location,varName);
                if any(strcmp(location,{'base','dictionary'}))
                    varValue=evalinGlobalScope(modelName,varName);
                    varWasResolved=true;
                else
                    varValue=[];
                    varWasResolved=false;
                end

            otherwise

                load_system(varWorkspace);
                modelWS=get_param(varWorkspace,'ModelWorkspace');
                varValue=slprivate('modelWorkspaceGetVariableHelper',modelWS,varName);
                varWasResolved=true;
            end



            if varWasResolved&&isa(varValue,'handle')
                varValue=copy(varValue);
            end
        end
    end
end

function fieldName=extractFirstField(str)





    fieldName=regexp(str,"^\.[^\.]*","match","once");

    fieldName=extractAfter(fieldName,".");
end

function p=getVariableWorkspaceAndContextParser()
    p=inputParser;
    isScalarText=@(x)validateattributes(x,{'char','string'},{'scalartext'});
    addParameter(p,'Workspace','global-workspace',isScalarText);
    addParameter(p,'context','',isScalarText);
end


