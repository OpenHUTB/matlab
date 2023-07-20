function schema=visualizeSelectedSignals(cbinfo)




    import Simulink.sdi.internal.SignalObserverMenu;
    tag='Simulink:InspectSelectedSignals';

    if SLStudio.Utils.showInToolStrip(cbinfo)
        startLabel='simulink_ui:studio:resources:LogSignalActionText';
        stopLabel=startLabel;
        icon='logSignal';
        toggle=true;
    else
        startLabel=DAStudio.message('SDI:sdi:SLMenuJetstreamLogSelectedSignals');
        stopLabel=DAStudio.message('SDI:sdi:SLMenuJetstreamStopLogSelectedSignals');
        icon='Simulink:JetstreamMarkSelectedSignals';
        toggle=false;
    end

    schema=SignalObserverMenu.getSimulinkSchema(cbinfo,tag,startLabel,stopLabel,icon,toggle);

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.tooltip='simulink_ui:studio:resources:LogSignalActionDescription';
    end
end

