classdef StudentBaseWorkspaceVar<learning.assess.assessments.StudentAssessment






    properties(Constant)
        type='BaseWorkspaceVar';
    end

    properties
VariableName
VariableValue
    end

    methods
        function obj=StudentBaseWorkspaceVar(props)




            obj.validateProps(props);

            obj.VariableName=props.VariableName;
            obj.VariableValue=props.VariableValue;

        end

        function isCorrect=assess(obj,userModelName)


            obj.validateProps(obj);


            isCorrect=false;%#ok<NASGU> 


            if~Simulink.data.existsInGlobal(userModelName,obj.VariableName)
                isCorrect=false;


            else

                expectedValue=str2double(obj.VariableValue);



                actualValue=Simulink.data.evalinGlobal(userModelName,obj.VariableName);
                isCorrect=abs(expectedValue-actualValue)<eps(expectedValue);
            end

        end

        function requirementString=generateRequirementString(obj)
            msg='learning:simulink:genericRequirements:baseWorkspace';
            requirementString=message(msg,obj.VariableName,obj.VariableValue).getString();
        end
    end

    methods(Access=protected)
        function validateProps(~,props)

            hasAllProps=~isempty(props.VariableName)&&~isempty(props.VariableValue);
            if~hasAllProps
                error(message('learning:simulink:resources:MissingParameters'));
            end


            if~isstring(props.VariableName)
                props.VariableName=string(props.VariableName);
            end



            value=props.VariableValue;

            if~isstring(value)
                props.VariableValue=string(value);
            end

            if isnan(str2double(value))
                error(message('learning:simulink:resources:InvalidInput'))
            end
        end
    end
end