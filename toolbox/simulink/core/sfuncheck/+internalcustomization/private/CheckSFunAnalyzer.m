function CheckSFunAnalyzer



    mdladvroot=ModelAdvisor.Root;


    sFunctionAdvCheck=ModelAdvisor.Check('mathworks.design.SFuncAnalyzer');
    sFunctionAdvCheck.Title=DAStudio.message('Simulink:tools:MATitleSFunctionAnalyzerCheck');
    sFunctionAdvCheck.TitleTips=DAStudio.message('Simulink:tools:MATitletipSFunctionAnalyzerCheck');
    sFunctionAdvCheck.setCallbackFcn(@ExecCheckSFunAdv,'None','StyleOne');
    sFunctionAdvCheck.CSHParameters.MapKey='ma.simulink';
    sFunctionAdvCheck.CSHParameters.TopicID='MATitleSFunctionAnalyzerCheck';
    sFunctionAdvCheck.Visible=true;
    sFunctionAdvCheck.Value=true;
    mdladvroot.publish(sFunctionAdvCheck,'Simulink');
end



function result=ExecCheckSFunAdv(system)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    result={};
    model=system;
    opts=Simulink.sfunction.analyzer.Options();
    reportDir=fullfile(pwd,'slprj','_sfcncheck');
    if~isfolder(reportDir)
        [~,~,~]=mkdir(reportDir);
    end
    opts.ReportPath=reportDir;
    cpChecker=Simulink.sfunction.Analyzer(model,'Options',opts);
    cpChecker.run();
    cpChecker.generateReport(false);

    ft1=ModelAdvisor.FormatTemplate('ListTemplate');
    ft1.setInformation(DAStudio.message('Simulink:tools:MAInfoSFunctionAnalyzerCheck'));
    summaryResults=arrayfun(@(i)cpChecker.CheckResult.Data(i).SummaryResult,1:numel(cpChecker.CheckResult.Data),'UniformOutput',false);
    if(~isempty(summaryResults))
        NotRunNum=find(cellfun(@(s)contains('Not Run',s),summaryResults));
        if(~isempty(NotRunNum))
            if(length(NotRunNum)==numel(cpChecker.CheckResult.Data))
                mdladvObj.setCheckResultStatus(true);
                setSubResultStatus(ft1,'Pass');
                setSubResultStatusText(ft1,DAStudio.message('Simulink:tools:MAPassSFunctionAnalyzerCheck'));
            end
        end

        if(~isempty(find(cellfun(@(s)contains('Fail',s),summaryResults),1)))
            mdladvObj.setCheckResultStatus(false);
            mdladvObj.setCheckErrorSeverity(1);
            setSubResultStatus(ft1,'Fail');
            setSubResultStatusText(ft1,DAStudio.message('Simulink:tools:MAFailSFunctionAnalyzerCheck'));

        elseif(~isempty(find(cellfun(@(s)contains('Warning',s),summaryResults),1)))
            mdladvObj.setCheckResultStatus(false);
            mdladvObj.setCheckErrorSeverity(0);
            setSubResultStatus(ft1,'Warn');
            setSubResultStatusText(ft1,DAStudio.message('Simulink:tools:MAWarnSFunctionAnalyzerCheck'));


        else
            PassNum=find(cellfun(@(s)contains('Pass',s),summaryResults),1);
            if(~isempty(PassNum))
                mdladvObj.setCheckResultStatus(true);
                setSubResultStatus(ft1,'Pass');
                setSubResultStatusText(ft1,DAStudio.message('Simulink:tools:MAPassSFunctionAnalyzerCheck'));
            end
        end
        ft1.setSubBar(0);
        result{end+1}=ft1;
        result{end+1}=ModelAdvisor.Paragraph(DAStudio.message('Simulink:tools:MASFunAnalyzerReport',[regexprep(model,'[ /\f\n\t\r]','_'),'_report']));
    else
        mdladvObj.setCheckResultStatus(true);
        setSubResultStatus(ft1,'Pass');
        result{end+1}=ModelAdvisor.Paragraph(DAStudio.message('Simulink:tools:MANoUserSfunctions'));
    end
end