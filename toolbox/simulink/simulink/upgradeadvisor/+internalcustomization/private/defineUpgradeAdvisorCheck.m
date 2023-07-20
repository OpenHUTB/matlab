function defineUpgradeAdvisorCheck()




    check=ModelAdvisor.Check('com.mathworks.Simulink.UpgradeAdvisor.MAEntryPoint');
    check.Title=DAStudio.message('SimulinkUpgradeAdvisor:tasks:maTaskTitle');
    check.TitleTips=DAStudio.message('SimulinkUpgradeAdvisor:tasks:maTaskDescription');
    check.setCallbackFcn(@openUpgradeAdvisorCheck,'None','StyleOne');
    check.CSHParameters.MapKey='ma.simulink';
    check.CSHParameters.TopicID='UpgradeAdvisorMAEntryPoint';
    check.SupportLibrary=true;
    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.publish(check,'Simulink');

end


function results=openUpgradeAdvisorCheck(system)

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(false);

    status=UpgradeAdvisor.AlertStatus(system);
    pass=~status.getDisplayStatus();

    model=bdroot(system);
    a2=ModelAdvisor.Text(DAStudio.message('SimulinkUpgradeAdvisor:tasks:maTaskActionAdvice',model));
    a3=ModelAdvisor.Text(DAStudio.message('SimulinkUpgradeAdvisor:tasks:maTaskActionLink'));
    a3.setHyperlink(['matlab:upgradeadvisor(''',model,''')']);

    if(pass)
        ft.setSubResultStatus('pass');
        a1=ModelAdvisor.Text(DAStudio.message('SimulinkUpgradeAdvisor:tasks:maTaskPass'));
        p2=ModelAdvisor.Paragraph(a2);
        p3=ModelAdvisor.Paragraph(a3);
        ft.setSubResultStatusText([a1,p2,p3]);
    else
        ft.setSubResultStatus('warn');
        a1=ModelAdvisor.Text(DAStudio.message('SimulinkUpgradeAdvisor:tasks:maTaskWarning'));
        ft.setSubResultStatusText(a1);
        ft.setRecAction([a2,a3]);
    end

    results=ft;

    modelAdvisor=Simulink.ModelAdvisor.getModelAdvisor(system);
    modelAdvisor.setCheckResultStatus(pass);
end
