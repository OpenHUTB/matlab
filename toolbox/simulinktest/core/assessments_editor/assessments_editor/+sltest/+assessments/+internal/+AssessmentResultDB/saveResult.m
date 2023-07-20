function resultID=saveResult(result)

    db=sltest.assessments.internal.AssessmentResultDB.AssessmentResultDB;
    resultID=db.addData(result);
end

