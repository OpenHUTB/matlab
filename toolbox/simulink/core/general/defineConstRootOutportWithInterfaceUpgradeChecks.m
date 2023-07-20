function defineConstRootOutportWithInterfaceUpgradeChecks






    check=ModelAdvisor.Check('mathworks.design.CheckConstRootOutportWithInterfaceUpgrade');
    check.setCallbackFcn(@locExecCheckForConstRootOutportWithInterfaceUpgrade,'PostCompile','StyleOne');
    check.Title=DAStudio.message('ModelAdvisor:engine:TitleCheckIdentConstRootOutportWithInterfaceUpgrade');
    check.CSHParameters.MapKey='ma.simulink';
    check.CSHParameters.TopicID='MACheckConstRootOutportWithInterfaceUpgrade';
    check.SupportLibrary=false;



    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(check);

end




function[ResultDescription]=locExecCheckForConstRootOutportWithInterfaceUpgrade(system)


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);


    model=bdroot(system);
    [bResultStatus,ResultDescription]=ModelAdvisor.Common.modelAdvisorCheck_ConstRootOutportWithInterfaceUpgrade(system,model);


    if bResultStatus
        mdladvObj.setCheckResultStatus(true);
    end

end




