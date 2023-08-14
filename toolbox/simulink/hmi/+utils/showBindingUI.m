


function showBindingUI(blockHandle)
    if(isBlockInWebPanel(blockHandle))
        Simulink.HMI.openDashboardBlockDDGDialog(blockHandle);
        return;
    end
    open_system(blockHandle);

end