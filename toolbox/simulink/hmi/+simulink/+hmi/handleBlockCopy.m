function handleBlockCopy(modelHandle,srcModel,dstBlkPath,dstID,srcID)






    try
        refBlock=get_param(dstBlkPath,'ReferenceBlock');
        isInLib=~isempty(refBlock);
        if isInLib
            return;
        end

        dstModelName=get_param(modelHandle,'Name');
        showInitialText=get_param(dstBlkPath,'ShowInitialText');
        bShowInitialText=strcmpi(showInitialText,'on');
        Simulink.HMI.WebHMI.showInitialText(modelHandle,dstID,bShowInitialText,isInLib);
        dstParent=dstModelName;
    catch me %#ok<NASGU>
        return
    end

    if isempty(srcModel)||strcmp(srcModel,'[]')
        srcModel=locGetSourceModel(srcModel,dstModelName,dstBlkPath);
    end


    if isempty(srcModel)||strcmp(srcModel,'[]')||strcmp(srcModel,dstModelName)
        return;
    end

    srcParent=srcModel;


    if~bdIsLoaded(srcModel)
        return
    end


    srcModelHandle=get_param(srcModel,'Handle');
    srcHMI=Simulink.HMI.WebHMI.getWebHMI(srcModelHandle);
    if isempty(srcHMI)
        return
    end

    srcWidget=srcHMI.getWidget(srcID,false);
    if isempty(srcWidget)
        return
    end

    dstHMI=Simulink.HMI.WebHMI.getWebHMI(modelHandle);
    dstWidget=dstHMI.getWidget(dstID,isInLib);


    propNames=properties(srcWidget);
    for idx=1:length(propNames)
        if~strcmp(propNames{idx},'ID')&&~strcmp(propNames{idx},'ClientID')&&~strcmp(propNames{idx},'Value')
            dstWidget.(propNames{idx})=srcWidget.(propNames{idx});
        end
    end


    if isa(dstWidget,'Simulink.HMI.SDIScope')
        signalInfo=locGetScopeSignals(srcModel,srcWidget);
        locRebindScope(signalInfo,dstWidget,dstModelName,isInLib);
    else
        srcBinding=srcHMI.getBoundElement(srcID,false);
        if~isempty(srcBinding)
            srcBinding=locUpdateBindingBlockPath(srcBinding,srcParent,dstParent);
            if isa(srcBinding,'Simulink.HMI.SignalSpecification')
                locRebindSignal(srcBinding,dstWidget,isInLib);
            elseif isa(srcBinding,'Simulink.HMI.ParamSourceInfo')
                locRebindParameter(srcBinding,dstWidget,dstModelName,isInLib);
            end
        end
    end
end


function srcBinding=locUpdateBindingBlockPath(srcBinding,srcModel,dstModelName)
    for idx=1:length(srcBinding)
        if srcBinding(idx).BlockPath.getLength()>0
            bpath=srcBinding(idx).BlockPath.convertToCell();
            charsToRemove=length(srcModel);
            bpath{1}=bpath{1}(charsToRemove+1:end);
            bpath{1}=[dstModelName,bpath{1}];
            if isa(srcBinding,'Simulink.HMI.SignalSpecification')
                srcBinding(idx).CachedBlockHandle_=[];
            end
            try
                sid=get_param(bpath{1},'SIDFullString');
                srcBinding(idx).BlockPath=...
                Simulink.HMI.BlockPathUtils.createPathFromMetaData(bpath,{sid},'');
            catch me %#ok<NASGU>
                srcBinding(idx).BlockPath=...
                Simulink.HMI.BlockPathUtils.createPathFromMetaData(bpath,{''},'');
            end
        end
    end
end


function locRebindSignal(srcBinding,dstWidget,isInLib)

    newBinding=srcBinding.applyRebindingRules();
    dstWidget.bind(newBinding,isInLib);
end


function signalInfo=locGetScopeSignals(srcModel,srcWidget)


    signalInfo=srcWidget.getBoundSignals();
    for idx=1:length(signalInfo)
        signalInfo(idx).mdl=srcModel;
        bpath=signalInfo(idx).BlockPath;
        signalInfo(idx).BlockPath=[srcModel,'/',bpath];
        [client,~,wasAdded]=Simulink.sdi.internal.Utils.getWebClient(signalInfo(idx));
        if~wasAdded
            signalInfo(idx).DefaultColorAndStyle=false;
            signalInfo(idx).LineStyle=client.ObserverParams.LineSettings.LineStyle;
            signalInfo(idx).LineColor=client.ObserverParams.LineSettings.Color*255;
        else
            signalInfo(idx).DefaultColorAndStyle=true;
            if~any(signalInfo(idx).LineColor>1)
                signalInfo(idx).LineColor=255*signalInfo(idx).LineColor;
            end
        end
        signalInfo(idx).BlockPath=bpath;
    end
end


function locRebindScope(signalInfo,dstWidget,dstModelName,isInLib)

    idxToRemove=[];
    for idx=1:length(signalInfo)
        sig=Simulink.HMI.SignalSpecification;
        sig.BlockPath=Simulink.BlockPath([dstModelName,'/',signalInfo(idx).BlockPath]);
        sig.OutputPortIndex=signalInfo(idx).OutputPortIndex;
        sig.SignalName_=signalInfo(idx).SignalName;
        sig=sig.applyRebindingRules();
        if isempty(sig.CachedBlockHandle_)
            idxToRemove(end+1)=idx;%#ok<AGROW>
        else

            blkObj=get_param(sig.CachedBlockHandle_,'Object');
            newBlkPath=blkObj.getFullName();
            charsToRemove=length(dstModelName)+1;
            signalInfo(idx).BlockPath=newBlkPath(charsToRemove+1:end);
        end
    end
    signalInfo(idxToRemove)=[];


    if~isempty(signalInfo)
        simulink.hmi.sdiscope.bind(dstWidget.ID,dstModelName,signalInfo,isInLib);
    end
end


function locRebindParameter(srcBinding,dstWidget,dstModelName,isInLib)
    newBinding=srcBinding.applyRebindingRules(dstModelName,dstModelName);
    dstWidget.bind(newBinding,isInLib);
end

function srcModel=locGetSourceModel(srcModelName,dstModelName,dstBlkPath)
    srcModel=srcModelName;
    bIsHarnessBd=isequal(get_param(dstModelName,'IsHarness'),'on');
    if bIsHarnessBd
        ownerBd=Simulink.harness.internal.getHarnessOwnerBD(dstModelName);
        charsToRemove=length(dstModelName);
        bpath=dstBlkPath(charsToRemove+1:end);
        bpath=[ownerBd,bpath];
        try
            parent=get_param(bpath,'Parent');
        catch
            return;
        end
        while~isempty(parent)
            ssHandle=get_param(parent,'Handle');
            if Simulink.harness.internal.hasHarness(ssHandle)
                srcModel=ownerBd;
                return;
            else
                parent=get_param(parent,'Parent');
            end
        end
    end
end
