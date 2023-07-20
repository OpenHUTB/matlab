
function linkingOptions(cbinfo)

    if~slreq.toolstrip.activateEditor(cbinfo)
        rmi.settings_mgr('set','settingsTab',1);
    end
    rmi_settings_dlg();

end
