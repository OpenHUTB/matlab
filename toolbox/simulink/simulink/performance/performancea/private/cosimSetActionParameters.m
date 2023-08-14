function rec=cosimSetActionParameters(rec,callBackFcn)


    vs1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionModeManually');
    vs2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionModeAuto');

    vs={vs1,vs2};


    rec.InputParametersLayoutGrid=[1,1];
    rec.setInputParametersCallbackFcn(@cosimAdjustActionParameters);

    idx=1;
    actionParam{idx}=ModelAdvisor.InputParameter;
    actionParam{idx}.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionMode');
    actionParam{idx}.Type='enum';
    actionParam{idx}.Entries={vs1,vs2};
    actionParam{idx}.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionModeToolTip');
    actionParam{idx}.Value=vs{1};
    actionParam{idx}.Default=vs{1};
    actionParam{idx}.RowSpan=[1,1];
    actionParam{idx}.ColSpan=[1,1];

    rec.setInputParameters(actionParam);

    recAction=ModelAdvisor.Action;
    recAction.setCallbackFcn(callBackFcn);

    name2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:FixButtonFixOnly');
    recAction.name=name2;

    name1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDescManually');
    name2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');
    if strcmp(actionParam{1}.value,vs1)
        recAction.Description=name1;
    else
        recAction.Description=name2;
    end

    rec.setAction(recAction);
end

function cosimAdjustActionParameters(taskobj)
    vs1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionModeManually');
    mdladvObj=taskobj.MAObj;
    inputParameters=mdladvObj.getInputParameters(taskobj.ID);


    name2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:FixButtonFixOnly');

    checkObj=mdladvObj.getCheckObj(taskobj.ID);
    action=checkObj.getAction;

    action.name=name2;

    name1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDescManually');
    name2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');
    if strcmp(inputParameters{1}.value,vs1)
        action.Description=name1;
    else
        action.Description=name2;
    end
end

