function deleteResult(idList)

    db=sltest.assessments.internal.AssessmentResultDB.AssessmentResultDB;
    for id=idList
        db.removeData(id);
    end
end

