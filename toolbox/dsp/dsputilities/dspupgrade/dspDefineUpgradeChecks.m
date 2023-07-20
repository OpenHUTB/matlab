function dspDefineUpgradeChecks







    check=ModelAdvisor.Check('mathworks.design.DSPFrameUpgrade');
    check.Title=DAStudio.message('dsp:UpgradeAdvisor:Title');
    check.setCallbackFcn(@checkForFrameUpgradeIssues,'None','StyleOne');
    check.CSHParameters.MapKey='ma.simulink';
    check.CSHParameters.TopicID='DSPFrameUpgrade';
    check.callbackcontext='PostCompile';
    check.SupportLibrary=false;
    check.SupportExclusion=true;
    check.Value=false;


    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(check);

end


function result=checkForFrameUpgradeIssues(system)




    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    ResultStatus=false;
    mdladvObj.setCheckResultStatus(ResultStatus);


    [blockSampleColumnAsRow,...
    blockFrameBasedOutput,...
    blockInheritedLogging]=analyzeModelForFrameUpgradeIssues(system);

    result={};

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(0);

    if(isempty(blockSampleColumnAsRow)&&...
        isempty(blockFrameBasedOutput)&&...
        isempty(blockInheritedLogging))
        ft.setCheckText({DAStudio.message('dsp:UpgradeAdvisor:Passed')});
        result{end+1}=ft;
        ResultStatus=true;
    else
        ft.setCheckText({DAStudio.message('dsp:UpgradeAdvisor:Failed')});
        ResultStatus=false;
        result{end+1}=ft;
        if~isempty(blockSampleColumnAsRow)
            ft0=ModelAdvisor.FormatTemplate('ListTemplate');
            ft0.setSubTitle({(DAStudio.message('dsp:UpgradeAdvisor:ColumnAsRowTitle'))})
            ft0.setInformation(DAStudio.message('dsp:UpgradeAdvisor:ColumnAsRow'))
            ft0.setListObj({blockSampleColumnAsRow{:}});%#ok<CCAT1>
            result{end+1}=ft0;
        end
        if~isempty(blockFrameBasedOutput)
            ft0=ModelAdvisor.FormatTemplate('ListTemplate');
            ft0.setSubTitle({(DAStudio.message('dsp:UpgradeAdvisor:FrameBasedOuputTitle'))})
            ft0.setInformation(DAStudio.message('dsp:UpgradeAdvisor:FrameBasedOuput'))
            ft0.setListObj({blockFrameBasedOutput{:}});%#ok<CCAT1>
            result{end+1}=ft0;
        end
        if~isempty(blockInheritedLogging)
            ft0=ModelAdvisor.FormatTemplate('ListTemplate');
            ft0.setSubTitle({(DAStudio.message('dsp:UpgradeAdvisor:InheritedLoggingTitle'))})
            ft0.setInformation(DAStudio.message('dsp:UpgradeAdvisor:InheritedLogging'))
            ft0.setListObj({blockInheritedLogging{:}});%#ok<CCAT1>
            result{end+1}=ft0;
        end
    end

    mdladvObj.setCheckResultStatus(ResultStatus);

end
