function dataURI=getDataURIFromScopeImg()





    assessmentWithPlot=[];
    assessmentObjs=learning.simulink.Application.getInstance().getInteractionAssessments();
    currentTaskNumber=learning.simulink.Application.getInstance().getCurrentTask();
    for i=1:length(assessmentObjs{currentTaskNumber})


        if~isstruct(assessmentObjs{currentTaskNumber})&&...
            isequal(class(assessmentObjs{currentTaskNumber}{i}),'learning.assess.assessments.student.StudentBlockValue')
            assessmentWithPlot=assessmentObjs{currentTaskNumber}{i};
            break;
        end
    end
    if isempty(assessmentWithPlot)
        if learning.simulink.Application.getInstance().getSclOpenTask~=0
            scopeNumber=learning.simulink.Application.getInstance().getSclOpenTask;
        else




            grader=find_system(learning.simulink.Application.getInstance().getModelName,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'RegExp','on','ReferenceBlock','signalChecks');
            scopeNumber=get_param(grader{1},'task');
        end

        fig_save_location=fullfile(tempdir,'signalCheck',['scope',num2str(scopeNumber),'.png']);
    else
        fig_save_location=fullfile(tempdir,'signalCheck',['task',num2str(currentTaskNumber),'.png']);
    end



    if exist(fig_save_location,'file')
        dataURI=matlab.ui.internal.URLUtils.getURLToUserFile(fig_save_location,false);
    else
        error(message('learning:simulink:referenceSignals:fileNotExist',fig_save_location).getString());
    end
end
