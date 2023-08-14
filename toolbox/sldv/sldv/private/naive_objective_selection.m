function naive_objective_selection(testComp)





    [goals,constraints]=mdl_allgoals(testComp);

    isXIL=testComp.isSIL()||testComp.isModelRefSIL();
    if isXIL
        codeCovInfo=sldv.code.xil.internal.CovDataReader(...
        testComp.startCovData,testComp.analysisInfo.covFilter);
    else
        codeCovInfo=sldv.code.internal.CustomCodeCovDataReader(testComp.startCovData,...
        testComp.analysisInfo.covFilter);
    end



    analysisMode=testComp.activeSettings.Mode;
    isTestGenOrDeadLogicDetection=strcmp(analysisMode,'TestGeneration')||...
    (strcmp(analysisMode,'DesignErrorDetection')&&...
    strcmp(testComp.activeSettings.DetectDeadLogic,'on'));
    sfVariantFilter=[];
    if isTestGenOrDeadLogicDetection
        sfVariantFilter=Sldv.CvApi.createSFVariantFilter(testComp.analysisInfo.analyzedModelH);
    end








    sutExecGoalIndex=-1;
    userVisibleGoalPresent=false;
    for i=1:length(goals)




        goal=goals(i);
        if~strcmp(goal.type,'AVT_GOAL_CUSBLKCOV')&&...
            ~strcmp(goal.type,'AVT_GOAL_PATH_OBJECTIVE')

            [isEnabled,filterInfo,goalStatus]=eng_goal_status(testComp,goal,codeCovInfo,sfVariantFilter);
            setGoalStatus(goal,isEnabled,filterInfo,goalStatus);
            if strcmp(goal.type,'AVT_GOAL_SUT_EXEC')
                sutExecGoalIndex=i;
            else
                userVisibleGoalPresent=true;
            end
        end
    end






    for idx=1:length(goals)
        if strcmp(goals(idx).type,'AVT_GOAL_CUSBLKCOV')

            enableOrDisableBlkCovGoal(goals(idx),testComp,codeCovInfo,sfVariantFilter);
        end
    end


    for idx=1:length(goals)
        if strcmp(goals(idx).type,'AVT_GOAL_PATH_OBJECTIVE')

            enableOrDisablePathGoal(goals(idx),testComp,codeCovInfo,sfVariantFilter);
        end
    end


    for i=1:length(constraints)
        isEnabled=eng_assumption_status(testComp,constraints(i));
        if isEnabled
            constraints(i).enable;
        else
            constraints(i).disable;
        end
    end

    hasMissingCovGoals=false;

    if~isXIL&&isTestGenOrDeadLogicDetection
        hasMissingCovGoals=mdl_addmissingcovgoals(testComp,sfVariantFilter);
    end




    userVisibleGoalPresent=userVisibleGoalPresent||hasMissingCovGoals;



    if sutExecGoalIndex~=-1&&...
userVisibleGoalPresent
        setGoalStatus(goals(sutExecGoalIndex),false,filterInfo,'');
    end
end

function enableOrDisableBlkCovGoal(blkCovGoal,testComp,codeCovInfo,sfVariantFilter)
    if eng_goal_status(testComp,blkCovGoal,codeCovInfo,sfVariantFilter)


        atleastOneEnabledCvgGoal=false;


        cvgGoalIds=testComp.getCovGoalIdsFromExtnGoalId(blkCovGoal.getGoalMapId);

        for idx=1:length(cvgGoalIds)
            cvgGoal=testComp.getGoal(cvgGoalIds(idx));


            if cvgGoal.isEnabled()&&...
                ~strcmpi(cvgGoal.status,'GOAL_SATISFIED_BY_COVERAGE_DATA')
                atleastOneEnabledCvgGoal=true;
                break;
            end
        end







        if~isempty(cvgGoalIds)&&~atleastOneEnabledCvgGoal
            blkCovGoal.disable;
        else
            blkCovGoal.enable;
        end
    else


        blkCovGoal.disable;
    end
end

function enableOrDisablePathGoal(pathGoal,testComp,codeCovInfo,sfVariantFilter)
    if eng_goal_status(testComp,pathGoal,codeCovInfo,sfVariantFilter)






        if pathGoal.composedGoals(1).isEnabled
            pathGoal.enable;
        else
            pathGoal.disable;
        end
    else


        pathGoal.disable;
    end
end


