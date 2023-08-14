function[status,messageString]=PreApply(hThis)





    validateFunc=nesl_private('nesl_validatecomponentsource');
    [status,messageString,newComponentName]=validateFunc(hThis.ComponentName);
    hThis.ComponentName=newComponentName;



    if~status
        daRoot=DAStudio.ToolRoot;
        openDlgs=daRoot.getOpenDialogs(hThis.getDlgSrcObj);
        openDlgs(1).refresh();
    end



    ev=DAStudio.EventDispatcher;
    ev.broadcastEvent('ObjectStateChangedEvent',hThis.BlockHandle,'Component Block Change')

end
