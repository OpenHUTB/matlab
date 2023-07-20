function createToolbarLoggingText(h,tb)




    assert(~isempty(tb));
    am=DAStudio.ActionManager;

    tb.addSeparator;

    h.hLoggingOffTxt=am.createToolBarText(tb);
    h.hLoggingOffTxt.setEnabled(1);
    h.hLoggingOffTxt.setVisible(0);
    h.hLoggingOffTxt.setText(DAStudio.message('Simulink:Logging:SigLogDlgLoggingDisabledText'));
    h.hLoggingOffTxt.setToolTip(DAStudio.message('Simulink:Logging:SigLogDlgLoggingDisabledStatusTip'));
    tb.addWidget(h.hLoggingOffTxt);

end
