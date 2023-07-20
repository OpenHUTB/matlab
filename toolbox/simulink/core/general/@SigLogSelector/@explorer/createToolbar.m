function createToolbar(h,tb)




    assert(~isempty(tb));


    action=h.getAction('VIEW_CONFIG_PARAMS');
    tb.addAction(action);


    action=h.getAction('HELP_LOGDLG');
    tb.addAction(action);

end
