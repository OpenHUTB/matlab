function createMenu(h)




    am=DAStudio.ActionManager;

    m=locCreateMenuFile(h,am);
    am.addSubMenu(h,m,...
    DAStudio.message('Simulink:Logging:SigLogDlgMenuFile'));

    m=locCreateMenuView(h,am);
    am.addSubMenu(h,m,...
    DAStudio.message('Simulink:Logging:SigLogDlgMenuView'));

    m=locCreateMenuHelp(h,am);
    am.addSubMenu(h,m,...
    DAStudio.message('Simulink:Logging:SigLogDlgMenuHelp'));

end


function m=locCreateMenuFile(h,am)

    m=am.createPopupMenu(h);

    action=h.getAction('FILE_CLOSE');
    m.addMenuItem(action);

end


function m=locCreateMenuView(h,am)

    m=am.createPopupMenu(h);

    action=h.getAction('VIEW_MASKS_MENU');
    m.addMenuItem(action);

    action=h.getAction('VIEW_LINKS_MENU');
    m.addMenuItem(action);

    action=h.getAction('VIEW_ALL_SUBSYS_MENU');
    m.addMenuItem(action);

    m.addSeparator;
    action=h.getAction('VIEW_CONFIG_PARAMS');
    m.addMenuItem(action);
end


function m=locCreateMenuHelp(h,am)

    m=am.createPopupMenu(h);

    action=h.getAction('HELP_LOGDLG');
    m.addMenuItem(action);

end