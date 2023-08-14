function status=saveCompatData(obj)




    testComp=obj.mTestComp;

    if~sldvprivate('isReuseTranslationON',testComp.activeSettings)
        status=true;
        return;
    end


    if~(strcmp(testComp.compatStatus,'DV_COMPAT_COMPATIBLE')||...
        strcmp(testComp.compatStatus,'DV_COMPAT_PARTIALLY_SUPPORTED'))
        status=true;
        return;
    end


    compatibilityData=testComp.getModelMappingInfo();


    if sldvprivate('isObserverSupportON',obj.mTestComp.activeSettings)
        compatibilityData.LinkSpec=testComp.getLinkSpec();
        compatibilityData.TraceInfo=testComp.getTraceInfo();
    end




    for idx=1:numel(compatibilityData.CheckExprInfo)
        blockH=compatibilityData.CheckExprInfo(idx).CheckTag.BlockID;
        sfId=compatibilityData.CheckExprInfo(idx).CheckTag.SFObjID;
        [blkSID,sfSID]=obj.convertToSIDs(blockH,sfId);
        compatibilityData.CheckExprInfo(idx).CheckTag.BlockID=blkSID;
        compatibilityData.CheckExprInfo(idx).CheckTag.SFObjID=sfSID;
        if~isSIDValid(blockH,blkSID)||~isSIDValid(sfId,sfSID)
            status=false;
            return;
        end
    end


    for idx=1:numel(compatibilityData.CompilationInfo.ModelObject)
        blockH=compatibilityData.CompilationInfo.ModelObject(idx).BlockID;
        sfId=compatibilityData.CompilationInfo.ModelObject(idx).SFObjID;
        [blkSID,sfSID]=obj.convertToSIDs(blockH,sfId);
        compatibilityData.CompilationInfo.ModelObject(idx).BlockID=blkSID;
        compatibilityData.CompilationInfo.ModelObject(idx).SFObjID=sfSID;
        if~isSIDValid(blockH,blkSID)||~isSIDValid(sfId,sfSID)
            status=false;
            return;
        end
    end


    emlIds=testComp.getEmlCovMapObjects();
    if~(isempty(emlIds.sfId)&&isempty(emlIds.blkH))
        ctr=0;
        [emlIds.sfId,uIdx]=unique(emlIds.sfId);
        emlIds.blkH=emlIds.blkH(uIdx);
        for idx=1:numel(emlIds.sfId)
            sfId=emlIds.sfId(idx);
            if sfId>0
                blkH=emlIds.blkH(idx);
                [blkSID,sfSID]=obj.convertToSIDs(blkH,sfId);

                ctr=ctr+1;
                compatibilityData.CompilationInfo.EmlCovMapInfo(ctr).sfId=sfSID;
                compatibilityData.CompilationInfo.EmlCovMapInfo(ctr).blkId=blkSID;
                compatibilityData.CompilationInfo.EmlCovMapInfo(ctr).covMap=sfprivate('sf','get',sfId,'.eml.cvMapInfo');

                if~isSIDValid(blkH,blkSID)||~isSIDValid(sfId,sfSID)
                    status=false;
                    return;
                end
            end
        end
    end


    compatStatus=testComp.compatStatus;


    if~isempty(obj.mExtractedModelH)
        analysisInfo.extractedModel=get_param(testComp.analysisInfo.extractedModelH,'Name');
        analysisInfo.analyzedSubsystem=Simulink.ID.getSID(testComp.analysisInfo.analyzedSubsystemH);
        analysisInfo.analyzedAtomicSubchartWithParam=testComp.analysisInfo.analyzedAtomicSubchartWithParam;
        analysisInfo.blockDiagramExtract=testComp.analysisInfo.blockDiagramExtract;
        analysisInfo.exportFcnGroupsInfo=testComp.analysisInfo.exportFcnGroupsInfo;
        analysisInfo.stubbedSimulinkFcnInfo=testComp.analysisInfo.stubbedSimulinkFcnInfo;
    else
        analysisInfo.extractedModel='';
    end


    analysisInfo.replacementInfo=testComp.analysisInfo.replacementInfo;
    if~isempty(analysisInfo.replacementInfo.replacementModelH)
        analysisInfo.replacementInfo.replacementModelName=get_param(analysisInfo.replacementInfo.replacementModelH,'Name');
        analysisInfo.replacementInfo=rmfield(analysisInfo.replacementInfo,'replacementModelH');
        analysisInfo.replacementInfo.replacementTable=replaceHdlsWithPath(analysisInfo.replacementInfo.replacementTable);
        analysisInfo.replacementInfo.notReplacedBlksTable=replaceHdlsWithPath(analysisInfo.replacementInfo.notReplacedBlksTable);
    end


    analysisInfo.emlIdInfo=testComp.getEmlIdInfo();
    analysisInfo.compatMsgIgnoreBlkTypes=testComp.getCompatIgnoreBlkTypes();
    analysisInfo.reducedBlocks=testComp.reducedBlocks;
    analysisInfo.conditionallyExecutedBlocks=testComp.conditionallyExecutedBlocks;
    analysisInfo.slowestTaskTicks=testComp.slowestTaskTicks;
    analysisInfo.mdlFlatIOInfo=testComp.mdlFlatIOInfo;
    analysisInfo.createableSimData=testComp.createableSimData;
    analysisInfo.mdlSampleTimes=testComp.mdlSampleTimes;
    analysisInfo.forcedTurnOnRelationalBoundary=testComp.forcedTurnOnRelationalBoundary;

    analysisInfo.pathCompositionSpec=testComp.pathCompositionSpec;

    [status,appliedTimerOptimizations]=getAppliedTimerOptimizations(obj);
    if status
        analysisInfo.appliedTimerOptimizations=appliedTimerOptimizations;
    else
        status=false;
        return;
    end


    translationState=obj.mTranslationState;



    assert(isfolder(obj.mCacheDirFullPath));

    [filename,fileExt]=obj.getTranslationDataFileName();
    filename=fullfile(obj.mCacheDirFullPath,[filename,fileExt]);
    compatTimestamp=testComp.compatTimestamp;
    try
        save(filename,'compatibilityData',...
        'analysisInfo',...
        'compatStatus',...
        'translationState',...
        'compatTimestamp');
        if~isempty(obj.mExtractedModelH)&&~isequal(obj.mExtractedModelH,obj.mRootModelH)
            extractedModelName=get_param(obj.mExtractedModelH,'Name');
            origMdl=which(extractedModelName);
            [~,~,ext]=fileparts(origMdl);
            extractedModel=fullfile(obj.mCacheDirFullPath,[extractedModelName,ext]);
            copyfile(origMdl,extractedModel);
        end
        if~isempty(testComp.analysisInfo.replacementInfo.replacementModelH)
            replacementModelName=get_param(testComp.analysisInfo.replacementInfo.replacementModelH,'Name');
            origMdl=which(replacementModelName);
            [~,~,ext]=fileparts(origMdl);
            replacementModel=fullfile(obj.mCacheDirFullPath,[replacementModelName,ext]);
            copyfile(origMdl,replacementModel);
        end
        status=true;
    catch
        status=false;
    end


    name=obj.getTranslationDvoFileName();
    status=status&&testComp.writeTranslationDvo(obj.mCacheDirFullPath,name);




    if status&&~obj.mIsTranslatorForComponent&&slfeature('SLDVCacheInSLXC')>0
        status=obj.mCacheHandler.updateSLDVCacheMarkerFile();
    end

    if~status
        return;
    end

end

function new_map=replaceHdlsWithPath(old_map)
    new_map=containers.Map;
    for k=old_map.keys
        new_map(Simulink.ID.getFullName(k{1}))=old_map(k{1});
    end
end

function check=isSIDValid(hdl,sid)
    isValidHdl=isnumeric(hdl)&&hdl>0;
    check=~isValidHdl||~isempty(sid);
end

function[status,appliedTimerOptimizationsInSIDForm]=getAppliedTimerOptimizations(obj)
    status=true;
    appliedTimerOptimizationsInSIDForm=[];
    testComp=obj.mTestComp;

    if isfield(testComp.analysisInfo,'appliedTimerOptimizations')&&...
        ~isempty(testComp.analysisInfo.appliedTimerOptimizations)
        appliedTimerOptimizationsInSIDForm=testComp.analysisInfo.appliedTimerOptimizations;

        sz=size(appliedTimerOptimizationsInSIDForm);
        for idx=1:sz(1)
            blkH=appliedTimerOptimizationsInSIDForm{idx,2};
            sfId=appliedTimerOptimizationsInSIDForm{idx,3};
            [blkSID,sfSID]=obj.convertToSIDs(blkH,sfId);
            appliedTimerOptimizationsInSIDForm(idx,2)={blkSID};
            appliedTimerOptimizationsInSIDForm(idx,3)={sfSID};
            if~isSIDValid(blkH,blkSID)||~isSIDValid(sfId,sfSID)
                status=false;
                return;
            end
        end
    end
end

