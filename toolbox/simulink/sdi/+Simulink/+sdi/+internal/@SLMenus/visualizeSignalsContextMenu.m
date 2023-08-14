function schema=visualizeSignalsContextMenu(cbinfo)




    import Simulink.sdi.internal.SignalObserverMenu;
    tag='Simulink:InspectSignal';

    startLabel=DAStudio.message('SDI:sdi:SLMenuJetstreamLogSelectedSignals');
    stopLabel=DAStudio.message('SDI:sdi:SLMenuJetstreamStopLogSelectedSignals');
    icon='Simulink:JetstreamMarkSelectedSignals';

    schema=SignalObserverMenu.getSimulinkSchema(cbinfo,tag,startLabel,stopLabel,icon,false);
end

