function assessmentWithPlot=checkAssessmentsForPlots(assessments)
    assessmentWithPlot=[];
    for i=1:length(assessments)
        if assessments{i}.hasPlot
            assessmentWithPlot=assessments{i};
            return
        end
    end
end