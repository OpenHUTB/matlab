classdef StudentBlockParameter<learning.assess.assessments.StudentAssessment




    properties(Constant)
        type='BlockParameter';
    end

    properties
BlockType
ReferenceBlock
Parameter
Count
    end

    properties(Hidden,Access=protected)



        ParameterStruct=struct('ParameterName','',...
        'ParameterValue','','ParameterUnitsName','',...
        'ParameterUnitsValue','');
    end

    methods
        function obj=StudentBlockParameter(props)

            obj.validateProps(props);

            obj.BlockType=props.BlockType;
            obj.ReferenceBlock=props.ReferenceBlock;
            obj.Parameter=props.Parameter;
            if isfield(props,'Count')
                obj.Count=props.Count;
            else
                obj.Count=1;
            end
        end

        function isCorrect=assess(obj,userModelName)



            obj.validateProps(obj);




            possibleBlockHandles=find_system(userModelName,'FindAll','on','LookUnderMasks','on','FollowLinks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType',obj.BlockType,'ReferenceBlock',obj.ReferenceBlock);







            numParameters=length(obj.Parameter);
            correctCount=0;
            for i=1:length(possibleBlockHandles)
                numCorrectParameters=0;
                for j=1:numParameters
                    currentIsCorrect=false;
                    currentParam=obj.Parameter(j);



                    try
                        currentParamValue=slResolve(currentParam.ParameterValue,userModelName);
                    catch
                        currentParamValue=currentParam.ParameterValue;
                    end

                    userParamValue=get_param(possibleBlockHandles(i),currentParam.ParameterName);



                    try
                        userParamValue=slResolve(userParamValue,possibleBlockHandles(i));
                    catch




                    end

                    if isempty(currentParam.ParameterUnitsName)

                        currentIsCorrect=learning.simulink.internal.util.CourseUtils().isParamValueEqual(currentParamValue,userParamValue);
                    else



                        userParamUnits=get_param(possibleBlockHandles(i),currentParam.ParameterUnitsName);
                        userParam=pm_value(userParamValue,userParamUnits);
                        answerParam=pm_value(currentParamValue,currentParam.ParameterUnitsValue);
                        if pm_commensurate(userParam.unit,answerParam.unit)&&...
                            abs(userParam.value(answerParam.unit)-answerParam.value(answerParam.unit))<eps
                            currentIsCorrect=true;
                        end
                    end

                    if currentIsCorrect
                        numCorrectParameters=numCorrectParameters+1;
                    else
                        break;
                    end
                end

                if isequal(numCorrectParameters,numParameters)
                    correctCount=correctCount+1;
                end
            end
            isCorrect=correctCount>=obj.Count;



            if~isCorrect&&~isempty(obj.ReferenceBlock)
                learning.assess.throwWarningIfUsingWrongLibrary(userModelName,obj.ReferenceBlock);
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

            if obj.Count>1
                messageName='learning:simulink:genericRequirements:blockParameterPlural';
                blockType=['(',num2str(obj.Count),') ',blockType];
            else
                messageName='learning:simulink:genericRequirements:blockParameter';
            end
            blockName=[newline,'     ',blockType,':'];
            allParametersText='';
            for i=1:length(obj.Parameter)
                parameterPrompt=obj.getParamPromptFromName(obj.Parameter(i).ParameterName);
                parameterValueText=learning.simulink.internal.util.getParamValueText(obj.Parameter(i).ParameterValue,obj.BlockType);


                if isequal(obj.Parameter(i).ParameterUnitsValue,'1')
                    parameterUnitsValue='';
                else
                    parameterUnitsValue=obj.Parameter(i).ParameterUnitsValue;
                end
                currentParameterText=['          ',parameterPrompt,': ',parameterValueText,' ',parameterUnitsValue];
                allParametersText=[allParametersText,newline,currentParameterText];
            end
            requirementString=message(messageName,[blockName,allParametersText]).getString();
        end

        function parameterPrompt=getParamPromptFromName(obj,parameterName)





            parameterPrompt=parameterName;
            if~isequal(obj.BlockType,'SimscapeBlock')
                return;
            end


            blockPath=replace(obj.ReferenceBlock,'\n',' ');
            libPath=strsplit(blockPath,'/');
            libPath=libPath{1};
            load_system(libPath);
            blockPromptTable=foundation.internal.mask.getEvaluatedBlockParameters(blockPath);
            bdclose(libPath);
            lowerCaseRowNames=cellfun(@(x)lower(x),blockPromptTable.Row,'UniformOutput',false);
            isMatch=cellfun(@(x)isequal(x,lower(parameterName)),lowerCaseRowNames);
            if any(isMatch)


                parameterPrompt=blockPromptTable(isMatch,:).Prompt{1};
            end
        end
    end

    methods(Access=protected)
        function validateProps(obj,props)
            hasAllProps=~isempty(props.BlockType)&&~isempty(props.Parameter);
            if isequal(props.BlockType,'SimscapeBlock')
                hasAllProps=hasAllProps&&~isempty(props.ReferenceBlock);
            end


            for i=1:length(props.Parameter)
                if~obj.isParameterValid(props.Parameter(i))
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
