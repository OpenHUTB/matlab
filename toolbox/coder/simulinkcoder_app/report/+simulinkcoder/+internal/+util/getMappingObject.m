function mapObj=getMappingObject(model,category,key)

    mapping=Simulink.CodeMapping.getCurrentMapping(model);
    switch category
    case 'Defaults'







        mapObj=mapping.DefaultsMapping.(key);
    case 'Inports'

        SLBlockPath=getfullname(key);
        mapObj=mapping.Inports.findobj('Block',SLBlockPath);
    case 'Outports'

        SLBlockPath=getfullname(key);
        mapObj=mapping.Outports.findobj('Block',SLBlockPath);
    case 'Signals'

        mapObj=mapping.Signals.findobj('PortHandle',key);
    case 'States'

        mapObj=mapping.States.findobj('OwnerBlockHandle',key);
    case 'DataStores'

        mapObj=mapping.DataStores.findobj('OwnerBlockHandle',key);
    case 'ModelScopedParameters'

        mapObj=mapping.ModelScopedParameters.findobj('Parameter',key);
    end
