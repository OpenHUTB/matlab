classdef StudentConnectedSignalName<learning.assess.assessments.StudentAssessment



    properties(Constant)
        type='ConnectedSignalName';
    end

    properties
BlockType
SignalName
    end

    methods
        function obj=StudentConnectedSignalName(props)
            obj.validateInput(props);
            obj.BlockType=props.BlockType;
            obj.SignalName=props.SignalName;
        end

        function isCorrect=assess(obj,userModelName)
            isCorrect=false;

            targetBlock=Simulink.findBlocks(userModelName,'BlockType',obj.BlockType);

            if isempty(targetBlock)
                return
            else


                for idx=1:numel(targetBlock)
                    isCorrect=any(contains(get_param(targetBlock(idx),'InputSignalNames'),obj.SignalName));
                    if isCorrect
                        break
                    end
                end
            end

        end

        function requirementString=generateRequirementString(obj)
            requirementString=message('learning:simulink:genericRequirements:signalName',...
            obj.SignalName,obj.BlockType).getString();
        end
    end

    methods(Access=protected)
        function validateInput(~,props)
            if isempty(props.BlockType)||isempty(props.SignalName)
                error(message('learning:simulink:resources:InvalidAssessmentObject'));
            end

            isBlockText=ischar(props.BlockType)||isstring(props.BlockType);
            if~isBlockText
                error(message('learning:simulink:resources:InvalidInput'));
            end
        end
    end

end
