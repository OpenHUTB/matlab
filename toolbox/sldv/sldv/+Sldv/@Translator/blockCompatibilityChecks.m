


function status=blockCompatibilityChecks(obj)








    status=true;

    try
        compatStatusStr=obj.mCompatStatus.char;
        if~obj.mSkipTranslation

            compatStatusStr=obj.designModelCompatibilityChecks();



            if~strcmp('DV_COMPAT_INCOMPATIBLE',compatStatusStr)
                [compatStatusStr,obj.mStubsfcns]=obj.genericCompatibilityChecks(...
                obj.mModelToCheckCompatH,obj.mBlkHs,obj.mBlkTypes);
            end
        end




        observerModelHs=obj.mCompatObserverModelHs;
        observerBlkHs=cell(1,numel(observerModelHs));
        observerBlkTypes=cell(1,numel(observerModelHs));
        observerStubSFcns=cell(1,numel(observerModelHs));






        sldvshareprivate('avtcgirunsupcollect','enableForcedWarning');
        enableErrorPush=onCleanup(@()sldvshareprivate('avtcgirunsupcollect','disableForcedWarning'));

        if~strcmp('DV_COMPAT_INCOMPATIBLE',compatStatusStr)


            for currObs=1:numel(observerModelHs)
                [observerBlkHs{currObs},observerBlkTypes{currObs}]=...
                obj.getBlockHsAndBlockTypes(observerModelHs(currObs));

                [obsCompatStatus,observerStubSFcns{currObs}]=...
                obj.genericCompatibilityChecks(observerModelHs(currObs),...
                observerBlkHs{currObs},observerBlkTypes{currObs});

                obsCompatStatus=checkIfObservingSFParameter(obj.mRootModelH,observerModelHs(currObs),obsCompatStatus);
                if strcmp(obsCompatStatus,'DV_COMPAT_INCOMPATIBLE')
                    registerIncompatObserver(obj.mRootModelH,observerModelHs(currObs));
                    obj.mCompatObserverModelHs(obj.mCompatObserverModelHs==observerModelHs(currObs))=[];
                end
            end
        end

        obj.mCompatStatus=Sldv.CompatStatus(compatStatusStr);




        if~isempty(observerModelHs)
            storeObserverTranslationInfo(obj.mRootModelH,observerModelHs,...
            observerBlkHs,observerBlkTypes,observerStubSFcns);
        end
    catch MEx
        status=false;
        obj.mCompatStatus=Sldv.CompatStatus('DV_COMPAT_INCOMPATIBLE');
        sldvshareprivate('avtcgirunsupcollect','push',obj.mModelToCheckCompatH,...
        'sldv',...
        MEx.message,'SLDV:Compatibility:Generic');
    end
end

function registerIncompatObserver(topMdlH,obsMdlH)
    errMsg=getString(message('Sldv:Observer:IgnoreIncompatObs',getfullname(obsMdlH)));
    sldvshareprivate('avtcgirunsupcollect','push',topMdlH,'sldv_warning',errMsg,...
    'Sldv:Observer:IgnoreIncompatObs');
    session=sldvprivate('sldvGetActiveSession',topMdlH);
    session.addToIncompatObserverList(obsMdlH);
end

function storeObserverTranslationInfo(designModelH,observerModelHs,observerBlkHs,observerBlkTypes,observerStubSFcns)



    activeSession=sldvprivate('sldvGetActiveSession',designModelH);
    assert(~isempty(activeSession));
    for currObs=1:numel(observerModelHs)
        translationInfo.Blocks=[observerBlkHs{currObs}];
        translationInfo.BlockTypes=observerBlkTypes{currObs};
        translationInfo.StubSFunctions=observerStubSFcns{currObs};
        activeSession.setObserverTranslationInfo(observerModelHs(currObs),translationInfo);
    end
end








function compatStatus=checkIfObservingSFParameter(topModelH,obsModelH,compatStatus)
    if strcmp('DV_COMPAT_INCOMPATIBLE',compatStatus)
        return;
    end



    Simulink.observer.internal.loadObserverModelsForBD(topModelH,false);
    switchStandalone=onCleanup(@()Sldv.utils.switchObsMdlsToStandaloneMode(topModelH));

    obsPortHs=Simulink.observer.internal.getObserverPortsInsideObserverModel(obsModelH);

    for obsPortNo=1:numel(obsPortHs)





        currObsPortH=obsPortHs(obsPortNo);
        obsEntityFullSpec=Simulink.observer.internal.getObservedEntity(currObsPortH);
        obsEntitySplitSpec=string(split(obsEntityFullSpec,'|'));
        if~strcmp(obsEntitySplitSpec(1),"SFD")
            continue;
        end
        sfSID=obsEntitySplitSpec(end-1)+":"+obsEntitySplitSpec(end);
        sfObjH=Simulink.ID.getHandle(sfSID);

        if~isequal(sfObjH.scope,'Parameter')
            continue;
        end

        errMsg=getString(message('Sldv:Observer:UnsupObsEntitySFParam',...
        getfullname(currObsPortH),getfullname(obsEntitySplitSpec(2))));
        sldvshareprivate('avtcgirunsupcollect','push',topModelH,'sldv_warning',errMsg,...
        'Sldv:Observer:UnsupObsEntitySFParam');

        compatStatus='DV_COMPAT_INCOMPATIBLE';
        return;
    end
end
