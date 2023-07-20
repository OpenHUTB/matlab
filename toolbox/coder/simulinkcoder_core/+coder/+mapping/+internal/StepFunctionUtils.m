

classdef StepFunctionUtils


    methods(Static,Access=public)
        function stepFcnName=getStepFcnName(hModel,func)
            if strcmpi(func.name,'USE_DEFAULT_FROM_FUNCTION_CLASSES')

                namingRule=coder.mapping.internal.StepFunctionMapping.getNamingRuleFromMapping...
                (hModel,'Execution');
                if isempty(namingRule)
                    namingRule='$R$N';
                end
                modelname=get_param(hModel,'Name');
                stepFcnName=slInternal('getIdentifierUsingNamingService',...
                modelname,namingRule,'step');
            else
                stepFcnName=func.name;
            end
        end

        function numArgs=getNumArgs(func)
            numArgs=length(func.arguments)+length(func.returnArguments);
        end

        function argName=getArgName(func,position)
            if~isempty(func.returnArguments)
                if position==1
                    argName=func.returnArguments{1}.name;
                else
                    argName=func.arguments{position-1}.name;
                end
            else
                argName=func.arguments{position}.name;
            end
        end

        function qualifier=getQualifier(func,position)
            if~isempty(func.returnArguments)
                if position==1
                    qualifier='none';
                    return;
                else
                    a=func.arguments{position-1};
                    qualifier=a.qualifier;
                end
            else
                a=func.arguments{position};
                qualifier=a.qualifier;
            end

            if strcmpi(char(a.passBy),'Reference')
                if strcmpi(qualifier,'Const')
                    qualifier='const &';
                else
                    qualifier='&';
                end
            else
                if strcmpi(char(a.passBy),'Pointer')&&strcmpi(qualifier,'Const')
                    qualifier='const *';
                elseif strcmpi(qualifier,'ConstPointerToConstData')
                    qualifier='const * const';
                elseif strcmpi(qualifier,'None')
                    qualifier='none';
                elseif strcmpi(qualifier,'Const')
                    qualifier='const';
                end
            end
        end

        function category=getCategory(func,position)
            if~isempty(func.returnArguments)
                if position==1
                    category=char(func.returnArguments{1}.passBy);
                else
                    category=char(func.arguments{position-1}.passBy);
                end
            else
                category=char(func.arguments{position}.passBy);
            end
        end

        function type=getSLObjectType(modelHandle,func,position)
            modelname=get_param(modelHandle,'Name');
            name=coder.mapping.internal.StepFunctionMapping.getNameFromPosition(modelname,func,position);
            [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(modelHandle);
            isCppEnabled=strcmp(mappingType,'CppModelMapping');

            if isCppEnabled
                isEnablePort=strcmpi(get_param(name,'BlockType'),'EnablePort');
                isTriggerPort=strcmpi(get_param(name,'BlockType'),'TriggerPort');

                if isEnablePort
                    type='Inport';
                elseif isTriggerPort
                    trigType=get_param(name,'TriggerType');
                    if~strcmpi(trigType,'function-call')
                        type='Inport';
                    end
                else
                    type=get_param(name,'BlockType');
                end
            else
                type=get_param(name,'BlockType');
            end
        end

        function num=getPortNum(modelHandle,func,position)
            modelname=get_param(modelHandle,'Name');
            name=coder.mapping.internal.StepFunctionMapping.getNameFromPosition(modelname,func,position);
            num=str2double(get_param(name,'Port'));
        end


        function num=getCppPortNum(modelHandle,func,position)
            modelname=get_param(modelHandle,'Name');
            name=coder.mapping.internal.StepFunctionMapping.getNameFromPosition(modelname,func,position);
            isEnablePort=strcmpi(get_param(name,'BlockType'),'EnablePort');
            isTriggerPort=strcmpi(get_param(name,'BlockType'),'TriggerPort');


            if isEnablePort||isTriggerPort
                inpH=coder.mapping.internal.StepFunctionMapping.getInportHandles(modelHandle);
                inportNames=get_param(inpH,'Name');
                blockName=get_param(name,'Name');
                [~,portmIdx]=intersect(inportNames,{blockName});
                if~isempty(portmIdx)
                    num=portmIdx;
                end
            else
                num=str2double(get_param(name,'Port'));
            end
        end

    end
end
