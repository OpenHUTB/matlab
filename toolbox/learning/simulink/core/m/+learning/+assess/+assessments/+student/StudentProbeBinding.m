classdef StudentProbeBinding<learning.assess.assessments.StudentAssessment



    properties(Constant)
        type='ProbeBinding';
    end

    properties
ReferenceBlock
Variables
BlockName
    end

    methods
        function obj=StudentProbeBinding(props)

            obj.validateAndSetProps(props);
        end

        function isCorrect=assess(obj,userModelName)
            isCorrect=false;



            probeBlocks=find_system(userModelName,'FindAll','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType','SimscapeProbe');
            if isempty(probeBlocks)
                return
            end

            for idx=1:length(probeBlocks)
                correctBlockBound=strcmp(obj.ReferenceBlock,get_param(simscape.probe.getBoundBlock(probeBlocks(idx)),'ReferenceBlock'));
                if correctBlockBound
                    isCorrect=isequal(sort(obj.Variables),sort(simscape.probe.getVariables(probeBlocks(idx))));
                    if isCorrect
                        return
                    end
                end

            end
        end

        function requirementString=generateRequirementString(obj)
            variableString=[newline,'     ',strjoin(obj.Variables,', ')];

            if length(obj.Variables)>1
                messageName='learning:simulink:genericRequirements:probeBindingPlural';
            else
                messageName='learning:simulink:genericRequirements:probeBinding';
            end
            requirementString=message(messageName,obj.BlockName,variableString).getString();
        end
    end

    methods(Access=protected)
        function validateAndSetProps(obj,props)

            if isempty(props.Variables)||isempty(props.ReferenceBlock)
                error(message('learning:simulink:resources:MissingParameters'));
            end

            mustBeTextScalar(props.ReferenceBlock);
            mustBeText(props.Variables);


            obj.ReferenceBlock=props.ReferenceBlock;
            fullBlockPath=strsplit(obj.ReferenceBlock,'/');
            obj.BlockName=fullBlockPath{end};

            if ischar(props.Variables)
                obj.Variables={props.Variables};
            else
                obj.Variables=convertStringsToChars(props.Variables);
            end
        end

    end
end
