function updateObjFromDlg(aObj,dlg)





    aObj.setGenerateCode(aObj.getWidgetValue('GenerateCode'));
    aObj.setTerminateOnIncompatibility(aObj.getWidgetValue('TerminateOnIncompatibility'));
    aObj.setTopModel(aObj.getWidgetValue('TopModel'));
    aObj.setFollowModelLinks(aObj.getWidgetValue('FollowModelLinks'));
    if dlg.isVisible(aObj.getWidgetId('IncludeTopModelChecksumForRef'))
        aObj.setIncludeTopModelChecksumForRefModels(...
        aObj.getWidgetValue('IncludeTopModelChecksumForRef'));
    end
    slci.Configuration.setInspectSharedUtils(aObj.getWidgetValue('InspectSharedUtils'));
    aObj.setCodePlacement(dlg.getComboBoxText(aObj.getWidgetId('CodePlacement')));
    aObj.setCodeFolder(aObj.getWidgetValue('CodeFolder'));
    aObj.setReportFolder(aObj.getWidgetValue('ReportFolder'));
end
