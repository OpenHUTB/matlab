function hasMissingGoals = blk_addmissingcovgoals(blk, testComp, covLevel, opts, sfVariantFilter)
% At various stages in the code generation process unreachable checknodes
% are eliminated. These "dead-code" degenerate goals should be inserted back
% into the representation with falsified status whenever we are doing test
% generation. This function also takes care of disabling relevant goals
% based on user-provided filter files, variant transitions, Requirements
% Table block, etc.

% Copyright 2006-2022 The MathWorks, Inc.

    hasMissingGoals = false;

    switch(lower(covLevel))
    case 'none'
        fillInGoals.decision = false;
        fillInGoals.condition = false;
        fillInGoals.mcdc = false;
        fillInGoals.relationalboundary = false;
    case 'decision'
        fillInGoals.decision = true;
        fillInGoals.condition = false;
        fillInGoals.mcdc = false;
        fillInGoals.relationalboundary = false;
    case 'conditiondecision'
        fillInGoals.decision = true;
        fillInGoals.condition = true;
        fillInGoals.mcdc = false;
        fillInGoals.relationalboundary = false;
    case 'mcdc'
        fillInGoals.decision = true;
        fillInGoals.condition = true;
        fillInGoals.relationalboundary = false;
        if blk_isxorlogic(blk.slBlkH)
            fillInGoals.mcdc = false;
        else
            fillInGoals.mcdc = true;
        end
    end
    
    if strcmp(opts.Mode,'TestGeneration') && strcmpi(opts.IncludeRelationalBoundary,'on')        
        %Turning off Relational Boundary for if and fcn blocks - g1146947
         if blk_isFcnOrIf(blk.slBlkH)
             fillInGoals.relationalboundary = false;
         else
             fillInGoals.relationalboundary = true;
         end
    end

    missingGoals = [];
    slsfCvId = blk.covId;
    
    if ~isempty(sfVariantFilter) && ~checkCovFilter(sfVariantFilter, [], slsfCvId, [])
        return;
    end
    
    % Requirements Table block requires special handling if the feature
    % flag is on. Note: the flag is currently off.
    % - Disable all Condition and Relational Boundary objectives
    % - Disable all MCDC objectives with 'False' outcome
    isBlkFromReqTable = blk.isStateflow && ...
                        sf('Feature','Coverage ReqTable PositiveOnly') && ...
                        blk.isReqTable;
    
    if Sldv.utils.isValidContainerMap(testComp.analysisInfo.disabledCvIdInfo) && ...
            testComp.analysisInfo.disabledCvIdInfo.isKey(slsfCvId)
        slsfCvIdInfo = testComp.analysisInfo.disabledCvIdInfo(slsfCvId);
    else
        slsfCvIdInfo = [];
    end

    if fillInGoals.condition
        conditions = blk.conditions;
        
        if isBlkFromReqTable
            % Disable all Condition goals
            for i = 1:length(conditions)
                condition = conditions(i);
                
                if sldv_datamodel_isempty(condition, 'Condition')
                    continue;
                end
                
                falseCondGoal = condition.falseGoal;
                trueCondGoal = condition.trueGoal;
                if ~sldv_datamodel_isempty(falseCondGoal, 'Goal')
                    falseCondGoal.disable;
                end
                if ~sldv_datamodel_isempty(trueCondGoal, 'Goal')
                    trueCondGoal.disable;
                end
            end
        else
            condIds = metricCvids(@Sldv.CvApi.getCondition, slsfCvId);
            conditions = add_missing_conditions(testComp, blk, conditions, condIds);

            if ~isempty(conditions) && ~isempty(condIds)
                for condIdx = 1:length(conditions)
                    condition = conditions(condIdx);
                    condId = condIds(condIdx);

                    if ~sldv_datamodel_isempty(condition, 'Condition')
                        if sldv_datamodel_isempty(condition.trueGoal, 'Goal') && ...
                                ~isDisabledCovId(slsfCvIdInfo, 'disabledCondInfo', condId, 1)
                           condition.trueGoal = missing_goal(testComp,condition,1);
                           missingGoals = [missingGoals condition.trueGoal];
                        end
                        if sldv_datamodel_isempty(condition.falseGoal, 'Goal') && ...
                                ~isDisabledCovId(slsfCvIdInfo, 'disabledCondInfo', condId, 0)
                           condition.falseGoal = missing_goal(testComp,condition,0);
                           missingGoals = [missingGoals condition.falseGoal];
                        end
                    end
                end
            end
        end
    end

    if fillInGoals.decision
        decisions = blk.decisions;
        decIds = metricCvids(@Sldv.CvApi.getDecision, slsfCvId); 
        decisions = add_missing_decisions(testComp, blk, decisions, decIds);

        if ~isempty(decisions) && (length(decisions)==length(decIds))
            for decIdx = 1:length(decisions)
                decision = decisions(decIdx);
                decId = decIds(decIdx);

                if ~sldv_datamodel_isempty(decision, 'Decision') && decId>0
                    goalList = decision.goals;
                    goalCnt = length(goalList);

                    outCnt = cv('get',decId,'.dc.numOutcomes');

                    if outCnt>goalCnt
                        if slavteng('feature','UDD2MCOS')
                            %create Empty goal
                            mfmodel = testComp.getAnalysisDataModel().getMF0Model;
                            emptyGoal = sldv.datamodel.mfzero.Goal(mfmodel);
                            goalList(goalCnt+1:outCnt) = emptyGoal;
                        else
                            goalList = [goalList ; handle(-1*ones(outCnt-goalCnt,1))];
                        end
                    end

                    for outIdx = 1:outCnt
                        if ~sldv_datamodel_isempty(goalList(outIdx), 'Goal')
                            continue;
                        end
                        
                        if ~isDisabledCovId(slsfCvIdInfo, 'disabledDecInfo', decId, outIdx-1)
                            goalList(outIdx) = missing_goal(testComp, decision, outIdx-1);
                            missingGoals = [missingGoals goalList(outIdx)];
                        end
                    end

                    goalList(~sldv_datamodel_isa(goalList,"Goal")) = [];
                    decision.goals = goalList;
                end
            end
        end
    end

    if fillInGoals.mcdc
        mcdcs = blk.mcdcExprs;
        mcdcIds = metricCvids(@Sldv.CvApi.getMcdcEntry, slsfCvId); 
        mcdcs = add_missing_mcdcExprs(testComp, blk, mcdcs, mcdcIds);

        if ~isempty(mcdcs) && (length(mcdcs)==length(mcdcIds))
            for mcdcIdx = 1:length(mcdcs)
                mcdc = mcdcs(mcdcIdx);
                mcdcId = mcdcIds(mcdcIdx);

                if ~sldv_datamodel_isempty(mcdc, 'McdcExpr') && mcdcId>0
                    trueGoals = mcdc.trueGoals;
                    falseGoals = mcdc.falseGoals;
                    predCnt = cv('get',mcdcId,'.numPredicates');
                    trueCnt = length(trueGoals);
                    falseCnt = length(falseGoals);

                    if predCnt>trueCnt
                        if slavteng('feature','UDD2MCOS')
                            %create Empty goal
                            mfmodel = testComp.getAnalysisDataModel().getMF0Model;
                            emptyGoal = sldv.datamodel.mfzero.Goal(mfmodel);
                            trueGoals(trueCnt+1:predCnt) = emptyGoal;
                        else
                            trueGoals = [trueGoals ; handle(-1*ones(predCnt-trueCnt,1))];
                        end
                    end

                    if predCnt>falseCnt
                        if slavteng('feature','UDD2MCOS')
                            %create Empty goal
                            mfmodel = testComp.getAnalysisDataModel().getMF0Model;
                            emptyGoal = sldv.datamodel.mfzero.Goal(mfmodel);
                            falseGoals(falseCnt+1:predCnt) = emptyGoal;
                        else
                            falseGoals = [falseGoals ; handle(-1*ones(predCnt-falseCnt,1))];
                        end
                    end

                    for predIdx = 1:predCnt
                        if sldv_datamodel_isempty(trueGoals(predIdx), 'Goal')
                            if ~isDisabledCovId(slsfCvIdInfo, 'disabledMcdcInfo', mcdcId, 1, predIdx-1)
                                trueGoals(predIdx) = missing_goal(testComp, mcdc, 1, predIdx-1);
                                missingGoals = [missingGoals trueGoals(predIdx)];
                            end
                        end
                        if sldv_datamodel_isempty(falseGoals(predIdx), 'Goal')
                            if ~isDisabledCovId(slsfCvIdInfo, 'disabledMcdcInfo', mcdcId, 0, predIdx-1)
                                falseGoals(predIdx) = missing_goal(testComp, mcdc, 0, predIdx-1);
                                missingGoals = [missingGoals falseGoals(predIdx)];
                            end
                        end
                    end
                    
                    if isBlkFromReqTable
                        % Disable the False goals
                        for i = 1:length(falseGoals)
                            if ~sldv_datamodel_isempty(falseGoals(i), 'Goal')
                                falseGoals(i).disable;
                            end
                        end
                    end
                    
                    trueGoals(~sldv_datamodel_isa(trueGoals,"Goal")) = [];
                    falseGoals(~sldv_datamodel_isa(falseGoals,"Goal")) = [];

                    mcdc.trueGoals = trueGoals;
                    mcdc.falseGoals = falseGoals;
                end
            end
        end
    end
    
    if fillInGoals.relationalboundary
        relBounds = blk.relationalBoundaryExprs;

        if isBlkFromReqTable
            % Disable all Relational Boundary goals
            for i = 1:length(relBounds)
                relBound = relBounds(i);
                if sldv_datamodel_isempty(relBound, 'RelationalBoundary')
                    continue;
                end
                
                ltGoal = relBound.lessThanGoal;
                eqGoal = relBound.equalGoal;
                gtGoal = relBound.greaterThanGoal;
                
                if ~sldv_datamodel_isempty(ltGoal, 'Goal')
                    ltGoal.disable;
                end
                if ~sldv_datamodel_isempty(eqGoal, 'Goal')
                    eqGoal.disable;
                end
                if ~sldv_datamodel_isempty(gtGoal, 'Goal')
                    gtGoal.disable;
                end
            end
        else
            relBoundIds = metricCvids(@Sldv.CvApi.getRelationalBoundary, slsfCvId);
            relBounds = add_missing_relationalBoundaryExprs(testComp, blk, relBounds, relBoundIds);

            if ~isempty(relBounds) && ~isempty(relBoundIds)
                for relBoundIdx = 1:length(relBounds)
                    relBound = relBounds(relBoundIdx);
                    relBoundId = relBoundIds(relBoundIdx);

                    if ~sldv_datamodel_isempty(relBound, 'RelationalBoundary')
                        if sldv_datamodel_isempty(relBound.lessThanGoal, 'Goal') && ...
                                ~isDisabledCovId(slsfCvIdInfo, 'disabledRelBoundInfo', relBoundId, 0)
                           relBound.lessThanGoal = missing_goal(testComp,relBound,0);
                           missingGoals = [missingGoals relBound.lessThanGoal];
                        end
                        if sldv_datamodel_isempty(relBound.equalGoal, 'Goal') && ...
                                ~isDisabledCovId(slsfCvIdInfo, 'disabledRelBoundInfo', relBoundId, 1)
                           relBound.equalGoal = missing_goal(testComp, relBound, 1);
                           missingGoals = [missingGoals relBound.equalGoal];
                        end
                        if sldv_datamodel_isempty(relBound.greaterThanGoal, 'Goal') && ...
                                ~isDisabledCovId(slsfCvIdInfo, 'disabledRelBoundInfo', relBoundId, 2) && ...
                                (cv('get', relBoundId, '.dc.numOutcomes') > 2) %to filter == obj in floating pt.
                           relBound.greaterThanGoal = missing_goal(testComp, relBound, 2);
                           missingGoals = [missingGoals relBound.greaterThanGoal];
                        end                    
                    end
                end
            end
        end
    end
    
    % Apply user-provided filter(s), register missingGoals
    if ~isempty(missingGoals)
        hasMissingGoals = true;
        applyFilterAndRegisterMissingGoals;
    end
    
    function applyFilterAndRegisterMissingGoals
        % If no filter is present, just enable and register the goals.
        % Otherwise, update their status if affected by filter.
        filter = testComp.analysisInfo.covFilter;
        if ~isempty(filter)
            
            % Use slsfCovId from the design model to query the filter.
            % Similar logic as in eng_goal_status.m
            slsfCvIdOriginal = mapSlSfCvId(testComp, slsfCvId, blk.slBlkH, blk.sfObjID, blk.emlFilePath);

            for goal = missingGoals
                covPt = goal.up;
            
                % Following logic is copied from eng_goal_status.m
                [isEnabled, filterInfo.mode, filterInfo.rationale] = checkCovFilter(filter, covPt, slsfCvIdOriginal, goal);
                if ~isEnabled && (filterInfo.mode ~= -1)
                    filterInfo.isFiltered = true;
                    setGoalStatus(goal, false, filterInfo,'');  % Keep the last argument (goalStatus) empty.
                                                                % setGoalStatus() determines the correct value.
                end
            end
        end
    
        for goal = missingGoals
            testComp.registerGoal(goal);
        end
    end
end

function diasabled = isDisabledCovId(slsfCvIdInfo, type, id, outIdx, predIdx)
    if nargin<5
        predIdx = 0;
    end
    diasabled = false;
    if ~isempty(slsfCvIdInfo)
        idInfo = slsfCvIdInfo.(type);
        for idx=1:length(idInfo)
            info = idInfo{idx};
            if id==info.id
                if strcmp(type, 'disabledMcdcInfo')
                    diasabled = (outIdx == info.outIdx) && ...
                        (predIdx == info.predIdx);
                else
                    diasabled = outIdx == info.outIdx;
                end
            end
            if diasabled
                break;
            end
        end
    end
end

function goal = missing_goal(testComp, parentObj, outIndex, predIdx)
    if nargin<4
        predIdx = 0;
    end

    if slavteng('feature','UDD2MCOS')
        mfmodel = testComp.getAnalysisDataModel().getMF0Model;
        goal = sldv.datamodel.mfzero.Goal(mfmodel);
    else
        goal = SlAvt.Goal;
    end

    % Attributes
    goal.type = 'AVT_GOAL_TESTGEN';
    goal.outIndex = outIndex;
    goal.connect(parentObj,'up');
    goal.condIndex = predIdx;
    goal.initialize(0,0,'','',''); % Character indices are not needed
    goal.enable;
    goal.status = 'GOAL_UNSATISFIABLE';
end

function cvIds = metricCvids(fcnHandle, slsfId)
%fcnHandle: @Sldv.CvApi.getCondition/getDecision etc.
    cvIds = [];
    idx = 0;
    stopped = false;

    if slsfId==0
        return;
    end

    while(~stopped)
        cvId = fcnHandle(slsfId, idx);

        if cvId==0
            stopped = true;
        else
            cvIds = [cvIds cvId]; %#ok<*AGROW>
        end
        idx = idx+1;
    end
end

function obj = new_objective_of_type(objType, blk, idx, cvId)
%obj.idx uses 0 based indexing
    obj = objType;
    obj.idx = idx;
    obj.connect(blk,'up');
    setCvId(obj,cvId);
end

function decisions = add_missing_decisions(testComp, blk, decisions, decIds)
    if isempty(decIds)
        return;
    end

    if slavteng('feature','UDD2MCOS')
        mfmodel = testComp.getAnalysisDataModel().getMF0Model;
    end

    if length(decisions) < length(decIds)
        for idx = (length(decisions)+1):length(decIds)
            if decIds(idx)>0

                if slavteng('feature','UDD2MCOS')
                    d = new_objective_of_type(sldv.datamodel.mfzero.Decision(mfmodel), blk, idx-1, decIds(idx));
                else
                    d = new_objective_of_type(SlAvt.Decision, blk, idx-1, decIds(idx));
                end

                if isempty(decisions)
                    decisions = d;
                else
                    decisions(end+1) = d;
                end
            end
        end
    elseif length(decisions) > length(decIds)
        newDecs = decisions(1);
        for idx = 2:length(decIds)
            newDecs(idx) = decisions(idx);
        end
        decisions = newDecs;
    end

    for idx = 1:length(decIds)
        if decIds(idx)>0 && sldv_datamodel_isempty(decisions(idx), 'Decision')

            if slavteng('feature','UDD2MCOS')
                d = new_objective_of_type(sldv.datamodel.mfzero.Decision(mfmodel), blk, idx-1, decIds(idx));
            else
                d = new_objective_of_type(SlAvt.Decision, blk, idx-1, decIds(idx));
            end
            decisions(idx) = d;
        end
    end

    blk.decisions = decisions;
end


function conditions = add_missing_conditions(testComp, blk, conditions, condIds)
    if isempty(condIds)
        return;
    end

    if slavteng('feature','UDD2MCOS')
        mfmodel = testComp.getAnalysisDataModel().getMF0Model;
    end

    if (length(conditions) < length(condIds))
        for idx = (length(conditions)+1):length(condIds)
            if condIds(idx)>0

                if slavteng('feature','UDD2MCOS')
                    c = new_objective_of_type(sldv.datamodel.mfzero.Condition(mfmodel), blk, idx-1, condIds(idx));
                else
                    c = new_objective_of_type(SlAvt.Condition, blk, idx-1, condIds(idx));
                end

                if isempty(conditions)
                    conditions = c;
                else
                    conditions(end+1) = c;
                end
            end
        end
    elseif length(conditions) > length(condIds)
        newConds = conditions(1);
        for idx = 2:length(condIds)
            newConds(idx) = conditions(idx);
        end
        conditions = newConds;
    end

    for idx = 1:length(condIds)
        if condIds(idx)>0 && sldv_datamodel_isempty(conditions(idx), 'Condition')

            if slavteng('feature','UDD2MCOS')
                c = new_objective_of_type(sldv.datamodel.mfzero.Condition(mfmodel), blk, idx-1, condIds(idx));
            else
                c = new_objective_of_type(SlAvt.Condition, blk, idx-1, condIds(idx));
            end

            conditions(idx) = c;
        end
    end

    blk.conditions = conditions;
end

function mcdcExprs = add_missing_mcdcExprs(testComp, blk, mcdcExprs, mcdcIds)
    if isempty(mcdcIds)
        return;
    end

    if slavteng('feature','UDD2MCOS')
        mfmodel = testComp.getAnalysisDataModel().getMF0Model;
    end

    if (length(mcdcExprs)~=length(mcdcIds))
        for idx = (length(mcdcExprs)+1):length(mcdcIds)
            if mcdcIds(idx)>0

                if slavteng('feature','UDD2MCOS')
                    m = new_objective_of_type(sldv.datamodel.mfzero.McdcExpr(mfmodel), blk, idx-1, mcdcIds(idx));
                else
                    m = new_objective_of_type(SlAvt.McdcExpr, blk, idx-1, mcdcIds(idx));
                end

                if isempty(mcdcExprs)
                    mcdcExprs = m;
                else
                    mcdcExprs(end+1) = m;
                end
            end
        end
    end

    for idx = 1:length(mcdcIds)
        if mcdcIds(idx)>0 && sldv_datamodel_isempty(mcdcExprs(idx), 'McdcExpr')

            if slavteng('feature','UDD2MCOS')
                m = new_objective_of_type(sldv.datamodel.mfzero.McdcExpr(mfmodel), blk, idx-1, mcdcIds(idx));
            else
                m = new_objective_of_type(SlAvt.McdcExpr, blk, idx-1, mcdcIds(idx));
            end

            mcdcExprs(idx) = m;
        end
    end

    blk.mcdcExprs = mcdcExprs;
end

function relationalBoundaryExprs = add_missing_relationalBoundaryExprs(testComp, blk, relationalBoundaryExprs, relBoundIds)
    if isempty(relBoundIds)
        return;
    end

    if slavteng('feature','UDD2MCOS')
        mfmodel = testComp.getAnalysisDataModel().getMF0Model;
    end

    if (length(relationalBoundaryExprs) < length(relBoundIds))
        for idx = (length(relationalBoundaryExprs)+1):length(relBoundIds)
            if relBoundIds(idx)>0

                if slavteng('feature','UDD2MCOS')
                    rb = new_objective_of_type(sldv.datamodel.mfzero.RelationalBoundary(mfmodel), blk, idx-1, relBoundIds(idx));
                else
                    rb = new_objective_of_type(SlAvt.RelationalBoundary, blk, idx-1, relBoundIds(idx));
                end

                if isempty(relationalBoundaryExprs)
                    relationalBoundaryExprs = rb;
                else
                    relationalBoundaryExprs(end+1) = rb;
                end
            end
        end
    elseif length(relationalBoundaryExprs) > length(relBoundIds)
        newRelBounds = relationalBoundaryExprs(1);
        for idx = 2:length(relBoundIds)
            newRelBounds(idx) = relationalBoundaryExprs(idx);
        end
        relationalBoundaryExprs = newRelBounds;
    end

    for idx = 1:length(relBoundIds)
        if relBoundIds(idx)>0 && sldv_datamodel_isempty(relationalBoundaryExprs(idx), 'RelationalBoundary')

            if slavteng('feature','UDD2MCOS')
                rb = new_objective_of_type(sldv.datamodel.mfzero.RelationalBoundary(mfmodel), blk, idx-1, relBoundIds(idx));
            else
                rb = new_objective_of_type(SlAvt.RelationalBoundary, blk, idx-1, relBoundIds(idx));
            end
            relationalBoundaryExprs(idx) = rb;
        end
    end

    blk.relationalBoundaryExprs = relationalBoundaryExprs;
end

% LocalWords: conditiondecision
