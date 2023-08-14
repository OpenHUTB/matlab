










function err=preprocessInput(rManager)

    err=[];%#ok<NASGU>


    origTopModelName=rManager.getOptions().TopModelOrigName;
    configInfosArg=rManager.getOptions().ConfigInfos;
    redMdlName=rManager.getOptions().TopModelName;
    absOutDirPath=rManager.getOptions().AbsOutDirPath;

    origMdlFileName=rManager.getOptions().TopModelFullName;


    if bdIsLoaded(origTopModelName)
        if any(strcmp(origTopModelName,rManager.Environment.BDsDirtyBeforeReduction))


            errid='Simulink:Variants:InvalidModelArgDirty';
            errmsg=message(errid,origTopModelName);
            err=MException(errmsg);
            return;
        end

        if Simulink.variant.utils.getIsSimulationPausedOrRunning(origTopModelName)



            errid='Simulink:VariantManager:ReducingWhileRunningSimulationNotSupported';
            errmsg=message(errid,origTopModelName);
            err=MException(errmsg);
            return;
        end

        if Simulink.variant.utils.getIsModelInCompiledState(origTopModelName)



            errid='Simulink:VariantManager:ReducingWhileCompiledNotSupported';
            errmsg=message(errid,origTopModelName);
            err=MException(errmsg);
            return;
        end
    else

        withCallbacks=true;
        Simulink.variant.reducer.utils.loadSystem(origMdlFileName,withCallbacks);
    end


    tobeProcessedModelInfoStruct=Simulink.variant.reducer.types.VRedModelInfo;


    configInfoStructsVec=Simulink.variant.reducer.types.VRedConfigInfo.empty;

    [~,~,topModelExt]=fileparts(origMdlFileName);

    bdNameRedBDNameMap=containers.Map(origTopModelName,redMdlName);
    rManager.BDNameRedBDNameMap=bdNameRedBDNameMap;

    topModelFileWithPath=[absOutDirPath,filesep,redMdlName,topModelExt];

    err=i_copyBDAndLoad(origMdlFileName,topModelFileWithPath,rManager);
    if~isempty(err)
        return;
    end

    tobeProcessedModelInfoStruct.FullPath=topModelFileWithPath;

    if isa(configInfosArg,'char')
        configInfosArg=i_mat2cell(configInfosArg);
    end

    if rManager.getOptions().IsConfigSpecifiedAsVariables
        try

            [configInfosArg,rManager.FullRangeAnalysisInfo]=...
            Simulink.variant.reducer.fullrange.FullRangeManager.processControlVars(...
            redMdlName,configInfosArg,rManager.getOptions().FullRangeVariables);

            vcdoObj=Simulink.variant.variablegroups.VCDOImpl(redMdlName,origTopModelName,configInfosArg);
            vtcObj=Simulink.variant.variablegroups.VarsToConfigImpl();
            vtcObj.convertVarsToObject(vcdoObj);
            newVCDO=vcdoObj.newVCDO;

            varsInGlobalWS=Simulink.variant.utils.evalStatementInConfigurationsSection(redMdlName,'whos');
            redModelVCDOName=Simulink.variant.reducer.utils.getUniqueName([redMdlName,'_VCDO'],...
            {varsInGlobalWS.name});
            set_param(redMdlName,'VariantConfigurationObject',redModelVCDOName);





            toDelete=true;
            rManager.getEnvironment().addVCDOForModel(redMdlName,redModelVCDOName,newVCDO,toDelete);

            configInfosArg={newVCDO.VariantConfigurations.Name};
            rManager.getOptions().setConfigInfos(configInfosArg);

        catch err
            Simulink.variant.reducer.utils.logException(err);
            return;
        end
    end


    if~isempty(configInfosArg)

        numConfigInfos=length(configInfosArg);






        vcdoName=get_param(redMdlName,'VariantConfigurationObject');
        vcdo=Simulink.variant.utils.getConfigurationDataNoThrow(redMdlName);
        vcdoInfoStruct=Simulink.variant.reducer.types.VRedVCDOInfo;
        vcdoInfoStruct.VCDOName=vcdoName;
        vcdoInfoStruct.VCDO=vcdo;
        if~isempty(vcdo)
            vcdoInfoStruct.DefaultConfiguration=vcdo.getDefaultConfiguration();
        end








        rManager.getEnvironment().addModelForDefaultConfigHandling(redMdlName);

        tobeProcessedModelInfoStruct.VCDOInfo=vcdoInfoStruct;
        for configInfoIdx=1:numConfigInfos
            configName=configInfosArg{configInfoIdx};
            if~isa(configName,'char')
                errid='Simulink:Variants:InvalidModelConfigsArgNonChar';
                errmsg=message(errid,configInfoIdx,1);
                err=MException(errmsg);
                return;
            end
            configInfoStruct=Simulink.variant.reducer.types.VRedConfigInfo;
            configInfoStruct.ConfigName=configName;

            config=[];
            if isempty(configName)&&~isempty(vcdo)

                config=vcdoInfoStruct.DefaultConfiguration;

            elseif~isempty(configName)&&isempty(vcdo)
                errid='Simulink:Variants:ConfigDataNotFoundForModel';
                errmsg=message(errid,origTopModelName,configName);
                err=MException(errmsg);
                return;
            elseif~isempty(configName)&&~isempty(vcdo)
                try
                    config=vcdo.getConfiguration(configName);
                catch
                    errid='Simulink:Variants:ConfigNotFoundForModel';
                    errmsg=message(errid,configName,vcdoName,origTopModelName);
                    err=MException(errmsg);
                    return;
                end
            end

            configInfoStruct.Configuration=config;
            configInfoStructsVec(configInfoIdx)=configInfoStruct;
        end


        configNamesCell={configInfoStructsVec.ConfigName};
        numConfigs=length(configNamesCell);
        numUniqueConfigs=length(unique(configNamesCell));
        if numConfigs~=numUniqueConfigs
            errid='Simulink:Variants:NonUniqueConfigNames';
            errmsg=message(errid,origTopModelName);
            err=MException(errmsg);
            return;
        end
    else


        configInfoStructsVec=Simulink.variant.reducer.types.VRedConfigInfo;
    end

    tobeProcessedModelInfoStruct.Name=redMdlName;
    tobeProcessedModelInfoStruct.ConfigInfos=configInfoStructsVec;
    tobeProcessedModelInfoStruct.OrigName=origTopModelName;
    rManager.ProcessedModelInfoStructsVec=tobeProcessedModelInfoStruct;
end


