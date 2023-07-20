function migrateVCD(configsObj,modelName,varargin)










    if~isa(configsObj,'Simulink.VariantConfigurationData')
        return;
    end

    if numel(varargin)==0
        optArgs=struct();
    else
        optArgs=varargin{1};
    end

    if isfield(optArgs,'SkipControlVarsAndConstraints')&&optArgs.SkipControlVarsAndConstraints
        return;
    end

    if configsObj.AreSubModelConfigurationsMigrated
        return;
    end
    configsObj.AreSubModelConfigurationsMigrated=true;


    oldConfigurations=configsObj.VariantConfigurations;
    nConfigurations=numel(oldConfigurations);
    if nConfigurations>0
        processedModels={};
        newConfigurations(1,nConfigurations)=slvariants.internal.config.types.getVariantConfigurationStruct();
        for configIdx=1:nConfigurations
            newConfigurations(configIdx)=createConfiguration(modelName,oldConfigurations(configIdx),processedModels);
        end
        configsObj.setVariantConfigurations(newConfigurations);
    end


    oldConstraints=configsObj.Constraints;
    if~isempty(oldConstraints)
        configsObj.setConstraints(oldConstraints);
    end
end

function newConfiguration=createConfiguration(currentModelName,oldConfiguration,processedModels)
    newConfiguration=slvariants.internal.config.types.getVariantConfigurationStruct();
    newConfiguration.Name=oldConfiguration.Name;
    newConfiguration.Description=oldConfiguration.Description;

    oldCtrlVars=oldConfiguration.ControlVariables;
    nCtrlVars=numel(oldCtrlVars);
    newCtrlVars=repmat(emptyCtrlVar(),1,nCtrlVars);




    hasSourceSpecified=isfield(oldCtrlVars,'Source');
    for ctrlVarIdx=1:nCtrlVars
        newCtrlVars(ctrlVarIdx).Name=oldCtrlVars(ctrlVarIdx).Name;
        newCtrlVars(ctrlVarIdx).Value=getCtrlVarValue(oldCtrlVars(ctrlVarIdx).Value);
        if hasSourceSpecified&&~isempty(oldCtrlVars(ctrlVarIdx).Source)
            newCtrlVars(ctrlVarIdx).Source=oldCtrlVars(ctrlVarIdx).Source;


            if strcmp(newCtrlVars(ctrlVarIdx).Source,'Base workspace')


                newCtrlVars(ctrlVarIdx).Source='base workspace';
            end
        end
    end


    [refCtrlVars,refSubModelConfigs]=processSubModelConfigurations(oldConfiguration.SubModelConfigurations,processedModels);

    for ctrlVarIdx=numel(refCtrlVars):-1:1
        for j=1:numel(newCtrlVars)
            if strcmp(newCtrlVars(j).Name,refCtrlVars(ctrlVarIdx).Name)&&...
                strcmp(newCtrlVars(j).Source,refCtrlVars(ctrlVarIdx).Source)
                if~isequal(newCtrlVars(j).Value,refCtrlVars(ctrlVarIdx).Value)
                    newValueStr=getUnderlyingValueStr(newCtrlVars(j).Value);
                    refValueStr=getUnderlyingValueStr(refCtrlVars(ctrlVarIdx).Value);
                    warn=MSLException('Simulink:VariantManager:VCDMigrateControlVarsConflict',...
                    refValueStr,...
                    newValueStr,...
                    newCtrlVars(j).Name,...
                    newConfiguration.Name);
                    warnBTState=warning('off','backtrace');
                    cleanupObj=onCleanup(@()warning(warnBTState.state,warnBTState.identifier));
                    sldiagviewer.reportWarning(warn);
                    cleanupObj=[];%#ok<NASGU>
                    newCtrlVars(j).Value=refCtrlVars(ctrlVarIdx).Value;
                end
                refCtrlVars(ctrlVarIdx)=[];
                break;
            end
        end
    end

    newConfiguration.ControlVariables=[newCtrlVars,refCtrlVars];

    for refIdx=numel(refSubModelConfigs):-1:1
        for j=1:numel(oldConfiguration.SubModelConfigurations)
            if strcmp(oldConfiguration.SubModelConfigurations(j).ModelName,refSubModelConfigs(refIdx).ModelName)
                if~strcmp(oldConfiguration.SubModelConfigurations(j).ConfigurationName,refSubModelConfigs(refIdx).ConfigurationName)
                    warn=MSLException('Simulink:VariantManager:VCDMigrateSubModelConflict',...
                    oldConfiguration.SubModelConfigurations(j).ConfigurationName,...
                    refSubModelConfigs(refIdx).ConfigurationName,...
                    refSubModelConfigs(refIdx).ModelName,...
                    newConfiguration.Name);
                    warnBTState=warning('off','backtrace');
                    cleanupObj=onCleanup(@()warning(warnBTState.state,warnBTState.identifier));
                    sldiagviewer.reportWarning(warn);
                    cleanupObj=[];%#ok<NASGU>
                end
                refSubModelConfigs(refIdx)=[];
                break;
            end
        end
    end

    newConfiguration.SubModelConfigurations=[oldConfiguration.SubModelConfigurations,refSubModelConfigs];


    function ctrlVarStruct=emptyCtrlVar()
        ddName=get_param(currentModelName,'DataDictionary');
        if isempty(ddName)
            defaultSource='base workspace';
        else
            defaultSource=ddName;
        end
        ctrlVarStruct=slvariants.internal.config.types.getControlVariableStruct();
        ctrlVarStruct.Source=defaultSource;
    end
end

function val=getCtrlVarValue(oldVal)
    val=oldVal;
    if isa(val,'char')
        try %#ok<TRYNC> 
            val=eval(val);
        end
    end
end

function[refCtrlVars,refSubModelConfigs]=processSubModelConfigurations(subModelConfigs,processedModels)
    refCtrlVars=slvariants.internal.config.types.getControlVariableStruct(true);
    refSubModelConfigs=slvariants.internal.config.types.getSubModelConfigurationStruct(true);
    for smcIdx=1:numel(subModelConfigs)
        subModelConfig=subModelConfigs(smcIdx);
        subModelName=subModelConfig.ModelName;
        subModelConfigName=subModelConfig.ConfigurationName;

        if ismember(subModelName,processedModels)
            continue;
        else
            processedModels{end+1}=subModelName;%#ok<AGROW>
        end

        if~bdIsLoaded(subModelName)
            try
                load_system(subModelName);

                subVcdoObj=Simulink.VariantConfigurationData.getFor(subModelName);
            catch loadExcep


                issueSMCWarning(loadExcep);
                continue;
            end
        end

        subModelVCDName=get_param(subModelName,'VariantConfigurationObject');
        if isempty(subModelVCDName)


            issueSMCWarning(MSLException('Simulink:VariantManager:ModelVCDNameIsEmpty',subModelName));
            continue;
        end

        exprToEval=['exist(','''',subModelVCDName,'''',',','''var''',')'];
        if evalinConfigurationsScope(subModelName,exprToEval)==0


            issueSMCWarning(MSLException('Simulink:Variants:ConfigDataNotFound',subModelVCDName));
            continue;
        end

        warnStateDC=warning('off','Simulink:VariantManager:DefaultConfigurationRemoved');
        warnStateSMC=warning('off','Simulink:VariantManager:SubModelConfigsRemoved');
        warnStateDCCleanup=onCleanup(@()warning(warnStateDC));
        warnStateSMCCleanup=onCleanup(@()warning(warnStateSMC));

        wsConfigSrc=evalinConfigurationsScope(subModelName,subModelVCDName);
        warnStateDCCleanup=[];warnStateSMCCleanup=[];%#ok<NASGU>
        if isa(wsConfigSrc,'Simulink.VariantConfigurationData')
            refOldConfig=getConfig(wsConfigSrc.VariantConfigurations);
            if isempty(refOldConfig)


                issueSMCWarning(MSLException('Simulink:Variants:ConfigNotFoundinVCDOForModel',...
                subModelConfigName,subModelVCDName,subModelName));
                continue;
            end
            refConfigObj=createConfiguration(subModelName,refOldConfig,processedModels);
        else


            issueSMCWarning(MSLException('Simulink:Variants:ConfigDataNotFound',subModelVCDName));
            continue;
        end

        tmpCtrlVars=refConfigObj.ControlVariables;
        for ctrlVarIdx=numel(tmpCtrlVars):-1:1
            for j=1:numel(refCtrlVars)
                if strcmp(refCtrlVars(j).Name,tmpCtrlVars(ctrlVarIdx).Name)&&...
                    strcmp(refCtrlVars(j).Source,tmpCtrlVars(ctrlVarIdx).Source)
                    if~isequal(refCtrlVars(j).Value,tmpCtrlVars(ctrlVarIdx).Value)
                        refValueStr=getUnderlyingValueStr(refCtrlVars(j).Value);
                        tmpValueStr=getUnderlyingValueStr(tmpCtrlVars(ctrlVarIdx).Value);
                        warn=MSLException('Simulink:VariantManager:VCDMigrateControlVarsConflict',...
                        tmpValueStr,...
                        refValueStr,...
                        refCtrlVars(j).Name,...
                        subModelConfig.ConfigurationName);
                        warnBTState=warning('off','backtrace');
                        cleanupObj=onCleanup(@()warning(warnBTState.state,warnBTState.identifier));
                        sldiagviewer.reportWarning(warn);
                        cleanupObj=[];%#ok<NASGU>
                        refCtrlVars(j).Value=tmpCtrlVars(ctrlVarIdx).Value;
                    end
                    tmpCtrlVars(ctrlVarIdx)=[];
                    break;
                end
            end
        end

        refCtrlVars=[refCtrlVars,tmpCtrlVars];%#ok<AGROW>
        refSubModelConfigs=[refSubModelConfigs,refConfigObj.SubModelConfigurations];%#ok<AGROW>
    end

    function config=getConfig(configs)
        config=[];
        for configIdx=1:numel(configs)
            if strcmp(subModelConfigName,configs(configIdx).Name)
                config=configs(configIdx);
                break;
            end
        end
    end

    function issueSMCWarning(actWarning)



        if slfeature('VMGRV2UI')<2
            return;
        end

        headerWarning=MSLException('Simulink:VariantManager:VCDMigrateSubModelMissing',...
        subModelConfigName,subModelName);
        headerWarning=headerWarning.addCause(actWarning);

        warnBTState=warning('off','backtrace');
        cleanup=onCleanup(@()warning(warnBTState.state,warnBTState.identifier));

        sldiagviewer.reportWarning(headerWarning);
    end
end

function valueStr=getUnderlyingValueStr(value)
    if isa(value,'Simulink.VariantControl')
        value=value.Value;
    end
    if isa(value,'Simulink.Parameter')
        value=value.Value;
    end
    valueStr=slvariants.internal.config.utils.iNum2Str(value);
end


