function result=getAssessmentsNames(self)
    result={};
    for assessmentInfo=self.assessmentsInfo
        result{end+1}=assessmentInfo.assessmentName;%#ok<AGROW>
    end
end
