function result_text=utilAddAppendInformation(mdladvObj,currentCheck)






    mdladvObj.setActionEnable(true);
    quickScan=strcmp(mdladvObj.UserData.Mode,'QuickScan');
    runButtonName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RunButton');


    actionMode=utilCheckActionMode(mdladvObj,currentCheck);
    action=currentCheck.getAction;
    fixButtonName=action.Name;

    if quickScan
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:AdviceAppendQS',fixButtonName,runButtonName));
    else
        if strfind(actionMode,'Manually')
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:AdviceAppendManually',fixButtonName));
        else
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:AdviceAppendAuto'));
        end
    end

    result_text=[result_text,ModelAdvisor.LineBreak,ModelAdvisor.LineBreak];
