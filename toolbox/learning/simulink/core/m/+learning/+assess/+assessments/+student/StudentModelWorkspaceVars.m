classdef StudentModelWorkspaceVars<learning.assess.assessments.StudentAssessment

    properties(Constant)
        type='ModelWorkspaceVars';
    end

    properties
VarNames
ModelName
    end

    methods
        function obj=StudentModelWorkspaceVars(props)

            obj.validateAndSetProps(props);
        end

        function isCorrect=assess(obj,userModelName)
            isCorrect=false;
            if~isempty(obj.ModelName)
                try
                    modelWorkspace=get_param(obj.ModelName,"ModelWorkspace");
                catch ME
                    if strcmp(ME.identifier,'Simulink:Commands:InvSimulinkObjectName')
                        warning(ME);
                        return
                    else
                        error(ME);
                    end
                end
            else
                modelWorkspace=get_param(userModelName,"ModelWorkspace");
            end
            isCorrect=all(cellfun(@(x)hasVariable(modelWorkspace,x),obj.VarNames));
        end

        function requirementString=generateRequirementString(obj)
            if length(obj.VarNames)>1
                messageName='learning:simulink:genericRequirements:modelWorkspacePlural';
            else
                messageName='learning:simulink:genericRequirements:modelWorkspace';
            end

            if~isempty(obj.ModelName)
                holeModel=""+obj.ModelName+"";
            else
                holeModel=message('learning:simulink:genericRequirements:theCurrentModel').getString();
            end

            holeString=newline+"     "+strjoin(obj.VarNames,newline+"     ");

            requirementString=message(messageName,holeModel,holeString).getString();
        end
    end

    methods(Access=protected)
        function validateAndSetProps(obj,props)
            if isempty(props.VarNames)
                error(message('learning:simulink:resources:MissingParameters'));
            end

            try
                obj.VarNames=cellstr(props.VarNames);
            catch ME
                error(message('learning:simulink:resources:CellArrayOfStrings'));
            end


            if isfield(props,'ModelName')
                mustBeTextScalar(props.ModelName);
                obj.ModelName=props.ModelName;
            end
        end
    end
end
