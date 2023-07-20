function updateLearnSection()



    persistent f;
    if isempty(f)||f.Status~=dastudio_util.cooperative.AsyncFunctionRepeaterTask.Status.Running
        f=dastudio_util.cooperative.AsyncFunctionRepeaterTask;
        f.start(@lProcess);
    end
end

function isDone=lProcess(~)
    isDone=false;
    if sltemplate.ui.StartPage.isServerReady()&&sltemplate.ui.StartPage.isClientReady()



        isAvailable=~isempty(ver('slcontrol'));
        sltemplate.ui.StartPage.showControlsCourse(isAvailable);

        isAvailable=~isempty(ver('simscape'));
        sltemplate.ui.StartPage.showSimscapeCourse(isAvailable);
        isDone=true;
    end
end

