function createmenu(h)





    am=DAStudio.ActionManager;

    m=createmenu_file(h);
    am.addSubMenu(h,m,DAStudio.message('RTW:tfldesigner:FileText'));

    m=createmenu_edit(h);
    am.addSubMenu(h,m,DAStudio.message('RTW:tfldesigner:EditText'));

    m=createmenu_view(h);
    am.addSubMenu(h,m,DAStudio.message('RTW:tfldesigner:ViewText'));

    m=createmenu_actions(h);
    am.addSubMenu(h,m,DAStudio.message('RTW:tfldesigner:ActionsText'));

    m=createmenu_help(h);
    am.addSubMenu(h,m,DAStudio.message('RTW:tfldesigner:HelpText'));

    h.updateactions;