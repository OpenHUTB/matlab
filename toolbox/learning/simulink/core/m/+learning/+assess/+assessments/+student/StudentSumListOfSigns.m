classdef StudentSumListOfSigns<learning.assess.assessments.StudentAssessment

    properties(Constant)
        type='SumListOfSigns';
    end

    properties
RequiredSigns
    end

    methods
        function obj=StudentSumListOfSigns(props)

            obj.validateAndSetProps(props);
        end

        function isCorrect=assess(obj,userModelName)

            isCorrect=false;
            possibleBlockHandles=Simulink.findBlocks(userModelName,'BlockType','Sum');
            for idx=1:length(possibleBlockHandles)
                blockSigns=get_param(possibleBlockHandles(idx),'Inputs');

                isCorrect=all(cellfun(@(x)contains(sort(blockSigns),x),sort(obj.RequiredSigns)));
                if isCorrect
                    break
                end
            end

        end

        function requirementString=generateRequirementString(obj)
            messageName='learning:simulink:genericRequirements:sumListOfSigns';
            requirementString=message(messageName,strjoin(obj.RequiredSigns,', ')).getString();
        end
    end

    methods(Access=protected)
        function validateAndSetProps(obj,props)
            if isempty(props.RequiredSigns)
                error(message('learning:simulink:resources:MissingParameters'));
            end

            try
                obj.RequiredSigns=cellstr(props.RequiredSigns);
            catch ME
                error(message('learning:simulink:resources:CellArrayOfStrings'));
            end
        end


    end
end
