function createUI(h)




    createActions(h);
    customize(h);
    createMenu(h);

    tb=createOverrideModeCtrl(h);
    createToolbar(h,tb);
    createToolbarLoggingText(h,tb);


    action=h.getAction('VIEW_LINKS');
    h.addTreeAction(action);
    action=h.getAction('VIEW_MASKS');
    h.addTreeAction(action);
    action=h.getAction('VIEW_ALL_SUBSYS');
    h.addTreeAction(action);


    h.setStatusMessage(...
    DAStudio.message('Simulink:Logging:SigLogDlgReadyStatusMsg'));

end
