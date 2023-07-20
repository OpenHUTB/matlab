function updateScopeSettings(dlg,properties)




    dlg.setWidgetValue('yMinLabel',properties{1});
    dlg.setWidgetValue('yMaxLabel',properties{2});
    dlg.setWidgetValue('ScopeTimeSpan',properties{3});
    dlg.setWidgetValue('FitToViewAtStop',properties{4});
    dlg.setWidgetValue('ShowInstructionalText',properties{5});
    dlg.setEnabled('ShowInstructionalText',properties{6});

    dlg.enableApplyButton(false,false);
end