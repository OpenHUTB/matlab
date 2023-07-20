




function sldvData=addCodeMappingInfo(sldvData,allGoals)


    modelObjName2Idx=containers.Map('KeyType','char','ValueType','any');
    for ii=1:numel(sldvData.ModelObjects)
        if sldvData.ModelObjects(ii).descr=="sldvlib"
            sldvData.ModelObjects(ii).descr=sldv.code.xil.ReportDataUtils.SHARED_UTILITY_LABEL;
            sldvData.ModelObjects(ii).sid=sldvData.ModelObjects(ii).designSid;
            sldvData.ModelObjects(ii).slPath=sldvData.ModelObjects(ii).designSid;
            modelObjName2Idx(sldv.code.xil.ReportDataUtils.SHARED_UTILITY_LABEL)=ii;
        else


            if~strcmp(sldvData.ModelObjects(ii).sid,sldvData.ModelObjects(ii).designSid)
                sldvData.ModelObjects(ii).designSid=sldvData.ModelObjects(ii).sid;
            end
            modelObjName2Idx(sldvData.ModelObjects(ii).sid)=ii;
        end
    end


    modelObjects=sldvData.ModelObjects;
    testObjectives=sldvData.Objectives;

    try

        sldv.code.xil.ReportDataUtils.hiliteCode("clearCache");


        if~isfield(modelObjects,'mappedElements')
            modelObjects(1).mappedElements=[];
        end
        if~isfield(testObjectives,'mappedElementsIdx')
            testObjectives(1).mappedElementsIdx=[];
        end


        supportedGoalTypes={...
        'AVT_GOAL_CODE_COND',...
        'AVT_GOAL_CODE_DEC',...
        'AVT_GOAL_CODE_MCDC',...
        'AVT_GOAL_CODE_ENTRY',...
        'AVT_GOAL_CODE_EXIT',...
'AVT_GOAL_CODE_RELATIONAL_BOUNDARIES'...
        };

        toModelObjectivesIdx=[testObjectives.modelObjectIdx];



        moduleName2Info=containers.Map('KeyType','char','ValueType','any');
        for ii=1:numel(allGoals)
            goal=allGoals(ii);
            if any(strcmp(goal.type,supportedGoalTypes))
                if~moduleName2Info.isKey(goal.moduleName)



                    moduleInfo.modelObjIdx=0;


                    if isempty(goal.moduleName)
                        moduleName2Info('$unknownModule$')=moduleInfo;
                        continue
                    end



                    [modelName,covMode,isSharedUtils]=...
                    SlCov.coder.EmbeddedCoder.parseModuleName(goal.moduleName);



                    if isSharedUtils
                        moduleName2Info(goal.moduleName)=moduleInfo;
                        continue
                    end



                    if~modelObjName2Idx.isKey(modelName)
                        moduleName2Info(goal.moduleName)=moduleInfo;
                        continue
                    end
                    modelObjIdx=modelObjName2Idx(modelName);
                    modelObject=modelObjects(modelObjIdx);


                    covMode=char(covMode);
                    codeAnalyzer=sldv.code.xil.internal.getCurrentCodeAnalyzer();
                    if~isempty(codeAnalyzer)&&~strcmp(covMode,codeAnalyzer.SimulationMode)
                        codeAnalyzer=[];
                    end
                    if isempty(codeAnalyzer)
                        codeAnalyzer=sldv.code.xil.CodeAnalyzer();
                        codeAnalyzer.ModelName=modelName;
                        codeAnalyzer.SimulationMode=covMode;
                    end
                    [cgDir,cgDirInfo]=codeAnalyzer.getCodeFolder();

                    moduleName=SlCov.coder.EmbeddedCoder.buildModuleName(...
                    modelName,covMode);
                    trDataFile=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(moduleName,cgDirInfo);
                    if~isfile(trDataFile)
                        moduleName2Info(goal.moduleName)=moduleInfo;
                        continue
                    end


                    rootId=getRootCovId(modelName,covMode);
                    if isempty(rootId)
                        moduleName2Info(goal.moduleName)=moduleInfo;
                        continue
                    end


                    traceInfoMat=fullfile(cgDir,'html','traceInfo.mat');
                    traceInfoBuilder=get_param(modelName,'CoderTraceInfo');
                    if(isempty(traceInfoBuilder)||isempty(traceInfoBuilder.files))
                        traceInfoBuilder=coder.trace.TraceInfoBuilder(modelName);
                        traceInfoBuilder.buildDir=cgDir;
                        traceInfoBuilder.repositoryDir=fullfile(cgDir,'tmwinternal');
                        if~traceInfoBuilder.load()
                            traceInfoBuilder=[];
                        end
                    end


                    resObj=SlCov.results.CodeCovData(...
                    'traceabilitydbfile',trDataFile,...
                    'forceNonEmptyResults',true,...
                    'name',moduleName);
                    resObj.Mode=SlCov.CovMode(covMode);
                    resObj.mapModelToCode(traceInfoMat,traceInfoBuilder,rootId);

                    slModelElements=resObj.CodeTr.getSLModelElements();
                    if isempty(slModelElements)
                        moduleName2Info(goal.moduleName)=moduleInfo;
                        continue
                    end



                    extraModelObjects=[];
                    sid2ExtraModelObjectIdx=containers.Map('KeyType','char','ValueType','any');

                    covId2ModelEl=containers.Map('KeyType','double','ValueType','any');
                    objIdx=numel(extraModelObjects);
                    for ss=1:numel(slModelElements)
                        sid=slModelElements(ss).sid;
                        keepIt=false;
                        covPts=[resObj.CodeTr.getDecisionPoints(slModelElements(ss))...
                        ,resObj.CodeTr.getConditionPoints(slModelElements(ss))...
                        ,resObj.CodeTr.getMCDCPoints(slModelElements(ss))...
                        ,resObj.CodeTr.getRelationalBoundaryPoints(slModelElements(ss))];
                        for jj=1:numel(covPts)
                            covId=double(covPts(jj).node.covId);
                            dataInfo=struct('sid',sid);
                            if covId2ModelEl.isKey(covId)
                                allDataInfo=covId2ModelEl(covId);
                            else
                                allDataInfo=[];
                            end
                            covId2ModelEl(covId)=[allDataInfo;dataInfo];
                            keepIt=true;
                        end

                        if keepIt&&~sid2ExtraModelObjectIdx.isKey(sid)
                            objIdx=objIdx+1;
                            slPath=strrep(Simulink.ID.getFullName(sid),newline,'');
                            newObj=modelObject;
                            newObj.descr=slPath;
                            newObj.typeDesc='Block';
                            newObj.slPath=slPath;
                            newObj.sid=sid;
                            newObj.designSid=sid;
                            newObj.replacementSid='';
                            newObj.objectives=[];
                            extraModelObjects=[extraModelObjects;newObj];%#ok<AGROW>
                            sid2ExtraModelObjectIdx(sid)=objIdx;
                        end
                    end

                    testObjectivesIdx=find(toModelObjectivesIdx==modelObjIdx);


                    moduleInfo.modelName=modelName;
                    moduleInfo.resObj=resObj;
                    moduleInfo.goalLabel2Info=containers.Map('KeyType','char','ValueType','any');
                    moduleInfo.testObjectivesIdx=testObjectivesIdx;
                    moduleInfo.modelObjIdx=modelObjName2Idx(modelName);
                    moduleInfo.covId2ModelEl=covId2ModelEl;
                    moduleInfo.extraModelObjects=extraModelObjects;
                    moduleInfo.sid2ExtraModelObjectIdx=sid2ExtraModelObjectIdx;
                    moduleName2Info(goal.moduleName)=moduleInfo;
                end



                moduleInfo=moduleName2Info(goal.moduleName);
                if moduleInfo.modelObjIdx<1
                    continue
                end


                moduleInfo.goalLabel2Info(goal.label)=goal;


                moduleName2Info(goal.moduleName)=moduleInfo;
            end
        end


        moduleNames=moduleName2Info.keys();
        for ii=1:numel(moduleNames)

            moduleName=moduleNames{ii};
            moduleInfo=moduleName2Info(moduleName);
            if moduleInfo.modelObjIdx<1
                continue
            end

            visitedIdx=false(1,numel(moduleInfo.extraModelObjects));


            numTestObjectives=numel(moduleInfo.testObjectivesIdx);
            toMappedMoIdx=cell(1,numTestObjectives);
            for jj=1:numTestObjectives

                to=testObjectives(moduleInfo.testObjectivesIdx(jj));
                if~moduleInfo.goalLabel2Info.isKey(to.label)
                    continue
                end
                goal=moduleInfo.goalLabel2Info(to.label);



                isDec=false;
                isCond=false;
                isMcdc=false;
                isRelBound=false;
                if strcmp(to.type,'Decision')
                    goalTypeStr='AVT_GOAL_CODE_DEC';
                    isDec=true;
                elseif strcmp(to.type,'Condition')
                    goalTypeStr='AVT_GOAL_CODE_COND';
                    isCond=true;
                elseif strcmp(to.type,'MCDC')
                    goalTypeStr='AVT_GOAL_CODE_MCDC';
                    isMcdc=true;
                elseif strcmp(to.type,'RelationalBoundary')
                    goalTypeStr='AVT_GOAL_CODE_RELATIONAL_BOUNDARIES';
                    isRelBound=true;
                else
                    continue
                end

                if~strcmp(goal.type,goalTypeStr)
                    continue
                end


                mEl=[];
                if isDec
                    covId=goal.condIndex-goal.outIndex;
                    if moduleInfo.covId2ModelEl.isKey(covId)
                        mEl=moduleInfo.covId2ModelEl(covId);
                    end
                elseif isCond
                    covId=goal.condIndex-goal.outIndex;
                    if moduleInfo.covId2ModelEl.isKey(covId)
                        mEl=moduleInfo.covId2ModelEl(covId);
                    end
                elseif isMcdc
                    condId=goal.outIndex;
                    if moduleInfo.covId2ModelEl.isKey(condId)
                        mEl=moduleInfo.covId2ModelEl(condId);
                    elseif moduleInfo.covId2ModelEl.isKey(condId-1)
                        mEl=moduleInfo.covId2ModelEl(condId-1);
                    else
                        continue
                    end
                elseif isRelBound
                    covId=goal.outIndex;
                    if moduleInfo.covId2ModelEl.isKey(covId)
                        mEl=moduleInfo.covId2ModelEl(covId);
                    end
                else
                    continue
                end


                mappedMoIdx=[];
                for kk=1:numel(mEl)
                    idx=moduleInfo.sid2ExtraModelObjectIdx(mEl(kk).sid);
                    visitedIdx(idx)=true;
                    mappedMoIdx=[mappedMoIdx,idx];%#ok<AGROW>
                    moduleInfo.extraModelObjects(idx).objectives=unique([...
                    moduleInfo.extraModelObjects(idx).objectives,...
                    moduleInfo.testObjectivesIdx(jj)]);
                end
                toMappedMoIdx{jj}=mappedMoIdx;
            end


            badIdx=find(~visitedIdx);
            for jj=1:numTestObjectives

                mappedMoIdx=toMappedMoIdx{jj};
                if isempty(mappedMoIdx)
                    continue
                end


                if~isempty(badIdx)
                    mappedMoIdx=mappedMoIdx-arrayfun(@(x)numel(find(badIdx<x)),mappedMoIdx);
                end


                testObjectives(moduleInfo.testObjectivesIdx(jj)).mappedElementsIdx=unique(mappedMoIdx);
            end


            modelObjects(moduleInfo.modelObjIdx).mappedElements=moduleInfo.extraModelObjects(visitedIdx);
        end


        sldvData.ModelObjects=modelObjects;
        sldvData.Objectives=testObjectives;


        sldvData=sldv.code.xil.ReportDataUtils.applyCodeMappingInfo(sldvData);

    catch MEx
        if sldv.code.internal.feature('disableErrorRecovery')
            rethrow(MEx);
        end
        return
    end


    function rootId=getRootCovId(modelName,covMode)


        rootId=getRootCodeCovId(modelName,covMode);
        if isempty(rootId)

            rootId=getRootNormalCovId(modelName);
        end


        function rootId=getRootNormalCovId(modelName)


            modelcovMangledName=SlCov.CoverageAPI.mangleModelcovName(modelName);
            modelcovId=SlCov.CoverageAPI.findModelcovMangled(modelcovMangledName);
            modelcovId(~cv('ishandle',modelcovId))=[];


            rootId=[];
            if~isempty(modelcovId)
                rootId=cv('get',modelcovId,'.rootTree.child');
                rootId(~cv('ishandle',rootId))=[];
            end

            if isempty(rootId)
                try
                    modelH=get_param(modelName,'handle');
                    prc=get_param(modelH,'RecordCoverage');
                    pcp=get_param(modelH,'CovPath');



                    prevDirty=get_param(modelH,'Dirty');
                    restoreDirtyFlag=onCleanup(@()set_param(modelH,'Dirty',prevDirty));
                    restoreLockFlag=cvprivate('unlockModel',modelName);
                    clrObjs=[restoreDirtyFlag,restoreLockFlag];%#ok<NASGU>

                    set_param(modelH,'RecordCoverage','on');
                    set_param(modelH,'CovPath','');

                    SlCov.CoverageAPI.compileForCoverage(modelName);
                    rootId=SlCov.CoverageAPI.getRootId(modelName);

                    set_param(modelH,'RecordCoverage',prc);
                    set_param(modelH,'CovPath',pcp);

                catch ME
                    if sldv.code.internal.feature('disableErrorRecovery')
                        rethrow(ME);
                    end
                end
            else
                rootId=rootId(1);
            end


            function rootId=getRootCodeCovId(modelName,covMode)


                rootId=[];
                modelcovMangledName=SlCov.CoverageAPI.mangleModelcovName(modelName,covMode);
                modelcovId=SlCov.CoverageAPI.findModelcovMangled(modelcovMangledName);
                modelcovId(~cv('ishandle',modelcovId))=[];
                if isempty(modelcovId)
                    return
                end


                modelcovId(cv('get',modelcovId,'.rootTree.child')==0)=[];


                harnessModel=cell(size(modelcovId));
                for ii=1:numel(modelcovId)
                    harnessModel{ii}=cv('get',modelcovId(ii),'.harnessModel');
                end
                idx=find(strcmp(harnessModel,'HARNESS_4_SLDV_SIL_CODEGEN_VALIDATION'),1);
                if~isempty(idx)
                    modelcovId=modelcovId(idx);
                else
                    modelcovId=modelcovId(1);
                end


                rootId=cv('get',modelcovId,'.rootTree.child');
                if~cv('ishandle',rootId)
                    rootId=[];
                end


