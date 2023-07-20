function props=getDynamicEnumerationPropertyNames(classname)
    props={};
    mc=meta.class.fromName(classname);
    mps=mc.Properties;
    for ii=1:length(mps)
        mp=mps{ii};
        if isa(mp,'matlab.system.CustomMetaProp')&&mp.DynamicEnumeration
            props{end+1}=mp.Name;
        end
    end
end
