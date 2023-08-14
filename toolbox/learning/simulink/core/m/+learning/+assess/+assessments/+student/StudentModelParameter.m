classdef StudentModelParameter<learning.assess.assessments.StudentAssessment

    properties(Constant)
        type='ModelParameter';
    end

    properties
ParameterName
ParameterValue
    end

    methods
        function obj=StudentModelParameter(props)
            obj.validateProps(props);

            obj.ParameterName=props.ParameterName;
            obj.ParameterValue=props.ParameterValue;
        end

        function isCorrect=assess(obj,userModelName)
            obj.validateProps(obj);



            try
                currentParamValue=slResolve(obj.ParameterValue,userModelName);
            catch
                currentParamValue=obj.ParameterValue;
            end

            try
                userParamValue=get_param(userModelName,obj.ParameterName);
            catch



                warningMessage=message('learning:simulink:resources:InvalidModelParameter',obj.ParameterName);
                warning(warningMessage);
                sldiagviewer.createStage('Analysis','ModelName',userModelName);
                sldiagviewer.reportWarning(warningMessage.getString());
                isCorrect=false;
                return
            end




            try
                userParamValue=slResolve(userParamValue,userModelName);
            catch




            end
            isCorrect=isempty(setdiff(currentParamValue,userParamValue));
        end

        function requirementString=generateRequirementString(obj)
            requirementString=message('learning:simulink:genericRequirements:modelParameter',obj.ParameterName,char(obj.ParameterValue)).getString();
        end
    end

    methods(Access=protected)
        function validateProps(~,props)
            hasAllProps=~isempty(props.ParameterName)&&~isempty(props.ParameterValue);
            if~hasAllProps
                error(message('learning:simulink:resources:MissingParameters'));
            end
        end
    end
end