function current=getCurrentSimMode(cbinfo)




    assert(...
    slfeature('EnhancedNormalMode')==0||...
    slfeature('EnhancedNormalMode')==1...
    );
    assert(...
    slsvTestingHook('EnhancedNormalFSpec')==0||...
    slsvTestingHook('EnhancedNormalFSpec')==1...
    );
    if slfeature('EnhancedNormalMode')==1&&slsvTestingHook('EnhancedNormalFSpec')==1
        current=DAStudio.message('Simulink:studio:SimModeAutoToolBar');
        if strcmp(SLStudio.Utils.isCurrentSimMode(cbinfo,'normal'),'Checked')
            current=DAStudio.message('Simulink:studio:SimModeNormalToolBar');
        end
    else
        current=DAStudio.message('Simulink:studio:SimModeNormalToolBar');
    end
    if strcmp(SLStudio.Utils.isCurrentSimMode(cbinfo,'accelerator'),'Checked')
        current=DAStudio.message('Simulink:studio:SimModeAcceleratedToolBar');
    elseif strcmp(SLStudio.Utils.isCurrentSimMode(cbinfo,'rapid-accelerator'),'Checked')
        current=DAStudio.message('Simulink:studio:SimModeRapidAcceleratorToolBar');
    elseif strcmp(SLStudio.Utils.isCurrentSimMode(cbinfo,'software-in-the-loop (sil)'),'Checked')
        current=DAStudio.message('Simulink:studio:SimModeSILToolBar');
    elseif strcmp(SLStudio.Utils.isCurrentSimMode(cbinfo,'processor-in-the-loop (pil)'),'Checked')
        current=DAStudio.message('Simulink:studio:SimModePILToolBar');
    elseif strcmp(SLStudio.Utils.isCurrentSimMode(cbinfo,'external'),'Checked')
        current=DAStudio.message('Simulink:studio:SimModeExternalToolBar');
    end
end
