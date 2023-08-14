classdef StudentScopeParameters<learning.assess.assessments.StudentAssessment






    properties(Constant)
        type='ScopeParameters';
        requiredFields={'ParameterName';'ParameterValue'};
    end

    properties
ScopeParameters
    end

    methods
        function obj=StudentScopeParameters(props)
            obj.validateInput(props);
            obj.ScopeParameters=props.ScopeParameters;
        end

        function isCorrect=assess(obj,userModelName)
            isCorrect=false;

            scopeBlocks=Simulink.findBlocks(userModelName,'BlockType','Scope');

            numParameters=length(obj.ScopeParameters);
            numCorrectParameters=0;
            for idx=1:numel(scopeBlocks)
                thisConfig=get_param(scopeBlocks(idx),'ScopeConfiguration');
                for jdx=1:numParameters
                    thisIsCorrect=isequal(thisConfig.(obj.ScopeParameters(jdx).ParameterName),...
                    obj.ScopeParameters(jdx).ParameterValue);





                    if thisIsCorrect
                        numCorrectParameters=numCorrectParameters+1;
                    end
                end
                if numCorrectParameters==numParameters
                    isCorrect=true;
                    return
                end
            end

        end

        function requirementString=generateRequirementString(obj)


            blockType='Scope';

            messageName='learning:simulink:genericRequirements:blockParameter';

            blockName=[newline,'     ',blockType,':'];
            allParametersText='';

            for idx=1:length(obj.ScopeParameters)

                isArray=isnumeric(obj.ScopeParameters(idx).ParameterValue)&&length(obj.ScopeParameters(idx).ParameterValue)>1;
                parameterValue=num2str(obj.ScopeParameters(idx).ParameterValue);
                if isArray
                    parameterValue=['[',parameterValue,']'];
                    parameterValue=strrep(parameterValue,'  ',' ');
                end
                currentParameterText=['          ',obj.ScopeParameters(idx).ParameterName,': ',parameterValue];
                allParametersText=[allParametersText,newline,currentParameterText];
            end
            requirementString=message(messageName,[blockName,allParametersText]).getString();
        end

    end

    methods(Access=protected)
        function validateInput(obj,props)



            hasAllProps=isstruct(props.ScopeParameters)||...
            isequal(intersect(fieldnames(props.ScopeParameters),obj.requiredFields),obj.requiredFields);


            for i=1:length(props.ScopeParameters)
                if~obj.isParameterValid(props.ScopeParameters(i))
                    hasAllProps=false;
                    break
                end
            end

            if~hasAllProps
                error(message('learning:simulink:resources:MissingParameters'));
            end

        end

        function isValid=isParameterValid(~,parameter)
            isValid=~isempty(parameter.ParameterName)&&~isempty(parameter.ParameterValue);
        end

    end
end
