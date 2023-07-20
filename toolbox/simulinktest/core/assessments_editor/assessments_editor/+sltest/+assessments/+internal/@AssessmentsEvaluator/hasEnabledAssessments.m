function result=hasEnabledAssessments(self)
    result=false;
    for assessmentInfo=self.assessmentsInfo
        if assessmentInfo.enabled
            result=true;
            return;
        end
    end
end
