function profiles=getDependentProfiles(profileName,varargin)




    if(nargin==2)
        doUnload=varargin{1};
    else

        doUnload=false;
    end

    profiles={};
    mdl=systemcomposer.internal.profile.Profile.loadFromFile(profileName);
    topLevelElements=mdl.topLevelElements;
    for elem=topLevelElements
        if elem.StaticMetaClass.isA(systemcomposer.internal.profile.ProfileResolver.StaticMetaClass)
            if~any(strcmp(elem.URI,{'systemcomposer',profileName}))

                profiles{end+1}=elem.URI;%#ok<AGROW>
                if doUnload
                    systemcomposer.internal.profile.Profile.unload(elem.URI);
                end
            end
        end
    end
    if doUnload
        systemcomposer.internal.profile.Profile.unload(profileName);
    end
end