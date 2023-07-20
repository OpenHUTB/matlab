classdef StudentConditionalSubsystem<learning.assess.assessments.StudentAssessment










    properties(Constant)
        type='ConditionalSubsystem';
        validInputs={'EnablePort';'TriggerPort'};
    end

    properties
RequiredBlocks
    end

    methods
        function obj=StudentConditionalSubsystem(props)

            obj.validateAndSetProps(props);
        end

        function isCorrect=assess(obj,userModelName)

            isCorrect=false;
            subsystemBlocks=Simulink.findBlocksOfType(userModelName,'SubSystem');

            for idx=1:length(subsystemBlocks)
                sys=getfullname(subsystemBlocks(idx));
                foundBlocks={};
                for jdx=1:length(obj.validInputs)
                    blockHandle=Simulink.findBlocksOfType(sys,obj.validInputs{jdx});
                    if~isempty(blockHandle)
                        foundBlocks=[foundBlocks;obj.validInputs{jdx}];
                    end
                end

                if isequal(foundBlocks,obj.RequiredBlocks)
                    isCorrect=true;
                    return
                end
            end

        end

        function requirementString=generateRequirementString(obj)
            messageName='learning:simulink:simulinkFundamentalsRequirements:containsCondSubsys';
            if length(obj.RequiredBlocks)==2
                condType='Enabled and Triggered';
            else
                if strcmp(obj.RequiredBlocks{1},'EnablePort')
                    condType=strrep(obj.RequiredBlocks{1},'Port','d');
                else
                    condType=strrep(obj.RequiredBlocks{1},'Port','ed');
                end
            end

            condType=[condType,' Subsystem'];

            requirementString=message(messageName,[newline,'     ',condType]).getString();
        end
    end

    methods(Access=protected)
        function validateAndSetProps(obj,props)
            if isempty(props.RequiredBlocks)
                error(message('learning:simulink:resources:MissingParameters'));
            end

            try

                obj.RequiredBlocks=cellstr(props.RequiredBlocks);
            catch ME
                error(message('learning:simulink:resources:CellArrayOfStrings'));
            end

            obj.RequiredBlocks=reshape(obj.RequiredBlocks,[],1);
            determineProps=sort(union(obj.RequiredBlocks,obj.validInputs));

            if~isequal(determineProps,obj.validInputs)
                error(message('learning:simulink:resources:InvalidInput'));
            end

        end

    end
end
