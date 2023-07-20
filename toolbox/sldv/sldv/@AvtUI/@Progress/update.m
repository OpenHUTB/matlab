function update(h)




    if~isempty(h.testComp)&&~h.closed


        isValidatorON=Sldv.Utils.isValidatorEnabled(h.testComp.activeSettings,h.testComp.simMode);

        if isValidatorON
            objTotal=h.testComp.getValidatedGoalCount('DV_GOAL_TOTAL');
            objSatisfied=h.testComp.getValidatedGoalCount('DV_GOAL_SATISFIED');
            if~strcmp(h.testComp.activeSettings.Mode,'DesignErrorDetection')
                objFalsified=h.testComp.getValidatedGoalCount('DV_GOAL_FALSIFIED');
                objProcessed=h.testComp.getValidatedGoalCount('DV_GOAL_PROCESSED');
            else















                objFalsified=h.testComp.getGoalCount('DV_GOAL_FALSIFIED');
                objFalsifiedValidated=h.testComp.getValidatedGoalCount('DV_GOAL_FALSIFIED');
                objProcessed=h.testComp.getValidatedGoalCount('DV_GOAL_PROCESSED')+...
                (objFalsified-objFalsifiedValidated);
            end

            objSatByCovData=h.testComp.getValidatedGoalCount('DV_GOAL_SATISFIED_BY_COVERAGE_DATA');
            objSatByExistingTests=h.testComp.getValidatedGoalCount('DV_GOAL_SATISFIED_BY_EXISTING_TESTCASE');
        else
            objTotal=h.testComp.getGoalCount('DV_GOAL_TOTAL');
            objFalsified=h.testComp.getGoalCount('DV_GOAL_FALSIFIED');
            objSatisfied=h.testComp.getGoalCount('DV_GOAL_SATISFIED');
            objProcessed=h.testComp.getGoalCount('DV_GOAL_PROCESSED');
            objSatByCovData=h.testComp.getGoalCount('DV_GOAL_SATISFIED_BY_COVERAGE_DATA');
            objSatByExistingTests=h.testComp.getGoalCount('DV_GOAL_SATISFIED_BY_EXISTING_TESTCASE');
        end










        h.browserparam1(1)=objProcessed/objTotal;
        h.browserparam1(2)=objTotal;
        h.browserparam1(3)=objFalsified;
        h.browserparam1(4)=objSatisfied;
        h.browserparam1(5)=objProcessed;














        h.browserparam1(12)=objSatByCovData;
        h.browserparam1(13)=objSatByExistingTests;

        h.progressHTML;
    end
