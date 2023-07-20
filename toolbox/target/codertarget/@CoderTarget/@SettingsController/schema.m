function schema()




    parentPkg=findpackage('Simulink');
    parentClass=findclass(parentPkg,'CustomCC');

    package=findpackage('CoderTarget');
    hThisClass=schema.class(package,'SettingsController',parentClass);

    thisProperty=schema.prop(hThisClass,'CoderTargetData','MATLAB array');
    thisProperty.FactoryValue='';

    listenerProperty=Simulink.TargetCCProperty(thisProperty,'PreSetListener','handle');
    listenerProperty.TargetCCPropertyAttributes.set_prop_attrib('NOT_FOR_CHECKSUM');
    listenerProperty.Visible='off';
    listenerProperty.AccessFlags.Serialize='off';

    hListener=handle.listener(hThisClass,hThisClass.Properties,'PropertyPreSet',@preSetFcn);
    thisProperty.PreSetListener=hListener;

    thisProperty=schema.prop(hThisClass,'TemporaryCoderTargetData','MATLAB array');
    thisProperty.FactoryValue='';
    thisProperty.Visible='off';
    thisProperty.AccessFlags.Serialize='off';

    thisProperty=schema.prop(hThisClass,'TaskManagerData','MATLAB array');
    thisProperty.FactoryValue='';
    thisProperty.Visible='off';
    thisProperty.AccessFlags.Serialize='off';

    thisProperty=schema.prop(hThisClass,'UseSoCFeatures','MATLAB array');
    thisProperty.FactoryValue='';
    thisProperty.Visible='off';
    thisProperty.AccessFlags.Serialize='off';

    thisProperty=schema.prop(hThisClass,'UseSoCProfilerForTargets','bool');
    thisProperty.FactoryValue=false;
    thisProperty.Visible='off';
    thisProperty.AccessFlags.Serialize='off';

    thisProperty=schema.prop(hThisClass,'DialogTemplateData','MATLAB array');
    thisProperty.FactoryValue='';
    thisProperty.Visible='off';
    thisProperty.AccessFlags.Serialize='off';

    thisProperty=schema.prop(hThisClass,'DynamicTargetHardwareResourcesUpdating','MATLAB array');
    thisProperty.FactoryValue='';
    thisProperty.Visible='off';
    thisProperty.AccessFlags.Serialize='off';

    thisProperty=schema.prop(hThisClass,'DynamicTargetHardwareResourcesBuilding','MATLAB array');
    thisProperty.FactoryValue='';
    thisProperty.Visible='off';
    thisProperty.AccessFlags.Serialize='off';

    thisProperty=schema.prop(hThisClass,'ConnectedIO','MATLAB array');
    thisProperty.FactoryValue='off';
    thisProperty.Visible='off';
    thisProperty.AccessFlags.Serialize='off';

    m=schema.method(hThisClass,'getName');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle'};
    m.Signature.OutputTypes={'string'};

    m=schema.method(hThisClass,'widgetChangedCallback');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle','string','string'};
    m.Signature.OutputTypes={};

    m=schema.method(hThisClass,'rtosChangedCallback');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle','string','string'};
    m.Signature.OutputTypes={};

    m=schema.method(hThisClass,'kernelLatencyChangedCallback');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle','string','string'};
    m.Signature.OutputTypes={};

    m=schema.method(hThisClass,'getPropsThatAffectChecksum');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','string'};
    m.Signature.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'update');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

end




function preSetFcn(hProp,eventData,~)
    hObj=eventData.AffectedObject;
    if~isequal(get(hObj,hProp.Name),eventData.NewVal)
        hObj.dirtyHostBD;
    end
end


