function plotAssessment=getAssessmentWithPlot()
    plotAssessment=[];

    interactionAssessments=learning.simulink.Application.getInstance().getInteractionAssessments();
    currentTaskNumber=learning.simulink.Application.getInstance().getCurrentTask();
    taskAssessments=interactionAssessments{currentTaskNumber};



    if isstruct(taskAssessments)||isstruct(taskAssessments{1})
        return;
    end


    for i=1:length(taskAssessments)
        if taskAssessments{i}.hasPlot
            plotAssessment=taskAssessments{i};
            break;
        end
    end
end

