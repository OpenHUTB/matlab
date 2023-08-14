function[ResultDescription,ResultDetails]=CheckModelRefRebuildSetting(system)







    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckModelRefRebuildSetting');


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});




    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckModelRefRebuildSettingTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);


    cfs=utilGetActiveConfigSet(model);

    if cfs.isConfigSetRef
        cfsString=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ConfigRef');
    else
        cfsString=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ModelConfig');
    end




    dParam={'UpdateModelReferenceTargets'};
    paramValue={'Force','IfOutOfDateOrStructuralChange','IfOutOfDate','AssumeUpToDate'};
    recommendValue='IfOutOfDate';

    dispValue={DAStudio.message('RTW:configSet:MRBuildAlways'),...
    DAStudio.message('RTW:configSet:MRBuildAnyChanges'),...
    DAStudio.message('RTW:configSet:MRBuildKnownDeps'),...
    DAStudio.message('RTW:configSet:MRBuildNever')};

    table=cell(1,4);




    actualIdx=strcmp(paramValue,get_param(model,dParam{1}));


    actualString=dispValue{actualIdx};

    if~(strcmp(get_param(model,dParam{1}),recommendValue))
        Pass=false;
    end

    table{1,1}=utilGetStatusImgLink(Pass);

    table{1,2}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:UpdateModelReferenceTargets'));
    link=utilCreateConfigSetHref(model,dParam{1});
    table{1,2}.setHyperlink(link);

    table{1,3}=actualString;

    table{1,4}=DAStudio.message('RTW:configSet:MRBuildKnownDeps');




    tableName='';
    h1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Severity');
    h2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DiagnosticsCheked');
    h3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActualValue');
    h4=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RecommendedValue');
    heading={h1,h2,h3,h4};
    resultTable=utilDrawReportTable(table,tableName,{},heading);

    if~Pass


        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckModelRefRebuildSettingAdvice',cfsString,model));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        result_text=utilAddAppendInformation(mdladvObj,currentCheck);
        result_paragraph.addItem(result_text);

        result_paragraph.addItem(resultTable.emitHTML);

    else

        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckModelRefRebuildSettingAdvice',cfsString,model));
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


