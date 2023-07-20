function enumName=getDependentEnumerationFiles(profileName)


    prof=systemcomposer.internal.profile.Profile.findLoadedProfile(profileName);
    if isempty(prof)
        profMf0Mdl=systemcomposer.internal.profile.Profile.loadFromFile(profileName);
        prof=systemcomposer.internal.profile.Profile.getProfile(profMf0Mdl);
    end



    enumName={};
    for stereo=prof.prototypes.toArray
        propSet=stereo.propertySet;
        for propDef=propSet.properties.toArray
            if isa(propDef.type,'systemcomposer.property.Enumeration')
                enumName{end+1}=propDef.type.MATLABEnumName;%#ok<AGROW>
            end
        end
    end