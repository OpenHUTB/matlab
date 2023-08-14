function[ResultDescription,ResultDetails]=IdentifyExpensiveDiagnostics(system)






    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.IdentifyExpensiveDiagnostics');


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});




    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    checkName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyExpensiveDiagnosticsTitle');
    baseLineAfter=utilCreateEmptyBaseline(checkName);


    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);


    cfs=utilGetActiveConfigSet(model);

    if cfs.isConfigSetRef
        cfsString=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ConfigRef');
    else
        cfsString=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ModelConfig');
    end


    dParam={'ConsistencyChecking','SignalResolutionControl','CheckMatrixSingularityMsg','SignalInfNanChecking','SignalRangeChecking','ArrayBoundsChecking','ReadBeforeWriteMsg','WriteAfterReadMsg','WriteAfterWriteMsg','MultiTaskDSMMsg','UniqueDataStoreMsg'};

    table=cell(length(dParam),4);



    table{1,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SolverDataInConsistency');
    table{2,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SignalResolution');
    table{3,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DivisionBySingularMatrix');
    table{4,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:InfOrNanBlockOutput');
    table{5,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SimulationRangeChecking');
    table{6,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ArrayBoundsExceeded');
    table{7,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ReadBeforeWriteMsg');
    table{8,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:WriteAfterReadMsg');
    table{9,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:WriteAfterWriteMsg');
    table{10,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:MultiTaskDSMMsg');
    table{11,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:UniqueDataStoreMsg');


    for i=1:length(dParam)
        table{i,3}=get_param(model,cell2mat(dParam(i)));
    end




    internalValue={'None','UseLocalSettings','TryResolveAll','TryResolveAllWithWarning'};
    dispValue={DAStudio.message('RTW:configSet:debugSignalResolutionNone'),...
    DAStudio.message('RTW:configSet:debugSignalResolutionExplicit'),...
    DAStudio.message('RTW:configSet:debugSignalResolutionExplicitAndImplicit'),...
    DAStudio.message('RTW:configSet:debugSignalResolutionExplicitAndWarnImplicit')};

    actualIdx=strcmp(internalValue,get_param(model,'SignalResolutionControl'));




    table{1,4}='none';
    table{2,4}='UseLocalSettings';
    table{3,4}='none';
    table{4,4}='none';
    table{5,4}='none';
    table{6,4}='none';
    table{7,4}='DisableAll';
    table{8,4}='DisableAll';
    table{9,4}='DisableAll';
    table{10,4}='none';
    table{11,4}='none';





    for i=1:length(dParam)
        table{i,2}=ModelAdvisor.Text(table{i,2});
        link=utilCreateConfigSetHref(model,dParam{i});
        table{i,2}.setHyperlink(link);

        if~strcmp(table{i,3},table{i,4})
            table{i,1}=utilGetStatusImgLink(0);
            Pass=false;
        else
            table{i,1}=utilGetStatusImgLink(1);
        end
    end


    table{2,3}=ModelAdvisor.Text(dispValue{actualIdx});
    table{2,4}=ModelAdvisor.Text(dispValue{2});



    tableName='';
    h1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Severity');
    h2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DiagnosticsCheked');
    h3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActualValue');
    h4=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RecommendedValue');
    heading={h1,h2,h3,h4};
    rowHeader={'Solver','Signals','','','','','DSM Blocks','','','',''};

    resultTable=utilDrawReportTable(table,tableName,rowHeader,heading);

    if~Pass


        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyExpensiveDiagnosticsAdvice',cfsString,model));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        result_text=utilAddAppendInformation(mdladvObj,currentCheck);
        result_paragraph.addItem(result_text);

        result_paragraph.addItem(resultTable.emitHTML);
    else

        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyExpensiveDiagnosticsAdvice',cfsString,model));
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


