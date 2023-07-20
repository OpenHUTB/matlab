function addPropertySets(this,properties)







    mfModel=mf.zero.getModel(this);
    if(ischar(properties)||isstring(properties))


        ProfModel=systemcomposer.internal.profile.Profile.loadFromFile(properties);
        profile=systemcomposer.internal.profile.Profile.getProfile(ProfModel);

        profileSchema=struct();
        for stereotype=profile.prototypes.toArray
            elementKinds=stereotype.appliesTo.toArray;
            if isempty(elementKinds)
                elementKinds=["Component","Port","Connector"];
            end
            profileSchema.(stereotype.getName)=struct('elementKinds',string(elementKinds));
        end

        properties=struct(properties,profileSchema);
    end
    profileNames=fieldnames(properties);
    for profileIdx=1:length(profileNames)
        if strcmp(profileNames{profileIdx},'IsAbstract')
            continue;
        end

        profileName=profileNames{profileIdx};
        ProfModel=systemcomposer.internal.profile.Profile.loadFromFile(profileName);
        profile=systemcomposer.internal.profile.Profile.getProfile(ProfModel);


        profileStruct=properties.(profileName);
        prototypeNames=fieldnames(profileStruct);


        for prototypeIdx=1:length(prototypeNames)

            prototypeName=prototypeNames{prototypeIdx};
            prototypeStruct=profileStruct.(prototypeName);


            prot=profile.prototypes.getByKey(prototypeName);
            set=prot.propertySet;
            usage=addPrototypeProperties(prototypeStruct,set,mfModel);
            this.p_PropertySets.add(usage);
        end
    end

    for profileIdx=1:length(profileNames)
        if strcmp(profileNames{profileIdx},'IsAbstract')
            continue;
        end
        profileName=profileNames{profileIdx};
        ProfModel=systemcomposer.internal.profile.Profile.loadFromFile(profileName);
        profile=systemcomposer.internal.profile.Profile.getProfile(ProfModel);
        profileStruct=properties.(profileName);
        prototypeNames=fieldnames(profileStruct);

        for prototypeIdx=1:length(prototypeNames)
            prototypeName=prototypeNames{prototypeIdx};
            prototypeStruct=profileStruct.(prototypeName);
            prot=profile.prototypes.getByKey(prototypeName);
            usage=this.getPropertySet(prot.fullyQualifiedName);

            if~isempty(usage)&&~prot.abstract
                if isfield(prototypeStruct,'elementKinds')
                    elementKinds=prototypeStruct.elementKinds;
                else
                    elementKinds=["Component","Port","Connector"];
                end

                for instanceKind=elementKinds
                    mapping=this.mapping.getByKey(instanceKind);

                    if isempty(mapping)
                        mapping=systemcomposer.internal.analysis.PropertySetMapping(mfModel);
                        mapping.setName(instanceKind);
                        this.mapping.add(mapping);
                    end


                    mapping.usages.add(usage);



                    parent=prot.parent;
                    while~isempty(parent)
                        parentUsage=this.getPropertySet(parent.fullyQualifiedName);
                        if~isempty(parentUsage)
                            mapping.usages.add(parentUsage);
                        end
                        parent=parent.parent;
                    end
                end
            end
        end
    end
end

function usage=addPrototypeProperties(prototypeStruct,set,mfModel)

    usage=systemcomposer.property.PropertySetUsage(mfModel);
    usage.propertySet=set;
    usage.setName(set.prototype.fullyQualifiedName);
    if isfield(prototypeStruct,'properties')
        propNames=fieldnames(prototypeStruct.properties);
        for pi=1:length(propNames)
            propertyName=propNames{pi};
            prop=set.getPropertyByName(propertyName);
            if~(isa(prop.type,'systemcomposer.property.StringType'))
                pu=systemcomposer.internal.analysis.AnalysisPropertyDefinition.make(prop,mfModel);
                pu.setName(propertyName);
                usage.properties.add(pu);
            end
        end
    else

        properties=set.getAllProperties();
        for prop=properties
            if~(isa(prop.type,'systemcomposer.property.StringType'))
                pu=systemcomposer.internal.analysis.AnalysisPropertyDefinition.make(prop,mfModel);
                usage.properties.add(pu);
            end
        end
    end
end
