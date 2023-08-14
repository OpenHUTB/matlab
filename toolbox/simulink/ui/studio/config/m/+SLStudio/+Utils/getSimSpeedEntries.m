function current=getSimSpeedEntries(cbinfo)




    current={SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:SimModeNormalToolBar')};
    if cbinfo.queryMenuAttribute('Simulink:SimModeAccelerated','visible',cbinfo.model.Handle)
        current=horzcat(current,SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:SimModeAcceleratedToolBar'));
    end
    if cbinfo.queryMenuAttribute('Simulink:SimModeRapidAccelerator','visible',cbinfo.model.Handle)
        if(slfeature('EnhancedNormalMode')>0)
            current=horzcat(current,SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:SimModeRapidToolBar'));
        else
            current=horzcat(current,SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:SimModeRapidAcceleratorToolBar'));
        end
    end
end
