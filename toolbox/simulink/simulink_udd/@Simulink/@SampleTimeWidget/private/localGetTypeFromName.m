function[type]=localGetTypeFromName(name)




    if strcmp(name,localGetNameFromType('Inherited'))
        type='Inherited';
    elseif strcmp(name,localGetNameFromType('Continuous'))
        type='Continuous';
    elseif strcmp(name,localGetNameFromType('Periodic'))
        type='Periodic';
    elseif strcmp(name,DAStudio.message('Simulink:SampleTime:SampleTimeWidgetTypeParameter'))||...
        strcmp(name,DAStudio.message('Simulink:SampleTime:SampleTimeWidgetTypeConstant'))

        type='Auto';
    elseif strcmp(name,localGetNameFromType('Unresolved'))
        type='Unresolved';
    else
        assert(false,'Bad Type');
        type='Invalid';
    end

end

