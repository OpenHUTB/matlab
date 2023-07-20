function[isEnabled,filterInfo,goalStatus]=eng_goal_status(testComp,goal,codeCovInfo,sfVariantFilter)





    filterInfo.isFiltered=false;
    filterInfo.mode=-1;
    filterInfo.rationale='';
    goalStatus='';

    try







        if~strcmp(goal.type,'AVT_GOAL_ASSERT')&&~goal.isEnabled()
            isEnabled=false;
            return;
        end


        [~,errStr]=slavteng('feature','IntentionalError');
        if strcmp(errStr,'DV_FORCE_ERROR_GOAL_ENABLE')
            error(message('Sldv:privateUtils:INTENTIONAL'));
        end

        switch(testComp.activeSettings.Mode)
        case 'TestGeneration'
            [isEnabled,filterInfo,goalStatus]=check_test_objectives(testComp,goal,codeCovInfo,sfVariantFilter);
        case 'PropertyProving'
            isEnabled=check_proof_objectives(testComp,goal);
        case 'DesignErrorDetection'
            [isEnabled,filterInfo]=check_rte_objectives(testComp,goal,codeCovInfo,sfVariantFilter);
        otherwise
            error(message('Sldv:privateUtils:UnexpectedSettings'));
        end
    catch MEx
        display(MEx.message);
        isEnabled=false;
    end


    [~,errStr]=slavteng('feature','IntentionalError');
    if strcmp(errStr,'DV_FORCE_ERROR_GOAL_ENABLE')
        error(message('Sldv:privateUtils:INTENTIONAL2'));
    end
end

function[isEnabled,filterInfo]=check_rte_objectives(testComp,goal,codeCovInfo,sfVariantFilter)
    isEnabled=false;
    filterInfo.isFiltered=false;
    filterInfo.mode=-1;
    filterInfo.rationale='';

    modelObj=goal.up;
    filter=testComp.analysisInfo.covFilter;

    tf=isRTEFilteredObjective(testComp,goal);
    if tf
        return;
    end

    as=testComp.activeSettings;
    deadLogicOn=strcmp(as.DetectDeadLogic,'on');

    switch goal.type
    case{'AVT_GOAL_RANGE','AVT_GOAL_CODE_RTE','AVT_GOAL_SFCN_RTE'}
        isEnabled=true;
        return;

    case 'AVT_GOAL_ARRBOUNDS'
        if slfeature('SLDVCombinedDLRTE')
            isEnabled=strcmpi(as.DetectOutOfBounds,'on');
        else
            isEnabled=~deadLogicOn&&strcmpi(as.DetectOutOfBounds,'on');
        end

    case 'AVT_GOAL_DIV0'
        if slfeature('SLDVCombinedDLRTE')
            isEnabled=strcmpi(as.DetectDivisionByZero,'on');
        else
            isEnabled=~deadLogicOn&&strcmpi(as.DetectDivisionByZero,'on');
        end

    case 'AVT_GOAL_OVERFLOW'
        if slfeature('SLDVCombinedDLRTE')
            isEnabled=strcmpi(as.DetectIntegerOverflow,'on');
        else
            isEnabled=~deadLogicOn&&strcmpi(as.DetectIntegerOverflow,'on');
        end

    case 'AVT_GOAL_DESRANGE'
        if slfeature('SLDVCombinedDLRTE')
            isEnabled=strcmpi(as.DesignMinMaxCheck,'on');
        else
            isEnabled=~deadLogicOn&&strcmpi(as.DesignMinMaxCheck,'on');
        end

    case{'AVT_GOAL_FLOAT_INF','AVT_GOAL_FLOAT_NAN'}
        if slfeature('SLDVCombinedDLRTE')
            isEnabled=strcmpi(as.DetectInfNaN,'on');
        else
            isEnabled=~deadLogicOn&&strcmpi(as.DetectInfNaN,'on');
        end

    case 'AVT_GOAL_FLOAT_SUBNORMAL'
        if slfeature('SLDVCombinedDLRTE')
            isEnabled=strcmpi(as.DetectSubnormal,'on');
        else
            isEnabled=~deadLogicOn&&strcmpi(as.DetectSubnormal,'on');
        end

    case{'AVT_GOAL_RBW_HAZARD','AVT_GOAL_WAR_HAZARD','AVT_GOAL_WAW_HAZARD'}
        if slfeature('SLDVCombinedDLRTE')
            isEnabled=slavteng('feature','DsmHazards')&&strcmpi(as.DetectDSMAccessViolations,'on');
        else
            isEnabled=slavteng('feature','DsmHazards')&&~deadLogicOn&&strcmpi(as.DetectDSMAccessViolations,'on');
        end

    case 'AVT_GOAL_BLOCK_INPUT_RANGE_VIOLATION'
        if slfeature('SLDVCombinedDLRTE')
            isEnabled=(slfeature('SldvCombinedDlRteAndBlockInputBoundaryViolations')>=2)&&strcmpi(as.DetectBlockInputRangeViolations,'on');
        else
            isEnabled=(slfeature('SldvCombinedDlRteAndBlockInputBoundaryViolations')>=2)&&~deadLogicOn&&strcmpi(as.DetectBlockInputRangeViolations,'on');
        end

    case{'AVT_GOAL_SFCN_COND','AVT_GOAL_SFCN_DEC','AVT_GOAL_SFCN_MCDC',...
        'AVT_GOAL_CODE_COND','AVT_GOAL_CODE_DEC','AVT_GOAL_CODE_MCDC'}
        if deadLogicOn&&~isempty(filter)

            codeCovId=goal.condIndex;
            modelObj=goal.up;
            if goal.isSFcnCodeGoal()
                blkH=get_resolved_blockH(testComp,modelObj);

                if strcmp(goal.type,'AVT_GOAL_SFCN_MCDC')
                    [isFiltered,filterInfo]=codeCovInfo.isMcdcFiltered(blkH,codeCovId,goal.outIndex);
                else
                    [isFiltered,filterInfo]=codeCovInfo.isFiltered(blkH,codeCovId);
                end
            else
                blkH=modelObj.slBlkH;

                if strcmp(goal.type,'AVT_GOAL_CODE_MCDC')
                    [isFiltered,filterInfo]=codeCovInfo.isMcdcFiltered(blkH,codeCovId,goal.outIndex,goal.moduleName);
                else
                    [isFiltered,filterInfo]=codeCovInfo.isFiltered(blkH,codeCovId,goal.moduleName);
                end
            end
            isEnabled=~isFiltered;
        else
            isEnabled=deadLogicOn;
        end
        return;

    case 'AVT_GOAL_TESTGEN'
        covPt=goal.up;
        modelObj=covPt.up;
        if deadLogicOn&&(sldv_datamodel_isa(covPt,'Decision')||...
            sldv_datamodel_isa(covPt,'Condition')||...
            sldv_datamodel_isa(covPt,'McdcExpr'))
            [isEnabled,slsfCvId]=check_if_keep_cov(goal,testComp.analysisInfo.analyzedModelH);
            if~isEnabled
                return;
            end


            if~isempty(sfVariantFilter)&&~checkCovFilter(sfVariantFilter,covPt,slsfCvId,goal)
                isEnabled=false;
                return;
            end

            if isempty(filter)
                return;
            end

            slsfCvIdOriginal=mapSlSfCvId(testComp,slsfCvId,modelObj.slBlkH,modelObj.sfObjID,modelObj.emlFilePath);
            [isEnabled,filterInfo.mode,filterInfo.rationale]=checkCovFilter(filter,covPt,slsfCvIdOriginal,goal);
            if~isEnabled&&(filterInfo.mode~=-1)
                filterInfo.isFiltered=true;
            end
        end
        return;

    otherwise
        [goalTypes,blockConds,~]=Sldv.utils.getSupportedBlockConditions;
        pos=find(strcmp(goalTypes,goal.type),1);
        if~isempty(pos)
            if slfeature('SLDVCombinedDLRTE')
                isEnabled=contains(as.DetectBlockConditions,blockConds{pos});
            else
                isEnabled=~deadLogicOn&&contains(as.DetectBlockConditions,blockConds{pos});
            end
        end

        if slavteng('feature','NewDesignErrors')
            isEnabled=check_new_rte_objectives(as,goal);
        end
    end



    if~isEnabled||isempty(filter)
        return;
    end


    [designSid,~,~,sfObjType]=...
    Sldv.DataUtils.getModelObjectInfoInDesignModel(testComp,modelObj);


    if isempty(designSid)

        designSid=modelObj.path;
    elseif strcmpi(sfObjType,'Script')&&isa(Simulink.ID.getHandle(designSid),'Stateflow.EMChart')
        designSid=Simulink.ID.getParent(designSid);
    end

    [filterInfo.isFiltered,filterInfo.mode,filterInfo.rationale]=...
    checkRteFilter(filter,goal,designSid);
    isEnabled=~filterInfo.isFiltered;
end


function isFiltered=isRTEFilteredObjective(testComp,goal)
    isFiltered=false;


    if isSyntheticSchedulerModelGoal(testComp,goal)
        isFiltered=true;
        return;
    end
end








function tf=isSyntheticSchedulerModelGoal(testComp,goal)%#ok<INUSL> 
    tf=false;

    try


        modelObj=goal_mdlobj(goal);
        blkH=modelObj.slBlkH;
        if~modelObj.isSlBlock&&~modelObj.isStateflow



            return;
        end
        if modelObj.isStateflow||...
            strcmp(get_param(modelObj.slBlkH,'BlockType'),'S-Function')







            blkH=get_param(blkH,'Parent');
        end
        blkName=get_param(blkH,'Name');




        if strcmp(blkName,'_SldvExportFcnScheduler')
            blkTag=get_param(blkH,'Tag');
            tf=strcmp(blkTag,'__SLT_FCN_CALL__');
        elseif contains(blkName,'SLDV Fcn Call Generator')





            blkTag=get_param(blkH,'Tag');
            tf=strcmp(blkTag,'_SLT_FCN_CALL_GEN_BLK_');
        end
    catch MEx %#ok<*NASGU>

        return;
    end
end

function isEnabled=check_new_rte_objectives(as,goal)
    isEnabled=false;
    switch goal.type
    case 'AVT_GOAL_TRANS_CNFCT'
        isEnabled=strcmpi(as.DetectSFTransConflict,'on');
    case 'AVT_GOAL_STATE_CONS'
        isEnabled=strcmpi(as.DetectSFStateInconsistency,'on');
    case 'AVT_GOAL_SFARRAY_BNDS'
        isEnabled=strcmpi(as.DetectSFArrayOutOfBounds,'on');
    case 'AVT_GOAL_EMLARRAY_BNDS'
        isEnabled=strcmpi(as.DetectEMLArrayOutOfBounds,'on');
    case 'AVT_GOAL_SELECT_BNDS'
        isEnabled=strcmpi(as.DetectSLSelectorOutOfBounds,'on');
    case 'AVT_GOAL_MPSWITCH_BNDS'
        isEnabled=strcmpi(as.DetectSLMPSwitchOutOfBounds,'on');
    case 'AVT_GOAL_INVALID_CAST'
        isEnabled=strcmpi(as.DetectSLInvalidCast,'on');
    case 'AVT_GOAL_MERGE_CNFCT'
        isEnabled=strcmpi(as.DetectSLMergeConflict,'on');
    case 'AVT_GOAL_UNINIT_DSR'
        isEnabled=strcmpi(as.DetectSLUninitializedDSR,'on');
    end
end

function isEnabled=check_proof_objectives(testComp,goal)

    as=testComp.activeSettings;

    switch goal.type
    case 'AVT_GOAL_CUSPROOF'
        isEnabled=sldvprivate('isVerificationObjectiveEnabled',testComp,'UseLocalSettings',goal);

    case 'AVT_GOAL_ASSERT'


        isEnabled=sldvprivate('isVerificationObjectiveEnabled',testComp,as.Assertions,goal);
    case 'AVT_GOAL_REQTABLE'
        isEnabled=true;

    otherwise
        isEnabled=false;
    end
end

function[isEnabled,slsfCvId]=check_if_keep_cov(goal,analyzedModel)%#ok<INUSD> 
    isEnabled=true;





    coveragePoint=goal.up;
    modelObj=goal.up.up;
    slsfCvId=modelObj.covId;



    if slsfCvId==0
        isEnabled=false;
        return;
    end



    if sldv_datamodel_isa(coveragePoint,'Condition')&&...
        modelObj.isStateflow&&...
        Sldv.CvApi.isEmptyConditions(slsfCvId)
        isEnabled=false;
    end

    cvId=0;


    if sldv_datamodel_isa(coveragePoint,'Decision')
        cvId=Sldv.CvApi.getDecision(slsfCvId,coveragePoint.idx);
    elseif sldv_datamodel_isa(coveragePoint,'Condition')
        cvId=Sldv.CvApi.getCondition(slsfCvId,coveragePoint.idx);
    elseif sldv_datamodel_isa(coveragePoint,'RelationalBoundary')
        cvId=Sldv.CvApi.getRelationalBoundary(slsfCvId,coveragePoint.idx);
    else
        if~blk_isxorlogic(modelObj.slBlkH)
            cvId=Sldv.CvApi.getMcdcEntry(slsfCvId,coveragePoint.idx);
        end
    end
    if cvId==0
        isEnabled=false;
    end
end

function[isEnabled,filterInfo,goalStatus]=check_test_objectives(testComp,goal,codeCovInfo,sfVariantFilter)
    isEnabled=true;
    filterInfo.isFiltered=false;
    filterInfo.mode=-1;
    filterInfo.rationale='';
    goalStatus='';

    analyzedModel=testComp.analysisInfo.analyzedModelH;

    if strcmp(goal.type,'AVT_GOAL_TESTGEN')






        coveragePoint=goal.up;
        modelObj=goal.up.up;

        [isEnabled,slsfCvId]=check_if_keep_cov(goal,analyzedModel);
        if~isEnabled
            return;
        end


        if~isempty(sfVariantFilter)&&~checkCovFilter(sfVariantFilter,coveragePoint,slsfCvId,goal)
            isEnabled=false;
            return;
        end


        if~isempty(testComp.startCovData)
            slsfCvIdOriginal=mapSlSfCvId(testComp,slsfCvId,modelObj.slBlkH,...
            modelObj.sfObjID,modelObj.emlFilePath);
            covdata=resolveCovdata(testComp.startCovData,slsfCvIdOriginal);
            if~isempty(covdata)&&...
                goal_covered(testComp,goal,covdata,slsfCvIdOriginal,slsfCvId)





                isEnabled=true;
                goalStatus='GOAL_SATISFIED_BY_COVERAGE_DATA';
                return;
            end
        end


        if~modelObj.isStateflow&&modelObj.slBlkH~=0
            blkH=modelObj.slBlkH;
            if ishandle(blkH)&&strcmp(get_param(blkH,'DisableCoverage'),'on')
                isEnabled=false;
                return;
            end
        end

        if sldv_datamodel_isa(coveragePoint,'RelationalBoundary')
            if(strcmpi(testComp.activeSettings.IncludeRelationalBoundary,'on'))
                if~testComp.forcedTurnOnRelationalBoundary
                    isEnabled=true;
                else
                    isEnabled=false;
                end
            else
                isEnabled=false;
                return;
            end
        else
            switch(lower(testComp.activeSettings.getDerivedModelCoverageObjectives()))
            case 'none'
                isEnabled=false;
                return;
            case 'decision'
                if~sldv_datamodel_isa(coveragePoint,'Decision')
                    isEnabled=false;
                    return;
                end
            case 'conditiondecision'
                if~(sldv_datamodel_isa(coveragePoint,'Decision')||sldv_datamodel_isa(coveragePoint,'Condition'))
                    isEnabled=false;
                    return;
                end
            case 'mcdc'
                if~(sldv_datamodel_isa(coveragePoint,'Decision')||sldv_datamodel_isa(coveragePoint,'Condition')||sldv_datamodel_isa(coveragePoint,'McdcExpr'))
                    isEnabled=false;
                    return;
                end
            end
        end

        if isEnabled&&~isempty(testComp.analysisInfo.covFilter)
            slsfCvIdOriginal=mapSlSfCvId(testComp,slsfCvId,modelObj.slBlkH,...
            modelObj.sfObjID,modelObj.emlFilePath);
            [isEnabled,filterInfo.mode,filterInfo.rationale]=...
            checkCovFilter(testComp.analysisInfo.covFilter,coveragePoint,slsfCvIdOriginal,goal);
            if~isEnabled&&(filterInfo.mode~=-1)
                filterInfo.isFiltered=true;
            end
        end
    elseif strcmp(goal.type,'AVT_GOAL_CUSTEST')
        modelObj=goal.up;
        if~sldvprivate('isVerificationObjectiveEnabled',testComp,testComp.activeSettings.TestObjectives,modelObj)
            isEnabled=false;
        else
            slsfCvId=modelObj.covId;
            slsfCvIdOriginal=mapSlSfCvId(testComp,slsfCvId,modelObj.slBlkH,...
            modelObj.sfObjID,modelObj.emlFilePath);
            if~isempty(testComp.analysisInfo.covFilter)

                [isEnabled,filterInfo.mode,filterInfo.rationale]=...
                checkCovFilter(testComp.analysisInfo.covFilter,[],slsfCvIdOriginal,goal);
                if~isEnabled
                    if filterInfo.mode~=-1
                        filterInfo.isFiltered=true;
                    end
                    return;
                end
            end
            if isempty(testComp.startCovData)
                isEnabled=true;
                return;
            end
            isEnabled=true;
            covData=resolveCovdata(testComp.startCovData,slsfCvIdOriginal);
            if isempty(covData)
                return;
            end
            if modelObj.sfObjID>0




                origdecIds=cv('MetricGet',slsfCvIdOriginal,...
                Sldv.CvApi.getMetricVal('cvmetric_Sldv_test'),'.baseObjs');

                metrics=SlCov.CoverageAPI.getCoverageMetricsDef(slsfCvIdOriginal,{'cvmetric_Sldv_test'});


                idxs=strcmp({metrics.details.text},goal.label(2:end));

                origdecIds=origdecIds(idxs);
                rawDecData=covData.metrics.testobjectives.cvmetric_Sldv_test;

                if any(origdecIds<=0)||isempty(rawDecData)
                    return;
                end


                baseIdxs=cv('get',origdecIds,'.dc.baseIdx');
                if isempty(baseIdxs)
                    return;
                end


                if(all(rawDecData(baseIdxs+2)>0))




                    goalStatus='GOAL_SATISFIED_BY_COVERAGE_DATA';
                end
            else




                [hit,total]=getCoverageInfo(testComp.startCovData,...
                get_sldv_block(goal.up.slBlkH),...
                cvmetric.Sldv.test);

                if~isempty(hit)
                    if(total.testobjects(goal.outIndex+1).executionCount~=0)
                        goalStatus='GOAL_SATISFIED_BY_COVERAGE_DATA';
                    end
                end
            end
        end
    elseif(strcmp(goal.type,'AVT_GOAL_OBJECTIVE_COMPOSITION'))
        isEnabled=true;
    elseif(strcmp(goal.type,'AVT_GOAL_PATH_OBJECTIVE')||...
        strcmp(goal.type,'AVT_GOAL_CUSBLKCOV'))
        if strcmp(testComp.activeSettings.getDerivedModelCoverageObjectives(),'EnhancedMCDC')
            isEnabled=true;
        end


    elseif(strcmp(goal.type,'AVT_GOAL_REQTABLE'))
        isEnabled=true;
    elseif goal.isSFcnCodeGoal()
        if~isempty(testComp.startCovData)||~isempty(testComp.analysisInfo.covFilter)
            if strcmp(goal.type,'AVT_GOAL_SFCN_MCDC')
                mcdcCovId=goal.outIndex;
            else
                mcdcCovId=0;
            end


            codeCovId=goal.condIndex;
            modelObj=goal.up;
            blkH=get_resolved_blockH(testComp,modelObj);


            if~isempty(testComp.startCovData)
                if strcmp(goal.type,'AVT_GOAL_SFCN_MCDC')
                    [isCoveredOrFiltered,~,filterInfo]=codeCovInfo.isMcdcCovered(blkH,testComp.startCovData,codeCovId,mcdcCovId);
                else
                    [isCoveredOrFiltered,~,filterInfo]=codeCovInfo.isCovered(blkH,testComp.startCovData,codeCovId);
                end
                if isCoveredOrFiltered&&(filterInfo.mode==-1)

                    isEnabled=true;
                    goalStatus='GOAL_SATISFIED_BY_COVERAGE_DATA';
                    return
                end
                isEnabled=~isCoveredOrFiltered;
            end


            if isEnabled&&~isempty(testComp.analysisInfo.covFilter)
                if mcdcCovId>0
                    [isFiltered,filterInfo]=codeCovInfo.isMcdcFiltered(blkH,codeCovId,mcdcCovId);
                else
                    [isFiltered,filterInfo]=codeCovInfo.isFiltered(blkH,codeCovId);
                end
                isEnabled=~isFiltered;
            end
        end
    elseif goal.isCodeGoal()

        codeCovId=goal.condIndex;
        modelObj=goal.up;
        blkH=modelObj.slBlkH;

        if strcmp(goal.type,'AVT_GOAL_CODE_MCDC')
            mcdcCovId=goal.outIndex;
        else
            mcdcCovId=0;
        end



        if sldv.code.xil.CodeAnalyzer.isATSHarnessModel(get_param(analyzedModel,'Name'))
            if mcdcCovId>0
                isExcluded=codeCovInfo.isMcdcExcludedInternally(blkH,codeCovId,mcdcCovId,goal.moduleName);
            else
                isExcluded=codeCovInfo.isExcludedInternally(blkH,codeCovId,goal.moduleName);
            end
            if isExcluded
                isEnabled=false;
                return
            end
        end



        if~isempty(testComp.startCovData)
            if mcdcCovId>0
                [isCoveredOrFiltered,~,filterInfo]=codeCovInfo.isMcdcCovered(blkH,testComp.startCovData,codeCovId,mcdcCovId,goal.moduleName);
            else
                [isCoveredOrFiltered,~,filterInfo]=codeCovInfo.isCovered(blkH,testComp.startCovData,codeCovId,goal.moduleName);
            end
            if isCoveredOrFiltered&&(filterInfo.mode==-1)

                isEnabled=true;
                goalStatus='GOAL_SATISFIED_BY_COVERAGE_DATA';
                return
            end
            isEnabled=~isCoveredOrFiltered;
        end


        if isEnabled&&~isempty(testComp.analysisInfo.covFilter)
            if mcdcCovId>0
                [isFiltered,filterInfo]=codeCovInfo.isMcdcFiltered(blkH,codeCovId,mcdcCovId,goal.moduleName);
            else
                [isFiltered,filterInfo]=codeCovInfo.isFiltered(blkH,codeCovId,goal.moduleName);
            end
            isEnabled=~isFiltered;
        end
    elseif(strcmp(goal.type,'AVT_GOAL_SUT_EXEC'))
        isEnabled=true;
    else
        isEnabled=false;
    end
end


function blkH=get_resolved_blockH(testComp,modelObj)
    blockReplacementApplied=testComp.analysisInfo.replacementInfo.replacementsApplied;
    atomicSubsystemAnalysis=mdl_iscreated_for_subsystem_analysis(testComp);

    if blockReplacementApplied||atomicSubsystemAnalysis
        origModelH=testComp.analysisInfo.designModelH;
        if atomicSubsystemAnalysis
            parent=get_param(testComp.analysisInfo.analyzedSubsystemH,'parent');
            parentH=get_param(parent,'Handle');
        else
            parentH=origModelH;
        end
        blkH=sldvshareprivate('util_resolve_obj',...
        modelObj.slBlkH,...
        parentH,...
        atomicSubsystemAnalysis,...
        blockReplacementApplied,...
        testComp);
    else
        blkH=modelObj.slBlkH;
    end
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















