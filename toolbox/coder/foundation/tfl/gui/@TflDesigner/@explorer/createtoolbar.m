function createtoolbar(h)





    am=DAStudio.ActionManager;

    tb=am.createToolBar(h);
    tb.label=DAStudio.message('RTW:tfldesigner:ToolbarLabel');

    action=h.getaction('FILE_TABLE');
    tb.addAction(action);

    action=h.getaction('FILE_IMPORT');
    tb.addAction(action);

    action=h.getaction('FILE_NEW_ENTRY');
    tb.addAction(action);

    action=h.getaction('FILE_EXPORT');
    tb.addAction(action);

    tb.addSeparator;

    action=h.getaction('EDIT_CUT');
    tb.addAction(action);

    action=h.getaction('EDIT_COPY');
    tb.addAction(action);

    action=h.getaction('EDIT_PASTE');
    tb.addAction(action);

    action=h.getaction('EDIT_DELETE');
    tb.addAction(action);

    tb.addSeparator;

    action=h.getaction('VALIDATE_TABLE');
    tb.addAction(action);

    action=h.getaction('HELP_TFLDESIGNER');
    tb.addAction(action);
