classdef StudentViewerAttached<learning.assess.assessments.StudentAssessment





    properties(Constant)
        type='ViewerAttached';
    end

    properties
BlockType
SignalName
    end

    methods
        function obj=StudentViewerAttached(props)
            obj.validateAndSetInput(props);
        end

        function isCorrect=assess(obj,userModelName)
            isCorrect=false;
            signalMatches=isempty(obj.SignalName);

            hScopes=find_system(userModelName,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,...
            'AllBlocks','on','BlockType','Scope','Floating','off','IOType','viewer');

            for idx=1:length(hScopes)

                connectedSignals=get_param(hScopes{idx},'IOSignals');
                connectedSignals=connectedSignals{1};
                for jdx=1:length(connectedSignals)
                    if connectedSignals(jdx).Handle~=-1
                        sourceBlock=get_param(connectedSignals(jdx).Handle,'Parent');
                        sourceType=get_param(sourceBlock,'BlockType');
                        blockMatches=strcmp(sourceType,obj.BlockType);
                        if~isempty(obj.SignalName)
                            thisName=get_param(connectedSignals(jdx).Handle,'Name');
                            signalMatches=strcmp(thisName,obj.SignalName);
                        end
                        isCorrect=blockMatches&&signalMatches;
                        if isCorrect
                            return
                        end
                    end
                end
            end
        end

        function requirementString=generateRequirementString(~)
            messageName='learning:simulink:genericRequirements:viewerConnected';
            requirementString=message(messageName).getString();
        end

    end

    methods(Access=protected)
        function validateAndSetInput(obj,props)
            if~isfield(props,'BlockType')
                error(message('learning:simulink:resources:MissingParameters'));
            else
                if(ischar(props.BlockType)||isstring(props.BlockType))
                    obj.BlockType=props.BlockType;
                else
                    error(message('learning:simulink:resources:InvalidInput'));
                end
            end

            if isfield(props,'SignalName')
                mustBeText(props.SignalName)
                if isempty(props.SignalName)||props.SignalName==""
                    error(message('learning:simulink:resources:InvalidInput'));
                else
                    obj.SignalName=props.SignalName;
                end
            end

        end

    end
end
