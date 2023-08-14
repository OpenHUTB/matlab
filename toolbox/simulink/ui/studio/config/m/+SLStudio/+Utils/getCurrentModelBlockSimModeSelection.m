function selection=getCurrentModelBlockSimModeSelection(modelBlockHandle)


    simMode=get_param(modelBlockHandle,'SimulationMode');

    selection='';

    switch(simMode)
    case 'Normal'
        selection='Simulink:studio:SimModeNormalToolBar';

    case 'Accelerator'
        selection='Simulink:studio:SimModeAcceleratedToolBar';

    case 'Software-in-the-loop (SIL)'
        selection='Simulink:studio:SimModeSILToolBar';

    case 'Processor-in-the-loop (PIL)'
        selection='Simulink:studio:SimModePILToolBar';
    end

    if isempty(selection)
        DAStudio.error('Simulink:General:InternalError',...
        'SLStudio.Utils.getCurrentModelBlockSimModeSelection');
    end
end