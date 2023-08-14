function res=getResult(id)

    db=sltest.assessments.internal.AssessmentResultDB.AssessmentResultDB;
    res=db.getData(id);
end

