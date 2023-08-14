classdef StudentBlockExistence<learning.assess.assessments.StudentAssessment







    properties(Constant)
        type='BlockExistence';
    end

    properties
BlockType
ReferenceBlock
Count
    end

    methods
        function obj=StudentBlockExistence(props)



            obj.validateProps(props);
            obj.BlockType=props.BlockType;
            obj.ReferenceBlock=props.ReferenceBlock;
            if isfield(props,'Count')
                obj.Count=props.Count;
            else
                obj.Count=1;
            end
        end

        function isCorrect=assess(obj,userModelName)



            obj.validateProps(obj);




            requiredBlockHandle=find_system(userModelName,'FindAll','on',...
            'LookUnderMasks','on','FollowLinks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType',obj.BlockType,'ReferenceBlock',obj.ReferenceBlock);



            hasHigherBlkCount=numel(requiredBlockHandle)>=obj.Count;
            hasExactBlkCount=numel(requiredBlockHandle)==obj.Count;





            isCorrect=(hasHigherBlkCount&&logical(obj.Count))||...
            (hasExactBlkCount&&~logical(obj.Count));




            if~isCorrect&&~isempty(obj.ReferenceBlock)
                learning.assess.throwWarningIfUsingWrongLibrary(userModelName,obj.ReferenceBlock);
            end
        end

        function requirementString=generateRequirementString(obj)
            blockType=learning.assess.getDefaultBlockName(obj.BlockType);





            if~isempty(obj.ReferenceBlock)
                fullBockPath=strsplit(obj.ReferenceBlock,'/');
                blockType=fullBockPath{end};
            end
            blockType=strrep(blockType,newline,' ');

            if obj.Count>1
                messageName='learning:simulink:genericRequirements:blockExistencePlural';
                blockType=['(',num2str(obj.Count),') ',blockType];
            elseif obj.Count==0
                messageName='learning:simulink:genericRequirements:blockAbsence';
            else
                messageName='learning:simulink:genericRequirements:blockExistence';
            end
            blockName=[newline,'     ',blockType];
            requirementString=message(messageName,blockName).getString();
        end
    end

    methods(Access=protected)
        function validateProps(~,props)
            hasAllProps=~isempty(props.BlockType);
            if isequal(props.BlockType,'SimscapeBlock')
                hasAllProps=hasAllProps&&~isempty(props.ReferenceBlock);
            end

            if~hasAllProps
                error(message('learning:simulink:resources:MissingParameters'));
            end
        end
    end
end
