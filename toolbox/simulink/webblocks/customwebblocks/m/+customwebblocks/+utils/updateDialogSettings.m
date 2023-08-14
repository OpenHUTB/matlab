
function updateDialogSettings(dlg,settings)


    settingNames=fieldnames(settings);
    for idx=1:numel(settingNames)
        settingName=settingNames{idx};
        settingValue=settings.(settingName);
        dlg.setWidgetValue(settingName,settingValue);
        dlg.clearWidgetDirtyFlag(settingName);
    end
    dlg.enableApplyButton(false,false);
end