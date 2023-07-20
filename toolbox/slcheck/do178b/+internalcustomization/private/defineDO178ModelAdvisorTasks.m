function defineDO178ModelAdvisorTasks

    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.FactoryGroup('do178');
    rec.DisplayName=DAStudio.message('ModelAdvisor:do178b:TaskGroupTitle');
    rec.Description=DAStudio.message('ModelAdvisor:do178b:TaskGroupTip');
    rec.addCheck('mathworks.do178.MdlChecksum');

    rec9=ModelAdvisor.Common.defineHISLTasks('do178',false);
    rec.addFactoryGroup(rec9);
    mdladvRoot.publish(rec9);

    rec3=ModelAdvisor.FactoryGroup('DO178B:Simulink');
    rec3.DisplayName=DAStudio.message('ModelAdvisor:do178b:SimulinkGroupName');
    rec3.Description=DAStudio.message('ModelAdvisor:do178b:SimulinkGroupDescription');
    rec3.addCheck('mathworks.design.UnconnectedLinesPorts');
    rec.addFactoryGroup(rec3);

    rec5=ModelAdvisor.FactoryGroup('DO178B:LibraryLinks');
    rec5.DisplayName=DAStudio.message('ModelAdvisor:do178b:LibraryLinksGroupName');
    rec5.Description=DAStudio.message('ModelAdvisor:do178b:LibraryLinksGroupDescription');
    if~slfeature('hisl_0075')
        rec5.addCheck('mathworks.design.DisabledLibLinks');
        rec5.addCheck('mathworks.design.ParameterizedLibLinks');
    end
    rec5.addCheck('mathworks.design.UnresolvedLibLinks');
    rec.addFactoryGroup(rec5);

    if~slfeature('hisl_0072')
        rec6=ModelAdvisor.FactoryGroup('DO178B:MdlRef');
        rec6.DisplayName=DAStudio.message('ModelAdvisor:do178b:MdlRefGroupName');
        rec6.Description=DAStudio.message('ModelAdvisor:do178b:MdlRefGroupDescription');

        rec6.addCheck('mathworks.design.ParamTunabilityIgnored');
        rec.addFactoryGroup(rec6);
    end

    rec1=ModelAdvisor.FactoryGroup('DO178B:Requirements');
    rec1.DisplayName=DAStudio.message('ModelAdvisor:do178b:RequirementsGroupName');
    rec1.Description=DAStudio.message('ModelAdvisor:do178b:RequirementsGroupDescription');
    rec1.addCheck('mathworks.req.Identifiers');
    rec1.addCheck('mathworks.req.Documents');
    rec1.addCheck('mathworks.req.Paths');
    rec1.addCheck('mathworks.req.Labels');
    rec.addFactoryGroup(rec1);

    if~slfeature('RevisitHIGuidelines')
        rec8=ModelAdvisor.FactoryGroup('DO178B:SimulinkCoder');
        rec8.DisplayName=DAStudio.message('ModelAdvisor:do178b:SlCoderGroupName');
        rec8.Description=DAStudio.message('ModelAdvisor:do178b:SlCoderGroupDescription');
        rec8.CSHParameters.MapKey='ma.simulink';
        rec8.CSHParameters.TopicID='SimulinkCoderGroup';
        rec8.addCheck('mathworks.codegen.HWImplementation');
        rec.addFactoryGroup(rec8);
    end

    rec7=ModelAdvisor.FactoryGroup('DO178B:BugReport');
    rec7.DisplayName=DAStudio.message('ModelAdvisor:do178b:BugReportGroupName');
    rec7.Description=DAStudio.message('ModelAdvisor:do178b:BugReportGroupDescription');
    rec7.CSHParameters.MapKey='ma.do178b';
    rec7.CSHParameters.TopicID='BugReportGroup';

    rec7.addCheck('doqualkits.bugreport.DO_Qualification_Kit');
    rec7.addCheck('doqualkits.bugreport.Embedded_Coder');
    rec7.addCheck('doqualkits.bugreport.Polyspace_Code_Prover');
    rec7.addCheck('doqualkits.bugreport.Polyspace_Code_Prover_Server');
    rec7.addCheck('doqualkits.bugreport.Polyspace_Bug_Finder');
    rec7.addCheck('doqualkits.bugreport.Polyspace_Bug_Finder_Server');
    rec7.addCheck('doqualkits.bugreport.Simulink_Code_Inspector');
    rec7.addCheck('doqualkits.bugreport.Simulink_Report_Generator');
    rec7.addCheck('doqualkits.bugreport.Simulink_Check');
    rec7.addCheck('doqualkits.bugreport.Simulink_Coverage');
    rec7.addCheck('doqualkits.bugreport.Simulink_Test');
    rec7.addCheck('doqualkits.bugreport.Simulink_Design_Verifier');
    rec7.addCheck('doqualkits.bugreport.Simulink');
    rec.addFactoryGroup(rec7);

    mdladvRoot.publish(rec1);
    mdladvRoot.publish(rec3);
    mdladvRoot.publish(rec5);
    if~slfeature('hisl_0072')
        mdladvRoot.publish(rec6);
    end
    mdladvRoot.publish(rec7);
    if~slfeature('RevisitHIGuidelines')
        mdladvRoot.publish(rec8);
    end
    mdladvRoot.publish(rec);

end
