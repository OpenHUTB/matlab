function[validationErrorsForHierarchy,validationLog,createModelInfoLog]=validateModelCoreImplementation(modelName,validationLog,optArgs)






    import Simulink.variant.manager.errorutils.*;


    Simulink.variant.utils.reportDiagnosticIfV2Enabled();

    validationErrorsForHierarchy={};

    calledFromTool=optArgs.CalledFromTool;
    hotlinkErrors=optArgs.HotlinkErrors;

    if isempty(optArgs.RootPathPrefix)
        rootPathPrefix=modelName;
    else
        rootPathPrefix=optArgs.RootPathPrefix;
    end

    variantConfigurationObject=optArgs.VariantConfigurationObject;
    variantConfigurationObjectName=optArgs.VariantConfigurationObjectName;
    configurationName=optArgs.ConfigurationName;

    createModelInfoLog=[];


    if isfield(optArgs,'ModelsSoFar')
        modelsSoFar=[optArgs.ModelsSoFar,modelName];
    else
        modelsSoFar={modelName};
    end
    errors={};

    if~calledFromTool





        variantmanager('WarnIfVMHadUnexportedChanges',modelName);
    end

    if Simulink.variant.utils.getIsSimulationPausedOrRunning(modelName)

        excepObj=MSLException(message('Simulink:VariantManager:ActivationWhileRunningSimulationNotSupported',modelName));
        error=getValidationError(excepObj,'Model',modelName,modelName);
        errors{end+1}=error;
    end

    if isempty(variantConfigurationObject)&&isempty(errors)
        if isfield(optArgs,'ConfigurationName')&&~isempty(optArgs.ConfigurationName)

            if isempty(variantConfigurationObjectName)



                messageId='Simulink:Variants:VCDONotFound';
                excepObj=MSLException(get_param(modelName,'Handle'),message(messageId,modelName));
                errors{end+1}=getValidationError(...
                excepObj,'Model',modelName,rootPathPrefix);
            else



                messageId='Simulink:Variants:ConfigDataNotFoundForConfig';
                excepObj=MSLException(get_param(modelName,'Handle'),message(messageId,...
                variantConfigurationObjectName,optArgs.ConfigurationName,modelName));
                errors{end+1}=getValidationError(...
                excepObj,'Model',modelName,rootPathPrefix);
            end
        elseif~isempty(variantConfigurationObjectName)



            messageId='Simulink:Variants:ConfigDataNotFound';
            excepObj=MException(message(messageId,variantConfigurationObjectName));
            errors{end+1}=getValidationError(excepObj,'Model',modelName,rootPathPrefix);

            variantConfigurationObject=Simulink.VariantConfigurationData;
        end
    end

    if~isempty(errors)&&~calledFromTool
        validationErrorsForHierarchy{end+1}=getValidationErrorForModel(modelName,errors);
        return;
    end




    if~isempty(validationLog)
        numModels=length(validationLog);
        for i=1:numModels
            nameOfPreviouslyValidatedModel=validationLog(i).Model;

            previouslyValidatedConfig=validationLog(i).Configuration;

            if strcmp(nameOfPreviouslyValidatedModel,modelName)



                previouslyValidatedConfigName='';
                if~isempty(previouslyValidatedConfig)
                    previouslyValidatedConfigName=previouslyValidatedConfig.Name;
                end

                if~strcmp(previouslyValidatedConfigName,configurationName)
                    messageId='Simulink:Variants:ConfigInConflictWithPreviousValidation';
                    excepObj=MSLException(get_param(modelName,'Handle'),message(messageId,...
                    modelName,configurationName,previouslyValidatedConfigName));
                    errors{end+1}=getValidationError(...
                    excepObj,'Model',modelName,rootPathPrefix);%#ok<AGROW>
                end
            elseif~isempty(previouslyValidatedConfig)

                tSubModelConfigs=previouslyValidatedConfig.SubModelConfigurations;
                idx=Simulink.variant.utils.searchInListPropByField(previouslyValidatedConfig,'SubModelConfigurations','ModelName',modelName);
                if~isempty(idx)
                    previouslyValidatedConfigName=tSubModelConfigs(idx).ConfigurationName;
                    if~strcmp(previouslyValidatedConfigName,configurationName)
                        messageId='Simulink:Variants:ConfigInConflictWithPreviousSelection';
                        excepObj=MSLException(get_param(modelName,'Handle'),message(messageId,...
                        modelName,configurationName,previouslyValidatedConfigName,nameOfPreviouslyValidatedModel));
                        errors{end+1}=getValidationError(...
                        excepObj,'Model',modelName,rootPathPrefix);%#ok<AGROW>
                    end
                end
            end
        end
    end

    if~isempty(errors)&&~calledFromTool
        validationErrorsForHierarchy{end+1}=getValidationErrorForModel(modelName,errors);
        return;
    end

    configBeingValidated=[];
    constraints=[];

    if~isempty(variantConfigurationObject)
        if~isfield(optArgs,'ConfigurationName')


            configBeingValidated=variantConfigurationObject.getDefaultConfiguration();
        elseif isfield(optArgs,'ConfigurationName')&&~isempty(optArgs.ConfigurationName)
            configName=optArgs.ConfigurationName;
            try

                configBeingValidated=variantConfigurationObject.getConfiguration(configName);
            catch
                configBeingValidated=[];



                messageId='Simulink:Variants:ConfigNotFoundinVCDOForModel';
                excepObj=MSLException(get_param(modelName,'Handle'),message(messageId,...
                configName,variantConfigurationObjectName,modelName));
                errors{end+1}=getValidationError(...
                excepObj,'Configuration',configName,rootPathPrefix);
            end
        end
        constraints=variantConfigurationObject.Constraints;
    elseif isfield(optArgs,'ConfigurationName')&&~isempty(optArgs.ConfigurationName)

        configBeingValidated.Name=optArgs.ConfigurationName;
        configBeingValidated.Description='';
        configBeingValidated.ControlVariables=[];
        configBeingValidated.SubModelConfigurations=[];
    end


    if~isempty(errors)&&~calledFromTool
        validationErrorsForHierarchy{end+1}=getValidationErrorForModel(modelName,errors);
        return;
    end

    if~isempty(configBeingValidated)&&~isempty(configBeingValidated.ControlVariables)
        isSourceFieldPresent=isfield(configBeingValidated.ControlVariables,'Source');

        for i=1:numel(configBeingValidated.ControlVariables)
            if isSourceFieldPresent&&~isempty(configBeingValidated.ControlVariables(i).Source)
                continue;
            end
            configBeingValidated.ControlVariables(i).Source=slvariants.internal.config.utils.getGlobalWorkspaceName(get_param(modelName,'DataDictionary'));
        end
    end


    if~isempty(configBeingValidated)&&~isempty(validationLog)
        conflictsInControlVariables=false;

        if~isempty(configBeingValidated.ControlVariables)

            vars=configBeingValidated.ControlVariables;
            controlVarSources=unique({vars(:).Source});
            for i=1:numel(controlVarSources)
                names={vars(strcmp({vars().Source},controlVarSources{i})).Name};
                numModels=length(validationLog);
                for j=1:numModels
                    previouslyValidatedConfig=validationLog(j).Configuration;
                    if~isempty(previouslyValidatedConfig)
                        varsInConfigBeingChecked=previouslyValidatedConfig.ControlVariables;
                        if~isempty(varsInConfigBeingChecked)
                            varNamesInConfigBeingChecked={varsInConfigBeingChecked(strcmp({varsInConfigBeingChecked().Source},controlVarSources{i})).Name};
                            commonVarNames=intersect(names,varNamesInConfigBeingChecked);
                            numCommonVars=length(commonVarNames);
                            for k=1:numCommonVars
                                valInConfigBeingValidated=vars(Simulink.variant.utils.searchInListPropByField(configBeingValidated,'ControlVariables','Name',commonVarNames{k})).Value;
                                valInPreviouslyValidatedConfig=varsInConfigBeingChecked(Simulink.variant.utils.searchInListPropByField(previouslyValidatedConfig,'ControlVariables','Name',commonVarNames{k})).Value;
                                if~isequal(valInConfigBeingValidated,valInPreviouslyValidatedConfig)
                                    conflictsInControlVariables=true;
                                    varNameWithSource=Simulink.variant.utils.getControlVarNameWithSource(commonVarNames{k},controlVarSources{i});
                                    messageId='Simulink:Variants:ControlVariableInConflict';
                                    tmpMdlName=validationLog(j).Model;
                                    excepObj=MSLException(get_param(tmpMdlName,'Handle'),...
                                    message(messageId,varNameWithSource,previouslyValidatedConfig.Name,tmpMdlName));
                                    errors{end+1}=getValidationErrorForConfiguration(...
                                    excepObj,'ControlVariable',varNameWithSource,previouslyValidatedConfig.Name,tmpMdlName);%#ok<AGROW>
                                end
                            end
                        end
                    end
                end
            end
        end

        conflictsInSubModelConfigs=false;

        if~isempty(configBeingValidated.SubModelConfigurations)
            subModelConfigs=configBeingValidated.SubModelConfigurations;
            subModelNames={subModelConfigs(:).ModelName};

            numModels=length(validationLog);
            for i=1:numModels
                previouslyValidatedConfig=validationLog(i).Configuration;
                if~isempty(previouslyValidatedConfig)
                    tSubModelConfigs=previouslyValidatedConfig.SubModelConfigurations;
                    if~isempty(tSubModelConfigs)



                        tSubModelNames={tSubModelConfigs(:).ModelName};
                        commonModelNames=intersect(subModelNames,tSubModelNames);
                        numCommonModelRefs=length(commonModelNames);
                        for j=1:numCommonModelRefs
                            overrideInConfigBeingValidated=subModelConfigs(Simulink.variant.utils.searchInListPropByField(configBeingValidated,'SubModelConfigurations','ModelName',commonModelNames{j})).ConfigurationName;
                            selectionInPreviouslyValidatedConfig=tSubModelConfigs(Simulink.variant.utils.searchInListPropByField(previouslyValidatedConfig,'SubModelConfigurations','ModelName',commonModelNames{j})).ConfigurationName;
                            if~strcmp(overrideInConfigBeingValidated,selectionInPreviouslyValidatedConfig)


                                conflictsInSubModelConfigs=true;
                                messageId='Simulink:Variants:SubmodelConfigInConflict';
                                tmpMdlName=validationLog(i).Model;
                                excepObj=MSLException(get_param(tmpMdlName,'Handle'),...
                                message(messageId,overrideInConfigBeingValidated,...
                                commonModelNames{j},selectionInPreviouslyValidatedConfig,...
                                previouslyValidatedConfig.Name,tmpMdlName));
                                errors{end+1}=getValidationErrorForConfiguration(...
                                excepObj,'SubModelConfiguration',commonModelNames{j},previouslyValidatedConfig.Name,tmpMdlName);%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end

        if conflictsInControlVariables||conflictsInSubModelConfigs



            messageId='Simulink:Variants:SkippingValidation';
            excepObj=MException(message(messageId,configBeingValidated.Name));
            errors{end+1}=getValidationErrorForConfiguration(...
            excepObj,'Configuration',configBeingValidated.Name,configBeingValidated.Name,modelName);



            if isempty(validationLog)
                validationLog=struct('Model',modelName,'Configuration',configBeingValidated);
            else
                validationLog(end+1).Model=modelName;
                validationLog(end).Configuration=configBeingValidated;
            end
        else


            if isempty(validationLog)
                validationLog=struct('Model',modelName,'Configuration',configBeingValidated);
            else
                validationLog(end+1).Model=modelName;
                validationLog(end).Configuration=configBeingValidated;
            end
        end
    else
        if isempty(validationLog)
            validationLog=struct('Model',modelName,'Configuration',configBeingValidated);
        else
            validationLog(end+1).Model=modelName;
            validationLog(end).Configuration=configBeingValidated;
        end
    end


    modelDataDictionary=get_param(modelName,'DataDictionary');
    variantConfigDataName=get_param(modelName,'VariantConfigurationObject');

    validationLog(end).DataDictionary=modelDataDictionary;
    validationLog(end).VariantConfigObject=variantConfigDataName;

    modelHandle=get_param(modelName,'Handle');

    if isempty(configBeingValidated)

        setUpTempWorkspaceInCreateInfoForModel=true;
        specialVarsInfoManager=[];
    else



        [errorsInSettingUpConfig,specialVarsInfoManager]=...
        Simulink.variant.manager.configutils.setupWorkspaceForVariantConfig(...
        modelHandle,configBeingValidated.Name,configBeingValidated.ControlVariables,optArgs);
        errors=horzcat(errors,errorsInSettingUpConfig);
        setUpTempWorkspaceInCreateInfoForModel=false;
    end


    if isempty(errors)&&~isempty(constraints)
        numConstraints=length(constraints);
        for i=1:numConstraints
            c=constraints(i);
            expr=c.Condition;
            try
                excep=[];
                val=Simulink.variant.utils.evalSimulinkBooleanExprInTempOrGlobalWS(...
                modelHandle,expr,~isempty(configBeingValidated));
            catch excep
                val=false;


            end
            if~val
                messageId='Simulink:Variants:FailedConstraint';
                excepObj=MException(message(messageId,c.Name));
                errors{end+1}=getValidationError(...
                excepObj,'Constraint',c.Name,'');%#ok<AGROW>
            end
            if~isempty(excep)

                errors{end+1}=getValidationError(...
                excep,'Constraint',c.Name,'');%#ok<AGROW>
            end
        end
    end

    if~isempty(configBeingValidated)&&isfield(optArgs,'VarNameSimParamExpressionHierarchyMap')
        ctrlVars=configBeingValidated.ControlVariables;
        for i=1:numel(ctrlVars)
            ctrlVarSource=ctrlVars(i).Source;
            if~optArgs.VarNameSimParamExpressionHierarchyMap.isKey(ctrlVarSource)
                optArgs.VarNameSimParamExpressionHierarchyMap(ctrlVarSource)=containers.Map;
            end
            if Simulink.variant.utils.getIsSimulinkParamWithSlexprValue(ctrlVars(i).Value)
                Simulink.variant.utils.i_addKeyValueWithDupsToMap(optArgs.VarNameSimParamExpressionHierarchyMap(ctrlVarSource),...
                ctrlVars(i).Name,char(ctrlVars(i).Value.Value.ExpressionString));
            end
        end
    end

    createModelInfoArgs=struct('Configuration',configBeingValidated,'HotlinkErrors',hotlinkErrors,'CalledFromTool',calledFromTool);
    if isfield(optArgs,'RootPathPrefix')
        createModelInfoArgs.RootPathPrefix=optArgs.RootPathPrefix;
    end
    if isfield(optArgs,'IgnoreErrors')
        createModelInfoArgs.IgnoreErrors=optArgs.IgnoreErrors;
    end
    createModelInfoArgs.HighLevelModelErrors=~isempty(errors);
    createModelInfoArgs.SpecialVarsInfoManager=specialVarsInfoManager;
    [createModelInfoLog.TopRow,mdlRefBlocksData,errorsInSettingUpConfig,errorsFromVariants,...
    createModelInfoLog.SpecialVarsInfoManager]=Simulink.variant.manager.configutils.createInfoForModel(modelName,...
    setUpTempWorkspaceInCreateInfoForModel,createModelInfoArgs);
    errors=horzcat(errors,errorsInSettingUpConfig,errorsFromVariants);
    if~isempty(errors)
        validationErrorsForHierarchy{end+1}=getValidationErrorForModel(modelName,errors);
    end

    if isfield(optArgs,'RecurseIntoModelReferences')&&~optArgs.RecurseIntoModelReferences

        return;
    end


    if~isempty(mdlRefBlocksData)
        subModelNames={mdlRefBlocksData.ModelName};

        numrefs=length(subModelNames);

        subModelConfigsInConfigBeingValidated=[];
        if~isempty(configBeingValidated)
            subModelConfigsInConfigBeingValidated=configBeingValidated.SubModelConfigurations;
        end

        for i=1:numrefs
            if mdlRefBlocksData(i).IsProtected

                continue;
            end
            subModelConfigurationName='';
            if~isempty(subModelConfigsInConfigBeingValidated)

                [~,subModelConfigurationName]=Simulink.variant.manager.configutils.getSubModelConfig(subModelNames{i},configBeingValidated);
            end

            subModelRootPathPrefix=mdlRefBlocksData(i).RootPathPrefix;
            subModelName=subModelNames{i};

            if any(strcmp(subModelName,modelsSoFar))



                continue;
            end

            modelRefBlockPath=subModelRootPathPrefix;

            subModelOptArgs=struct('ModelsSoFar',{modelsSoFar},'RootPathPrefix',subModelRootPathPrefix,...
            'HotlinkErrors',hotlinkErrors,'CalledFromTool',calledFromTool);
            if~isempty(subModelConfigurationName)
                subModelOptArgs.ConfigurationName=subModelConfigurationName;
            end

            if isfield(optArgs,'VarNameSimParamExpressionHierarchyMap')
                subModelOptArgs.VarNameSimParamExpressionHierarchyMap=optArgs.VarNameSimParamExpressionHierarchyMap;
            end

            [validationErrorsForRefModelHierarchy,validationLog]=Simulink.variant.manager.configutils.validateModelRefEntry(...
            modelRefBlockPath,subModelName,validationLog,subModelOptArgs);
            validationErrorsForHierarchy=horzcat(validationErrorsForHierarchy,validationErrorsForRefModelHierarchy);%#ok<AGROW>
        end
    end
end


