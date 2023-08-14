function defineJMAABModelAdvisorTasks()
    mdladvRoot=ModelAdvisor.Root;




    rec=ModelAdvisor.FactoryGroup('jmaab');
    rec.DisplayName=DAStudio.message('ModelAdvisor:styleguide:JMAABChecks');
    rec.Description=DAStudio.message('ModelAdvisor:styleguide:GroupJMAABchecks');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jmaab_overview';




    recNc=ModelAdvisor.FactoryGroup('JMAAB Naming Conventions');
    recNc.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABNamingConventionChecks');
    recNc.Description=DAStudio.message('ModelAdvisor:styleguide:NamingConventionsMAABchecks');
    recNc.CSHParameters.MapKey='ma.mw.jmaab';
    recNc.CSHParameters.TopicID='jmaab_naming_conventions_overview';

    recNc.addCheck('mathworks.jmaab.ar_0001');
    recNc.addCheck('mathworks.jmaab.ar_0002');
    recNc.addCheck('mathworks.jmaab.jc_0201');
    recNc.addCheck('mathworks.jmaab.jc_0211');
    recNc.addCheck('mathworks.jmaab.jc_0231');
    recNc.addCheck('mathworks.jmaab.jc_0222');
    recNc.addCheck('mathworks.jmaab.jc_0232');
    recNc.addCheck('mathworks.jmaab.jc_0241');
    recNc.addCheck('mathworks.jmaab.jc_0242');
    recNc.addCheck('mathworks.jmaab.jc_0243');
    recNc.addCheck('mathworks.jmaab.jc_0244');
    recNc.addCheck('mathworks.jmaab.jc_0245');
    recNc.addCheck('mathworks.jmaab.jc_0246');
    recNc.addCheck('mathworks.jmaab.jc_0247');

    rec.addFactoryGroup(recNc);




    recMa=ModelAdvisor.FactoryGroup('JMAAB Model Architecture');
    recMa.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABModelArchitectureChecks');
    recMa.Description=DAStudio.message('ModelAdvisor:styleguide:ModelArchitectureMAABchecks');
    recMa.CSHParameters.MapKey='ma.mw.jmaab';
    recMa.CSHParameters.TopicID='jmaab_model_architecture_overview';

    recMa.addCheck('mathworks.maab.db_0143');
    rec.addFactoryGroup(recMa);




    recMc=ModelAdvisor.FactoryGroup('JMAAB Model Configuration Options');
    recMc.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABModelConfigurationChecks');
    recMc.Description=DAStudio.message('ModelAdvisor:styleguide:ModelConfigurationOptionsMAABchecks');
    recMc.CSHParameters.MapKey='ma.mw.jmaab';
    recMc.CSHParameters.TopicID='jmaab_model_config_overview';

    recMc.addCheck('mathworks.maab.jc_0011');
    recMc.addCheck('mathworks.jmaab.jc_0806');
    rec.addFactoryGroup(recMc);




    recSim=ModelAdvisor.FactoryGroup('JMAAB Simulink');
    recSim.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkChecks');
    recSim.Description=DAStudio.message('ModelAdvisor:styleguide:SimulinkMAABchecks');
    recSim.CSHParameters.MapKey='ma.mw.jmaab';
    recSim.CSHParameters.TopicID='jmaab_simulink_overview';

    recSim.addCheck('mathworks.maab.na_0004');
    recSim.addCheck('mathworks.jmaab.db_0043');
    recSim.addCheck('mathworks.jmaab.db_0042');
    recSim.addCheck('mathworks.maab.db_0142');
    recSim.addCheck('mathworks.maab.jc_0061');
    recSim.addCheck('mathworks.maab.db_0140');
    recSim.addCheck('mathworks.jmaab.jc_0281');
    recSim.addCheck('mathworks.jmaab.db_0081');
    recSim.addCheck('mathworks.maab.jc_0141');
    recSim.addCheck('mathworks.maab.jc_0131');
    recSim.addCheck('mathworks.jmaab.db_0112');
    recSim.addCheck('mathworks.maab.db_0110');
    recSim.addCheck('mathworks.jmaab.jc_0008');
    recSim.addCheck('mathworks.jmaab.jc_0009');
    recSim.addCheck('mathworks.jmaab.jc_0627');
    recSim.addCheck('mathworks.jmaab.jc_0630');
    recSim.addCheck('mathworks.jmaab.jc_0643');
    recSim.addCheck('mathworks.jmaab.jc_0650');
    recSim.addCheck('mathworks.jmaab.jc_0611');
    recSim.addCheck('mathworks.jmaab.jc_0642');
    recSim.addCheck('mathworks.jmaab.jc_0644');
    recSim.addCheck('mathworks.jmaab.jc_0628');
    recSim.addCheck('mathworks.jmaab.jc_0659');
    recSim.addCheck('mathworks.jmaab.jc_0623');
    recSim.addCheck('mathworks.jmaab.jc_0110');
    recSim.addCheck('mathworks.jmaab.jc_0604');
    recSim.addCheck('mathworks.jmaab.jc_0610');
    recSim.addCheck('mathworks.jmaab.jc_0621');
    recSim.addCheck('mathworks.jmaab.jc_0645');
    recSim.addCheck('mathworks.jmaab.jc_0656');
    recSim.addCheck('mathworks.jmaab.jc_0626');
    recSim.addCheck('mathworks.jmaab.jc_0622');
    recSim.addCheck('mathworks.jmaab.jc_0640');
    recSim.addCheck('mathworks.jmaab.jc_0653');
    recSim.addCheck('mathworks.jmaab.jc_0800');
    recSim.addCheck('mathworks.jmaab.jc_0791');
    recSim.addCheck('mathworks.jmaab.jc_0792');
    recSim.addCheck('mathworks.jmaab.jc_0651');
    recSim.addCheck('mathworks.jmaab.jc_0603');
    recSim.addCheck('mathworks.jmaab.jc_0602');
    recSim.addCheck('mathworks.jmaab.jc_0641');
    recSim.addCheck('mathworks.jmaab.jc_0121');
    recSim.addCheck('mathworks.jmaab.db_0097');
    recSim.addCheck('mathworks.jmaab.na_0020');
    recSim.addCheck('mathworks.jmaab.jc_0624');
    recSim.addCheck('mathworks.jmaab.jc_0161');
    recSim.addCheck('mathworks.jmaab.na_0002');
    recSim.addCheck('mathworks.jmaab.db_0141');
    recSim.addCheck('mathworks.jmaab.na_0010');
    recSim.addCheck('mathworks.jmaab.jc_0171');
    recSim.addCheck('mathworks.jmaab.db_0146');
    recSim.addCheck('mathworks.jmaab.db_0032');
    recSim.addCheck('mathworks.maab.na_0011');
    recSim.addCheck('mathworks.jmaab.jc_0794');
    recSim.addCheck('mathworks.maab.na_0037');
    recSim.addCheck('mathworks.maab.na_0003');
    recSim.addCheck('mathworks.maab.jc_0081');
    recSim.addCheck('mathworks.maab.na_0036');
    rec.addFactoryGroup(recSim);




    recSf=ModelAdvisor.FactoryGroup('JMAAB Stateflow');
    recSf.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABStateflowChecks');
    recSf.Description=DAStudio.message('ModelAdvisor:styleguide:StateflowMAABchecks');
    recSf.CSHParameters.MapKey='ma.mw.jmaab';
    recSf.CSHParameters.TopicID='jmaab_stateflow_overview';

    recSf.addCheck('mathworks.jmaab.db_0132');
    recSf.addCheck('mathworks.maab.jc_0511');
    recSf.addCheck('mathworks.jmaab.jc_0501');
    recSf.addCheck('mathworks.jmaab.jc_0531');
    recSf.addCheck('mathworks.jmaab.db_0125');
    recSf.addCheck('mathworks.jmaab.db_0127');
    recSf.addCheck('mathworks.maab.jm_0011');
    recSf.addCheck('mathworks.jmaab.na_0001');
    recSf.addCheck('mathworks.maab.jc_0451');
    recSf.addCheck('mathworks.jmaab.jc_0738');
    recSf.addCheck('mathworks.jmaab.jc_0655');
    recSf.addCheck('mathworks.jmaab.jc_0763');
    recSf.addCheck('mathworks.jmaab.jc_0772');
    recSf.addCheck('mathworks.jmaab.jc_0732');
    recSf.addCheck('mathworks.jmaab.jc_0730');
    recSf.addCheck('mathworks.jmaab.jc_0752');
    recSf.addCheck('mathworks.jmaab.jc_0762');
    recSf.addCheck('mathworks.jmaab.jc_0753');
    recSf.addCheck('mathworks.jmaab.jc_0701');
    recSf.addCheck('mathworks.jmaab.jc_0731');
    recSf.addCheck('mathworks.jmaab.jc_0712');
    recSf.addCheck('mathworks.jmaab.jc_0734');
    recSf.addCheck('mathworks.jmaab.jc_0700');
    recSf.addCheck('mathworks.jmaab.jc_0741');
    recSf.addCheck('mathworks.jmaab.jc_0760');
    recSf.addCheck('mathworks.jmaab.jc_0721');
    recSf.addCheck('mathworks.jmaab.jc_0722');
    recSf.addCheck('mathworks.jmaab.jc_0736');
    recSf.addCheck('mathworks.jmaab.jc_0739');
    recSf.addCheck('mathworks.jmaab.jc_0751');
    recSf.addCheck('mathworks.jmaab.jc_0797');
    recSf.addCheck('mathworks.jmaab.jc_0770');
    recSf.addCheck('mathworks.jmaab.jc_0790');
    recSf.addCheck('mathworks.jmaab.jc_0795');
    recSf.addCheck('mathworks.jmaab.jc_0796');
    recSf.addCheck('mathworks.jmaab.jc_0723');
    recSf.addCheck('mathworks.jmaab.jc_0733');
    recSf.addCheck('mathworks.jmaab.jc_0702');
    recSf.addCheck('mathworks.jmaab.jc_0771');
    recSf.addCheck('mathworks.jmaab.jc_0775');
    recSf.addCheck('mathworks.jmaab.jc_0802');
    recSf.addCheck('mathworks.jmaab.jc_0804');
    recSf.addCheck('mathworks.jmaab.jc_0740');
    recSf.addCheck('mathworks.jmaab.jc_0801');

    recSf.addCheck('mathworks.jmaab.jc_0773');
    recSf.addCheck('mathworks.jmaab.jc_0774');
    recSf.addCheck('mathworks.jmaab.db_0126');
    recSf.addCheck('mathworks.jmaab.db_0129');
    recSf.addCheck('mathworks.jmaab.jm_0012');
    recSf.addCheck('mathworks.jmaab.na_0042');
    recSf.addCheck('mathworks.jmaab.db_0137');
    recSf.addCheck('mathworks.maab.jc_0481');
    recSf.addCheck('mathworks.maab.na_0039');
    rec.addFactoryGroup(recSf);




    recEml=ModelAdvisor.FactoryGroup('JMAAB MATLAB Functions');
    recEml.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAAB_MFBChecksName');
    recEml.Description=DAStudio.message('ModelAdvisor:styleguide:MAAB_MFBChecksDescription');
    recEml.CSHParameters.MapKey='ma.mw.jmaab';
    recEml.CSHParameters.TopicID='jmaab_model_architecture_overview';

    recEml.addCheck('mathworks.maab.na_0034');
    recEml.addCheck('mathworks.maab.na_0024');
    recEml.addCheck('mathworks.maab.na_0021');
    recEml.addCheck('mathworks.maab.na_0031');
    rec.addFactoryGroup(recEml);


    mdladvRoot.publish(recNc);
    mdladvRoot.publish(recMa);
    mdladvRoot.publish(recMc);
    mdladvRoot.publish(recSf);
    mdladvRoot.publish(recEml);
    mdladvRoot.publish(recSim);
    mdladvRoot.publish(rec);
end
