function simModeEntries=getModelBlockSimModeEntries(modelBlockHandle)



    obj=get_param(modelBlockHandle,'Object');

    allowedValues=obj.getPropAllowedValues('SimulationMode',false);
    simModeEntries={};

    for idx=1:length(allowedValues)
        simModeEntries{end+1}=...
        loc_getMenuEntryForAllowedValue(allowedValues{idx});%#ok<AGROW>
    end
end

function menuEntry=loc_getMenuEntryForAllowedValue(allowedValue)
    menuEntry='';

    switch(allowedValue)
    case 'Normal'
        menuEntry='Simulink:studio:SimModeNormalToolBar';

    case 'Accelerator'
        menuEntry='Simulink:studio:SimModeAcceleratedToolBar';

    case 'Software-in-the-loop (SIL)'
        menuEntry='Simulink:studio:SimModeSILToolBar';

    case 'Processor-in-the-loop (PIL)'
        menuEntry='Simulink:studio:SimModePILToolBar';
    end

    if isempty(menuEntry)
        DAStudio.error('Simulink:General:InternalError',...
        'SLStudio.Utils.getModelBlockSimModeEntries');
    end

end
