function customizationCoderFoundation()




    cm=DAStudio.CustomizationManager;


    cm.addModelAdvisorCheckFcn(@defineToolchainInfoUpgradeChecks);


    cm.addModelAdvisorTaskAdvisorFcn(@defineToolchainInfoUpgradeTasks);

end




function defineToolchainInfoUpgradeChecks

    if coder.oneclick.Utils.isSimulinkCoderInstalledAndLicensed

        check=ModelAdvisor.Check('mathworks.codegen.toolchainInfoUpgradeAdvisor.check');
        check.Title=DAStudio.message('coder_compile:toolchain:UAToolchainInfo_TaskTitle');
        check.TitleTips=DAStudio.message('coder_compile:toolchain:UAToolchainInfo_TaskDescription');
        check.Visible=true;
        check.CSHParameters.MapKey='ma.rtw';
        check.CSHParameters.TopicID='UpgradeToUseToolchainInfo';
        check.setCallbackFcn(@checkToolchainInfoCompliance,'None','StyleOne');


        modifyAction=ModelAdvisor.Action;
        modifyAction.Name=DAStudio.message('coder_compile:toolchain:UAToolchainInfo_ActionButton');
        modifyAction.Description=DAStudio.message('coder_compile:toolchain:UAToolchainInfo_ActionDescription');
        modifyAction.Enable=true;
        modifyAction.setCallbackFcn(@updateModelToUseToolchainInfo);
        check.setAction(modifyAction);


        modelAdvisor=ModelAdvisor.Root;
        modelAdvisor.register(check);
    end

end




function defineToolchainInfoUpgradeTasks

    if coder.oneclick.Utils.isSimulinkCoderInstalledAndLicensed

        task=ModelAdvisor.Task('mathworks.codegen.toolchainInfoUpgradeAdvisor.task');
        task.DisplayName=DAStudio.message('coder_compile:toolchain:UAToolchainInfo_TaskTitle');
        task.Description=DAStudio.message('coder_compile:toolchain:UAToolchainInfo_TaskDescription');
        task.setCheck('mathworks.codegen.toolchainInfoUpgradeAdvisor.check');


        mdlAdvisor=ModelAdvisor.Root;
        mdlAdvisor.register(task);


        upgAdvisor=UpgradeAdvisor;
        upgAdvisor.addTask(task);
    end

end




function results=checkToolchainInfoCompliance(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    modelName=bdroot(system);

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(false);


    output=coder.internal.checkModelToolchainCompliance(modelName);

    docLink=['<a href="matlab:helpview(fullfile(docroot, ''toolbox'', ''rtw'', ''helptargets.map''), ',...
'''upgrading_to_ToolchainInfo_approach'')">'...
    ,DAStudio.message('coder_compile:toolchain:UAToolchainInfo_RecDocLink'),'</a>'];

    if~output.IsTargetCompliant
        ft.setSubResultStatus('pass');

        p1=ModelAdvisor.Text(DAStudio.message('coder_compile:toolchain:UAToolchainInfo_NotUsingToolchainInfo'));
        p2=ModelAdvisor.Paragraph(output.TargetComplianceReport);
        ft.setSubResultStatusText([p1,p2]);

        r1=ModelAdvisor.Text(DAStudio.message('coder_compile:toolchain:UAToolchainInfo_CannotAutoUpgrade'));
        r2=ModelAdvisor.Paragraph(DAStudio.message('coder_compile:toolchain:UAToolchainInfo_TargetNotCompliantRecommendation',docLink));
        ft.setRecAction([r1,r2]);

        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
    else
        if output.AllParamsCompliant
            ft.setSubResultStatus('pass');
            ft.setSubResultStatusText(DAStudio.message('coder_compile:toolchain:UAToolchainInfo_UsingToolchainInfo'));
            mdladvObj.setCheckResultStatus(true);
            mdladvObj.setActionEnable(false);
        else
            ft.setSubResultStatus('warn');

            if output.ToolchainOverride
                p0=ModelAdvisor.Text(DAStudio.message('coder_compile:toolchain:UAToolchainInfo_TargetCompliantNonDefaultParameters'));
            else
                p0=ModelAdvisor.Text(DAStudio.message('coder_compile:toolchain:UAToolchainInfo_NonDefaultParameters'));
            end
            p={};



            ft.setSubResultStatusText([p0,p{:}]);

            upgradable=true;
            upgradeMsg=[];
            for i=1:numel(output.Params)
                if~output.Params(i).IsCompliant
                    if strcmpi(output.Params(i).UpgradeMode,'not-upgradable')
                        upgradable=false;
                        break;
                    elseif strcmpi(output.Params(i).UpgradeMode,'upgradable')
                        upgradeMsg=[upgradeMsg,output.Params(i).UpgradeMessage,'<br>'];%#ok<AGROW>
                    end
                end
            end
            if upgradable&&~isempty(upgradeMsg)
                if~output.ToolchainOverride
                    actioMessage=[...
                    DAStudio.message('coder_compile:toolchain:UAToolchainInfo_CanAutoUpgrade'),...
                    '<br><br>',upgradeMsg];
                else
                    actioMessage=[...
                    DAStudio.message('coder_compile:toolchain:UAToolchainInfo_TargetCompliantCanAutoUpgrade'),...
                    '<br><br>',upgradeMsg];
                end
            else
                if~output.ToolchainOverride

                    actioMessage=[...
                    DAStudio.message('coder_compile:toolchain:UAToolchainInfo_CannotAutoUpgrade'),'<br><br>',...
                    DAStudio.message('coder_compile:toolchain:UAToolchainInfo_NonDefaultParametersRecommendation',docLink)];
                    upgradable=false;
                else
                    actioMessage=[...
                    DAStudio.message('coder_compile:toolchain:UAToolchainInfo_TargetCompliantCannotAutoUpgrade'),'<br><br>',...
                    DAStudio.message('coder_compile:toolchain:UAToolchainInfo_NonDefaultParametersRecommendation',docLink)];
                    upgradable=false;
                end
            end
            ft.setRecAction(actioMessage);
            mdladvObj.setActionEnable(upgradable);
            mdladvObj.setCheckResultStatus(false);
        end
    end

    results=ft;

end




function result=updateModelToUseToolchainInfo(taskobj)

    mdladvObj=taskobj.MAObj;
    result=ModelAdvisor.Paragraph;
    system=getfullname(mdladvObj.System);

    paramChanges=coder.internal.upgradeModelForToolchainCompliance(system);
    if isempty(paramChanges)
        return
    end
    numRows=numel(paramChanges)/3;

    report_paragraph=ModelAdvisor.Paragraph;
    reportResult=ModelAdvisor.Paragraph(DAStudio.message('coder_compile:toolchain:UAToolchainInfo_ActionReport'));

    reportChangeDesc=ModelAdvisor.Paragraph(DAStudio.message('coder_compile:toolchain:UAToolchainInfo_ActionChangeDescription'));
    report_paragraph.addItem([reportResult,reportChangeDesc]);

    report_table=ModelAdvisor.Table(numRows,3);
    report_table.setColHeading(1,DAStudio.message('coder_compile:toolchain:UAToolchainInfo_ParameterName'));
    report_table.setColHeading(2,DAStudio.message('coder_compile:toolchain:UAToolchainInfo_ParameterOldValue'));
    report_table.setColHeading(3,DAStudio.message('coder_compile:toolchain:UAToolchainInfo_ParameterNewValue'));
    report_table.setColHeadingAlign(1,'center');
    report_table.setColHeadingAlign(2,'center');
    report_table.setColHeadingAlign(3,'center');

    for n=1:numRows
        report_table.setEntry(n,1,['<tt>',paramChanges{3*(n-1)+1},'</tt>']);
        report_table.setEntry(n,2,['<tt>',paramChanges{3*(n-1)+2},'</tt>']);
        report_table.setEntry(n,3,['<tt>',paramChanges{3*(n-1)+3},'</tt>']);
    end
    report_paragraph.addItem(report_table);
    result.addItem(report_paragraph);

    mdladvObj.setActionEnable(false);

end


