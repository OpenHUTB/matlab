function loggingSettingChangeCB(~,dlg)



    locUpdateEnabledStates(dlg);
    locClearWidgetErrors(dlg);
    dlg.enableApplyButton(true);
end


function locUpdateEnabledStates(dlg)

    bCustomName=dlg.getWidgetValue('chkCustomName');
    dlg.setEnabled('txtCustomName',bCustomName);


    bDecimate=dlg.getWidgetValue('chkDecimate');
    dlg.setEnabled('txtDecimate',bDecimate);


    bMaxPts=dlg.getWidgetValue('chkMaxPoints');
    dlg.setEnabled('txtMaxPoints',bMaxPts);
end


function locClearWidgetErrors(dlg)
    dlg.clearWidgetWithError('txtSubPlot');
    dlg.clearWidgetWithError('txtRelativeTolerance');
    dlg.clearWidgetWithError('txtAbsoluteTolerance');
end
