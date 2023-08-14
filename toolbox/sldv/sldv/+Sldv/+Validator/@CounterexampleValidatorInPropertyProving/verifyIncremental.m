


function[counterExamples,validatedIdx]=verifyIncremental(obj,futureObjects,counterExamples)
    objectivesWithStatus=obj.verifyCounterExamples(futureObjects);
    validatedIdx=cell(1,numel(objectivesWithStatus));

    for statusIdx=1:numel(objectivesWithStatus)
        ceObjId=objectivesWithStatus(statusIdx).ceObjId;
        status=objectivesWithStatus(statusIdx).status;
        obj.updateObjectiveStatus(ceObjId,status);
        validatedIdx{statusIdx}=ceObjId;
    end
end
