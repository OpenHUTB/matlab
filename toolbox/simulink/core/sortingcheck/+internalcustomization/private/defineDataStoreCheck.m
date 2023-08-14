function rec=defineDataStoreCheck

    rec=ModelAdvisor.Check('com.mathworks.sorting.datastorecheck');
    rec.Title=DAStudio.message('Simulink:tools:MATitleDataStoreExecutionOrder');
    rec.TitleTips=DAStudio.message('Simulink:tools:MATitleTipDataStoreExecutionOrder');
    rec.setCallbackFcn(@dataStoreCheckStyleCallback,'DIY','DetailStyle');

    rec.setReportStyle('ModelAdvisor.Report.DefaultStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.DefaultStyle'});


    rec.DefaultSelection=false;

    rec.CSHParameters.MapKey='ma.simulink';


    rec.CSHParameters.TopicID='mataskbasedsorting';


    dataStoreAction=ModelAdvisor.Action;
    dataStoreAction.setCallbackFcn(@dataStoresActionCB);
    dataStoreAction.Name=DAStudio.message('Simulink:tools:MADataStoreExecutionOrderModify');
    dataStoreAction.Description=DAStudio.message('Simulink:tools:MADataStoreExecutionOrderAction');
    rec.setAction(dataStoreAction);