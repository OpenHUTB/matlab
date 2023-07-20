function resolvedName=getResolvedFunctionName(mapObj,model,modelElementCategory)





    mdlH=get_param(model,'Handle');
    [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(mdlH);
    isCppMapping=strcmp(mappingType,'CppModelMapping');
    isPublicSimulinkFcn=false;
    isGlobalSimulinkFcn=false;
    useSimulinkDefault=false;
    namingRule='';
    dollarN='';
    defaultsCategory='InitializeTerminate';

    baseRateName='';
    if isCppMapping&&...
        isequal(modelElementCategory,'OutputFunctionMappings')
        baseRateName=modelMapping.OutputFunctionMappings(1).getCodeFunctionName();
        if~isempty(baseRateName)












            baseRateName=slInternal('getIdentifierUsingNamingService',...
            model,baseRateName,'step');
        end
    end


    switch(modelElementCategory)
    case 'OneShotFunctionMappings'
        defaultsCategory='InitializeTerminate';
        if isequal(mapObj.SimulinkFunctionName,'Initialize')
            dollarN='initialize';
        else
            dollarN='terminate';
        end
    case 'OutputFunctionMappings'
        defaultsCategory='Execution';
        tid='';
        if startsWith(mapObj.SimulinkFunctionName,'Step')
            dollarN='step';
            tid=regexp(mapObj.SimulinkFunctionName,'Step(\d+)','tokens');
        elseif startsWith(mapObj.SimulinkFunctionName,'Output')
            dollarN='output';
            tid=regexp(mapObj.SimulinkFunctionName,'Output(\d+)','tokens');
        end
        if~isempty(tid)
            if~isempty(baseRateName)&&~isequal(tid{1}{1},'0')

                dollarN=baseRateName;
            end
            dollarN=strcat(dollarN,tid{1}{1});
        end
    case 'UpdateFunctionMappings'
        defaultsCategory='Execution';
        dollarN='update';
        tid=regexp(mapObj.SimulinkFunctionName,'Update(\d+)','tokens');
        if~isempty(tid)
            dollarN=strcat(dollarN,tid{1}{1});
        end
    case 'FcnCallInports'
        defaultsCategory='Execution';
        portHandles=get_param(mapObj.Block,'PortHandles');
        outputPort=portHandles.Outport;
        signalLabel=get(outputPort,'label');
        if~isempty(signalLabel)
            dollarN=signalLabel;
        else
            dollarN=get_param(mapObj.Block,'Name');
        end
    case 'ResetFunctions'
        defaultsCategory='Execution';
        dollarN=mapObj.SimulinkFunctionName;
    case 'ServerFunctions'
        defaultsCategory='Execution';
        dollarN=mapObj.SimulinkFunctionName;
        fcnBlock=coder.mapping.internal.SimulinkFunctionMapping.getSimulinkFunctionOrCallerBlock(...
        model,dollarN);
        [isPublicSimulinkFcn,~,~,~]=...
        coder.mapping.internal.isPublicSimulinkFunction(fcnBlock);
        if~isPublicSimulinkFcn
            isGlobalSimulinkFcn=true;
        end
    end


    if(isGlobalSimulinkFcn)

        namingRule=mapObj.getCodeFunctionName();
        if isempty(namingRule)

            [namingRule,~]=Simulink.CodeMapping.getNamingRuleFromFunctionClass(mapObj,mdlHl,defaultsCategory);
        end
        if isempty(namingRule)

            namingRule='$N';
        end
    else
        if isPublicSimulinkFcn




        else
            if~isempty(mapObj.getCodeFunctionName())

                namingRule=mapObj.getCodeFunctionName();
            end
        end
        if isempty(namingRule)
            if~isPublicSimulinkFcn

                [namingRule,useSimulinkDefault]=Simulink.CodeMapping.getNamingRuleFromFunctionClass(mapObj,mdlH,defaultsCategory);
            end

            if isempty(namingRule)
                if isa(modelMapping,'Simulink.CoderDictionary.ModelMapping')&&...
                    modelMapping.isFunctionPlatform

                    hlp=coder.internal.CoderDataStaticAPI.getHelper();
                    dataDict=get_param(mdlH,'EmbeddedCoderDictionary');
                    if isempty(dataDict)
                        dataDict=get_param(mdlH,'DataDictionary');
                    end
                    dd=hlp.openDD(dataDict);
                    cdType=Simulink.CodeMapping.getCoderDataTypeForFunctionCategory(modelMapping,defaultsCategory);
                    platformDefault=hlp.getPlatformDefault(dd,cdType);
                    namingRule=platformDefault.FunctionName;
                else

                    namingRule=coder.mapping.internal.StepFunctionMapping.getNamingRuleFromMapping(...
                    mdlH,defaultsCategory);
                end
            end
        end
    end

    isMDSFunction=isMDSEntryPoint(model,modelElementCategory);

    if isMDSFunction
        dollarN=getMDSEntryPointName(model,mapObj,dollarN);
    end

    if(useSimulinkDefault||isempty(namingRule))

        if isequal(modelElementCategory,'FcnCallInports')
            if isequal(get_param(model,'IsExportFunctionModel'),'on')
                namingRule='$N';
            else

                namingRule=get_param(model,'CustomSymbolStrFcn');
            end
        elseif isequal(modelElementCategory,'ResetFunctions')


            namingRule='$R$N';
        else
            if isCppMapping||isMDSFunction
                namingRule='$N';
            else
                namingRule='$R$N';
            end
        end
    end
    resolvedName=slInternal('getIdentifierUsingNamingService',...
    model,namingRule,dollarN);
end

function tf=isMDSEntryPoint(model,modelElementCategory)
    tf=strcmp(get_param(model,'ExplicitPartitioning'),'on')&&...
    matlab.internal.feature('SLMulticoreCodeMapping')>0&&...
    any(strcmp(modelElementCategory,...
    {'OutputFunctionMappings','UpdateFunctionMappings','FcnCallInports'}));
end

function dollarN=getMDSEntryPointName(model,mapObj,dollarN)


    if isa(mapObj,'Simulink.CoderDictionary.BlockFcnMapping')||...
        isa(mapObj,'Simulink.CppModelMapping.BlockFcnMapping')


        taskName=Simulink.CodeMapping.getMDSAperiodicTaskName(...
        model,get_param(mapObj.Block,'Handle'));
        if~isempty(taskName)
            dollarN=taskName;
        end
    elseif isa(mapObj,'Simulink.CoderDictionary.PeriodicFunctionMapping')||...
        isa(mapObj,'Simulink.CppModelMapping.PeriodicFunctionMapping')



        if startsWith(mapObj.SimulinkFunctionName,'Step')
            suffix='step';
        elseif startsWith(mapObj.SimulinkFunctionName,'Output')
            suffix='output';
        elseif startsWith(mapObj.SimulinkFunctionName,'Update')
            suffix='update';
        end

        dollarN=[mapObj.PartitionName,'_',suffix];
    end
end
