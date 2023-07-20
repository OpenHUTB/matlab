function setSimulationMode(cbinfo,newSelection)




    modelName=SLStudio.Utils.getModelName(cbinfo);
    mode='';%#ok<NASGU>

    assert(...
    slfeature('EnhancedNormalMode')==0||...
    slfeature('EnhancedNormalMode')==1...
    );
    assert(...
    slsvTestingHook('EnhancedNormalFSpec')==0||...
    slsvTestingHook('EnhancedNormalFSpec')==1...
    );
    switch(newSelection)
    case 'Simulink:SimModeAuto'
        if slfeature('EnhancedNormalMode')==1&&...
            slsvTestingHook('EnhancedNormalFSpec')==1
            mode='auto';
        else
            error(message('Simulink:studio:SelectionIsInvalid'));
        end
    case{'Simulink:SimModeNormal','normal'}
        mode='normal';
    case{'Simulink:SimModeAccelerated','accelerator'}
        mode='accelerator';
    case{'Simulink:SimModeRapidAccelerator','rapid-accelerator'}
        mode='rapid-accelerator';
    case{'Simulink:SimModeSIL','software-in-the-loop (sil)'}
        mode='software-in-the-loop (sil)';
    case{'Simulink:SimModePIL','processor-in-the-loop (pil)'}
        mode='processor-in-the-loop (pil)';
    case{'Simulink:SimModeExternal','external'}
        mode='external';
    otherwise
        error(message('Simulink:studio:SelectionIsInvalid'));
    end
    current_mode=get_param(modelName,'SimulationMode');
    if~strcmpi(current_mode,mode)
        set_param(modelName,'SimulationMode',mode);
    end
end
