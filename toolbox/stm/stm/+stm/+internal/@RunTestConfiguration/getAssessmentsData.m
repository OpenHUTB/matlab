


function getAssessmentsData(simInputs,simWatcher,signalLoggingOn,sigLoggingName,obj)
    assessmentsData=[];

    if(isfield(simInputs,'RunningOnMRT')&&simInputs.RunningOnMRT&&...
        strcmpi(stm.internal.assessmentsFeature('AllowMRTAssessments'),'off'))
        return;
    end

    try








        if obj.useAssessmentsInfoFromRunCfg
            assessmentsInfo=obj.assessmentsInfo;
        else
            assessmentsInfo=stm.internal.getAssessmentsInfo(stm.internal.getAssessmentsID(simInputs.TestCaseId));
        end
        assessmentsEvaluator=sltest.assessments.internal.AssessmentsEvaluator(assessmentsInfo);
        if assessmentsEvaluator.hasAssessments()
            simIndex=stm.internal.util.getSimulationIndex(simWatcher);
            if simIndex==1
                assessmentsData.signalLoggingOn=signalLoggingOn;
                assessmentsData.sigLoggingName=sigLoggingName;
                parameters=assessmentsEvaluator.parseParameters(1,simWatcher.modelToRun,struct());
                assessmentsData.parameterValues=assessmentsEvaluator.evaluateParameters(parameters);
            else
                symbolInfosFromSim1=assessmentsEvaluator.parseSymbols({'Variable','Parameter'},1,simWatcher.modelToRun,struct());
                assessmentsData.signalLoggingOn=signalLoggingOn;
                assessmentsData.sigLoggingName=sigLoggingName;
                assessmentsData.parameterValues=assessmentsEvaluator.evaluateParameters(...
                assessmentsEvaluator.parseParameters(2,simWatcher.modelToRun,symbolInfosFromSim1));
            end
        end
    catch me
        assessmentsData=me;
    end

    if obj.useAssessmentsInfoFromRunCfg







        h=get_param(simWatcher.modelToRun,'Handle');
        dataId='STM_AssessmentsData';



        try
            Simulink.BlockDiagramAssociatedData.get(h,dataId);
        catch me
            if strcmp(me.identifier,'Simulink:AssociatedData:NotRegistered')
                Simulink.BlockDiagramAssociatedData.register(h,dataId,'any');
                Simulink.BlockDiagramAssociatedData.set(h,dataId,assessmentsData);
            end
        end
    else
        obj.out.assessmentsData=assessmentsData;
    end
end
