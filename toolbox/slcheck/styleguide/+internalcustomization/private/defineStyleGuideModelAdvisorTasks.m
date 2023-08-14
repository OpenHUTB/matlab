


function defineStyleGuideModelAdvisorTasks




    mdladvRoot=ModelAdvisor.Root;


    rec=ModelAdvisor.FactoryGroup('maab');
    rec.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABChecks');
    rec.Description=DAStudio.message('ModelAdvisor:styleguide:GroupMAABchecks');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='mab_overview';


    rec1=ModelAdvisor.FactoryGroup('MAB Naming Conventions');
    rec1.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABNamingConventionChecks');
    rec1.Description=DAStudio.message('ModelAdvisor:styleguide:NamingConventionsMAABchecks');
    rec1.CSHParameters.MapKey='ma.mw.jmaab';
    rec1.CSHParameters.TopicID='mab_naming_conventions_overview';


    rec21=ModelAdvisor.FactoryGroup('MAB Naming Conventions General');
    rec21.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABNamingConventionGeneral');
    rec21.Description=DAStudio.message('ModelAdvisor:styleguide:MAABNamingConventionGeneralDescription');
    rec21.CSHParameters.MapKey='ma.mw.jmaab';
    rec21.CSHParameters.TopicID='mab_naming_conventions_overview';

    rec21.addCheck('mathworks.jmaab.ar_0001');
    rec21.addCheck('mathworks.jmaab.ar_0002');
    rec21.addCheck('mathworks.jmaab.jc_0241');
    rec21.addCheck('mathworks.jmaab.jc_0242');
    rec1.addFactoryGroup(rec21);


    rec22=ModelAdvisor.FactoryGroup('MAB Naming Conventions Content');
    rec22.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABNamingConventionContent');
    rec22.Description=DAStudio.message('ModelAdvisor:styleguide:MAABNamingConventionContentDescription');
    rec22.CSHParameters.MapKey='ma.mw.jmaab';
    rec22.CSHParameters.TopicID='mab_naming_conventions_overview';

    rec22.addCheck('mathworks.jmaab.jc_0201');
    rec22.addCheck('mathworks.jmaab.jc_0211');
    rec22.addCheck('mathworks.jmaab.jc_0231');
    rec22.addCheck('mathworks.jmaab.jc_0243');
    rec22.addCheck('mathworks.jmaab.jc_0247');
    rec22.addCheck('mathworks.jmaab.jc_0244');
    rec22.addCheck('mathworks.jmaab.jc_0222');
    rec22.addCheck('mathworks.jmaab.jc_0232');
    rec22.addCheck('mathworks.jmaab.jc_0245');
    rec22.addCheck('mathworks.jmaab.jc_0246');
    rec22.addCheck('mathworks.jmaab.jc_0795');
    rec22.addCheck('mathworks.jmaab.jc_0796');
    rec22.addCheck('mathworks.jmaab.jc_0791');
    rec22.addCheck('mathworks.jmaab.jc_0792');
    rec22.addCheck('mathworks.jmaab.jc_0700');
    rec22.addCheck('mathworks.maab.na_0019');
    rec1.addFactoryGroup(rec22);

    rec.addFactoryGroup(rec1);


    rec2=ModelAdvisor.FactoryGroup('MAB Simulink');
    rec2.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkChecks');
    rec2.Description=DAStudio.message('ModelAdvisor:styleguide:SimulinkMAABchecks');
    rec2.CSHParameters.MapKey='ma.mw.jmaab';
    rec2.CSHParameters.TopicID='mab_simulink_overview';


    rec3=ModelAdvisor.FactoryGroup('MAB Simulink Configuration Parameters');
    rec3.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkConfigParam');
    rec3.Description=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkConfigParamDescription');
    rec3.CSHParameters.MapKey='ma.mw.jmaab';
    rec3.CSHParameters.TopicID='mab_simulink_overview';

    rec3.addCheck('mathworks.maab.jc_0011');
    rec3.addCheck('mathworks.jmaab.jc_0642');
    rec3.addCheck('mathworks.jmaab.jc_0806');
    rec3.addCheck('mathworks.maab.jc_0021');
    rec2.addFactoryGroup(rec3);


    rec4=ModelAdvisor.FactoryGroup('MAB Simulink Diagram Appearance');
    rec4.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkDiagramAppear');
    rec4.Description=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkDiagramAppearDescription');
    rec4.CSHParameters.MapKey='ma.mw.jmaab';
    rec4.CSHParameters.TopicID='mab_simulink_overview';

    rec4.addCheck('mathworks.maab.na_0004');
    rec4.addCheck('mathworks.jmaab.db_0043');
    rec4.addCheck('mathworks.maab.db_0142');
    rec4.addCheck('mathworks.maab.jc_0061');
    rec4.addCheck('mathworks.maab.db_0140');
    rec4.addCheck('mathworks.jmaab.jc_0603');
    rec4.addCheck('mathworks.jmaab.jc_0604');
    rec4.addCheck('mathworks.jmaab.db_0081');
    rec4.addCheck('mathworks.jmaab.db_0032');
    rec4.addCheck('mathworks.jmaab.db_0141');
    rec4.addCheck('mathworks.maab.db_0110');
    rec4.addCheck('mathworks.jmaab.jc_0171');
    rec4.addCheck('mathworks.jmaab.jc_0602');
    rec4.addCheck('mathworks.jmaab.jc_0281');
    rec4.addCheck('mathworks.maab.db_0143');
    rec4.addCheck('mathworks.jmaab.jc_0653');
    rec4.addCheck('mathworks.maab.hd_0001');
    rec2.addFactoryGroup(rec4);


    rec5=ModelAdvisor.FactoryGroup('MAB Simulink Signal');
    rec5.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkSignal');
    rec5.Description=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkSignalDescription');
    rec5.CSHParameters.MapKey='ma.mw.jmaab';
    rec5.CSHParameters.TopicID='mab_simulink_overview';

    rec5.addCheck('mathworks.jmaab.na_0010');
    rec5.addCheck('mathworks.jmaab.jc_0008');
    rec5.addCheck('mathworks.jmaab.jc_0009');
    rec5.addCheck('mathworks.jmaab.db_0097');
    rec5.addCheck('mathworks.maab.na_0008');
    rec5.addCheck('mathworks.maab.na_0009');
    rec2.addFactoryGroup(rec5);


    rec6=ModelAdvisor.FactoryGroup('MAB Simulink Block Consistency');
    rec6.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkBlockConsistency');
    rec6.Description=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkBlockConsistencyDescription');
    rec6.CSHParameters.MapKey='ma.mw.jmaab';
    rec6.CSHParameters.TopicID='mab_simulink_overview';

    rec6.addCheck('mathworks.jmaab.db_0112');
    rec6.addCheck('mathworks.jmaab.jc_0110');
    rec6.addCheck('mathworks.jmaab.jc_0645');
    rec6.addCheck('mathworks.jmaab.jc_0641');
    rec6.addCheck('mathworks.jmaab.jc_0643');
    rec6.addCheck('mathworks.jmaab.jc_0644');
    rec2.addFactoryGroup(rec6);


    rec7=ModelAdvisor.FactoryGroup('MAB Simulink Condition Subsystem');
    rec7.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkConditionSubsys');
    rec7.Description=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkConditionSubsysDescription');
    rec7.CSHParameters.MapKey='ma.mw.jmaab';
    rec7.CSHParameters.TopicID='mab_simulink_overview';

    rec7.addCheck('mathworks.jmaab.db_0146');
    rec7.addCheck('mathworks.jmaab.jc_0640');
    rec7.addCheck('mathworks.jmaab.jc_0659');
    rec7.addCheck('mathworks.maab.na_0003');
    rec7.addCheck('mathworks.jmaab.jc_0656');
    rec2.addFactoryGroup(rec7);


    rec8=ModelAdvisor.FactoryGroup('MAB Simulink Operation Blocks');
    rec8.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkOperationBlocks');
    rec8.Description=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkOperationBlocksDescription');
    rec8.CSHParameters.MapKey='ma.mw.jmaab';
    rec8.CSHParameters.TopicID='mab_simulink_overview';

    rec8.addCheck('mathworks.jmaab.na_0002');
    rec8.addCheck('mathworks.jmaab.jc_0121');
    rec8.addCheck('mathworks.jmaab.jc_0610');
    rec8.addCheck('mathworks.jmaab.jc_0611');
    rec8.addCheck('mathworks.jmaab.jc_0622');
    rec8.addCheck('mathworks.jmaab.jc_0621');
    rec8.addCheck('mathworks.maab.jc_0131');
    rec8.addCheck('mathworks.jmaab.jc_0800');
    rec8.addCheck('mathworks.jmaab.jc_0626');
    rec8.addCheck('mathworks.jmaab.jc_0623');
    rec8.addCheck('mathworks.jmaab.jc_0624');
    rec8.addCheck('mathworks.jmaab.jc_0627');
    rec8.addCheck('mathworks.jmaab.jc_0628');
    rec8.addCheck('mathworks.jmaab.jc_0651');
    rec8.addCheck('mathworks.jmaab.jc_0794');
    rec2.addFactoryGroup(rec8);


    rec9=ModelAdvisor.FactoryGroup('MAB Simulink Other Blocks');
    rec9.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkOtherBlocks');
    rec9.Description=DAStudio.message('ModelAdvisor:styleguide:MAABSimulinkOtherBlocksDescription');
    rec9.CSHParameters.MapKey='ma.mw.jmaab';
    rec9.CSHParameters.TopicID='mab_simulink_overview';

    rec9.addCheck('mathworks.jmaab.db_0042');
    rec9.addCheck('mathworks.maab.jc_0081');
    rec9.addCheck('mathworks.maab.na_0011');
    rec9.addCheck('mathworks.jmaab.jc_0161');
    rec9.addCheck('mathworks.maab.jc_0141');
    rec9.addCheck('mathworks.jmaab.jc_0650');
    rec9.addCheck('mathworks.jmaab.jc_0630');
    rec9.addCheck('mathworks.jmaab.na_0020');
    rec9.addCheck('mathworks.maab.na_0036');
    rec9.addCheck('mathworks.maab.na_0037');
    rec2.addFactoryGroup(rec9);


    rec.addFactoryGroup(rec2);



    rec10=ModelAdvisor.FactoryGroup('MAB Stateflow');
    rec10.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABStateflowChecks');
    rec10.Description=DAStudio.message('ModelAdvisor:styleguide:StateflowMAABchecks');
    rec10.CSHParameters.MapKey='ma.mw.jmaab';
    rec10.CSHParameters.TopicID='mab_stateflow_overview';


    rec11=ModelAdvisor.FactoryGroup('MAB Stateflow Block Data Event');
    rec11.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABStateflowBlockDataEvent');
    rec11.Description=DAStudio.message('ModelAdvisor:styleguide:MAABStateflowBlockDataEventDescription');
    rec11.CSHParameters.MapKey='ma.mw.jmaab';
    rec11.CSHParameters.TopicID='mab_stateflow_overview';

    rec11.addCheck('mathworks.maab.db_0123');
    rec11.addCheck('mathworks.jmaab.jc_0712');
    rec11.addCheck('mathworks.jmaab.db_0125');
    rec11.addCheck('mathworks.jmaab.jc_0701');
    rec11.addCheck('mathworks.jmaab.jc_0722');
    rec11.addCheck('mathworks.jmaab.db_0126');
    rec10.addFactoryGroup(rec11);


    rec12=ModelAdvisor.FactoryGroup('MAB Stateflow Diagram');
    rec12.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABStateflowDiagram');
    rec12.Description=DAStudio.message('ModelAdvisor:styleguide:MAABStateflowDiagramDescription');
    rec12.CSHParameters.MapKey='ma.mw.jmaab';
    rec12.CSHParameters.TopicID='mab_stateflow_overview';

    rec12.addCheck('mathworks.jmaab.jc_0797');
    rec12.addCheck('mathworks.jmaab.db_0137');
    rec12.addCheck('mathworks.jmaab.jc_0721');
    rec12.addCheck('mathworks.jmaab.db_0129');
    rec12.addCheck('mathworks.jmaab.jc_0531');
    rec12.addCheck('mathworks.jmaab.jc_0723');
    rec12.addCheck('mathworks.jmaab.jc_0751');
    rec12.addCheck('mathworks.jmaab.jc_0760');
    rec12.addCheck('mathworks.jmaab.jc_0763');
    rec12.addCheck('mathworks.jmaab.jc_0762');
    rec12.addCheck('mathworks.jmaab.db_0132');
    rec12.addCheck('mathworks.jmaab.jc_0773');
    rec12.addCheck('mathworks.jmaab.jc_0775');
    rec12.addCheck('mathworks.jmaab.jc_0738');
    rec10.addFactoryGroup(rec12);


    rec13=ModelAdvisor.FactoryGroup('MAB Stateflow Condition Transition Action');
    rec13.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABStateflowConditionTransition');
    rec13.Description=DAStudio.message('ModelAdvisor:styleguide:MAABStateflowConditionTransitionDescription');
    rec13.CSHParameters.MapKey='ma.mw.jmaab';
    rec13.CSHParameters.TopicID='mab_stateflow_overview';

    rec13.addCheck('mathworks.jmaab.jc_0790');
    rec13.addCheck('mathworks.jmaab.jc_0702');
    rec13.addCheck('mathworks.maab.jm_0011');

    rec13.addCheck('mathworks.jmaab.jm_0012');
    rec13.addCheck('mathworks.jmaab.jc_0733');
    rec13.addCheck('mathworks.jmaab.jc_0734');
    rec13.addCheck('mathworks.jmaab.jc_0740');
    rec13.addCheck('mathworks.jmaab.jc_0741');
    rec13.addCheck('mathworks.jmaab.jc_0772');
    rec13.addCheck('mathworks.jmaab.jc_0753');
    rec13.addCheck('mathworks.jmaab.db_0127');
    rec13.addCheck('mathworks.maab.jc_0481');
    rec13.addCheck('mathworks.jmaab.na_0001');
    rec13.addCheck('mathworks.jmaab.jc_0655');
    rec13.addCheck('mathworks.maab.jc_0451');
    rec13.addCheck('mathworks.jmaab.jc_0802');

    rec13.addCheck('mathworks.jmaab.jc_0804');
    rec10.addFactoryGroup(rec13);


    rec14=ModelAdvisor.FactoryGroup('MAB Stateflow Label');
    rec14.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABStateflowLabel');
    rec14.Description=DAStudio.message('ModelAdvisor:styleguide:MAABStateflowLabelDescription');
    rec14.CSHParameters.MapKey='ma.mw.jmaab';
    rec14.CSHParameters.TopicID='mab_stateflow_overview';

    rec14.addCheck('mathworks.jmaab.jc_0732');
    rec14.addCheck('mathworks.jmaab.jc_0730');
    rec14.addCheck('mathworks.jmaab.jc_0731');
    rec14.addCheck('mathworks.jmaab.jc_0501');
    rec14.addCheck('mathworks.jmaab.jc_0736');
    rec14.addCheck('mathworks.jmaab.jc_0739');
    rec14.addCheck('mathworks.jmaab.jc_0770');
    rec14.addCheck('mathworks.jmaab.jc_0771');
    rec14.addCheck('mathworks.jmaab.jc_0752');
    rec14.addCheck('mathworks.jmaab.jc_0774');
    rec10.addFactoryGroup(rec14);


    rec15=ModelAdvisor.FactoryGroup('MAB Stateflow Miscellaneous');
    rec15.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABStateflowMiscellaneous');
    rec15.Description=DAStudio.message('ModelAdvisor:styleguide:MAABStateflowMiscellaneousDescription');
    rec15.CSHParameters.MapKey='ma.mw.jmaab';
    rec15.CSHParameters.TopicID='mab_stateflow_overview';

    rec15.addCheck('mathworks.maab.jc_0511');

    rec15.addCheck('mathworks.jmaab.na_0042');
    rec15.addCheck('mathworks.maab.na_0039');
    rec10.addFactoryGroup(rec15);


    rec.addFactoryGroup(rec10);


    rec16=ModelAdvisor.FactoryGroup('MAB MATLAB');
    rec16.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABMATLAB');
    rec16.Description=DAStudio.message('ModelAdvisor:styleguide:MAABMATLABDescription');
    rec16.CSHParameters.MapKey='ma.mw.jmaab';
    rec16.CSHParameters.TopicID='mab_matlab_overview';













    rec18=ModelAdvisor.FactoryGroup('MAB MATLAB Data and Operations');
    rec18.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABMATLABData');
    rec18.Description=DAStudio.message('ModelAdvisor:styleguide:MAABMATLABDataDescription');
    rec18.CSHParameters.MapKey='ma.mw.jmaab';
    rec18.CSHParameters.TopicID='mab_matlab_overview';

    rec18.addCheck('mathworks.maab.na_0024');
    rec18.addCheck('mathworks.maab.na_0031');
    rec18.addCheck('mathworks.maab.na_0034');
    rec16.addFactoryGroup(rec18);


    rec19=ModelAdvisor.FactoryGroup('MAB MATLAB Usage');
    rec19.DisplayName=DAStudio.message('ModelAdvisor:styleguide:MAABMATLABUsage');
    rec19.Description=DAStudio.message('ModelAdvisor:styleguide:MAABMATLABUsageDescription');
    rec19.CSHParameters.MapKey='ma.mw.jmaab';
    rec19.CSHParameters.TopicID='mab_matlab_overview';
    rec19.addCheck('mathworks.maab.na_0016');
    rec19.addCheck('mathworks.maab.na_0017');
    rec19.addCheck('mathworks.maab.na_0018');
    rec19.addCheck('mathworks.maab.na_0021');
    rec19.addCheck('mathworks.maab.na_0022');
    rec19.addCheck('mathworks.jmaab.jc_0801');
    rec16.addFactoryGroup(rec19);

    rec.addFactoryGroup(rec16);


    mdladvRoot.publish(rec);
    mdladvRoot.publish(rec21);
    mdladvRoot.publish(rec22);

    mdladvRoot.publish(rec3);
    mdladvRoot.publish(rec4);
    mdladvRoot.publish(rec5);
    mdladvRoot.publish(rec6);
    mdladvRoot.publish(rec7);
    mdladvRoot.publish(rec8);
    mdladvRoot.publish(rec9);

    mdladvRoot.publish(rec11);
    mdladvRoot.publish(rec12);
    mdladvRoot.publish(rec13);
    mdladvRoot.publish(rec14);
    mdladvRoot.publish(rec15);


    mdladvRoot.publish(rec18);
    mdladvRoot.publish(rec19);

    mdladvRoot.publish(rec16);
    mdladvRoot.publish(rec1);
    mdladvRoot.publish(rec2);
    mdladvRoot.publish(rec10);
