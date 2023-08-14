function setIndividualFunctionProperties(modelName,modelMapping,fcnId,argParser)




    if~contains(fcnId,':')
        functionType=fcnId;
        slFcnName='';
    else
        functionType=strtrim(extractBefore(fcnId,':'));
        slFcnName=extractAfter(fcnId,':');
        if~isequal(functionType,'ExportedFunction')




            slFcnName=strtrim(slFcnName);
        end
    end
    result=validatestring(functionType,coder.mapping.internal.functionTypes(),...
    'setFunction','FUNCTIONTYPE',2);
    functionType=result;

    slFcnName=char(slFcnName);
    [mapping,category]=coder.mapping.internal.getFunctionMapping(modelName,modelMapping,functionType,slFcnName);
    if length(mapping)~=1
        DAStudio.error('coderdictionary:api:FunctionMappingNotFound',...
        modelName,functionType,num2str(slFcnName));
    elseif isequal(functionType,'SimulinkFunction')&&...
        ~codermapping.internal.simulinkfunction.doesFunctionHaveSimulinkFunctionBlock(...
        get_param(modelName,'Handle'),mapping.SimulinkFunctionName)
        DAStudio.error('coderdictionary:api:MappingIsFunctionCaller',...
        modelName,functionType,slFcnName,'setFunctionCaller');
    end

    allowedProps=coder.mapping.internal.allowedFunctionProperties(modelName,modelMapping,functionType,slFcnName);

    MemorySection=argParser.Results.MemorySection;
    FunctionCustomizationTemplate=argParser.Results.FunctionCustomizationTemplate;
    modelH=get_param(modelName,'Handle');

    if~isempty(FunctionCustomizationTemplate)
        FunctionCustomizationTemplate=validatestring(FunctionCustomizationTemplate,modelMapping.DefaultsMapping.getAllowedFunctionClassNames(category,'IndividualLevel'));
        if strcmp(FunctionCustomizationTemplate,DAStudio.message('coderdictionary:api:FunctionDefault'))

            mapping.unmapFunctionClass();
        elseif strcmp(FunctionCustomizationTemplate,DAStudio.message('coderdictionary:api:ModelDefault'))||...
            strcmp(FunctionCustomizationTemplate,DAStudio.message('coderdictionary:mapping:PlatformDefault'))

            mapping.mapFunctionClass('')
        else
            uuid=codermapping.internal.c.dictionary.getFunctionCustomizationTemplateUuidFromName(...
            modelH,FunctionCustomizationTemplate,category);
            mapping.mapFunctionClass(uuid)
        end
    end

    if~isempty(MemorySection)
        if modelMapping.isFunctionPlatform
            DAStudio.error('coderdictionary:api:invalidPropertyName','MemorySection',...
            'mapping','function',functionType,strjoin(allowedProps,', '));
        end

        MemorySection=validatestring(MemorySection,modelMapping.DefaultsMapping.getAllowedMemorySectionNames(category,'IndividualLevel'));
        if strcmp(MemorySection,DAStudio.message('coderdictionary:api:None'))

            mapping.unmapMemorySection()
        elseif strcmp(MemorySection,DAStudio.message('coderdictionary:api:ModelDefault'))

            mapping.mapMemorySection('')
        else
            uuid=modelMapping.DefaultsMapping.getMemorySectionUuidFromName(MemorySection);
            mapping.mapMemorySection(uuid)
        end
    end

    isPublicSimulinkFunction=false;
    if strcmp(functionType,'SimulinkFunction')
        fcnBlock=coder.mapping.internal.SimulinkFunctionMapping.getSimulinkFunctionOrCallerBlock(...
        modelName,slFcnName);
        isPublicSimulinkFunction=coder.mapping.internal.SimulinkFunctionMapping.isPublicFcn(...
        fcnBlock,slFcnName);
    end

    params=argParser.Unmatched;
    if~isempty(fields(params))

        propertyNames=transpose(fieldnames(params));
        for prop=propertyNames
            if isequal(prop{1},'FunctionName')
                FunctionName=params.(prop{1});
                isEmptyDisallowed=false;
                isDollarMTokenAllowed=true;
                if strcmp(functionType,'SimulinkFunction')
                    if isPublicSimulinkFunction


                        DAStudio.error('coderdictionary:api:ScopedSimulinkFunctionCustomName',...
                        fcnBlock);
                    end

                    isEmptyDisallowed=true;
                    isDollarMTokenAllowed=false;
                end
                isValid=simulinkcoder.internal.slfpc.EntryFunctionControlUI.isValidIdentifier(...
                FunctionName,isEmptyDisallowed,isDollarMTokenAllowed);
                if~isValid
                    DAStudio.error('coderdictionary:mapping:InvalidFunctionName',...
                    modelName,FunctionName);
                end
                mapping.setCodeFunctionName(FunctionName);
            elseif isequal(prop{1},'Arguments')&&...
                any(ismember(allowedProps,'Arguments'))
                coder.mapping.internal.setArgumentString(modelName,mapping,functionType,slFcnName,params.(prop{1}))
            elseif isequal(prop{1},'TimerService')&&...
                any(ismember(allowedProps,'TimerService'))
                timerServiceName=params.(prop{1});
                timerServiceName=validatestring(timerServiceName,...
                codermapping.internal.c.dictionary.getAllowedTimerServiceNames(modelH));

                if isequal(timerServiceName,DAStudio.message('coderdictionary:mapping:PlatformDefault'))
                    tsUUID='';
                else
                    coderData=coderdictionary.data.SlCoderDataClient.getElementByNameOfCoderDataType(...
                    modelH,'TimerService',timerServiceName);
                    tsUUID=coderData.getProperty('UUID');
                end
                mapping.mapTimerService(tsUUID);
            else
                mappingType='mapping';
                if isPublicSimulinkFunction

                    allowedProps(ismember(allowedProps,'FunctionName'))=[];
                end

                if~any(strcmp(prop{1},allowedProps))
                    if isempty(slFcnName)
                        DAStudio.error('coderdictionary:api:invalidPropertyName',prop{1},...
                        mappingType,'function',functionType,strjoin(allowedProps,', '));
                    else
                        DAStudio.error('coderdictionary:api:invalidPropertyName',prop{1},...
                        mappingType,[functionType,' function'],num2str(slFcnName),strjoin(allowedProps,', '));
                    end
                end
            end
        end

    end

    if isempty(FunctionCustomizationTemplate)&&isempty(MemorySection)...
        &&isempty(fields(params))
        DAStudio.error('coderdictionary:api:UnspecifiedPropertyName',...
        argParser.FunctionName,strjoin(allowedProps,', '));
    end

end


