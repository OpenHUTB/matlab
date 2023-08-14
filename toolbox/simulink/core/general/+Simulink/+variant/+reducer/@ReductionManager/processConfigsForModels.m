function err=processConfigsForModels(rManager)










    err=[];














    modelInfoStructsVec=rManager.ProcessedModelInfoStructsVec;
    absOutDirPath=rManager.getOptions().AbsOutDirPath;
    bdNameRedBDNameMap=rManager.BDNameRedBDNameMap;

    optArgsProc.ModelInfoStructsVec=modelInfoStructsVec;

    modelIdx=1;
    numModelInfos=1;

    redModelNameModelNameMap=containers.Map(bdNameRedBDNameMap.values,bdNameRedBDNameMap.keys);
    optArgsProc.RedModelNameModelNameMap=redModelNameModelNameMap;

    try
        while modelIdx<=numModelInfos
            optArgsProc.ModelIdx=modelIdx;
            modelInfoStruct=modelInfoStructsVec(modelIdx);
            modelName=modelInfoStruct.Name;
            optArgsProc.ModelName=modelName;
            origModelName=modelInfoStruct.OrigName;
            optArgsProc.OrigName=origModelName;
            configInfoStructsVec=modelInfoStruct.ConfigInfos;
            optArgsProc.ConfigInfoStructsVec=configInfoStructsVec;


            origModelIdx=modelIdx;
            optArgsProc.OrigModelIdx=origModelIdx;


            modelHasBeenProcessed=false;
            optArgsProc.ModelHasBeenProcessed=modelHasBeenProcessed;

            [isProtected,modelFilePathWithExt]=Simulink.variant.utils.getIsProtectedModelAndFullFile(modelName);
            if~isProtected
                origModelFullPath=get_param(origModelName,'FileName');
                [~,~,ext]=fileparts(origModelFullPath);
                modelFilePathWithExt=[absOutDirPath,filesep,modelName,ext];
            end

            modelInfoStruct.IsProtected=isProtected;
            modelInfoStruct.FullPath=modelFilePathWithExt;
            modelInfoStructsVec(modelIdx)=modelInfoStruct;


            if isProtected



                modelIdx=modelIdx+1;
                continue;
            end


            vcdoName=get_param(modelName,'VariantConfigurationObject');
            idxOfModelInfoWithVCDOName=[];

            vcdoInfoStruct=[];
            vcdo=[];

            if~isempty(vcdoName)
                if modelIdx>1

                    alreadyProcessedModelInfoStructsVec=modelInfoStructsVec(1:modelIdx-1);
                    vcdoNamesCell=arrayfun(@i_getVCDONameFromModelInfo,...
                    alreadyProcessedModelInfoStructsVec,'UniformOutput',false);
                    idxOfModelInfoWithVCDOName=...
                    i_searchNameInCell(vcdoName,vcdoNamesCell);





                    if~isempty(idxOfModelInfoWithVCDOName)


                        proxyModelInfo=modelInfoStructsVec(idxOfModelInfoWithVCDOName);
                        vcdoInfoStruct=proxyModelInfo.VCDOInfo;
                        vcdo=vcdoInfoStruct.VCDO;
                        modelInfoStruct.VCDOProxyModelIdx=idxOfModelInfoWithVCDOName;
                        modelInfoStructsVec(modelIdx)=modelInfoStruct;
                    end
                end
            end
            optArgsProc.IdxOfModelInfoWithVCDOName=idxOfModelInfoWithVCDOName;



            if isempty(idxOfModelInfoWithVCDOName)
                vcdo=Simulink.variant.utils.getConfigurationDataNoThrow(modelName);




                if modelIdx>1
                    vcdoInfoStruct=Simulink.variant.reducer.types.VRedVCDOInfo;
                    vcdoInfoStruct.VCDOName=vcdoName;
                    vcdoInfoStruct.VCDO=vcdo;

                    modelInfoStruct.VCDOInfo=vcdoInfoStruct;
                    modelInfoStructsVec(modelIdx)=modelInfoStruct;
                elseif modelIdx==1


                    modelInfoStruct=modelInfoStructsVec(modelIdx);
                    vcdoInfoStruct=modelInfoStruct.VCDOInfo;
                    if isempty(vcdoInfoStruct)


                        vcdoInfoStruct=Simulink.variant.reducer.types.VRedVCDOInfo;
                    end
                end
            end
            optArgsProc.ModelInfoStructsVec=modelInfoStructsVec;
            optArgsProc.ModelInfoStruct=modelInfoStruct;
            optArgsProc.VcdoInfoStruct=vcdoInfoStruct;
            optArgsProc.Vcdo=vcdo;
            optArgsProc.VcdoName=vcdoName;











            [err,optArgsProc]=i_processConfigInfoStructsVec(rManager,optArgsProc);

            modelInfoStructsVec=optArgsProc.ModelInfoStructsVec;
            modelHasBeenProcessed=optArgsProc.ModelHasBeenProcessed;
            modelIdx=optArgsProc.ModelIdx;
            if~isempty(err)
                return;
            end

            if~modelHasBeenProcessed
                modelIdx=modelIdx+1;



            end
            numModelInfos=length(modelInfoStructsVec);
        end

        rManager.ProcessedModelInfoStructsVec=modelInfoStructsVec;

        i_moveRefModelInfoFromModelToLibInfoStruct(rManager);

    catch err
        return;
    end
end



function[err,optArgsProc]=i_processConfigInfoStructsVec(rMgr,optArgsProc)
    err=[];

    modelName=optArgsProc.ModelName;
    origModelName=optArgsProc.OrigName;
    modelInfoStruct=optArgsProc.ModelInfoStruct;
    modelInfoStructsVec=optArgsProc.ModelInfoStructsVec;
    configInfoStructsVec=optArgsProc.ConfigInfoStructsVec;
    vcdoInfoStruct=optArgsProc.VcdoInfoStruct;
    vcdo=optArgsProc.Vcdo;
    vcdoName=optArgsProc.VcdoName;
    modelIdx=optArgsProc.ModelIdx;
    origModelIdx=optArgsProc.OrigModelIdx;
    idxOfModelInfoWithVCDOName=optArgsProc.IdxOfModelInfoWithVCDOName;

    try

















        modelRefsDataForModel=modelInfoStructsVec(origModelIdx).ModelRefsDataStructsVec;









        numConfigInfos=length(configInfoStructsVec);
        for configInfoIdx=1:numConfigInfos
            configInfoStruct=configInfoStructsVec(configInfoIdx);

            if modelIdx==1

                configInfoStruct.TopModelConfigName=configInfoStruct.ConfigName;
            end


            if configInfoStruct.IsProcessed
                continue;
            end

            configName=configInfoStruct.ConfigName;
            if isempty(configName)

                if~isempty(vcdo)
                    config=vcdoInfoStruct.DefaultConfiguration;
                else
                    config=[];
                end
            else
                if isempty(vcdo)
                    errid='Simulink:Variants:ConfigDataNotFoundForModel';
                    errmsg=message(errid,origModelName,configName);
                    err=MException(errmsg);
                    return;
                else
                    try
                        config=vcdo.getConfiguration(configName);
                    catch
                        errid='Simulink:Variants:ConfigNotFoundForModel';
                        errmsg=message(errid,configName,vcdoName,origModelName);
                        err=MException(errmsg);
                        return;
                    end
                end
            end

            if~isempty(config)
                configName=config.Name;
                configInfoStruct.ConfigName=configName;
            end


            pushCtrlVarsToGWS(modelName,config);
            modelRefsData=getModelRefsData(rMgr,modelName,...
            configInfoStruct.TopModelConfigName,optArgsProc.RedModelNameModelNameMap);

            configInfoStruct.Configuration=config;
            configInfoStruct.IsProcessed=true;
            configInfoStruct.ModelRefsData=modelRefsData;
            configInfoStruct.SourceModelName=modelName;

            configInfoStructsVec(configInfoIdx)=configInfoStruct;


            if~isempty(config)&&~isempty(vcdoInfoStruct)
                vcdoInfoStruct.ConfigInfosTobeSaved(end+1)=configInfoStruct;

                if~isempty(idxOfModelInfoWithVCDOName)

                    tmpModelInfo=modelInfoStructsVec(idxOfModelInfoWithVCDOName);
                    tmpModelInfo.VCDOInfo=vcdoInfoStruct;
                    modelInfoStructsVec(idxOfModelInfoWithVCDOName)=tmpModelInfo;
                else
                    modelInfoStruct.VCDOInfo=vcdoInfoStruct;
                    modelInfoStructsVec(modelIdx)=modelInfoStruct;
                end
            end

            modelInfoStruct.ConfigInfos=configInfoStructsVec;
            modelInfoStructsVec(modelIdx)=modelInfoStruct;

            optArgsProc.ModelInfoStructsVec=modelInfoStructsVec;
            optArgsProc.ModelRefsData=modelRefsData;
            optArgsProc.ModelRefsDataForModel=modelRefsDataForModel;
            optArgsProc.Config=config;
            optArgsProc.TopModelConfigName=configInfoStruct.TopModelConfigName;



            [err,optArgsProc]=i_processModelRefDataForSpecifiedConfig(optArgsProc);

            if~isempty(err)
                return;
            end

            modelInfoStructsVec=optArgsProc.ModelInfoStructsVec;
            modelRefsDataForConfig=optArgsProc.ModelRefsDataForConfig;



            if configInfoIdx==1
                modelInfoStructsVec(origModelIdx).ModelRefsDataStructsVec=modelRefsDataForConfig;
            else
                modelInfoStructsVec(origModelIdx).appendModelRefsDataStructsVec(modelRefsDataForConfig(:));
            end

        end

        optArgsProc.ModelInfoStructsVec=modelInfoStructsVec;
    catch err
        return;
    end
end

function pushCtrlVarsToGWS(modelName,config)







    if isempty(config)


        return;
    end
    pushToTempWorspace=0;
    reportErrors=0;
    skipAssigninGlobalWkspce=0;
    usedByDefaultConfig=0;
    Simulink.variant.manager.configutils.pushControlVarsToGlobalOrTempWS(modelName,...
    config.Name,config.ControlVariables,pushToTempWorspace,reportErrors,...
    skipAssigninGlobalWkspce,usedByDefaultConfig);
end

function mdlRefData=getModelRefsData(rMgr,modelName,configName,redToOrigBDName)


    mdlRefData=[];
    if~isKey(rMgr.CfgToMdlRefData,configName)
        return;
    end
    bdToMdlRefData=rMgr.CfgToMdlRefData(configName);
    compiledMdlName=getCompiledModelName(rMgr,redToOrigBDName,modelName);
    if~isKey(bdToMdlRefData,compiledMdlName)
        return;
    end
    mdlRefDataOrig=bdToMdlRefData(compiledMdlName);
    mdlRefData=changeMdlRefDataToReferReducedMdls(rMgr,mdlRefDataOrig);
end

function compiledMdl=getCompiledModelName(rMgr,redToOrigBDName,modelName)

    compiledMdl=modelName;
    if isequal(rMgr.getOptions().TopModelName,modelName)

        return;
    end
    if redToOrigBDName.isKey(modelName)
        compiledMdl=redToOrigBDName(modelName);
    end
end

function redMdlRefsData=changeMdlRefDataToReferReducedMdls(rMgr,mdlRefsData)

    redMdlRefsData=mdlRefsData;
    for mdlRefDataIdx=1:numel(redMdlRefsData)
        currMdlRefData=redMdlRefsData(mdlRefDataIdx);
        if rMgr.BDNameRedBDNameMap.isKey(currMdlRefData.ModelName)


            currMdlRefData.ModelName=rMgr.BDNameRedBDNameMap(currMdlRefData.ModelName);
        end
        paths=Simulink.variant.utils.splitPathInHierarchy(currMdlRefData.RootPathPrefix);

        if rMgr.BDNameRedBDNameMap.isKey(paths{1})


            paths{1}=rMgr.BDNameRedBDNameMap(paths{1});
        end




        currMdlRefData.RootPathPrefix=strjoin(paths,'/');
        redMdlRefsData(mdlRefDataIdx)=currMdlRefData;
    end
end



function[err,optArgsProc]=i_processModelRefDataForSpecifiedConfig(optArgsProc)
    err=[];

    modelRefsData=optArgsProc.ModelRefsData;
    config=optArgsProc.Config;
    modelIdx=optArgsProc.ModelIdx;
    modelRefsDataForModel=optArgsProc.ModelRefsDataForModel;
    redModelNameModelNameMap=optArgsProc.RedModelNameModelNameMap;
    modelHasBeenProcessed=optArgsProc.ModelHasBeenProcessed;

    try


        optArgsProc.ModelRefsDataForConfig=Simulink.variant.reducer.types.VRedModelRefsData.empty;
        if~isempty(modelRefsData)
            numrefs=length(modelRefsData);

            subModelConfigsInConfig=[];
            if~isempty(config)
                subModelConfigsInConfig=config.SubModelConfigurations;
            end

            for ii=1:numrefs
                subModelConfigFound=false;
                subModelName=modelRefsData(ii).ModelName;
                isProtected=modelRefsData(ii).IsProtected;







                if~isProtected&&isempty(i_searchNameInCell(subModelName,redModelNameModelNameMap.keys))


                    continue;
                end

                if isProtected
                    subModelNameOrig=subModelName;
                else
                    subModelNameOrig=redModelNameModelNameMap(subModelName);
                end


                isMdlRefInfoPresent=i_searchNameInCell(modelRefsData(ii).RootPathPrefix,{modelRefsDataForModel.RootPathPrefix});
                if isempty(isMdlRefInfoPresent)
                    modelRefDataForIter=Simulink.variant.reducer.types.VRedModelRefsData;
                    modelRefDataForIter.Name=subModelName;
                    modelRefDataForIter.IsProtected=isProtected;
                    modelRefDataForIter.RootPathPrefix=modelRefsData(ii).RootPathPrefix;
                    if~isProtected
                        modelRefDataForIter.RefInports=i_getInportBlockHandles(subModelName);
                        modelRefDataForIter.RefOutports=i_getOutportBlockHandles(subModelName);
                    else
                        modelRefDataForIter.RefInports={};
                        modelRefDataForIter.RefOutports={};
                    end

                    optArgsProc.ModelRefsDataForConfig(end+1)=modelRefDataForIter;
                end


                if~isProtected&&~isempty(subModelConfigsInConfig)
                    [subModelConfigFound,subModelConfig]=...
                    Simulink.variant.manager.configutils.getSubModelConfig(subModelNameOrig,config);
                end

                if subModelConfigFound
                    subConfigName=subModelConfig;
                else
                    subConfigName='';
                end




                modelNamesCell={optArgsProc.ModelInfoStructsVec.Name};
                idxOfSubModel=i_searchNameInCell(subModelName,modelNamesCell);
                if isempty(idxOfSubModel)
                    newConfigInfoStruct=Simulink.variant.reducer.types.VRedConfigInfo;
                    newConfigInfoStruct.ConfigName=subConfigName;
                    newConfigInfoStruct.TopModelConfigName=optArgsProc.TopModelConfigName;
                    newModelInfoStruct=Simulink.variant.reducer.types.VRedModelInfo;
                    newModelInfoStruct.Name=subModelName;
                    newModelInfoStruct.OrigName=subModelNameOrig;
                    newModelInfoStruct.ConfigInfos=newConfigInfoStruct;

                    optArgsProc.ModelInfoStructsVec(end+1)=newModelInfoStruct;
                elseif~isProtected


                    configNamesCell={optArgsProc.ModelInfoStructsVec(idxOfSubModel).ConfigInfos.ConfigName};
                    idxOfConfig=i_searchNameInCell(subConfigName,configNamesCell);
                    if isempty(idxOfConfig)
                        newConfigInfoStruct=Simulink.variant.reducer.types.VRedConfigInfo;
                        newConfigInfoStruct.ConfigName=subConfigName;
                        newConfigInfoStruct.TopModelConfigName=optArgsProc.TopModelConfigName;
                        optArgsProc.ModelInfoStructsVec(idxOfSubModel).ConfigInfos(end+1)=newConfigInfoStruct;

                        submodelInfoStruct=optArgsProc.ModelInfoStructsVec(idxOfSubModel);
                        submodelInfoStruct.ConfigInfos=optArgsProc.ModelInfoStructsVec(idxOfSubModel).ConfigInfos;
                        optArgsProc.ModelInfoStructsVec(idxOfSubModel)=submodelInfoStruct;
                    end
                end

                if idxOfSubModel<modelIdx

                    modelIdx=idxOfSubModel;
                    modelHasBeenProcessed=true;
                end
            end
        end

        optArgsProc.ModelHasBeenProcessed=modelHasBeenProcessed;
        optArgsProc.ModelIdx=modelIdx;

    catch err
        return;
    end
end









function i_moveRefModelInfoFromModelToLibInfoStruct(rManager)
    modelStructsVec=rManager.ProcessedModelInfoStructsVec;
    libStructsVec=rManager.LibInfoStructsVec;
    mdlBlksInLib=rManager.ModelBlocksInLib;
    topModelName=rManager.getOptions().TopModelName;
    reverseBDMap=i_invertMap(rManager.BDNameRedBDNameMap);
    allLibBlkMap=rManager.AllLibBlksMap;





    for modelIter=1:numel(modelStructsVec)
        mdlRefStructsVec=modelStructsVec(modelIter).ModelRefsDataStructsVec;

        [mdlBlkCell,referencedMdlCell]=arrayfun(@(x)i_getMdlBlkNameFromRootPathPrefix(...
        topModelName,reverseBDMap,x.('RootPathPrefix')),...
        mdlRefStructsVec,'UniformOutput',false);

        for refIter=numel(mdlBlkCell):-1:1
            currMdlBlk=mdlBlkCell{refIter};
            referencedMdl=referencedMdlCell{refIter};
            if isempty(i_searchNameInCell(currMdlBlk,mdlBlksInLib)),continue;end
            refStruct=mdlRefStructsVec(refIter);
            Simulink.variant.reducer.utils.assert(isKey(allLibBlkMap,currMdlBlk))
            rootPathPrefix=allLibBlkMap(currMdlBlk);





            if iscell(rootPathPrefix)
                tempRefBlock=rootPathPrefix{1};
                bdName=i_getRootBDNameFromPath(tempRefBlock);
                bdIdx=i_searchNameInCell(bdName,{libStructsVec.Name});
                if isempty(bdIdx)
                    continue;
                else
                    rootPathPrefix=tempRefBlock;
                end
            end

            mdlRefStructsVec(refIter)=[];

            if~isempty(referencedMdl)
                rootPathPrefix=[rootPathPrefix,'/',referencedMdl];%#ok<AGROW> % visited as part of MLINT cleanup
            end

            libName=i_getRootBDNameFromPath(rootPathPrefix);
            libIdx=i_searchNameInCell(libName,{libStructsVec.Name});
            Simulink.variant.reducer.utils.assert(~isempty(libIdx));

            if~isempty(i_searchNameInCell(rootPathPrefix,{libStructsVec(libIdx).ModelRefsDataStructsVec.RootPathPrefix}))
                continue;
            end

            refStruct.RootPathPrefix=rootPathPrefix;
            libStructsVec(libIdx).ModelRefsDataStructsVec(end+1)=refStruct;
        end
        modelStructsVec(modelIter).ModelRefsDataStructsVec=mdlRefStructsVec;
    end
    rManager.ProcessedModelInfoStructsVec=modelStructsVec;
    rManager.LibInfoStructsVec=libStructsVec;
end


function vcdoName=i_getVCDONameFromModelInfo(modelInfo)
    vcdoInfo=modelInfo.VCDOInfo;
    if~isempty(vcdoInfo)
        vcdoName=vcdoInfo.VCDOName;
    else
        vcdoName='';
    end
end



