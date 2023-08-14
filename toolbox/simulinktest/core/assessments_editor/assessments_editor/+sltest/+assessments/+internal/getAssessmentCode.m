function res=getAssessmentCode(assessmentsInfo,quantitative)
    codeGenerator=sltest.assessments.internal.AssessmentsEvaluator(assessmentsInfo,'OutputNamespace','resultList{end+1}');
    res=sprintf('resultList = {};\n%s\n',codeGenerator.generateCode());
end

