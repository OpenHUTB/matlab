function m=createmenu_edit(h)




    am=DAStudio.ActionManager;
    m=am.createPopupMenu(h);


    action=h.getaction('EDIT_CUT');
    m.addMenuItem(action);

    action=h.getaction('EDIT_COPY');
    m.addMenuItem(action);

    action=h.getaction('EDIT_PASTE');
    m.addMenuItem(action);

    action=h.getaction('EDIT_DELETE');
    m.addMenuItem(action);

    m.addSeparator;

    action=h.getaction('EDIT_COPYBUILDINFO');
    m.addMenuItem(action);

    action=h.getaction('EDIT_PASTEBUILDINFO');
    m.addMenuItem(action);

