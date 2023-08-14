function iconFiles=getDependentStereotypeIconFiles(profileName)





    prof=systemcomposer.internal.profile.Profile.findLoadedProfile(profileName);
    if isempty(prof)
        profMf0Mdl=systemcomposer.internal.profile.Profile.loadFromFile(profileName);
        prof=systemcomposer.internal.profile.Profile.getProfile(profMf0Mdl);
    end


    iconFiles={};
    for stereo=prof.prototypes.toArray
        if stereo.icon==systemcomposer.internal.profile.PrototypeIcon.CUSTOM
            iconFiles{end+1}=stereo.getCustomIconPath();%#ok<AGROW> 
        end
    end
