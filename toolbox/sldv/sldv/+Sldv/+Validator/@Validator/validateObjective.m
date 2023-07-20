function[isCovered,falseCount,noCoverage,isUnvalidated]=validateObjective(obj,goal,covData,varargin)







    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        addOptional(argParser,...
        'codeCovReader',[],...
        @(x)isempty(x)||(isa(x,'sldv.code.internal.CovDataReader')&&(numel(x)==1)));
    end

    parse(argParser,varargin{:});

    try
        noCoverage=false;
        isCovered=false;%#ok<NASGU> 
        falseCount=-1;%#ok<NASGU>
        isUnvalidated=false;%#ok<NASGU>
        [isCovered,falseCount,noCoverage,isUnvalidated]=checkObjective(obj.testCompAnalysisInfo,goal,covData,argParser.Results.codeCovReader,obj.simMode);
    catch MEx
        display(MEx.message);
        isCovered=false;
        falseCount=-1;
        isUnvalidated=false;
    end
end

function[isCovered,falseCount,noCoverage,isUnvalidated]=checkObjective(testCompAnalysisInfo,goal,covData,codeCovReader,simMode)
    noCoverage=false;
    isCovered=false;
    falseCount=-1;
    isUnvalidated=false;
    if strcmp(goal.type,'AVT_GOAL_TESTGEN')
        modelObj=goal.up.up;
        slsfCvId=modelObj.covId;

        if~isempty(covData)
            [slsfCvIdOriginal,~]=mapSlSfCvId(testCompAnalysisInfo,slsfCvId,...
            modelObj.slBlkH,modelObj.sfObjID,modelObj.emlFilePath);
            if slsfCvIdOriginal==0
                noCoverage=true;
                return;
            end
            covdata=resolveCovdata(covData,slsfCvIdOriginal);
            if isempty(covdata)
                noCoverage=true;
                return;
            elseif goalCovered(goal,covdata,slsfCvIdOriginal,slsfCvId)
                isCovered=true;
            end
        end

    elseif strcmp(goal.type,'AVT_GOAL_CUSTEST')||strcmp(goal.type,'AVT_GOAL_CUSPROOF')
        modelObj=goal.up;


        if~isempty(goal.validationFuncName)
            falseCount=feval(goal.validationFuncName,modelObj.slBlkH,...
            modelObj.sfObjID,goal.startCharIdx,goal.endCharIdx);
            return;
        end

        slsfCvId=modelObj.covId;
        [slsfCvIdOriginal,origBlockH]=mapSlSfCvId(testCompAnalysisInfo,slsfCvId,...
        modelObj.slBlkH,modelObj.sfObjID,modelObj.emlFilePath);
        if~isempty(covData)
            if modelObj.sfObjID>0
                if slsfCvIdOriginal==0
                    noCoverage=true;
                    return;
                end




                if strcmp(goal.type,'AVT_GOAL_CUSTEST')
                    origdecId=cv('MetricGet',slsfCvIdOriginal,...
                    Sldv.CvApi.getMetricVal('cvmetric_Sldv_test'),'.baseObjs');
                elseif strcmp(goal.type,'AVT_GOAL_CUSPROOF')
                    origdecId=cv('MetricGet',slsfCvIdOriginal,...
                    Sldv.CvApi.getMetricVal('cvmetric_Sldv_proof'),'.baseObjs');
                end
                newIdx=0;
                if strcmp(goal.type,'AVT_GOAL_CUSTEST')




                    metrics=SlCov.CoverageAPI.getCoverageMetricsDef(slsfCvIdOriginal,{'cvmetric_Sldv_test'});
                elseif strcmp(goal.type,'AVT_GOAL_CUSPROOF')
                    metrics=SlCov.CoverageAPI.getCoverageMetricsDef(slsfCvIdOriginal,{'cvmetric_Sldv_proof'});
                end
                for idx=1:length(metrics.details)
                    if contains([goal.label,')'],metrics.details(idx).text)
                        if newIdx==0
                            newIdx=idx;
                        else





                            isUnvalidated=true;
                            return;
                        end
                    end
                end
                if newIdx==0
                    isUnvalidated=true;
                    return;
                end

                origdecId=origdecId(newIdx);
                covdata=resolveCovdata(covData,slsfCvIdOriginal);
                if~isempty(covdata)
                    if strcmp(goal.type,'AVT_GOAL_CUSTEST')
                        rawDecData=covdata.metrics.testobjectives.cvmetric_Sldv_test;
                    elseif strcmp(goal.type,'AVT_GOAL_CUSPROOF')
                        rawDecData=covdata.metrics.testobjectives.cvmetric_Sldv_proof;
                    end

                    if origdecId>0&&~isempty(rawDecData)
                        baseIdx=cv('get',origdecId,'.dc.baseIdx');
                        if isempty(baseIdx)
                            isCovered=false;
                        else
                            isCovered=rawDecData(baseIdx+2)>0;
                            falseCount=rawDecData(baseIdx+1);

                        end
                    end
                else
                    noCoverage=true;
                    return;
                end
            else



                if slsfCvIdOriginal==0
                    noCoverage=true;
                    return;
                end
                if strcmp(goal.type,'AVT_GOAL_CUSTEST')
                    [hit,total]=getCoverageInfo(covData,...
                    sldvprivate('get_sldv_block',origBlockH),...
                    cvmetric.Sldv.test);
                    if~isempty(hit)
                        isCovered=total.testobjects(goal.outIndex+1).executionCount>0;
                    end
                end
            end
        end
    elseif strcmp(goal.type,'AVT_GOAL_REQTABLE')
        isCovered=sfreq.internal.analysis.validateSLDVGoal(goal);
        falseCount=isCovered;
    elseif goal.isSFcnCodeGoal()
        if~isempty(covData)

            sfcnCovId=goal.condIndex;
            modelObj=goal.up;
            blockReplacementApplied=testCompAnalysisInfo.replacementInfo.replacementsApplied;
            atomicSubsystemAnalysis=sldvprivate('mdl_iscreated_for_subsystem_analysis',testCompAnalysisInfo);

            if blockReplacementApplied||atomicSubsystemAnalysis
                if atomicSubsystemAnalysis
                    parentH=testCompAnalysisInfo.extractedModelH;
                else
                    parentH=testCompAnalysisInfo.designModelH;
                end
                blkH=sldvshareprivate('util_resolve_obj',modelObj.slBlkH,parentH,atomicSubsystemAnalysis,...
                blockReplacementApplied,testCompAnalysisInfo);
            else
                blkH=modelObj.slBlkH;
            end
            if isempty(codeCovReader)
                codeCovReader=sldv.code.internal.CustomCodeCovDataReader(covData);
            end
            if strcmp(goal.type,'AVT_GOAL_SFCN_MCDC')
                mcdcCovId=goal.outIndex;
                [isCovered,hasCoverage]=codeCovReader.isMcdcCovered(blkH,covData,sfcnCovId,mcdcCovId);
            else
                [isCovered,hasCoverage]=codeCovReader.isCovered(blkH,covData,sfcnCovId);
            end
            noCoverage=~hasCoverage;
        end

    elseif goal.isCodeGoal()&&~isempty(covData)

        codeCovId=goal.condIndex;
        modelObj=goal.up;
        blkH=modelObj.slBlkH;

        if~SlCov.CovMode.isXIL(simMode)
            blockReplacementApplied=testCompAnalysisInfo.replacementInfo.replacementsApplied;
            atomicSubsystemAnalysis=sldvprivate('mdl_iscreated_for_subsystem_analysis',testCompAnalysisInfo);
            if blockReplacementApplied||atomicSubsystemAnalysis
                if atomicSubsystemAnalysis
                    parentH=testCompAnalysisInfo.extractedModelH;
                else
                    parentH=testCompAnalysisInfo.designModelH;
                end
                blkH=sldvshareprivate('util_resolve_obj',modelObj.slBlkH,parentH,atomicSubsystemAnalysis,...
                blockReplacementApplied,testCompAnalysisInfo);
            end
        end


        if isempty(codeCovReader)
            if SlCov.CovMode.isXIL(simMode)
                codeCovReader=sldv.code.xil.internal.CovDataReader(covData);
            else
                codeCovReader=sldv.code.internal.CustomCodeCovDataReader(covData);
            end
        end


        if strcmp(goal.type,'AVT_GOAL_CODE_MCDC')
            [isCovered,hasCoverage]=codeCovReader.isMcdcCovered(blkH,covData,codeCovId,goal.outIndex,goal.moduleName);
        else
            [isCovered,hasCoverage]=codeCovReader.isCovered(blkH,covData,codeCovId,goal.moduleName);
        end
        noCoverage=~hasCoverage;
    end
end


function[slsfCvIdOriginal,origBlockH]=mapSlSfCvId(testCompAnalysisInfo,slsfCvId,blockH,sfId,emlFilePath)
    blockReplacementApplied=testCompAnalysisInfo.replacementInfo.replacementsApplied;
    atomicSubsystemAnalysis=sldvprivate('mdl_iscreated_for_subsystem_analysis',testCompAnalysisInfo);
    origBlockH=blockH;


    if blockReplacementApplied||atomicSubsystemAnalysis
        if atomicSubsystemAnalysis
            origModelH=testCompAnalysisInfo.extractedModelH;
            parentH=origModelH;
        else
            origModelH=testCompAnalysisInfo.designModelH;
            parentH=origModelH;
        end
        [slsfCvIdOriginal,origBlockH]=deriveSlSfCvId(parentH,blockReplacementApplied,...
        atomicSubsystemAnalysis,blockH,sfId,emlFilePath,testCompAnalysisInfo);
    else
        slsfCvIdOriginal=slsfCvId;
    end
end



function[slsfCvIdOriginal,origblockH]=deriveSlSfCvId(parentH,blockReplacementApplied,...
    atomicSubsystemAnalysis,blockH,sfId,emlFilePath,...
    testCompAnalysisInfo)

    if blockH==0&&sfId==0
        origblockH=0;
        slsfCvIdOriginal=Sldv.CvApi.slsfId(emlFilePath,0,0);
        return;
    end

    if sfId==0
        origsfId=0;
        origblockH=sldvshareprivate('util_resolve_obj',blockH,parentH,atomicSubsystemAnalysis,...
        blockReplacementApplied,testCompAnalysisInfo);
    else
        origblockH=0;
        origsfId=sldvshareprivate('util_resolve_obj',sfId,...
        parentH,atomicSubsystemAnalysis,blockReplacementApplied,testCompAnalysisInfo);
        if blockH~=0


            origblockH=sldvshareprivate('find_equiv_handle',origsfId);
            if origblockH~=0
                if strcmp(get_param(bdroot(origblockH),'BlockDiagramType'),'library')


                    designBlockH=sldvshareprivate('util_resolve_obj',blockH,parentH,atomicSubsystemAnalysis,...
                    blockReplacementApplied,testCompAnalysisInfo);
                    origblockH=get_param(designBlockH,'Handle');
                end




                origblockH=find_system(origblockH,'SearchDepth',1,...
                'LookUnderMasks','on',...
                'FollowLinks','On',...
                'BlockType','S-Function');
            end
        end
    end
    slsfCvIdOriginal=Sldv.CvApi.slsfId(emlFilePath,origblockH,origsfId);
end


function cvd=resolveCovdata(data,slsfCvId)
    if isa(data,'cv.cvdatagroup')
        name=SlCov.CoverageAPI.getModelcovName(cv('get',slsfCvId,'.modelcov'));
        if isempty(name)
            cvd=[];
        else
            cvd=data.get(name);
        end
    else
        cvd=data;
    end
end


function out=goalCovered(goal,covData,slsfCvIdOriginal,slsfCvId)
    out=false;
    if slsfCvId<=0
        return;
    end

    coveragePoint=goal.up;
    outIdx=goal.outIndex;
    predIdx=goal.condIndex;
    covIdx=coveragePoint.idx;

    if sldvprivate('sldv_datamodel_isa',coveragePoint,'Decision')
        origdecId=Sldv.CvApi.getDecision(slsfCvIdOriginal,coveragePoint.idx);
        rawDecData=covData.metrics.decision;
        if origdecId>0&&~isempty(rawDecData)
            baseIdx=cv('get',origdecId,'.dc.baseIdx');
            if isempty(baseIdx)
                out=false;
            else
                out=rawDecData(baseIdx+outIdx+1)>0;
            end
        end
    elseif sldvprivate('sldv_datamodel_isa',coveragePoint,'Condition')
        origcondId=Sldv.CvApi.getCondition(slsfCvIdOriginal,covIdx);
        rawCondData=covData.metrics.condition;
        if origcondId>0&&~isempty(rawCondData)
            baseIdx=cv('get',origcondId,'.coverage.falseCountIdx');
            out=rawCondData(baseIdx+outIdx+1)>0;
        end
    elseif sldvprivate('sldv_datamodel_isa',coveragePoint,'RelationalBoundary')
        origRelBoundId=Sldv.CvApi.getRelationalBoundary(slsfCvIdOriginal,covIdx);
        if~isempty(covData.metrics.testobjectives)&&isfield(covData.metrics.testobjectives,'cvmetric_Structural_relationalop')
            rawRelBoundData=covData.metrics.testobjectives.cvmetric_Structural_relationalop;
            if origRelBoundId>0&&~isempty(rawRelBoundData)
                baseIdx=cv('get',origRelBoundId,'.dc.baseIdx');
                if isempty(baseIdx)
                    out=false;
                else
                    out=rawRelBoundData(baseIdx+outIdx+1)>0;
                end
            end
        end
    elseif predIdx>=0
        origmcdcId=Sldv.CvApi.getMcdcEntry(slsfCvIdOriginal,covIdx);
        rawMcdcData=covData.metrics.mcdc;
        if origmcdcId>0&&~isempty(rawMcdcData)
            baseIdx=cv('get',origmcdcId,'.dataBaseIdx.predSatisfied');
            predicateCov=rawMcdcData(baseIdx+predIdx+1);
            if(outIdx==1)
                out=(predicateCov==SlCov.PredSatisfied.True_Only)||(predicateCov==SlCov.PredSatisfied.Fully_Satisfied);
            else
                out=(predicateCov==SlCov.PredSatisfied.False_Only)||(predicateCov==SlCov.PredSatisfied.Fully_Satisfied);
            end
        end
    end

    if isempty(out)
        out=false;
    end
end



