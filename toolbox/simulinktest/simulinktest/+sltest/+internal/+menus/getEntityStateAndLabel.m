function[state,label]=getEntityStateAndLabel(obsPrtH)
    label='';
    if Simulink.observer.internal.getObserverPortStatus(obsPrtH)=="Invalid"
        state='Disabled';
    else
        state='Enabled';
    end

    entType=Simulink.observer.internal.getObservedEntityType(obsPrtH);
    switch entType
    case 'Outport'
        label=DAStudio.message('Simulink:studio:GoToObservedSignal');
    case 'SFState'
        label=DAStudio.message('Simulink:studio:GoToObservedState');
    case 'SFData'
        label=DAStudio.message('Simulink:studio:GoToObservedData');
    case 'Unknown'
        state='Hidden';
    end
end
