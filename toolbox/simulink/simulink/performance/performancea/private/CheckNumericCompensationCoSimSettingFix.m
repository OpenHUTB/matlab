function Result=CheckNumericCompensationCoSimSettingFix(taskobj)







    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    result_paragraph=ModelAdvisor.Paragraph;
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckNumericCompensationCoSimSetting');


    mdladvObj.setActionEnable(false);
    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Wait');


    me=mdladvObj.MAExplorer;
    dlg=me.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end


    baseline=utilGetBaselineBefore(mdladvObj,model,currentCheck);
    baseline.check.validationPassed='na';
    baseline.check.name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CoSimNumericalCompensationCheckTitle');

    try
        baseline=utilGenerateBaselineIfNeeded(baseline,mdladvObj,model,currentCheck);
    catch ME

        text=DAStudio.message('SimulinkPerformanceAdvisor:advisor:OldBaselineFailed');
        Result=publishActionFailedMessage(ME,text);
        baseline.check.fixed='n';
        utilUpdateBaseline(mdladvObj,currentCheck,baseline,baseline);
        currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');
        return;
    end



    for i=1:length(mdladvObj.UserData.candidateInputPorts)
        portSetting=mdladvObj.UserData.candidateInputPorts(i);
        p=get_param(portSetting.block,'PortHandles');
        set_param(p.Inport(portSetting.port),'CoSimSignalCompensationMode','Always');
    end

    title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CoSimNumericalCompensationInputPortAction');
    h1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CoSimNumericalCompensationBlockName');
    h2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CoSimNumericalCompensationInputPort');
    h3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CoSimNumericalCompensationNewSetting');
    table=cell(length(mdladvObj.UserData.candidateInputPorts),3);
    for i=1:length(mdladvObj.UserData.candidateInputPorts)
        table{i,1}=mdladvObj.getHiliteHyperlink(mdladvObj.UserData.candidateInputPorts(i).block);
        table{i,2}=num2str(mdladvObj.UserData.candidateInputPorts(i).port);
        table{i,3}='Always';
    end
    heading={h1,h2,h3};
    resultTable=utilDrawReportTable(table,title,{},heading);
    result_paragraph.addItem(resultTable.emitHTML);

    result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CoSimNumericalCompensationCheckFixApply'));
    result_paragraph.addItem(result_text);
    baseline.check.fixed='y';





    baselineOk=true;
    try

        [~,newBaseline,needUndo,validated,compare_result]=utilCheckActionResult(mdladvObj,currentCheck,baseline);
    catch ME

        baseText1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:NewBaselineFailed');
        baseText2=publishActionFailedMessage(ME,baseText1);
        result_paragraph.addItem(baseText2);
        baselineOk=false;
    end






    if baselineOk
        [validateTime,validateAccuracy]=utilCheckValidation(mdladvObj,currentCheck);
        if(validateTime||validateAccuracy)




        end

    else
        needUndo=true;
    end

    if needUndo

























    end

    Result=result_paragraph;



    currentCheck.ResultData.after=newBaseline;


    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');

end




