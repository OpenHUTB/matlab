function ids=getAssessmentsIDs(assessmentsID,assessmentsUUID)
    ids=string([]);
    assessmentsJSON=stm.internal.getAssessmentsInfo(assessmentsID);
    if~isempty(assessmentsJSON)
        data=jsondecode(assessmentsJSON);

        assessmentsInfo=sltest.assessments.internal.AssessmentsEvaluator.tableToTree(data.AssessmentsInfo,'placeHolder');
        if~isempty(assessmentsInfo)
            ids=string(assessmentsUUID)+":"+[assessmentsInfo.id];
        end
    end
end

