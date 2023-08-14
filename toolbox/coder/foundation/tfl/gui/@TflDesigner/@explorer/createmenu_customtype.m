function m=createmenu_customtype(h)



    am=DAStudio.ActionManager;
    m=am.createPopupMenu(h);



    action=h.getaction('FILE_CUSTOM_NEW_ENTRY');
    m.addMenuItem(action);

    action=h.getaction('FILE_CUSTOM_OPEN_ENTRY');
    m.addMenuItem(action);