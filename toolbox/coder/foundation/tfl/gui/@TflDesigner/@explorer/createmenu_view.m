function m=createmenu_view(h)



    am=DAStudio.ActionManager;
    m=am.createPopupMenu(h);

    action=h.getaction('VIEW_SHOWDYNDLGS');
    m.addMenuItem(action);

    action=h.getaction('VIEW_INCREASEFONT');
    m.addMenuItem(action);

    action=h.getaction('VIEW_DECREASEFONT');
    m.addMenuItem(action);

    action=h.getaction('OPTIONS_PROMPT_DLG_REPLACE');
    m.addMenuItem(action);

