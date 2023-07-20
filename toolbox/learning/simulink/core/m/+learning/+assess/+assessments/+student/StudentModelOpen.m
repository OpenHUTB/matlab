classdef StudentModelOpen<learning.assess.assessments.StudentAssessment


    properties(Constant)
        type='ModelOpen';
    end

    properties
ModelName
    end

    methods
        function obj=StudentModelOpen(props)

            obj.validateAndSetProps(props);
        end

        function isCorrect=assess(obj,~)
            isCorrect=bdIsLoaded(obj.ModelName)&&strcmp(get_param(obj.ModelName,'Shown'),'on');
        end

        function requirementString=generateRequirementString(obj)
            messageName='learning:simulink:genericRequirements:modelOpened';
            requirementString=message(messageName,obj.ModelName).getString();
        end
    end

    methods(Access=protected)
        function validateAndSetProps(obj,props)
            if isempty(props.ModelName)
                error(message('learning:simulink:resources:MissingParameters'));
            end

            mustBeTextScalar(props.ModelName);

            if exist(props.ModelName,"file")~=4
                error(message('learning:simulink:resources:ModelNotOnPath',props.ModelName));
            end

            obj.ModelName=props.ModelName;
        end


    end
end
