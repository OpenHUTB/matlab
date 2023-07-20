function[goals,constraints,filteredGoals]=blk_allgoals(blk,onlyActive,allowInternalGoals,needFilteredGoals)




    goals=[];
    filteredGoals=[];
    constraints=blk.constraints(:)';

    if nargin<2
        onlyActive=false;
    end

    if nargin<3
        allowInternalGoals=false;
    end

    if nargin<4
        needFilteredGoals=false;
    end

    if~sldvprivate('sldv_datamodel_isempty',blk.assertGoal,'Goal')
        append_goal(blk.assertGoal);
    end















    decisions=blk.decisions;
    if~isempty(decisions)

        for decIdx=1:length(decisions)
            decision=decisions(decIdx);
            if~sldvprivate('sldv_datamodel_isempty',decision,'Decision')
                outCnt=numel(decision.goals);
                goal1=decision.goals(1);
                if(outCnt==2&&sldvprivate('sldv_datamodel_isa',goal1,'Goal')&&...
                    strcmpi(goal1.label,getString(message('Sldv:goal_label:False'))))
                    append_goal(decision.goals(2));
                    append_goal(decision.goals(1));
                else
                    for outIdx=1:length(decision.goals)
                        append_goal(decision.goals(outIdx));
                    end
                end
            end
        end
    end


    conditions=blk.conditions;
    if~isempty(conditions)
        for condIdx=1:length(conditions)
            condition=conditions(condIdx);

            if~sldvprivate('sldv_datamodel_isempty',condition,'Condition')

                if~sldvprivate('sldv_datamodel_isempty',condition.trueGoal,'Goal')
                    append_goal(condition.trueGoal);
                end


                if~sldvprivate('sldv_datamodel_isempty',condition.falseGoal,'Goal')
                    append_goal(condition.falseGoal);
                end
            end
        end
    end

    mcdcs=blk.mcdcExprs;
    if~isempty(mcdcs)
        for mcdcIdx=1:length(mcdcs)
            mcdc=mcdcs(mcdcIdx);
            if~sldvprivate('sldv_datamodel_isempty',mcdc,'McdcExpr')
                cndCnt=numel(mcdc.trueGoals);
                assert(numel(mcdc.falseGoals)==cndCnt);


                for outIdx=1:cndCnt
                    append_goal(mcdc.trueGoals(outIdx));
                    append_goal(mcdc.falseGoals(outIdx));
                end
            end
        end
    end

    relationalBoundaryExprs=blk.relationalBoundaryExprs;
    if~isempty(relationalBoundaryExprs)
        for relBoundIdx=1:length(relationalBoundaryExprs)
            relBound=relationalBoundaryExprs(relBoundIdx);

            if~sldvprivate('sldv_datamodel_isempty',relBound,'RelationalBoundary')
                if~sldvprivate('sldv_datamodel_isempty',relBound.lessThanGoal,'Goal')
                    append_goal(relBound.lessThanGoal);
                end
                if~sldvprivate('sldv_datamodel_isempty',relBound.equalGoal,'Goal')
                    append_goal(relBound.equalGoal);
                end
                if~sldvprivate('sldv_datamodel_isempty',relBound.greaterThanGoal,'Goal')
                    append_goal(relBound.greaterThanGoal);
                end
            end
        end
    end

    cusProofPoints=blk.cusProofPoints;
    for idx=1:length(cusProofPoints)
        append_goal(cusProofPoints(idx));
    end
    cusTestPoints=blk.cusTestPoints;
    for idx=1:length(cusTestPoints)
        append_goal(cusTestPoints(idx));
    end

    cusBlkCovPoints=blk.cusBlkCovPoints;
    for idx=1:length(cusBlkCovPoints)
        append_goal(cusBlkCovPoints(idx));
    end
    pathObjectives=blk.pathObjectives;
    for idx=1:length(pathObjectives)
        append_goal(pathObjectives(idx));
    end
    codeCvGoals=blk.codeCvGoals;
    for idx=1:length(codeCvGoals)
        append_goal(codeCvGoals(idx));
    end
    overflows=blk.overflows;
    for idx=1:length(overflows)
        append_goal(overflows(idx));
    end
    ranges=blk.ranges;
    for idx=1:length(ranges)
        append_goal(ranges(idx));
    end
    desranges=blk.desranges;
    for idx=1:length(desranges)
        append_goal(desranges(idx));
    end
    arrBounds=blk.arrBounds;
    for idx=1:length(arrBounds)
        append_goal(arrBounds(idx));
    end
    dsmHazards=blk.dsmHazards;
    for idx=1:length(dsmHazards)
        append_goal(dsmHazards(idx));
    end
    blockCondChecks=blk.blockCondChecks;
    for idx=1:length(blockCondChecks)
        append_goal(blockCondChecks(idx));
    end
    blockInputRangeViolations=blk.blockInputRangeViolations;
    for idx=1:length(blockInputRangeViolations)
        append_goal(blockInputRangeViolations(idx));
    end
    desChecks=blk.designChecks;
    for idx=1:length(desChecks)
        append_goal(desChecks(idx));
    end
    objectiveCompositions=blk.objectiveCompositions;
    for idx=1:length(objectiveCompositions)
        append_goal(objectiveCompositions(idx));
    end
    goals=goals(:)';

    function append_goal(goal)

        if sldvprivate('sldv_datamodel_isempty',goal,'Goal')
            return;
        end

        if(allowInternalGoals||~goal.isInternal())&&...
            (~onlyActive||goal.isEnabled)
            goals=[goals,goal];
        end

        if needFilteredGoals&&~goal.isEnabled&&...
            any(strcmp(goal.status,{'GOAL_EXCLUDED','GOAL_JUSTIFIED'}))
            filteredGoals=[filteredGoals,goal];
        end
    end
end


