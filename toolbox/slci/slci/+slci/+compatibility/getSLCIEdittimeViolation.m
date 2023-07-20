function aViolation=getSLCIEdittimeViolation(aBlock)





    currentMdlAdvCheckObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();


    if isempty(currentMdlAdvCheckObj)
        aViolation='';
        return
    else
        mdlAdvTaskID=currentMdlAdvCheckObj.LatestRunID;
    end
    sfManObj=slcheck.MASFEditTimeManager.getInstance();
    aViolation=sfManObj.getSFViolation(aBlock,mdlAdvTaskID);
end
