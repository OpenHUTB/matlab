function dataAccessSettingCB(~,dlg)



    locUpdateEnabledStates(dlg);
    dlg.enableApplyButton(true);
end


function locUpdateEnabledStates(dlg)

    bDataAccessEnable=dlg.getWidgetValue('chkBoxEnable');
    dlg.setEnabled('txtFcnCallback',bDataAccessEnable);
    dlg.setEnabled('chkBoxTime',bDataAccessEnable);
    dlg.setEnabled('txtFcnParam',bDataAccessEnable);

end

