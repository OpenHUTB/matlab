function[ResultDescription,ResultDetails]=CheckSimTargetEchoStatus(system)






    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckSimTargetEchoStatus');


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});




    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckSimTargetEchoStatusTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);


    cfs=utilGetActiveConfigSet(model);

    if cfs.isConfigSetRef
        cfsString=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ConfigRef');
    else
        cfsString=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ModelConfig');
    end


    dParam={'SFSimEcho'};

    table=cell(length(dParam),4);



    table{1,1}=utilGetStatusImgLink(1);


    table{1,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SFSimEcho');


    for i=1:length(dParam)
        table{i,3}=get_param(model,cell2mat(dParam(i)));
    end



    table{1,4}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:off');




    for i=1:length(dParam)
        if strcmp(table{i,3},'on')
            table{i,1}=utilGetStatusImgLink(0);
            Pass=false;
        else
            table{i,1}=utilGetStatusImgLink(1);
        end

        table{i,2}=ModelAdvisor.Text(table{i,2});
        link=utilCreateConfigSetHref(model,dParam{i});
        table{i,2}.setHyperlink(link);
    end




    tableName='';
    h1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Severity');
    h2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DiagnosticsCheked');
    h3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActualValue');
    h4=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RecommendedValue');
    heading={h1,h2,h3,h4};
    resultTable=utilDrawReportTable(table,tableName,{},heading);

    if~Pass


        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckSimTargetEchoStatusAdvice',cfsString,model));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        result_text=utilAddAppendInformation(mdladvObj,currentCheck);
        result_paragraph.addItem(result_text);

        result_paragraph.addItem(resultTable.emitHTML);
    else

        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckSimTargetEchoStatusAdvice',cfsString,model));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:AdviceAppendPassed'));
        result_paragraph.addItem(result_text);


        result_paragraph.addItem(resultTable.emitHTML);
    end


    ResultDescription{end+1}=result_paragraph;
    ResultDetails{end+1}='';



    mdladvObj.setCheckResultStatus(Pass);

    if~Pass


        mdladvObj.setCheckErrorSeverity(0);



        utilRunFix(mdladvObj,currentCheck,Pass);
    end


    if(Pass)
        baseLineAfter.time=baseLineBefore.time;
        baseLineAfter.check.passed='y';
    else
        baseLineAfter=utilGetBaselineAfter(mdladvObj,model,currentCheck);
        baseLineAfter.check.passed='n';
    end

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);

end


