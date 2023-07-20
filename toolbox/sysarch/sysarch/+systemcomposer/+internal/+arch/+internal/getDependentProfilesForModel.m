function profiles=getDependentProfilesForModel(model)




    if~ishandle(model)
        model=get_param(model,'Handle');
    end

    rootArch=systemcomposer.utils.getArchitecturePeer(bdroot(model));
    mdl=mf.zero.getModel(rootArch);
    profiles={};
    topLevelElements=mdl.topLevelElements;
    for elem=topLevelElements
        if elem.StaticMetaClass.isA(systemcomposer.internal.profile.ProfileResolver.StaticMetaClass)
            currentProfile=elem.URI;
            if~any(strcmp(currentProfile,horzcat('systemcomposer',profiles)))
                dependentProfile=systemcomposer.internal.arch.internal.getDependentProfiles(currentProfile,false);
                profiles=horzcat(profiles,currentProfile,dependentProfile);%#ok<AGROW>
            end
        end
    end





    profiles=unique(profiles);

end