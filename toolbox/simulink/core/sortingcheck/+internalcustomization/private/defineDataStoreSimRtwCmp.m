function rec=defineDataStoreSimRtwCmp()

    rec=ModelAdvisor.Check('mathworks.design.datastoresimrtwcmp');
    rec.Title=DAStudio.message('Simulink:tools:MATitleDataStoreRTWExecutionOrder');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitleTipDataStoreRTWExecutionOrder');
    rec.setCallbackFcn(@dataStoreCheckStyleCallback,'DIY','DetailStyle');

    rec.setReportStyle('ModelAdvisor.Report.DefaultStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.DefaultStyle'});


    rec.DefaultSelection=false;

    rec.CSHParameters.MapKey='ma.rtw';


    rec.CSHParameters.TopicID='datastoreexecutionrtw';


    dataStoreAction=ModelAdvisor.Action;
    dataStoreAction.setCallbackFcn(@dataStoresActionCB);
    dataStoreAction.Name=DAStudio.message('Simulink:tools:MADataStoreRTWExecutionOrderModify');
    dataStoreAction.Description=DAStudio.message('Simulink:tools:MADataStoreRTWExecutionOrderAction');
    rec.setAction(dataStoreAction);
