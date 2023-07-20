function getAssessmentsData(simInputs,signalLoggingOn,sigLoggingName,obj)




    parameters=simInputs.assessmentsLoggingInfo.parameters;
    assessmentsData=[];
    try
        assessmentsData.signalLoggingOn=signalLoggingOn;
        assessmentsData.sigLoggingName=sigLoggingName;
        assessmentsData.parameterValues=...
        stm.internal.MRT.share.evaluateParameters(parameters);
    catch me
        assessmentsData=me;
    end
    obj.out.assessmentsData=assessmentsData;
end
