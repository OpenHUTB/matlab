



function filename=addAndReturnFile(filenames,coverageResultIds,groupStartIndices,...
    isTopLevelModel,resultSetID,resultID)
    import stm.internal.Coverage;
    if slsvTestingHook('STMForceCoverageFailure')
        error STMForceCoverageFailure;
    end
    covRes=[];
    groupStartIndices=groupStartIndices+1;

    rs=sltest.testmanager.ResultSet('stm.ResultSet',resultSetID);

    for idx=1:numel(groupStartIndices)-1
        startIdx=groupStartIndices(idx);
        endIdx=groupStartIndices(idx+1)-1;

        cr.filenames=filenames(startIdx:endIdx);
        cr.cloneId=coverageResultIds(startIdx:endIdx);
        covResult=stm.internal.getTestManagerCoverageResults(coverageResultIds(startIdx));
        cr.topLevelModel=covResult.TopLevelModel;
        cr.analyzedModel=covResult.AnalyzedModel;
        cr.SimMode=covResult.SimMode;
        cr.ownerType=covResult.HarnessType;
        cr.ownerFullPath=covResult.HarnessOwner;
        cr.aggregatedCvdataIds=covResult.AggregatedCvdataIds;
        cr.isTopLevelModel=isTopLevelModel(idx);
        cr.Release=covResult.Release;
        cr.Checksum=covResult.Checksum;
        cr.StructuralChecksum=covResult.StructuralChecksum;
        cr.RelBndMetricChecksum=covResult.RelBndMetricChecksum;
        cr.SatOvfMetricChecksum=covResult.SatOvfMetricChecksum;
        cr.CoverageMetrics=covResult.CoverageMetrics;
        if isempty(covRes)
            covRes=cr;
        else
            covRes(end+1)=cr;%#ok<AGROW>
        end
    end

    coverageResults=[];
    covModelUpdateGuards=[];
    hasSubsytemCoverage=false;
    for idx=1:numel(covRes)
        cr=covRes(idx);
        if~hasSubsytemCoverage&&strcmpi(cr.ownerType,'Simulink.Subsystem')
            hasSubsytemCoverage=true;
        end

        if isscalar(cr.filenames)&&~isResultSetWithFilters(resultSetID==resultID,rs)



            tmpCoverageResults=Coverage.getCoverageResultsStruct();
            tmpCoverageResults.cloneId=cr.cloneId;
            tmpCoverageResults.SimMode=cr.SimMode;
            tmpCoverageResults.ownerType=cr.ownerType;
            tmpCoverageResults.Release=cr.Release;
            tmpCoverageResults.filename=cr.filenames{1};
            tmpCoverageResults.analyzedModel=cr.analyzedModel;
            tmpCoverageResults.ownerFullPath=cr.ownerFullPath;
            tmpCoverageResults.aggregatedCvdataIds=cr.aggregatedCvdataIds;
            tmpCoverageResults.checksum=cvChecksumStr2Struct(cr.Checksum);
            tmpCoverageResults.structuralChecksum=cvChecksumStr2Struct(cr.StructuralChecksum);
            tmpCoverageResults.relBndMetricChecksum=cvChecksumStr2Struct(cr.RelBndMetricChecksum);
            tmpCoverageResults.satOvfMetricChecksum=cvChecksumStr2Struct(cr.SatOvfMetricChecksum);
            tmpCoverageResults.metricSettings=cr.CoverageMetrics;
        else
            if bdIsLoaded(cr.topLevelModel)

                covModelUpdateGuards=[covModelUpdateGuards,SlCov.ContextGuard(get_param(cr.topLevelModel,'Name'))];%#ok<AGROW>
            end
            tmpCoverageResults=Coverage.add(cr,rs,resultID);
            tmpCoverageResults.cloneId=0;
            tmpCoverageResults.SimMode=cr.SimMode;
            tmpCoverageResults.Release=cr.Release;
            if cr.isTopLevelModel
                tmpCoverageResults.topLevelModel=cr.analyzedModel;
            else
                tmpCoverageResults.topLevelModel=cr.topLevelModel;
            end

        end

        if isempty(coverageResults)
            coverageResults=tmpCoverageResults;
        else
            coverageResults(end+1)=tmpCoverageResults;%#ok<AGROW>
        end
    end

    if hasSubsytemCoverage
        coverageResults=aggregateSubsystem(coverageResults,rs.getReqMdlTestInfo);
        if SlCov.isATSCodeCovFeatureOn()
            coverageResults=aggregateXILSubsystem(coverageResults);
        end
    end

    coverageResults=coverageResults';
    filename=[tempname,'.mat'];
    save(filename,'coverageResults');
end


function coverageResults=aggregateSubsystem(coverageResults,reqInfo)



    import stm.internal.Coverage;
    mIdx={coverageResults.ownerType}~="Simulink.SubSystem"&...
    {coverageResults.SimMode}=="Normal";
    modelIdx=find(mIdx);

    if isempty(modelIdx)
        return;
    end

    sIdx={coverageResults.ownerType}=="Simulink.SubSystem"&...
    {coverageResults.SimMode}=="Normal";
    subsysIdx=find(sIdx);

    if isempty(subsysIdx)
        return;
    end


    modelMap=buildModelmap(coverageResults,modelIdx,subsysIdx);


    for idxM=1:numel(modelMap)
        s=modelMap(idxM);
        modelName=s.modelName;

        if~isempty(s.subSysIdx)
            topCoverageResults=coverageResults(s.modelIdx);

            cleanUp=loadOwnerIfRequired(modelName);%#ok<NASGU>


            topCvdataObj=Coverage.loadCovObjects(topCoverageResults.filename,modelName);
            toSumCvdata=struct('cvd',topCvdataObj,'assoc','');

            for idxS=1:numel(s.subSysIdx)
                subsysCoverageResults=coverageResults(s.subSysIdx(idxS));




                if isSubsysCovResultCompatibleWithTop(topCvdataObj,subsysCoverageResults)



                    subsysCvdataObj=Coverage.loadCovObjects(subsysCoverageResults.filename);
                    if subsysCvdataObj.canHarnessMapBackToOwner&&...
                        ~subsysCvdataObj.isExternalMATLABFile
                        toSumCvdata(end+1)=struct('cvd',subsysCvdataObj,'assoc',subsysCoverageResults.ownerFullPath);%#ok<AGROW>
                    end
                end
            end
            if numel(toSumCvdata)>1
                covAggregator=cv.aggregation();
                covAggregator.setRequirementsMapping(reqInfo);
                for idxToSum=1:numel(toSumCvdata)
                    covAggregator.addData(toSumCvdata(idxToSum).cvd,toSumCvdata(idxToSum).assoc);
                end
                tmpSum=covAggregator.getSum();


                if~isempty(tmpSum)
                    coverageResults(s.modelIdx)=Coverage.getMetrics(tmpSum,topCoverageResults.ownerType,topCoverageResults.ownerFullPath);
                    coverageResults(s.modelIdx).topLevelModel=modelName;
                end
            end
        end
    end
end


function coverageResults=aggregateXILSubsystem(coverageResults)

    import stm.internal.Coverage;


    allSimModes={coverageResults.SimMode};
    mIdx={coverageResults.ownerType}~="Simulink.SubSystem"&...
    (allSimModes=="SIL"|allSimModes=="PIL"|allSimModes=="ModelRefSIL"|allSimModes=="ModelRefPIL");
    modelIdx=find(mIdx);

    if isempty(modelIdx)
        return
    end

    badIdx=[];
    for ii=1:numel(modelIdx)
        [~,~,ext]=fileparts(coverageResults(modelIdx(ii)).analyzedModel);
        if~isempty(ext)
            badIdx=[badIdx,ii];%#ok<AGROW>
        end
    end
    modelIdx(badIdx)=[];

    if isempty(modelIdx)
        return
    end


    sIdx={coverageResults.ownerType}=="Simulink.SubSystem"&...
    (allSimModes=="SIL"|allSimModes=="PIL"|allSimModes=="ModelRefSIL"|allSimModes=="ModelRefPIL");
    subsysIdx=find(sIdx);

    if isempty(subsysIdx)
        return
    end


    modelMap=buildModelmap(coverageResults,modelIdx,subsysIdx);


    for idxM=1:numel(modelMap)
        s=modelMap(idxM);
        modelName=s.modelName;

        if isempty(s.subSysIdx)
            continue
        end

        cleanUp=loadOwnerIfRequired(modelName);%#ok<NASGU>


        subsysCum=cvdata.empty();
        for idxS=1:numel(s.subSysIdx)
            subsysCoverageResults=coverageResults(s.subSysIdx(idxS));
            subsysCvdataObj=Coverage.loadCovObjects(subsysCoverageResults.filename,modelName);
            if subsysCvdataObj.canHarnessMapBackToOwner&&...
                ~(subsysCvdataObj.isSharedUtility||subsysCvdataObj.isCustomCode)
                if isempty(subsysCum)
                    subsysCum=subsysCvdataObj;
                else
                    try
                        subsysCum=subsysCum+subsysCvdataObj;
                    catch

                    end
                end
            end
        end



        if~isempty(subsysCum)
            try
                topCoverageResults=coverageResults(s.modelIdx);
                topCvdataObj=Coverage.loadCovObjects(topCoverageResults.filename,modelName);
                tmpSum=subsysCum+topCvdataObj;
            catch

                tmpSum=[];
            end

            if~isempty(tmpSum)
                coverageResults(s.modelIdx)=Coverage.getMetrics(tmpSum,topCoverageResults.ownerType,topCoverageResults.ownerFullPath);
                coverageResults(s.modelIdx).topLevelModel=modelName;
            end
        end
    end
end


function res=isAlreadyAggregated(covRes1,covRes2)
    acvid1=covRes1.aggregatedCvdataIds;
    acvid2=covRes2.aggregatedCvdataIds;
    res=~isempty(acvid1)&&~isempty(acvid2)&&...
    all(contains(split(acvid2),split(acvid1)));
end


function bool=isResultSetWithFilters(isResultSet,rs)

    bool=~isempty(stm.internal.Coverage.getFilterFiles(isResultSet,rs));
end


function cleanUp=loadOwnerIfRequired(modelName)


    cleanUp=onCleanup.empty;
    if~bdIsLoaded(modelName)
        load_system(modelName);
        cleanUp=onCleanup(@()close_system(modelName,0));
    end


    res=Simulink.harness.internal.getActiveHarness(modelName);
    if~isempty(res)
        harnessName=res.name;
        bdclose(harnessName);
    end
end


function modelMap=buildModelmap(coverageResults,modelIdx,subsysIdx)

    modelMap=struct('modelName',{coverageResults(modelIdx).analyzedModel},...
    'modelIdx',num2cell(modelIdx),...
    'subSysIdx',[]);


    for idx=subsysIdx
        subsysCoverageResults=coverageResults(idx);
        ownerModel=split(subsysCoverageResults.ownerFullPath,'/');
        ownerModel=string(ownerModel{1});



        foundModelIdxs=find({modelMap.modelName}==ownerModel);
        for f=1:length(foundModelIdxs)
            fIdx=foundModelIdxs(f);
            s=modelMap(fIdx);
            if~isAlreadyAggregated(coverageResults(s.modelIdx),subsysCoverageResults)
                modelMap(fIdx).subSysIdx=[s.subSysIdx,idx];
            end
        end
    end
end


function chkStruct=cvChecksumStr2Struct(chkStr)
    chkStruct=[];
    if ischar(chkStr)&&(numel(chkStr)==40)
        chkStruct=struct(...
        'u1',str2double(chkStr(1:10)),...
        'u2',str2double(chkStr(11:20)),...
        'u3',str2double(chkStr(21:30)),...
        'u4',str2double(chkStr(31:40)));
    end
end


function chkArr=cvChecksumStruct2Array(chkStruct)
    chkArr=[];
    if~isempty(chkStruct)
        chkArr=[chkStruct.u1,chkStruct.u2,chkStruct.u3,chkStruct.u4];
    end
end


function isCompatible=isSubsysCovResultCompatibleWithTop(topCvdataObj,subsysCoverageResults)
    isCompatible=false;


    if~isequal(topCvdataObj.dbVersion(2:end-1),subsysCoverageResults.Release)
        return;
    end



    ownerFullPathSplit=split(string(subsysCoverageResults.ownerFullPath),'/');
    ownerBlock=ownerFullPathSplit(end).char;
    subsysChecksum=cvChecksumStruct2Array(subsysCoverageResults.checksum);
    isCompatible=SlCov.CoverageAPI.hasMatchingPossibleRoot(topCvdataObj.rootID,ownerBlock,subsysChecksum);
end
