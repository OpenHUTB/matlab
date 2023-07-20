function setModelBlockSimModeFromSelection(modelBlockHandle,newSelection)


    newSimMode='';

    switch(newSelection)
    case 'Simulink:studio:SimModeNormalToolBar'
        newSimMode='Normal';

    case 'Simulink:studio:SimModeAcceleratedToolBar'
        newSimMode='Accelerator';

    case 'Simulink:studio:SimModeSILToolBar'
        newSimMode='Software-in-the-loop (SIL)';

    case 'Simulink:studio:SimModePILToolBar'
        newSimMode='Processor-in-the-loop (PIL)';
    end

    if isempty(newSimMode)
        DAStudio.error('Simulink:General:InternalError',...
        'SLStudio.Utils.setModelBlockSimModeFromSelection');
    end

    set_param(modelBlockHandle,'SimulationMode',newSimMode);
end