function m=createmenu_file(h)



    am=DAStudio.ActionManager;
    m=am.createPopupMenu(h);

    action=h.getaction('FILE_IMPORT');
    m.addMenuItem(action);

    action=h.getaction('FILE_EXPORT');
    m.addMenuItem(action);

    m.addSeparator;

    action=h.getaction('FILE_TABLE');
    m.addMenuItem(action);

    k=createmenu_entrytypes(h);
    m.addSubMenu(k,DAStudio.message('RTW:tfldesigner:FileNewEntry'));

    k=createmenu_customtype(h);
    m.addSubMenu(k,DAStudio.message('RTW:tfldesigner:FileCustomEntry'));

    m.addSeparator;

    action=h.getaction('FILE_CREATE_SL_CUSTOMIZATION');
    m.addMenuItem(action);

    m.addSeparator;

    action=h.getaction('FILE_CLOSE');
    m.addMenuItem(action);
