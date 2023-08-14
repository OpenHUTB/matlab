

function result=actionRapidAcceleratorSignalLogging(taskobj)



    result=ModelAdvisor.Paragraph();
    mdladvObj=taskobj.MAObj;



    system=bdroot(mdladvObj.System);
    set_param(system,'SignalLogging','on');

    result=DAStudio.message('ModelAdvisor:engine:MACheckRapidAcceleratorSignalLogging_Enabled');


