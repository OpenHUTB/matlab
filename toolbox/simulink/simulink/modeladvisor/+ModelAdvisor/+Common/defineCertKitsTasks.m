function rec=defineCertKitsTasks(tagName)

    rec=ModelAdvisor.FactoryGroup([tagName,':BugReport']);
    rec.DisplayName=DAStudio.message('ModelAdvisor:iec61508:BugReportGroupName');
    rec.Description=DAStudio.message('ModelAdvisor:iec61508:BugReportGroupDescription');
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='BugReportGroup';

    rec.addCheck('ieccertkits.bugreport.Embedded_Coder');
    rec.addCheck('ieccertkits.bugreport.IEC_Certification_Kit');
    rec.addCheck('ieccertkits.bugreport.Polyspace_Code_Prover');
    rec.addCheck('ieccertkits.bugreport.Polyspace_Bug_Finder');
    rec.addCheck('ieccertkits.bugreport.Polyspace_Code_Prover_Server');
    rec.addCheck('ieccertkits.bugreport.Polyspace_Bug_Finder_Server');
    rec.addCheck('ieccertkits.bugreport.Simulink_Design_Verifier');
    rec.addCheck('ieccertkits.bugreport.Simulink_PLC_Coder');
    rec.addCheck('ieccertkits.bugreport.Simulink_Check');
    rec.addCheck('ieccertkits.bugreport.Simulink_Coverage');
    rec.addCheck('ieccertkits.bugreport.Simulink_Test');
    rec.addCheck('ieccertkits.bugreport.AUTOSAR_Blockset');
    rec.addCheck('ieccertkits.bugreport.HDL_Coder');

end