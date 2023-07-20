






function t=getTimeOfObservation(obj)

    curObjId=obj.DebugCtx.curObjId;
    curObjective=obj.sldvData.Objectives(curObjId);




    if~isfield(curObjective,'testCaseIdx')
        t=0;
        return;
    elseif strcmpi(curObjective.status,'Undecided due to runtime error')
        t=0;
        modelslicerprivate('MessageHandler','open',obj.designMdl);
        timeSetToZeroMsg=getString(message('Sldv:DebugUsingSlicer:SimTimeSetToZeroForRunTimeError'));
        modelslicerprivate('MessageHandler','info',timeSetToZeroMsg);
        return;
    end
    testCaseIdx=curObjective.testCaseIdx;
    simInputValues=obj.getTestCase(testCaseIdx);
    testCaseObjectives=simInputValues.objectives;
    index=[testCaseObjectives.objectiveIdx]==curObjId;
    t=testCaseObjectives(index).atTime;
end
