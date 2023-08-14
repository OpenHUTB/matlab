function status=loadCompatData(obj)




    compatData=load(obj.mCompatDataInfo.sldvCachePath,'compatibilityData');
    testComp=obj.mTestComp;


    for idx=1:numel(compatData.compatibilityData.CheckExprInfo)
        blockSID=compatData.compatibilityData.CheckExprInfo(idx).CheckTag.BlockID;
        sfObjSID=compatData.compatibilityData.CheckExprInfo(idx).CheckTag.SFObjID;
        [blkH,sfId]=obj.convertToHdlOrSfId(blockSID,sfObjSID);
        compatData.compatibilityData.CheckExprInfo(idx).CheckTag.BlockID=blkH;
        compatData.compatibilityData.CheckExprInfo(idx).CheckTag.SFObjID=sfId;

        if~isHdlValid(blkH,blockSID)||~isHdlValid(sfId,sfObjSID)
            status=false;
            return;
        end
    end


    for idx=1:numel(compatData.compatibilityData.CompilationInfo.ModelObject)
        blockSID=compatData.compatibilityData.CompilationInfo.ModelObject(idx).BlockID;
        sfObjSID=compatData.compatibilityData.CompilationInfo.ModelObject(idx).SFObjID;
        [blkH,sfId]=obj.convertToHdlOrSfId(blockSID,sfObjSID);
        compatData.compatibilityData.CompilationInfo.ModelObject(idx).BlockID=blkH;
        compatData.compatibilityData.CompilationInfo.ModelObject(idx).SFObjID=sfId;

        if~isHdlValid(blkH,blockSID)||~isHdlValid(sfId,sfObjSID)
            status=false;
            return;
        end
    end


    if isfield(compatData.compatibilityData.CompilationInfo,'EmlCovMapInfo')
        for idx=1:numel(compatData.compatibilityData.CompilationInfo.EmlCovMapInfo)
            blkSID=compatData.compatibilityData.CompilationInfo.EmlCovMapInfo(idx).blkId;
            sfSID=compatData.compatibilityData.CompilationInfo.EmlCovMapInfo(idx).sfId;
            [blkH,sfId]=obj.convertToHdlOrSfId(blkSID,sfSID);
            compatData.compatibilityData.CompilationInfo.EmlCovMapInfo(idx).blkId=blkH;
            compatData.compatibilityData.CompilationInfo.EmlCovMapInfo(idx).sfId=sfId;

            if sfId>0
                sfprivate('sf','set',sfId,'.eml.cvMapInfo',compatData.compatibilityData.CompilationInfo.EmlCovMapInfo(idx).covMap);
            end

            if~isHdlValid(blkH,blkSID)||~isHdlValid(sfId,sfSID)
                status=false;
                return;
            end
        end
    end

    tModelName=obj.mModelToCheckCompatName;
    tModelH=obj.mModelToCheckCompatH;
    tDVMode=testComp.activeSettings.Mode;
    tIsDeadLogic=isequal(testComp.activeSettings.DetectDeadLogic,'on');
    tIsAnalyzingForFixpt=sldvshareprivate('util_is_analyzing_for_fixpt_tool');


    createDesignIR(obj,compatData,tModelName);


    testComp.setDvInternalStates(tModelH,...
    tModelName,...
    tDVMode,...
    tIsDeadLogic,...
    tIsAnalyzingForFixpt);



    analysisInfo=obj.mCompatibilityData.analysisInfo;
    if~isempty(analysisInfo.emlIdInfo)
        testComp.setEmlIdInfo(analysisInfo.emlIdInfo);
    end
    testComp.reducedBlocks=analysisInfo.reducedBlocks;
    testComp.conditionallyExecutedBlocks=analysisInfo.conditionallyExecutedBlocks;
    testComp.slowestTaskTicks=analysisInfo.slowestTaskTicks;
    cellfun(@(x)testComp.addCompatIgnoreBlkType(x),...
    analysisInfo.compatMsgIgnoreBlkTypes);

    testComp.mdlFlatIOInfo=analysisInfo.mdlFlatIOInfo;
    testComp.createableSimData=analysisInfo.createableSimData;

    testComp.mdlSampleTimes=analysisInfo.mdlSampleTimes;
    testComp.mdlFundamentalTs=sldvshareprivate('mdl_derive_sampletime_for_sldvdata',testComp.mdlSampleTimes);

    testComp.forcedTurnOnRelationalBoundary=analysisInfo.forcedTurnOnRelationalBoundary;

    testComp.pathCompositionSpec=analysisInfo.pathCompositionSpec;

    status=setAppliedTimerOptimizations(obj,analysisInfo);
    if~status
        status=false;
        return;
    end

    testComp.analysisInfo.mappedSfId=...
    containers.Map('KeyType','double','ValueType','double');
    testComp.analysisInfo.mappedBlockH=...
    containers.Map('KeyType','double','ValueType','double');

    testComp.compatStatus=obj.mCompatibilityData.compatStatus;
    obj.mCompatStatus=Sldv.CompatStatus(testComp.compatStatus);

    status=true;
end

function createDesignIR(obj,compatData,aModelName)

    filename=obj.mCompatDataInfo.dvoCachePath;
    [filepath,name]=fileparts(filename);
    status=obj.mTestComp.readTranslationDvo(filepath,name,aModelName);
    if~status
        status=false;%#ok<*NASGU>
        return;
    end


    compatibilityData=compatData.compatibilityData;
    try

        status=obj.mTestComp.initModelMapping(compatibilityData,aModelName);


        if status&&isfield(compatibilityData,'LinkSpec')&&...
            (sldvprivate('isObserverSupportON',obj.mTestComp.activeSettings))
            status=obj.mTestComp.initLinkSpec(compatibilityData.LinkSpec,aModelName);




            obj.initIncompatObserverList(compatibilityData.LinkSpec);
        end


        if status&&isfield(compatibilityData,'TraceInfo')&&...
            (sldvprivate('isObserverSupportON',obj.mTestComp.activeSettings))
            status=obj.mTestComp.initTraceInfo(compatibilityData.TraceInfo,aModelName);
        end
    catch
        status=false;
    end

    if~status
        status=false;
        return;
    end
end

function check=isHdlValid(hdl,sid)
    check=(strcmp(sid,'-1')&&hdl==-1)||...
    (strcmp(sid,'DefaultBlockDiagram')&&hdl==0);
    check=check||isempty(sid)||hdl>0;
end

function status=setAppliedTimerOptimizations(obj,analysisInfo)
    status=true;

    if isfield(analysisInfo,'appliedTimerOptimizations')&&...
        ~isempty(analysisInfo.appliedTimerOptimizations)

        sz=size(analysisInfo.appliedTimerOptimizations);
        for idx=1:sz(1)
            blkSID=analysisInfo.appliedTimerOptimizations{idx,2};
            sfSID=analysisInfo.appliedTimerOptimizations{idx,3};

            [blkH,sfId]=obj.convertToHdlOrSfId(blkSID,sfSID);

            analysisInfo.appliedTimerOptimizations(idx,2)={blkH};
            analysisInfo.appliedTimerOptimizations(idx,3)={sfId};

            if~isHdlValid(blkH,blkSID)||~isHdlValid(sfId,sfSID)
                status=false;
                return;
            end
        end
        obj.mTestComp.analysisInfo.appliedTimerOptimizations=analysisInfo.appliedTimerOptimizations;
    end
end
