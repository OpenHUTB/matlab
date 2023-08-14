function[topRow,mdlRefBlocksData,errorsInSettingUpConfig,errorsFromVariants,...
    specialVarsInfoManager]=createInfoForModel(modelName,setupTempWorkspace,optArgsStruct)








    errorsInSettingUpConfig={};
    if isfield(optArgsStruct,'SpecialVarsInfoManager')
        specialVarsInfoManager=optArgsStruct.SpecialVarsInfoManager;
    else
        specialVarsInfoManager=[];
    end
    if isfield(optArgsStruct,'Configuration')
        configuration=optArgsStruct.Configuration;
    else

        configuration='';
    end

    useTempWS=~isempty(configuration);
    if useTempWS

        [hasCollision,collidingVars]=Simulink.variant.manager.configutils.checkNameCollisions(configuration.ControlVariables);

        if setupTempWorkspace
            [errorsInSettingUpConfig,specialVarsInfoManager]=Simulink.variant.manager.configutils.setupWorkspaceForVariantConfig(...
            get_param(modelName,'Handle'),configuration.Name,configuration.ControlVariables,optArgsStruct);

            if hasCollision
                messageId='Simulink:Variants:VariantManagerClashingVariables';
                err=Simulink.variant.manager.errorutils.getValidationError(...
                MException(message(messageId,strjoin(collidingVars,', '))),...
                'Model',modelName,pathInHierarchy);
                errorsInSettingUpConfig{end+1}=err;
            end
        end
    end

    if isfield(optArgsStruct,'RootPathPrefix')
        rootPathPrefix=optArgsStruct.RootPathPrefix;
    else
        rootPathPrefix=[];
    end

    highLevelModelErrors=(isfield(optArgsStruct,'HighLevelModelErrors')&&optArgsStruct.HighLevelModelErrors)||...
    ~isempty(errorsInSettingUpConfig);

    ignoreErrors=(isfield(optArgsStruct,'IgnoreErrors')&&optArgsStruct.IgnoreErrors)||highLevelModelErrors;
    hotlinkErrors=~isfield(optArgsStruct,'HotlinkErrors')||optArgsStruct.HotlinkErrors;
    calledFromTool=isfield(optArgsStruct,'CalledFromTool')&&optArgsStruct.CalledFromTool;
    calledFromReducer=isfield(optArgsStruct,'CalledFromReducer')&&optArgsStruct.CalledFromReducer;

    if calledFromTool

        [ssBlockHs,ivAndModelBlockHs]=...
        Simulink.variant.utils.getAllSubsystemModelAndIVBlocksInModel(...
        modelName,Simulink.variant.utils.getAllOrActiveVariants(calledFromTool,calledFromReducer));
        blocksPathsInModel=Simulink.variant.utils.i_getFullName([ssBlockHs;ivAndModelBlockHs]);
    else

        blocksPathsInModel=Simulink.variant.utils.i_getFullName(...
        Simulink.variant.utils.getAllVariantAndModelBlocks(modelName,...
        Simulink.variant.utils.getAllOrActiveVariants(calledFromTool,calledFromReducer)));
    end

    blocksPathsInModel=sort(blocksPathsInModel);

    createModelInfoArgs=Simulink.variant.manager.configutils.CreateModelInfoArgs(...
    rootPathPrefix,useTempWS,ignoreErrors,hotlinkErrors,calledFromTool,...
    blocksPathsInModel,configuration);

    topRow=Simulink.variant.manager.hrow.createVariantManagerRow(modelName,modelName,createModelInfoArgs);
    if highLevelModelErrors
        topRow.setFlagonModelWideErrors();
    elseif ignoreErrors
        topRow.setIgnoredFlagonModel();
    end

    blockIndex=1;
    while blockIndex<=length(createModelInfoArgs.BlocksPathsInModel)

        blocksPathsInModel=createModelInfoArgs.BlocksPathsInModel;
        blockPathInModel=Simulink.variant.utils.replaceNewLinesWithSpaces(blocksPathsInModel{blockIndex});

        Simulink.variant.manager.hrow.createVariantManagerRow(modelName,blockPathInModel,createModelInfoArgs);
        blockIndex=blockIndex+1;
    end
    errorsFromVariants=createModelInfoArgs.getLoggedErrors();
    mdlRefBlocksData=createModelInfoArgs.MdlRefBlocksData;
end


