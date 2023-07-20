function m=createmenu_actions(h)



    am=DAStudio.ActionManager;
    m=am.createPopupMenu(h);

    action=h.getaction('VALIDATE_TABLE');
    m.addMenuItem(action);


