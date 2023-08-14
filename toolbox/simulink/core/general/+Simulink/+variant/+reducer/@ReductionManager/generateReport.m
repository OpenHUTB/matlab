function generateReport(rMgr)




    if~isempty(rMgr.Error)

        return;
    end
    if~rMgr.getOptions().GenerateReport
        return;
    end

    verboseHandler=rMgr.getOptions().VerboseInfoObj;
    verboseHandler.updateProgressBarMessage('Simulink:Variants:GeneratingReport');
    Simulink.variant.reducer.summary.generateReport(rMgr);
    verboseHandler.updateTimerMessage();
end
