function features=getCustomComponentFeatureList(componentName)








    mcs=configset.internal.getConfigSetStaticData;
    component=mcs.getComponent(componentName);
    if isempty(component)
        features={};
    elseif strcmp(component.Type,'Target')
        target=mcs.getComponent('Target');
        features=[component.PrototypeFeature;target.PrototypeFeature];
    else
        features=component.PrototypeFeature;
    end

