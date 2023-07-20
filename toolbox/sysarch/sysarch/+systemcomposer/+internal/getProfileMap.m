function[protoTypeNameMap,propNameDefaultValMap]=getProfileMap(iProfileName)



    propNameDefaultValMap=containers.Map('keytype','char','valuetype','any');

    protoTypeNameMap=containers.Map('keytype','char','valuetype','any');

    import systemcomposer.internal.profile.*;
    if(~isempty(iProfileName))

        loadFileName=strcat(iProfileName,'.xml');
        if(isequal(exist(char(loadFileName),'file'),2))

            profModel=systemcomposer.internal.profile.Profile.loadFromFile(iProfileName);
            if(~isempty(profModel))
                profile=systemcomposer.internal.profile.Profile.getProfile(profModel);
                if~isempty(profile)

                    prototypeList=profile.prototypes.toArray;
                    for protItr=1:numel(prototypeList)

                        prototype=prototypeList(protItr);
                        prototypeName=prototype.fullyQualifiedName;

                        protoTypeNameMap(prototypeName)=prototype;
                        properties=prototype.propertySet.getAllProperties;
                        for propItr=1:numel(properties)
                            property=properties(propItr);
                            propertyName=property.fullyQualifiedName;

                            propNameDefaultValMap(propertyName)=property;
                        end
                    end
                end
            end
        end
    end
end

