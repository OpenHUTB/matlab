

function recoverEditTimeChecks(studio)
    src=slci.view.internal.getSource(studio);
    modelH=src.modelH;
    modelName=src.modelName;
    maflag=edittime.getAdvisorChecking(modelH);

    try
        if strcmp(maflag,'on')
            editControl=edittimecheck.EditTimeEngine.getInstance();
            editControl.enableMA(modelName);
        end
    catch ME
        slci.internal.outputMessage(ME,'error');
    end
end