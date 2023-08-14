function[name]=localGetNameFromType(type)



    switch type
    case 'Inherited'
        name=DAStudio.message('Simulink:SampleTime:SampleTimeWidgetTypeInherited');
    case 'Auto'
        name=DAStudio.message('Simulink:SampleTime:SampleTimeWidgetTypeParameter');
    case 'Continuous'
        name=DAStudio.message('Simulink:SampleTime:SampleTimeWidgetTypeContinuous');
    case 'Periodic'
        name=DAStudio.message('Simulink:SampleTime:SampleTimeWidgetTypePeriodic');
    otherwise
        name=DAStudio.message('Simulink:SampleTime:SampleTimeWidgetTypeUnresolved');
    end

end
