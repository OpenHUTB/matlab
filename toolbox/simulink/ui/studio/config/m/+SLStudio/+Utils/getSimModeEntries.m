function current=getSimModeEntries(cbinfo)




    assert(...
    slfeature('EnhancedNormalMode')==0||...
    slfeature('EnhancedNormalMode')==1...
    );
    assert(...
    slsvTestingHook('EnhancedNormalFSpec')==0||...
    slsvTestingHook('EnhancedNormalFSpec')==1...
    );
    if slfeature('EnhancedNormalMode')==1&&slsvTestingHook('EnhancedNormalFSpec')==1
        current={DAStudio.message('Simulink:studio:SimModeAutoToolBar')};
        if cbinfo.queryMenuAttribute('Simulink:SimModeNormal','visible',cbinfo.model.Handle)
            current=horzcat(current,DAStudio.message('Simulink:studio:SimModeNormalToolBar'));
        end
    else
        current={DAStudio.message('Simulink:studio:SimModeNormalToolBar')};
    end
    if cbinfo.queryMenuAttribute('Simulink:SimModeAccelerated','visible',cbinfo.model.Handle)
        current=horzcat(current,DAStudio.message('Simulink:studio:SimModeAcceleratedToolBar'));
    end
    if cbinfo.queryMenuAttribute('Simulink:SimModeRapidAccelerator','visible',cbinfo.model.Handle)
        current=horzcat(current,DAStudio.message('Simulink:studio:SimModeRapidAcceleratorToolBar'));
    end
    if cbinfo.queryMenuAttribute('Simulink:SimModeSIL','visible',cbinfo.model.Handle)
        current=horzcat(current,DAStudio.message('Simulink:studio:SimModeSILToolBar'));
    end
    if cbinfo.queryMenuAttribute('Simulink:SimModePIL','visible',cbinfo.model.Handle)
        current=horzcat(current,DAStudio.message('Simulink:studio:SimModePILToolBar'));
    end
    if cbinfo.queryMenuAttribute('Simulink:SimModeExternal','visible',cbinfo.model.Handle)
        current=horzcat(current,DAStudio.message('Simulink:studio:SimModeExternalToolBar'));
    end
end
