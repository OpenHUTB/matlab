function requirements=getAssessmentRequirements(interactionAssessments)
    requirements=cell(1,length(interactionAssessments));
    for i=1:length(interactionAssessments)
        requirements{i}=interactionAssessments{i}.generateRequirementString();
    end
end

