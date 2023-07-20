function m=createmenu_options(h)



    am=DAStudio.ActionManager;
    m=am.createPopupMenu(h);

    action=h.getaction('OPTIONS_PROMPT_DLG_REPLACE');
    m.addMenuItem(action);
