classdef StudentBlockSimpleCode<learning.assess.assessments.StudentAssessment


    properties(Constant)
        type='BlockSimpleCode';
    end

    properties
BlockType
ReferenceBlock
ParameterName
Code
    end

    methods
        function obj=StudentBlockSimpleCode(props)
            obj.validateProps(props);

            obj.BlockType=props.BlockType;
            obj.ReferenceBlock=props.ReferenceBlock;
            obj.ParameterName=props.ParameterName;
            obj.Code=props.Code;
        end

        function isCorrect=assess(obj,userModelName)
            isCorrect=false;
            possibleBlockHandles=Simulink.findBlocks(userModelName,...
            'BlockType',obj.BlockType,'ReferenceBlock',obj.ReferenceBlock);
            for i=1:length(possibleBlockHandles)
                currentBlocksCode=get_param(possibleBlockHandles(i),obj.ParameterName);
                userCode=obj.cleanCode(currentBlocksCode);
                answerCode=obj.cleanCode(obj.Code);
                linesMatch=cellfun(@(x)any(strcmp(x,userCode)),answerCode);
                if all(linesMatch)
                    isCorrect=true;
                    return
                end
            end
        end

        function requirementString=generateRequirementString(obj)
            blockType=learning.assess.getDefaultBlockName(obj.BlockType);
            if~isempty(obj.ReferenceBlock)
                blockPath=obj.ReferenceBlock;
                blockPathSplit=strsplit(blockPath,'/');
                blockType=blockPathSplit{end};
            end
            blockType=strrep(blockType,newline,' ');
            messageName='learning:simulink:genericRequirements:blockParameter';
            blockName=[newline,'     ',blockType,':'];
            allParametersText=[newline,'          ',obj.ParameterName,':'];
            splitCode=strsplit(obj.Code,'\n');
            for i=1:length(splitCode)
                currentParameterText=['               ',splitCode{i}];
                allParametersText=[allParametersText,newline,currentParameterText];
            end
            requirementString=message(messageName,[blockName,allParametersText]).getString();
        end
    end

    methods(Static,Access=protected)
        function validateProps(props)
            hasAllProps=~isempty(props.BlockType)&&~isempty(props.ParameterName)&&~isempty(props.Code);

            if isequal(props.BlockType,'SimscapeBlock')
                hasAllProps=hasAllProps&&~isempty(props.ReferenceBlock);
            end

            if~hasAllProps
                error(message('learning:simulink:resources:MissingParameters'));
            end
        end

        function codeBlocks=cleanCode(code)

            normalizedCode=strrep(code,' ','');


            normalizedCode=strrep(normalizedCode,[';',newline],newline);
            expression=';$';
            idx=regexp(normalizedCode,expression);
            normalizedCode(idx)='';

            expression='\n';
            codeBlocks=regexp(normalizedCode,expression,'split');

            blankLines=cellfun(@(x)isempty(x),codeBlocks);
            codeBlocks(blankLines)=[];
        end
    end
end