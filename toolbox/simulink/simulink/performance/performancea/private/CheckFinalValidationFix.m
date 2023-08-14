function Result=CheckFinalValidationFix(taskobj)


    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    result_paragraph=ModelAdvisor.Paragraph;
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.FinalValidation');


    mdladvObj.setActionEnable(false);
    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Wait');


    me=mdladvObj.MAExplorer;
    dlg=me.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end



    needUndo=true;

    if needUndo

        heading=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SuccessActionsTaken'));
        heading={heading};

        Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:FinalValidationFaliedPerformance'),{'bold','fail'});


        baseLineCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CreateBaseline');

        text=UndoFix(model,baseLineCheck,Failed);
        table=cell(1,1);
        table{1,1}=text;
        undoTable=utilDrawReportTable(table(1,1),'','',heading);

        initBaseline=mdladvObj.UserData.Progress.initBaseLine;
        initBaseline.check.name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:FinalValidationTitle');
        initBaseline.check.validationPassed='na';
        initBaseline.check.fixed='y';

        result_paragraph.addItem(undoTable.emitHTML);
        result_paragraph.addItem(ModelAdvisor.LineBreak);

    end

    Result=result_paragraph;





    currentCheck.ResultData.after=initBaseline;


    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');

end


function Result=UndoFix(model,check,Failed)




    text=ModelAdvisor.Text([Failed.emitHTML]);
    try
        Result=DefaultUndo(model,check,text);
    catch ME
        Result=ME.message;
    end
end



