function rec=utilSetDefaultActionParameters(rec,value1,value2,value3,callBackFcn,defaultEnableParameter)











    vs1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionModeManually');
    vs2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionModeAuto');

    vs={vs1,vs2};

    if nargin<6
        defaultEnableParameter=ones(3,1);
    end


    rec.InputParametersLayoutGrid=[1,6];
    rec.setInputParametersCallbackFcn(@utilAdjustDefaultActionParameters);

    idx=1;

    actionParam{idx}=ModelAdvisor.InputParameter;
    actionParam{idx}.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionMode');
    actionParam{idx}.Type='enum';

    actionParam{idx}.Entries={vs1,vs2};
    actionParam{idx}.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionModeToolTip');

    if defaultEnableParameter(idx)~=0
        actionParam{idx}.Enable=true;
    else
        actionParam{idx}.Enable=false;
    end
    actionParam{idx}.Value=vs{value1};

    actionParam{idx}.Default=vs{value1};


    actionParam{idx}.RowSpan=[1,1];
    actionParam{idx}.ColSpan=[1,1];

    idx=idx+1;

    actionParam{idx}=ModelAdvisor.InputParameter;
    actionParam{idx}.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidateTime');
    actionParam{idx}.Type='bool';
    actionParam{idx}.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidateTime');

    if defaultEnableParameter(idx)~=0
        actionParam{idx}.Enable=true;
    else
        actionParam{idx}.Enable=false;
    end

    actionParam{idx}.Default=value2;

    actionParam{idx}.Value=value2;
    actionParam{idx}.RowSpan=[3,3];
    actionParam{idx}.ColSpan=[1,1];

    idx=idx+1;

    actionParam{idx}=ModelAdvisor.InputParameter;
    actionParam{idx}.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidateAccuracy');
    actionParam{idx}.Type='bool';
    actionParam{idx}.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidateAccuracy');

    if defaultEnableParameter(idx)~=0
        actionParam{idx}.Enable=true;
    else
        actionParam{idx}.Enable=false;
    end

    actionParam{idx}.Default=value3;

    actionParam{idx}.Value=value3;
    actionParam{idx}.RowSpan=[5,5];
    actionParam{idx}.ColSpan=[1,1];












    rec.setInputParameters(actionParam);

    recAction=ModelAdvisor.Action;
    recAction.setCallbackFcn(callBackFcn);

    name1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:FixButton');
    name2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:FixButtonFixOnly');

    if(actionParam{2}.value||actionParam{3}.value)
        recAction.name=name1;
    else
        recAction.name=name2;
    end

    name1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDescManually');
    name2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');
    if strcmp(actionParam{1}.value,vs1)
        recAction.Description=name1;
    else
        recAction.Description=name2;
    end

    rec.setAction(recAction);
end


function showSdi(~)
    sdiGui=Simulink.sdi.Instance.gui();
    sdiGui.Show();
end

function utilAdjustDefaultActionParameters(taskobj)

    vs1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionModeManually');
    mdladvObj=taskobj.MAObj;
    inputParameters=mdladvObj.getInputParameters(taskobj.ID);


    name1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:FixButton');
    name2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:FixButtonFixOnly');

    checkObj=mdladvObj.getCheckObj(taskobj.ID);
    action=checkObj.getAction;

    if(inputParameters{2}.value||inputParameters{3}.value)
        action.name=name1;
    else
        action.name=name2;
    end

    name1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDescManually');
    name2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');
    if strcmp(inputParameters{1}.value,vs1)
        action.Description=name1;
    else
        action.Description=name2;
    end

end

