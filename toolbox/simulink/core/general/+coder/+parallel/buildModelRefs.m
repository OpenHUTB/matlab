function[status,reason,buildStatusMgr]=buildModelRefs(...
    pool,...
    iMdl,allMdlRefNames,parMdlRefs,orderedMdlRefs,...
    iTopTflChecksum,...
    iBuildArgs,verbose,mdlrefUpdateCtrl,thisMdlUpdateCtrl,runningForExternalMode,targetType,...
    mdlRefSimModeMap,buildStatusMgr,libsToClose,updateMsg)




    if strcmp(targetType,'RTW')&&...
        coder.make.internal.buildMethodIsCMake(iBuildArgs.BaModelCompInfo.ToolchainInfo)






        iBuildArgs.BaModelCompInfo.ToolchainInfo.validate('useCachedReport');
    end




    updateTopMdlRefTargetInSerial=...
    iBuildArgs.UpdateTopModelReferenceTarget&&...
    (length(parMdlRefs{end})==1)&&strcmp(iMdl,parMdlRefs{end}.modelName);

    if updateTopMdlRefTargetInSerial



        nTotalMdls=length(allMdlRefNames)-1;

        topMdlBuildOrderedMdlRefs=orderedMdlRefs(end);
        orderedMdlRefs=orderedMdlRefs(1:end-1);

        topMdlBuildParMdlRefs=parMdlRefs(end);
        parMdlRefs=parMdlRefs(1:end-1);
    else
        nTotalMdls=length(allMdlRefNames);
    end


    [status,reason,buildStatusMgr]=...
    locBuildModelRefs(...
    pool,...
    iMdl,allMdlRefNames,parMdlRefs,orderedMdlRefs,nTotalMdls,...
    iTopTflChecksum,updateTopMdlRefTargetInSerial,...
    iBuildArgs,verbose,mdlrefUpdateCtrl,thisMdlUpdateCtrl,runningForExternalMode,targetType,...
    mdlRefSimModeMap,buildStatusMgr,updateMsg);


    if updateTopMdlRefTargetInSerial
        secTopLvlMdlRefNames={parMdlRefs{end}(:).modelName};

        [status,reason,buildStatusMgr]=...
        coder.parallel.buildTopRefModel(...
        iMdl,allMdlRefNames,secTopLvlMdlRefNames,topMdlBuildParMdlRefs,topMdlBuildOrderedMdlRefs,...
        iTopTflChecksum,...
        iBuildArgs,verbose,mdlrefUpdateCtrl,thisMdlUpdateCtrl,runningForExternalMode,targetType,...
        mdlRefSimModeMap,buildStatusMgr,libsToClose,updateMsg,...
        status,reason);
    end
end

function[status,reason,buildStatusMgr]=locBuildModelRefs(...
    pool,...
    iMdl,allMdlRefNames,parMdlRefs,orderedMdlRefs,nTotalMdls,...
    iTopTflChecksum,updateTopMdlRefTarget,...
    iBuildArgs,verbose,mdlrefUpdateCtrl,thisMdlUpdateCtrl,runningForExternalMode,targetType,...
    mdlRefSimModeMap,buildStatusMgr,updateMsg)

    tSlxcMasterData=[];
    status=repmat(Simulink.ModelReference.internal.ModelRefStatusHelper.getDefaultStatus(),nTotalMdls,1);
    reason=repmat({''},nTotalMdls,1);
    mainObjFolder=repmat({''},nTotalMdls,1);
    parMdlRefCopyDir='par_mdl_ref';
    fullPathParCopy=fullfile(pwd,parMdlRefCopyDir);
    mdlRefNames={orderedMdlRefs.modelName};

    parBuildTestMode=isa(pool,'coder.parallel.TestModePool');


    if parBuildTestMode
        startMsg=sl('construct_modelref_message',...
        'Simulink:slbuild:startingParallelTestModeCoderBuild',...
        'Simulink:slbuild:startingParallelTestModeSIMBuild',...
        targetType);
    else
        startMsg=sl('construct_modelref_message',...
        'Simulink:slbuild:startingParallelCoderBuild',...
        'Simulink:slbuild:startingParallelSIMBuild',...
        targetType);
    end
    slprivate('sl_disp_info',startMsg,true);


    if exist(fullPathParCopy,'dir')
        slprivate('removeDir',fullPathParCopy);
    end

    folders=Simulink.filegen.internal.FolderConfiguration(iMdl);

    if strcmp(targetType,'SIM')
        rootMdlRefDir=folders.Simulation.TargetRoot;
        sharedDir=folders.Simulation.SharedUtilityCode;
        absoluteSharedDir=folders.Simulation.absolutePath('SharedUtilityCode');
    else
        rootMdlRefDir=folders.CodeGeneration.TargetRoot;
        sharedDir=folders.CodeGeneration.SharedUtilityCode;
        absoluteSharedDir=folders.CodeGeneration.absolutePath('SharedUtilityCode');
    end

    rootMdlRefDir=RTW.reduceRelativePath(rootMdlRefDir);



    rootMdlRefSimDir=folders.Simulation.TargetRoot;
    rootMdlRefSimDir=RTW.reduceRelativePath(rootMdlRefSimDir);
    sharedSimDir=folders.Simulation.SharedUtilityCode;

    workerShared='_shared';

    if~exist(absoluteSharedDir,'dir')
        Simulink.internal.io.FileSystem.robustMkdir(absoluteSharedDir);
    end




    if slfeature('SharedCodeManager')
        if~exist(fullfile(absoluteSharedDir,'shared_file.dmr'),'file')
            SharedCodeManager.SharedCodeManagerInterface(fullfile(absoluteSharedDir,'shared_file.dmr'));
        end
    end


    addlistener(iBuildArgs.Bsn,'startMdlRefBuild',@locUpdateStatusStringParallelBuild);

    buildStatusDB=coder.internal.buildstatus.BuildStatusDB(buildStatusMgr.TopMdlName,...
    allMdlRefNames,pool.NumWorkers,targetType,iBuildArgs);
    buildStatusMgr.setBuildStatusDB(buildStatusDB);
    if isempty(buildStatusMgr.BuildStatusDialog)
        buildStatusMgr.setBuildStatusDialog(...
        coder.internal.buildstatus.getBuildStatusDialog(buildStatusMgr.TopMdlName));
    end
    if~buildStatusMgr.IsToolstripInitialized


        if iBuildArgs.OpenBuildStatusAutomatically
            buildStatusMgr.openBuildStatusDialog;
        else
            buildStatusMgr.initializeUI;
            buildStatusMgr.IsToolstripInitialized=true;
        end
    else

        buildStatusMgr.openBuildStatusTab('reset');
    end
    coder.internal.buildstatus.deregisterPreviousBuildStatusReceiverCBs;
    BsdqConnectionId=coder.internal.buildstatus.BuildStatusReceiver.getInstance.setupCallback(...
    pool,@buildStatusDB.updateInfoFromWorkersCB);
    cleanupReceiverCB=onCleanup(@()coder.internal.buildstatus.BuildStatusReceiver.getInstance.deregisterCB(BsdqConnectionId));
    buildStatusDB.ctrlTotalElapsedTimer('startTimer');

    rebuiltChildren(1:nTotalMdls)={''};
    tmpUpdateCtrl(1:nTotalMdls)={mdlrefUpdateCtrl};

    if~updateTopMdlRefTarget

        if~isempty(thisMdlUpdateCtrl)
            if(strcmpi(updateMsg,'error')&&any([status.parentalAction]))



                tmpUpdateCtrl{end}='DO_NOT_BUILD';
            else

                tmpUpdateCtrl{end}=thisMdlUpdateCtrl;
            end
        end
    end





    for i=1:nTotalMdls
        mdlSubDir=fullfile(pwd,parMdlRefCopyDir,mdlRefNames{i});
        Simulink.internal.io.FileSystem.robustMkdir(mdlSubDir);
        mdlSubFlagDir=fullfile(pwd,parMdlRefCopyDir,'flag',mdlRefNames{i});
        Simulink.internal.io.FileSystem.robustMkdir(mdlSubFlagDir);
    end





    clientFileGenCfg=Simulink.fileGenControl('getConfig');





    for i=1:nTotalMdls

        mexfile=[mdlRefNames{i},...
        coder.internal.modelRefUtil(mdlRefNames{i},...
        'getBinExt',false)];
        clear(mexfile);

        mexfile=[mdlRefNames{i},'_sfun'];
        clear(mexfile);
    end


    slcc('unloadCustomCodeDLLs');



    lCurrentSystemTargetFile=coder.internal.infoMATFileMgr('getSTF','minfo',...
    iMdl,targetType);
    [~,fTmp,eTmp]=fileparts(lCurrentSystemTargetFile);
    lCurrentSystemTargetFile=[fTmp,eTmp];


    [orderedMdlRefs,parMdlRefs]=slprivate('parComputeWeights',orderedMdlRefs,parMdlRefs,targetType,false);

    tmpOrderedMdlRefs=orderedMdlRefs;



    [orderedMdlRefs.buildTime]=deal(realmin);

    [~,sIdx]=sort([parMdlRefs{1}(:).weight],'descend');
    readyList=parMdlRefs{1}(sIdx);


    rIdx=ismember(mdlRefNames,{readyList.modelName});
    parTmpUpdateCtrl=tmpUpdateCtrl(rIdx);
    parRebuiltChildren=rebuiltChildren(rIdx);

    numMdlRefBuildsStarted=0;
    numMdlRefBuildsCompleted=0;
    futures=coder.parallel.interfaces.IFuture.empty(nTotalMdls,0);

    iBuildArgs.Bsn.numWorkers=pool.NumWorkers;
    iBuildArgs.Bsn.update(numMdlRefBuildsCompleted,'');


    createDVStages=iBuildArgs.OkayToPushNags&&verbose;
    buildLogWriter=coder.parallel.BuildLogWriter(parMdlRefs,createDVStages,iMdl);

    lastLevel={parMdlRefs{end}(:).modelName};


    while numMdlRefBuildsCompleted<nTotalMdls




        simTargetSharedObjs=locGetSimTargetObjs(sharedDir,targetType);

        if(~isempty(readyList))&&(numMdlRefBuildsStarted<nTotalMdls)

            buildStatusDB.updateBuildStatusTable({readyList.modelName},'status',...
            DAStudio.message('RTW:buildStatus:Scheduled'));




            iLinkChecksums=coder.make.internal.LinkObjChecksumCache.instance('getCsData');

            if parBuildTestMode




                numModelsToBuild=1;
            else
                numModelsToBuild=length(readyList);
            end


            for idx=1:numModelsToBuild

                numMdlRefBuildsStarted=numMdlRefBuildsStarted+1;

                lMdlRefSimModes=mdlRefSimModeMap(readyList(idx).modelName);

                mdlName=readyList(idx).modelName;


                origProtectedModelReferenceTarget=iBuildArgs.ProtectedModelReferenceTarget;
                iBuildArgs.ProtectedModelReferenceTarget=locGetProtectedModelReferenceTarget(mdlName,iBuildArgs,lastLevel);


                futures(numMdlRefBuildsStarted)=pool.runOnWorkerAsync(...
                @coder.parallel.worker.buildModelRef,...
                parTmpUpdateCtrl{idx},...
                mdlName,...
                rootMdlRefDir,...
                rootMdlRefSimDir,...
                parMdlRefCopyDir,...
                simTargetSharedObjs,...
                sharedDir,...
                sharedSimDir,...
                workerShared,...
                readyList(idx).pathToMdlRef,...
                lCurrentSystemTargetFile,...
                targetType,...
                parRebuiltChildren{idx},...
                iBuildArgs,...
                iLinkChecksums,...
                iTopTflChecksum,...
                runningForExternalMode,...
                clientFileGenCfg,...
                verbose,...
                lMdlRefSimModes,...
                readyList(idx).mdlRefSimMode,...
                readyList(idx).children,...
                readyList(idx).childSimMode,...
                readyList(idx).skipRebuild,...
                orderedMdlRefs);


                iBuildArgs.ProtectedModelReferenceTarget=origProtectedModelReferenceTarget;
            end


            readyList=readyList(numModelsToBuild+1:end);
        end


        [tParBuildLog,...
        tStatus,...
        tReason,...
        tMainObjFolder,...
        tSLXCData,...
        tHErr,...
        tErr,...
        tSubDir,...
        tMdlRefName,...
        tBuildTime,...
        buildSummary]=fetchNext(futures);


        numMdlRefBuildsCompleted=numMdlRefBuildsCompleted+1;


        buildLogWriter.printMdlRefBuildLog(tMdlRefName,tParBuildLog);


        iBuildArgs.BuildSummary.mergeForParallelBuild(buildSummary);


        if~strcmp(mdlrefUpdateCtrl,'AssumeUpToDate')
            if(tStatus.pushParBuildArtifacts~=Simulink.ModelReference.internal.ModelRefPushParBuildArtifacts.NONE)&&~tHErr

                generateCodeOnly=logical(iBuildArgs.BaGenerateCodeOnly)&&...
                ~strcmp(iBuildArgs.ModelReferenceTargetType,'SIM');

                coder.parallel.mergeBuildArtifacts(tSubDir,...
                rootMdlRefDir,...
                sharedDir,...
                tMainObjFolder,...
                workerShared,...
                iMdl,...
                tMdlRefName,...
                tStatus.pushParBuildArtifacts,...
                targetType,...
                generateCodeOnly);

            else
                [~,cIdx]=ismember(tMdlRefName,mdlRefNames);
                pathsToMdlRef={orderedMdlRefs(:).pathToMdlRef};
                if(tStatus.targetStatus==Simulink.ModelReference.internal.ModelRefTargetStatus.TARGET_WAS_UP_TO_DATE)&&~tHErr&&...
                    ~Simulink.DistributedTarget.DistributedTargetUtils.requiresRTWBuild(...
                    tMdlRefName,pathsToMdlRef{cIdx},targetType)

                    binfoCache=coder.internal.infoMATFileMgr(...
                    'createEmptyBinfo','binfo',...
                    tMdlRefName,...
                    targetType);
                    fullMatFileName=coder.internal.infoMATFileMgr...
                    ('getMatFileName','binfo',tMdlRefName,targetType);
                    coder.internal.saveMinfoOrBinfo(binfoCache,fullMatFileName);
                end
            end


            if~isempty(tSLXCData)
                tSlxcMasterData=[tSlxcMasterData,tSLXCData];%#ok
            end
        end



        buildCanceled=locCheckForCanceledBuild();
        if tHErr||buildCanceled
            locTerminateBuildAndThrowException(...
            futures,buildStatusMgr,parBuildTestMode,buildCanceled,...
            tMdlRefName,tmpOrderedMdlRefs,tSlxcMasterData,tBuildTime,...
            tStatus,numMdlRefBuildsCompleted,targetType,tErr);
        end


        iBuildArgs.Bsn.update(numMdlRefBuildsCompleted,'');


        if tStatus.targetStatus==Simulink.ModelReference.internal.ModelRefTargetStatus.TARGET_UPDATED
            buildStatusLastMsg=DAStudio.message('RTW:buildStatus:Completed');
        else
            buildStatusLastMsg=DAStudio.message('RTW:buildStatus:WasUpToDate');
        end
        buildStatusDB.updateBuildStatusTable({tMdlRefName},...
        'status',buildStatusLastMsg,...
        'buildTime',tBuildTime);
        buildStatusDB.updateTopProgressBar(numMdlRefBuildsCompleted);

        [~,cIdx]=ismember(tMdlRefName,mdlRefNames);
        status(cIdx)=tStatus;
        reason{cIdx}=tReason;
        mainObjFolder{cIdx}=tMainObjFolder;


        [tmpOrderedMdlRefs,readyList,tmpUpdateCtrl,parTmpUpdateCtrl,...
        parRebuiltChildren,rebuiltChildren]=...
locUpdateReadyToBuild...
        (tmpOrderedMdlRefs,readyList,tMdlRefName,...
        thisMdlUpdateCtrl,mdlRefNames,updateMsg,status,tmpUpdateCtrl,...
        rebuiltChildren);


        orderedMdlRefs(cIdx).buildTime=tBuildTime;

    end




    if(rtwprivate('rtw_is_cpp_build',iMdl))
        langExtension='.cpp';
    else
        langExtension='.c';
    end
    outFileName=fullfile(absoluteSharedDir,['const_params',langExtension]);
    if isfile(outFileName)
        rtwprivate('cBeautifierWithOptions',outFileName,iMdl);
    end


    clientSUManifest=fullfile(absoluteSharedDir,'manifest.mat');
    if(exist(clientSUManifest,'file')==2)
        builtin('delete',clientSUManifest);
    end


    okToThrow=true;
    if parBuildTestMode
        packType=Simulink.packagedmodel.pack.PackType.PARALLEL_BUILD_TESTING;
    else
        packType=Simulink.packagedmodel.pack.PackType.PARALLEL_BUILD;
    end
    coder.slxc.doPackSLCache(tSlxcMasterData,okToThrow,packType);



    [~,optNumWorkers]=slprivate('estimateParBuildTime',buildStatusMgr.TopMdlName,0,false,...
    strcmp(targetType,'SIM'),true,orderedMdlRefs,parMdlRefs);
    buildStatusDB.updateOptNumWorkers(optNumWorkers);
    if length(buildStatusDB.StatusTable.keys)==length(orderedMdlRefs)
        buildStatusDB.ctrlTotalElapsedTimer('stopTimer');
        switch targetType
        case 'SIM'
            lFolder=RTW.getBuildDir(buildStatusMgr.TopMdlName).ModelRefRelativeRootSimDir;
        case 'RTW'
            lFolder=RTW.getBuildDir(buildStatusMgr.TopMdlName).ModelRefRelativeRootTgtDir;
        end
        save(fullfile(lFolder,['buildStatusDB_',buildStatusMgr.TopMdlName,'.mat']),'buildStatusDB');
    end
    buildStatusMgr.setBuildStatusDB(buildStatusDB);






    if exist(fullPathParCopy,'dir')
        slprivate('removeDir',fullPathParCopy);
    end

end

function locUpdateStatusStringParallelBuild(bsn,~)

    switch(bsn.targetType)
    case 'SIM'
        statusMsgId='Simulink:modelReference:updatingParallelSIMTargetStatus';
    case 'RTW'
        statusMsgId='Simulink:modelReference:updatingParallelCoderTargetStatus';
    otherwise
        assert(false,['Unexpected target type: ',bsn.targetType]);
    end


    parallelStatusStr=DAStudio.message(...
    statusMsgId,...
    bsn.mdlCounter,...
    bsn.nTotalMdls,...
    bsn.numWorkers);
    set_param(bsn.iMdl,'StatusString',parallelStatusStr);
end





function simTargetSharedObjs=locGetSimTargetObjs(sharedDir,targetType)

    if strcmp(targetType,'SIM')

        simTargetSharedObjs=dir(fullfile(sharedDir,'*.o*'));
        simTargetSharedObjs={simTargetSharedObjs.name};



        constParamsPrefix='const_params.';
        constParamsIdx=strncmp(simTargetSharedObjs,constParamsPrefix,...
        length(constParamsPrefix));
        simTargetSharedObjs=simTargetSharedObjs(~constParamsIdx);
    else
        simTargetSharedObjs={};
    end
end

function locTerminateBuildAndThrowException(...
    futures,buildStatusMgr,parBuildTestMode,buildCanceled,tMdlRefName,...
    tmpOrderedMdlRefs,tSlxcMasterData,tBuildTime,tStatus,...
    numMdlRefBuildsCompleted,targetType,tErr)

    if~parBuildTestMode
        if buildCanceled
            cancelingList=locUpdateUIWithCanceledBuilds(tMdlRefName,...
            tmpOrderedMdlRefs,buildStatusMgr.BuildStatusDB);
        end


        cancel(futures);
    end



    okToThrow=false;
    if parBuildTestMode
        packType=Simulink.packagedmodel.pack.PackType.PARALLEL_BUILD_TESTING;
    else
        packType=Simulink.packagedmodel.pack.PackType.PARALLEL_BUILD;
    end
    coder.slxc.doPackSLCache(tSlxcMasterData,okToThrow,packType);

    if buildCanceled
        slprivate('checkBuildState','setstate',...
        coder.internal.BuildState.CANCELED);

        buildStatusMgr.BuildStatusDB.updateBuildStatusTable(cancelingList,...
        'status',DAStudio.message('RTW:buildStatus:Canceled'));
        buildStatusMgr.updateWithFinalState(tMdlRefName,targetType,false,...
        tStatus.targetStatus,tBuildTime,numMdlRefBuildsCompleted);
        DAStudio.error('RTW:buildProcess:buildCanceledByUser');
    else
        slprivate('checkBuildState','setstate',...
        coder.internal.BuildState.ERROR);

        buildStatusMgr.updateWithFinalState(tMdlRefName,targetType,true);
        rethrow(tErr);
    end
end

function[tmpOrderedMdlRefs,readyList,tmpUpdateCtrl,...
    parTmpUpdateCtrl,parRebuiltChildren,rebuiltChildren]=...
locUpdateReadyToBuild...
    (tmpOrderedMdlRefs,readyList,tMdlRefName,...
    thisMdlUpdateCtrl,mdlRefNames,updateMsg,status,tmpUpdateCtrl,...
    rebuiltChildren)


    [tmpOrderedMdlRefs,readyList,newReadyNode]=locUpdateReadyList(tmpOrderedMdlRefs,readyList,tMdlRefName);

    for i=1:length(newReadyNode)
        if~isempty(thisMdlUpdateCtrl)
            if strcmp(newReadyNode(i).modelName,mdlRefNames{end})
                if(strcmpi(updateMsg,'error')&&any([status.parentalAction]))



                    tmpUpdateCtrl{end}='DO_NOT_BUILD';
                else

                    tmpUpdateCtrl{end}=thisMdlUpdateCtrl;
                end
            end
        end








        childIdx=ismember(mdlRefNames,newReadyNode(i).children);
        paIdx=[status(childIdx).parentalAction]==...
        Simulink.ModelReference.internal.ModelRefParentalAction.CHECK_FOR_REBUILD;
        if any(paIdx)
            numericIdx=find(childIdx);
            [~,nodeIdx]=ismember(newReadyNode(i).modelName,mdlRefNames);
            rebuiltChildren{nodeIdx}=mdlRefNames{numericIdx(paIdx)};
        end
    end


    rIdx=ismember(mdlRefNames,{readyList.modelName});
    parTmpUpdateCtrl=tmpUpdateCtrl(rIdx);
    parRebuiltChildren=rebuiltChildren(rIdx);
end

function[oStruct,readyList,newReadyNode]=locUpdateReadyList(oStruct,readyList,tMdlRefName)
    newReadyNode=struct('modelName',{},'children',{});

    idx=strcmp(tMdlRefName,{oStruct(:).modelName});
    node=oStruct(idx);

    oStruct(idx)=[];

    [tf,idx]=ismember(node.directParents,{oStruct(:).modelName});
    pNode=oStruct(idx(tf));
    for numPNode=1:length(pNode)
        tf=ismember(pNode(numPNode).children,{oStruct(:).modelName});
        if~any(tf)


            newReadyNode(end+1).modelName=pNode(numPNode).modelName;%#ok<AGROW>
            newReadyNode(end).children=pNode(numPNode).children;
            readyList(end+1)=pNode(numPNode);%#ok<AGROW>
            [~,sIdx]=sort([readyList(:).weight],'descend');
            readyList=readyList(sIdx);
        end
    end
end

function buildCanceled=locCheckForCanceledBuild()
    drawnow;
    buildCanceled=false;
    buildState=slprivate('checkBuildState','getstate');
    if((buildState==coder.internal.BuildState.CANCELING)||...
        (buildState==coder.internal.BuildState.CANCELED))
        buildCanceled=true;
    end
end

function cancelingList=locUpdateUIWithCanceledBuilds(tMdlRefName,tmpOrderedMdlRefs,buildStatusDB)
    fullList={tmpOrderedMdlRefs(:).modelName};
    fullList=setdiff(fullList,tMdlRefName);
    cancelingList=unique(fullList);
    if ismember(buildStatusDB.TopMdlName,buildStatusDB.StatusTable.keys)
        cancelingList=[cancelingList,{buildStatusDB.TopMdlName}];
    end
    buildStatusDB.updateBuildStatusTable(cancelingList,'status',DAStudio.message('RTW:buildStatus:Canceling'));
end

function protectedModelReferenceTarget=locGetProtectedModelReferenceTarget(mdlRef,buildArgs,lastLevel)
    if buildArgs.UpdateTopModelReferenceTarget||contains(mdlRef,lastLevel)
        protectedModelReferenceTarget=false;
    else
        protectedModelReferenceTarget=buildArgs.ProtectedModelReferenceTarget;
    end
end




