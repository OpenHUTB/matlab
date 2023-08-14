function[status,reason,buildStatusMgr]=hBuildModelRefs(...
    iMdl,mdlRefNames,secTopLvlMdlRefNames,parMdlRefs,orderedMdlRefs,...
    iTopTflChecksum,updateTopMdlRefTargetInSerial,...
    iBuildArgs,verbose,mdlrefUpdateCtrl,thisMdlUpdateCtrl,runningForExternalMode,targetType,...
    mdlRefSimModeMap,buildStatusMgr,libsToClose,updateMsg,...
    status,reason)




    nMdlRefLvls=length(parMdlRefs);
    lvlStatus=struct('targetStatus',[],'parentalAction',[],'artifactStatus',[],'pushParBuildArtifacts',[]);
    tSlxcMasterData=[];


    coder.internal.ParallelAnchorDirManager('set','','');






    topStoredChecksum=iBuildArgs.StoredChecksum;
    iBuildArgs.StoredChecksum=[];
    topStoredParamChecksum=iBuildArgs.StoredParameterChecksum;
    iBuildArgs.StoredParameterChecksum=[];

    locRegisterListeners(iMdl,iBuildArgs);



    for lvl=1:nMdlRefLvls
        if updateTopMdlRefTargetInSerial
            [~,mdlIdx,lvlIdx]=intersect(mdlRefNames,secTopLvlMdlRefNames);
            lvlStatus(lvlIdx)=status(mdlIdx);
        end



        nMdlRefs=length(parMdlRefs{lvl});



        rebuiltChildren={};
        rebuiltChildren(1:nMdlRefs)={''};

        tmpUpdateCtrl={};
        tmpUpdateCtrl(1:nMdlRefs)={mdlrefUpdateCtrl};
        for i=1:nMdlRefs
            if~isempty(thisMdlUpdateCtrl)
                if((lvl==nMdlRefLvls)&&(i==nMdlRefs))
                    if(strcmpi(updateMsg,'error')&&any([lvlStatus.parentalAction]))



                        tmpUpdateCtrl{i}='DO_NOT_BUILD';
                    else

                        tmpUpdateCtrl{i}=thisMdlUpdateCtrl;
                    end
                end
            end



            if(lvl>1)||updateTopMdlRefTargetInSerial






                childIdx=ismember(mdlRefNames,parMdlRefs{lvl}(i).children);
                paIdx=[status(childIdx).parentalAction]==...
                Simulink.ModelReference.internal.ModelRefParentalAction.CHECK_FOR_REBUILD;
                if any(paIdx)
                    numericIdx=find(childIdx);
                    rebuiltChildren{i}=mdlRefNames{numericIdx(paIdx)};
                end
            end
        end

        lvlStatus=repmat(Simulink.ModelReference.internal.ModelRefStatusHelper.getDefaultStatus(),nMdlRefs,1);
        lvlReason=repmat({''},nMdlRefs,1);
        lvlMainObjFolder=repmat({''},nMdlRefs,1);
        lvlSLXCData=repmat({},nMdlRefs,1);

        lvlMdlRefNames={parMdlRefs{lvl}(:).modelName};
        lvlMdlRefSimModes=cellfun(@(x)mdlRefSimModeMap(x),...
        {parMdlRefs{lvl}(:).modelName},...
        'UniformOutput',false);
        pathToMdls={parMdlRefs{lvl}(:).pathToMdlRef};









        origProtectedModelReferenceTarget=iBuildArgs.ProtectedModelReferenceTarget;

        if(lvl<nMdlRefLvls)
            iBuildArgs.ProtectedModelReferenceTarget=false;
        end


        for i=1:nMdlRefs

            iBuildArgs.Bsn.increment(lvlMdlRefNames{i});

            if strcmp(tmpUpdateCtrl(i),'DO_NOT_BUILD')
                continue;
            end

            if((lvl==nMdlRefLvls)&&(i==nMdlRefs)&&(updateTopMdlRefTargetInSerial))
                iBuildArgs.StoredChecksum=topStoredChecksum;
                iBuildArgs.StoredParameterChecksum=topStoredParamChecksum;
            end

            try


                if iBuildArgs.OkayToPushNags&&verbose
                    model_name_mv_hdr_stage=Simulink.output.Stage(...
                    DAStudio.message('Simulink:modelReference:MessageViewer_BuildingTarget',...
                    lvlMdlRefNames{i}),...
                    'ModelName',iMdl,'UIMode',true);%#ok<NASGU>
                end



                skipName=arrayfun(@(x)strcmp(x.modelName,lvlMdlRefNames{i}),orderedMdlRefs);
                indexSkip=find(skipName);
                if~isempty(indexSkip)
                    skipRebuild=orderedMdlRefs(indexSkip).skipRebuild;
                end

                [lvlStatus(i),lvlReason{i},lvlMainObjFolder{i},lvlSLXCData{i}]=...
                slprivate('updateMdlRefTarget',lvlMdlRefNames{i},...
                pathToMdls{i},...
                targetType,...
                tmpUpdateCtrl{i},...
                rebuiltChildren{i},...
                iBuildArgs,...
                lvlMdlRefSimModes{i},...
                iTopTflChecksum,...
                runningForExternalMode,...
                verbose,...
                [],...
                [],...
                [],...
                '',...
                skipRebuild);
                if~isempty(lvlSLXCData{i})
                    tSlxcMasterData=[tSlxcMasterData,lvlSLXCData{i}];%#ok<AGROW>
                end
                if updateTopMdlRefTargetInSerial
                    tBuildTime=0;
                    infoStruct=coder.internal.infoMATPostBuild('load','binfo',...
                    lvlMdlRefNames{i},targetType,...
                    get_param(lvlMdlRefNames{i},'SystemTargetFile'));

                    if isfield(infoStruct.buildStats,'buildTime')
                        tBuildTime=infoStruct.buildStats.buildTime;
                    end
                    nTotalMdls=length(mdlRefNames);
                    buildStatusMgr.updateWithFinalState(lvlMdlRefNames{i},...
                    targetType,false,lvlStatus(i).targetStatus,tBuildTime,nTotalMdls);
                end


                clear model_name_mv_hdr_stage;



                if coder.make.internal.featureOn('ExplicitLibClosing')
                    slprivate('close_models',libsToClose(lvlMdlRefNames{i}));
                end
            catch me
                okToThrow=false;
                packType=Simulink.packagedmodel.pack.PackType.SERIAL_BUILD;
                coder.slxc.doPackSLCache(tSlxcMasterData,okToThrow,packType);
                if updateTopMdlRefTargetInSerial
                    buildStatusMgr.updateWithFinalState(lvlMdlRefNames{i},...
                    targetType,true);
                end
                rethrow(me);
            end
        end


        iBuildArgs.ProtectedModelReferenceTarget=origProtectedModelReferenceTarget;

        [~,mdlIdx,lvlIdx]=intersect(mdlRefNames,lvlMdlRefNames);
        status(mdlIdx)=lvlStatus(lvlIdx);
        reason(mdlIdx)=lvlReason(lvlIdx);
    end

    okToThrow=true;
    packType=Simulink.packagedmodel.pack.PackType.SERIAL_BUILD;
    coder.slxc.doPackSLCache(tSlxcMasterData,okToThrow,packType);
end

function locRegisterListeners(iMdl,iBuildArgs)
    addlistener(iBuildArgs.Bsn,'startMdlRefBuild',@locUpdateStatusStringSerialBuild);
    if~isempty(get_param(iMdl,'CoderWizard'))
        addlistener(iBuildArgs.Bsn,'startMdlRefBuild',@coder.internal.wizard.Wizard.buildStatusUpdate);
    end
end

function locUpdateStatusStringSerialBuild(bsn,~)


    switch(bsn.targetType)
    case 'SIM'
        statusMsgId='Simulink:modelReference:updatingSIMTargetStatus';
    case 'RTW'
        statusMsgId='Simulink:modelReference:updatingCoderTargetStatus';
    otherwise
        assert(false,['Unexpected target type: ',bsn.targetType]);
    end
    statusMsg=DAStudio.message(statusMsgId,...
    bsn.mdlCounter,bsn.nTotalMdls,bsn.lvlMdlRefName);
    set_param(bsn.iMdl,'StatusString',statusMsg);
    if slsvTestingHook('ProtectedModelTestProgressStatus')>0
        disp(statusMsg);
    end
end


