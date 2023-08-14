function unpackCoderTargetNeverRebuild(topModel,buildArgs)






    if Simulink.ModelReference.ProtectedModel.protectingModel(buildArgs.TopOfBuildModel)||...
        ~strcmp(buildArgs.ModelReferenceTargetType,'RTW')||...
        buildArgs.IsRapidAccelerator||...
        buildArgs.IsSimulinkAccelerator||...
        buildArgs.XilInfo.UpdatingRTWTargetsForXil
        return;
    end


    myData.STFName=strrep(get_param(topModel,'SystemTargetFile'),'.tlc','');
    myData.folderConfig=char(Simulink.fileGenControl('get','CodeGenFolderStructure'));
    myData.targetSuffix=Simulink.packagedmodel.getTargetSuffix(topModel,...
    'ModelReferenceCode',myData.STFName);
    myData.okayToPushNags=buildArgs.OkayToPushNags;
    myData.generateCodeOnly=buildArgs.BaGenerateCodeOnly;
    myData.ModelReferenceRTWTargetOnly=buildArgs.ModelReferenceRTWTargetOnly;
    myData.IsDebug=slsvTestingHook('LogUnpackCoderNeverRebuildSLXC')>0;
    myData.DefaultCompInfo=buildArgs.BaDefaultCompInfo;
    myData.ModelCompInfo=buildArgs.BaModelCompInfo;





    if buildArgs.TopModelStandalone
        topModelMode=slcache.Modes.CODER_TOP;
    else
        loc_unpackModel(topModel,topModel,myData);
        topModelMode=slcache.Modes.CODER;
    end


    info=builtin('_getSLCacheModelInfo',topModel,topModelMode);
    if info.unpacked
        subModels=info.extraInformation.subModels.toArray()';
        for k=1:length(subModels)
            loc_unpackModel(topModel,subModels{k},myData);

            builtin('_deleteSLCacheModelInfo',subModels{k});
        end
    end
end


function loc_unpackModel(topModel,model,myData)

    if~myData.ModelReferenceRTWTargetOnly&&slfeature('NoSimTargetForBuild')==0
        loc_debugMsg(model,'SIM',myData.IsDebug);
        compiler=Simulink.packagedmodel.getSimCompilerFromCompInfo(myData.DefaultCompInfo);
        builtin('_unpackSLCacheSIM',topModel,model,...
        myData.okayToPushNags,'SIM',compiler);
    end


    loc_debugMsg(model,'CODER',myData.IsDebug);
    compiler=Simulink.packagedmodel.getCoderCompilerFromCompInfo(myData.ModelCompInfo);
    builtin('_unpackSLCacheCoder',topModel,model,...
    myData.okayToPushNags,'RTW',myData.STFName,myData.targetSuffix,...
    myData.generateCodeOnly,myData.folderConfig,compiler);
end


function loc_debugMsg(model,target,isDebug)
    if~isDebug
        return;
    end
    msg=sprintf('Unpacking %s target for %s for Never Rebuild from %s',...
    target,model,mfilename);
    sl('sl_disp_info',msg,true);
end


