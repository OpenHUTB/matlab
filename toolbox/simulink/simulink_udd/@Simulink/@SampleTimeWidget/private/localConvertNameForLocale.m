function[translatedName]=localConvertNameForLocale(name)




    translatedName=name;

    switch(name)
    case slsvInternal('slsvGetEnStringFromCatalog','Simulink:SampleTime:SampleTimeWidgetTypeParameter');
        translatedName=DAStudio.message('Simulink:SampleTime:SampleTimeWidgetTypeParameter');
    case slsvInternal('slsvGetEnStringFromCatalog','Simulink:SampleTime:SampleTimeWidgetTypeConstant');
        translatedName=DAStudio.message('Simulink:SampleTime:SampleTimeWidgetTypeConstant');
    case slsvInternal('slsvGetEnStringFromCatalog','Simulink:SampleTime:SampleTimeWidgetTypeInherited');
        translatedName=DAStudio.message('Simulink:SampleTime:SampleTimeWidgetTypeInherited');
    case slsvInternal('slsvGetEnStringFromCatalog','Simulink:SampleTime:SampleTimeWidgetTypeContinuous');
        translatedName=DAStudio.message('Simulink:SampleTime:SampleTimeWidgetTypeContinuous');
    case slsvInternal('slsvGetEnStringFromCatalog','Simulink:SampleTime:SampleTimeWidgetTypePeriodic');
        translatedName=DAStudio.message('Simulink:SampleTime:SampleTimeWidgetTypePeriodic');
    case slsvInternal('slsvGetEnStringFromCatalog','Simulink:SampleTime:SampleTimeWidgetTypeUnresolved');
        translatedName=DAStudio.message('Simulink:SampleTime:SampleTimeWidgetTypeUnresolved');
    end

end
