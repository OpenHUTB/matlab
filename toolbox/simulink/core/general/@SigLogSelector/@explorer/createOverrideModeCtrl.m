function tb=createOverrideModeCtrl(h)





    am=DAStudio.ActionManager;
    tb=am.createToolBar(h);


    label=am.createToolBarText(tb);
    label.setEnabled(1);
    label.setVisible(1);
    label.setText(DAStudio.message('Simulink:Logging:SigLogDlgOverrideModeLabel'));
    tb.addWidget(label);


    h.hOverrideCombo=am.createToolBarComboBox(tb);
    h.hOverrideCombo.insertItems(...
    2,...
    {DAStudio.message('Simulink:Logging:SigLogDlgOverrideNone'),...
    DAStudio.message('Simulink:Logging:SigLogDlgOverrideSome')});
    h.hOverrideCombo.setToolTip(...
    DAStudio.message('Simulink:Logging:SigLogDlgOverrideModeTip'));
    h.hOverrideCombo.setEditable(false);
    h.hOverrideCombo.setEnabled(true);
    h.hOverrideCombo.setVisible(true);
    h.hOverrideCombo.setMinimumSize(175,20);
    tb.addWidget(h.hOverrideCombo);

    tb.addSeparator;


    assert(isempty(h.listeners));
    cb_listener=handle.listener(...
    h.hOverrideCombo,...
    'SelectionChangedEvent',...
    @SigLogSelector.cb_overrideModeChanged);
    h.listeners{1}=cb_listener;

end
