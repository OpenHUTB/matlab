function[new_result_paragraph,newBaseline,needUndo,validated,compare_result]=utilCheckActionResult(mdladvObj,currentCheck,baseline)






    new_result_paragraph=ModelAdvisor.Paragraph;
    validated=true;
    compare_result.Time=0;
    compare_result.Accuracy=0;


    text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Validations'));
    new_result_paragraph.addItem(text);


    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    needUndo=false;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});
    Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Failed'),{'bold','fail'});
    NotRequired=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NotRequired'),{'bold','warn'});


    actionMode=utilCheckActionMode(mdladvObj,currentCheck);

    switch actionMode
    case{'AutoNoValidate','ManuallyNoValidate'}

        newBaseline=baseline;

        text=NotRequired;
        new_result_paragraph.addItem(text);
        new_result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
    otherwise

        validated=true;
        newBaseline=utilCreateBaseline(mdladvObj,currentCheck,model);
        newBaseline.check=baseline.check;
        compare_result=utilCompareBaseLine(mdladvObj,currentCheck,newBaseline,baseline);

        if(compare_result.Pass==true)
            text=Passed;
            newBaseline.check.validationPassed='y';
        else

            needUndo=true;
            text=Failed;
            newBaseline.check.validationPassed='n';
        end
        new_result_paragraph.addItem(text);
        new_result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        text=compare_result.TimeString;
        new_result_paragraph.addItem(text);
        new_result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        text=compare_result.AccuracyString;
        new_result_paragraph.addItem(text);
        new_result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
    end

end




