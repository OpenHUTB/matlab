function saveModelsAndDependencies(rMgr)








    rMgr.getEnvironment().ModelTargetReplacer.resetRebuildOptions();


    rMgr.getEnvironment().resetDefaultConfigs();


    rMgr.saveBDCopies();
    saveModelDeps(rMgr);

    rMgr.getEnvironment().resetAddedVCDOs();
end

function saveModelDeps(rMgr)
    modelInfoStructsVec=rMgr.ProcessedModelInfoStructsVec;
    numModels=length(modelInfoStructsVec);
    for modelIdx=numModels:-1:1
        modelInfoStruct=modelInfoStructsVec(modelIdx);


        if modelInfoStruct.IsProtected
            continue;
        end

        modelName=modelInfoStruct.Name;
        fullModelPath=modelInfoStruct.FullPath;
        [~,~,ext]=fileparts(fullModelPath);


        rMgr.Error=saveModelCopyAndDeps(rMgr,modelName,ext,modelIdx);
        rMgr.throwOnError();
    end
end






function err=saveModelCopyAndDeps(rManager,modelName,ext,modelIdx)
    err=[];%#ok<NASGU> % visited as part of MLINT cleanup
    modelInfoStructsVec=rManager.ProcessedModelInfoStructsVec;
    absOutputDir=rManager.getOptions().AbsOutDirPath;
    bdNameRedBDNameMap=rManager.BDNameRedBDNameMap;
    suffix=rManager.getOptions().Suffix;

    isConfigSpecifiedAsVariables=rManager.getOptions().IsConfigSpecifiedAsVariables;
    tempVCDOName=get_param(modelName,'VariantConfigurationObject');





















































    try
        modelInfoStruct=modelInfoStructsVec(modelIdx);
        origModelName=modelInfoStruct.OrigName;





        configInfoStructsVec=modelInfoStruct.ConfigInfos;
        numConfigs=length(configInfoStructsVec);

        vcdoProxyModelIdx=modelInfoStruct.VCDOProxyModelIdx;
        if numConfigs>1

            vcdoName='';
            if~isempty(vcdoProxyModelIdx)


                tmpModelInfoStruct=modelInfoStructsVec(vcdoProxyModelIdx);
                vcdoInfoStruct=tmpModelInfoStruct.VCDOInfo;
                vcdoName=vcdoInfoStruct.VCDOName;
            elseif~isempty(modelInfoStruct.VCDOInfo)&&~isempty(modelInfoStruct.VCDOInfo.ConfigInfosTobeSaved)


                vcdoInfoStruct=modelInfoStruct.VCDOInfo;
                tobeSavedConfigInfoStructsVec=vcdoInfoStruct.ConfigInfosTobeSaved;
                vcdoName=get_param(modelName,'VariantConfigurationObject');

                if isempty(vcdoName)


                    vcdoName=[modelName,'VCDO'];
                    set_param(modelName,'VariantConfigurationObject',vcdoName);
                end


                vcdoTobeSaved=Simulink.VariantConfigurationData;















                numConfigInfos=length(tobeSavedConfigInfoStructsVec);

                for configIdx=1:numConfigInfos
                    configInfo=tobeSavedConfigInfoStructsVec(configIdx);
                    config=configInfo.Configuration;

                    if isempty(config),continue;end

                    configName=config.Name;

                    subModelConfigStruct=config.SubModelConfigurations;



                    for subModelIter=numel(subModelConfigStruct):-1:1
                        subModelNameOrig=subModelConfigStruct(subModelIter).ModelName;
                        if isempty(Simulink.variant.reducer.utils.searchNameInCell(subModelNameOrig,bdNameRedBDNameMap.keys))
                            subModelConfigStruct(subModelIter)=[];
                            continue;
                        end

                        subModelName=bdNameRedBDNameMap(subModelNameOrig);
                        subModelConfig=subModelConfigStruct(subModelIter).ConfigurationName;
                        subModelVCDO=Simulink.variant.utils.getConfigurationDataNoThrow(subModelName);
                        if~isempty(subModelVCDO)&&~isempty(Simulink.variant.reducer.utils.searchNameInCell(subModelConfig,{subModelVCDO.VariantConfigurations.Name}))
                            subModelConfigStruct(subModelIter).ModelName=subModelName;
                        else
                            subModelConfigStruct(subModelIter)=[];
                        end
                    end

                    savedConfigNamesCell={};
                    if~isempty(vcdoTobeSaved.VariantConfigurations)
                        savedConfigNamesCell={vcdoTobeSaved.VariantConfigurations(:).Name};
                    end


                    if~isempty(Simulink.variant.reducer.utils.searchNameInCell(configName,savedConfigNamesCell))
                        continue;
                    end








































                    ctrlVarsFinal=config.ControlVariables;

                    vcdoTobeSaved.addConfiguration(...
                    configName,...
                    config.Description,...
                    ctrlVarsFinal,...
                    subModelConfigStruct);

                end






                try %#ok<TRYNC>
                    vcdoTobeSaved.setDefaultConfigurationName(evalinConfigurationsScope(modelName,[vcdoName,'.DefaultConfigurationName']));
                end

                eval([vcdoName,' = vcdoTobeSaved;']);
                matSavePath=[absOutputDir,filesep,getMATFileNameForVCDO(vcdoName,suffix,isConfigSpecifiedAsVariables)];
                if~isConfigSpecifiedAsVariables||strcmp(modelName,rManager.ReductionOptions.TopModelName)

                    save(matSavePath,vcdoName);

                    rManager.ReportDataObj.addDependentFile(matSavePath);
                end
            end

            if~isempty(vcdoName)

                postLoadFcn=get_param(modelName,'PostLoadFcn');
                vcdoMatName=getMATFileNameForVCDO(vcdoName,suffix,isConfigSpecifiedAsVariables);
                matLoadCmd=['evalinConfigurationsScope(''',modelName,''', ''load(''''',vcdoMatName,''''');'');'];








                postLoadFcn=[postLoadFcn,newline,'try',newline,matLoadCmd,newline,'catch',newline,'end'];

                postLoadFcn=sprintf('%s',postLoadFcn);
                set_param(modelName,'PostLoadFcn',postLoadFcn);
            end
        else





            if~isempty(vcdoProxyModelIdx)

                tmpModelInfoStruct=modelInfoStructsVec(vcdoProxyModelIdx);
                vcdoInfoStruct=tmpModelInfoStruct.VCDOInfo;

                tobeSavedConfigInfoStructsVec=vcdoInfoStruct.ConfigInfosTobeSaved;
                numConfigInfosInProxy=length(tobeSavedConfigInfoStructsVec);


                for configInfoIdx=numConfigInfosInProxy:-1:1
                    tobeSavedConfigInfoStruct=tobeSavedConfigInfoStructsVec(configInfoIdx);
                    sourceModelNameInProxy=tobeSavedConfigInfoStruct.SourceModelName;
                    if strcmp(modelName,sourceModelNameInProxy)
                        tobeSavedConfigInfoStructsVec(configInfoIdx)=[];
                        vcdoInfoStruct.ConfigInfosTobeSaved=tobeSavedConfigInfoStructsVec;
                        tmpModelInfoStruct.VCDOInfo=vcdoInfoStruct;
                        modelInfoStructsVec(vcdoProxyModelIdx)=tmpModelInfoStruct;
                        break;
                    end
                end
            end





            vcdoVarName=get_param(modelName,'VariantConfigurationObject');
            set_param(modelName,'VariantConfigurationObject','');





            modelInfoStructsVec(modelIdx).Variables=setdiff(modelInfoStructsVec(modelIdx).Variables,vcdoVarName);
        end



        if~isempty(modelInfoStruct.BusObjectNames)&&isempty(get_param(modelInfoStruct.Name,'DataDictionary'))
            dataMatName=[modelInfoStruct.Name,'_data'];
            dataMatSavePath=[absOutputDir,filesep,dataMatName];


            evalin('base',['save(''',dataMatSavePath,''',''',modelInfoStruct.BusObjectNames{1},''')']);


            for ii=2:numel(modelInfoStruct.BusObjectNames)
                evalin('base',['save(''',dataMatSavePath,''',''',modelInfoStruct.BusObjectNames{ii},''',''-append'')']);
            end


            rManager.ReportDataObj.addDependentFile([dataMatSavePath,'.mat']);


            postLoadFcn=get_param(modelName,'PostLoadFcn');
            matLoadCmd=[newline,'load(''',dataMatName,''');'];

            postLoadFcn=[postLoadFcn,newline,'try',newline,matLoadCmd,newline,'catch',newline,'end'];
            postLoadFcn=sprintf('%s',postLoadFcn);
            set_param(modelName,'PostLoadFcn',postLoadFcn);
        end




        if isConfigSpecifiedAsVariables&&strcmp(modelName,rManager.ReductionOptions.TopModelName)
            redModelVCDOName=get_param(modelName,'VariantConfigurationObject');
            if~isempty(redModelVCDOName)


                try %#ok<TRYNC>
                    redModelVCDO=Simulink.variant.utils.evalStatementInConfigurationsSection(rManager.getOptions().TopModelName,redModelVCDOName);
                    if numel(redModelVCDO.VariantConfigurations)>1
                        dataDictionary=get_param(modelName,'DataDictionary');
                        if~isempty(dataDictionary)

                            ddObj=Simulink.data.dictionary.open(dataDictionary);
                            ddObj.saveChanges();
                        end
                    end
                end
            end
        end


        if isConfigSpecifiedAsVariables&&~strcmp(modelName,rManager.ReductionOptions.TopModelName)
            set_param(modelName,'VariantConfigurationObject','');



            if~isempty(tempVCDOName)
                Simulink.variant.utils.evalStatementInConfigurationsSection(modelName,['clear(''',tempVCDOName,''')']);
            end
        end
        modelObj=get_param(modelName,'Object');
        try
            modelObj.refreshModelBlocks;
        catch ex %#ok<NASGU> % visited as part of MLINT cleanup
        end

        err=i_saveSystem(modelName,modelInfoStruct.FullPath,'SaveDirtyReferencedModels',true);
        if~isempty(err),return;end


        fullModelPath=modelInfoStruct.FullPath;

        [modelDir,~,~]=fileparts(fullModelPath);

        modelDir=[modelDir,filesep];
        modelDirLength=length(modelDir);

        for depIdx=1:numel(modelInfoStruct.FileDependencies)

            if modelInfoStruct.FileDependencies(depIdx).DependencyType~=Simulink.variant.reducer.enums.ModelDependencyType.SELF_REDUCIBLE&&...
                modelInfoStruct.FileDependencies(depIdx).DependencyType~=Simulink.variant.reducer.enums.ModelDependencyType.NON_REDUCIBLE
                continue;
            end

            depPath=modelInfoStruct.FileDependencies(depIdx).DependencyPath;


            if length(depPath)>=modelDirLength
                prefixFromDepPath=depPath(1:modelDirLength);
            else


                prefixFromDepPath='';
            end

            if strcmp(modelDir,prefixFromDepPath)
                depSavePath=[absOutputDir,depPath(modelDirLength:end)];
            else

                [~,depName,depExt]=fileparts(depPath);
                depSavePath=[absOutputDir,filesep,depName,depExt];
            end

            try
                [depOutFolder,~,~]=fileparts(depSavePath);

                if~(exist(depOutFolder,'dir')==7)
                    mkdir(depOutFolder);
                end







                if~strcmp(depPath,depSavePath)
                    copyfile(depPath,depSavePath,'f');
                end
            catch me
                warnid='Simulink:Variants:DepCannotBeSaved';
                warnmsg=message(warnid,depPath,origModelName,depSavePath);
                warnObj=MException(warnmsg);
                warnObj=warnObj.addCause(me);
                rManager.Warnings{end+1}=warnObj;
            end

            rManager.ReportDataObj.addDependentFile(depSavePath);
        end
        rManager.ProcessedModelInfoStructsVec=modelInfoStructsVec;
    catch me
        modelSavePath=[absOutputDir,filesep,modelName,ext];
        errid='Simulink:Variants:ErrInSaving';
        errmsg=message(errid,modelName,modelSavePath);
        err=MException(errmsg);
        err=err.addCause(me);
    end

end


function matFileName=getMATFileNameForVCDO(vcdoName,suffix,isConfigSpecifiedAsVariables)
    if isConfigSpecifiedAsVariables
        try %#ok<TRYNC>




            suffixMatches=regexp(vcdoName,suffix);
            suffixMatches=suffixMatches(end);
            vcdoName(suffixMatches:suffixMatches+numel(suffix)-1)=[];
        end
    end
    matFileName=[vcdoName,suffix];
end















