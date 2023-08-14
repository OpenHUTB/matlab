function assessmentsLoggingInfo=...
    getAssessmentsLoggingInfo(testId,model,simIndex)




    assessmentsLoggingInfo=struct('signals',[],...
    'parameters',struct());

    if(strcmp(stm.internal.assessmentsFeature('AllowMRTAssessments'),'off'))
        return;
    end

    assessmentsID=stm.internal.getAssessmentsID(testId);
    assessmentsInfo=stm.internal.getAssessmentsInfo(assessmentsID);

    assessmentsEvaluator=...
    sltest.assessments.internal.AssessmentsEvaluator(assessmentsInfo);

    if assessmentsEvaluator.hasAssessments()
        assessmentsLoggingInfo.signals=...
        sltest.assessments.internal.getLoggedSignalsFromMappingInfo(...
        assessmentsInfo,simIndex,model);

        if simIndex==1
            parameters=...
            assessmentsEvaluator.parseParameters(1,model,struct());
        else
            symbolInfosFromSim1=...
            assessmentsEvaluator.parseSymbols({'Variable','Parameter'},...
            1,model,struct());

            parameters=assessmentsEvaluator.parseParameters(...
            2,model,symbolInfosFromSim1);
        end
        assessmentsLoggingInfo.parameters=parameters;
    end

end

