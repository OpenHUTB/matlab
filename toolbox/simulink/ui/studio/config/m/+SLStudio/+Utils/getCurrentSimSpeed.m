function current=getCurrentSimSpeed(cbinfo)




    current=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:SimModeNormalToolBar');
    if strcmp(SLStudio.Utils.isCurrentSimMode(cbinfo,'accelerator'),'Checked')
        current=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:SimModeAcceleratedToolBar');
    elseif strcmp(SLStudio.Utils.isCurrentSimMode(cbinfo,'rapid-accelerator'),'Checked')
        current=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:SimModeRapidAcceleratorToolBar');
    end
end