classdef ProfileEditor<handle






    properties(Constant,Hidden)
    end



    methods(Hidden,Static)
        function profMdls=getProfileModels()
            profMdls=[];
            profs=systemcomposer.internal.profile.Profile.getProfilesInCatalog();
            for prof=profs
                if strcmp(prof.getName,'systemcomposer')
                    continue;
                end
                model=mf.zero.getModel(prof);
                profMdls=cat(1,profMdls,model);
            end
        end

        function profile=getProfile(semanticID)
            models=systemcomposer.internal.profile.ProfileEditor.getProfileModels();
            for idx=1:length(models)
                model=models(idx);
                if~isempty(model.findElement(semanticID))
                    profile=systemcomposer.internal.profile.Profile.getProfile(model);
                    break;
                end
            end
        end

        function elem=getElement(elemUUID)
            models=systemcomposer.internal.profile.ProfileEditor.getProfileModels();
            for idx=1:length(models)
                model=models(idx);
                if~isempty(model.findElement(elemUUID))
                    elem=model.findElement(elemUUID);
                    break;
                end
            end
        end

        function[protoList,currentValue]=getArchitecturePrototypes(elem)
            protoList={'none'};
            currentValue='';
            if isa(elem,'systemcomposer.internal.profile.Profile')
                profile=elem;
                proto=profile.defaultArchPrototype;
                if~isempty(proto)
                    currentValue=proto.getName;
                end
            elseif isa(elem,'systemcomposer.internal.profile.Prototype')
                profile=elem.profile;
            end

            prototypes=profile.prototypes.toArray;
            for i=1:numel(prototypes)
                if~prototypes(i).abstract&&(systemcomposer.internal.profile.ProfileEditor.isPrototypeType(prototypes(i),'Component')...
                    ||isempty(prototypes(i).appliesTo.toArray))
                    protoList{end+1}=prototypes(i).getName;
                end
            end
            proto=elem;
            if isa(proto,'systemcomposer.internal.profile.Prototype')&&systemcomposer.internal.profile.ProfileEditor.isPrototypeType(proto,'Component')
                archDefault={};
                if~isempty(proto.defaultStereotypeMap)
                    archDefault=proto.defaultStereotypeMap.getArchitectureDefault;
                end
                currentValue='';
                if~isempty(archDefault)
                    currentValue=archDefault.getName;
                end
            end
        end
        function[protoList,currentValue]=getPortPrototypes(elem)
            protoList={'none'};
            currentValue='';
            if isa(elem,'systemcomposer.internal.profile.Profile')
                profile=elem;
            elseif isa(elem,'systemcomposer.internal.profile.Prototype')
                profile=elem.profile;
            end
            prototypes=profile.prototypes.toArray;
            for i=1:numel(prototypes)
                if~prototypes(i).abstract&&(systemcomposer.internal.profile.ProfileEditor.isPrototypeType(prototypes(i),'Port')...
                    ||isempty(prototypes(i).appliesTo.toArray))
                    protoList{end+1}=prototypes(i).getName;
                end
            end

            proto=elem;

            if isa(proto,'systemcomposer.internal.profile.Prototype')&&systemcomposer.internal.profile.ProfileEditor.isPrototypeType(proto,'Component')
                portDefault={};
                if~isempty(proto.defaultStereotypeMap)
                    portDefault=proto.defaultStereotypeMap.getPortDefault;
                end
                if~isempty(portDefault)
                    currentValue=portDefault.getName;
                end
            end
        end

        function[protoList,currentValue]=getConnectorPrototypes(elem)
            protoList={'none'};
            currentValue='';
            if isa(elem,'systemcomposer.internal.profile.Profile')
                profile=elem;
            elseif isa(elem,'systemcomposer.internal.profile.Prototype')
                profile=elem.profile;
            end
            prototypes=profile.prototypes.toArray;
            for i=1:numel(prototypes)
                if~prototypes(i).abstract&&(systemcomposer.internal.profile.ProfileEditor.isPrototypeType(prototypes(i),'Connector')...
                    ||isempty(prototypes(i).appliesTo.toArray))
                    protoList{end+1}=prototypes(i).getName;
                end
            end

            proto=elem;
            if isa(proto,'systemcomposer.internal.profile.Prototype')&&systemcomposer.internal.profile.ProfileEditor.isPrototypeType(proto,'Component')
                connDefault={};
                if~isempty(proto.defaultStereotypeMap)
                    connDefault=proto.defaultStereotypeMap.getConnectorDefault;
                end
                if~isempty(connDefault)
                    currentValue=connDefault.getName;
                end
            end
        end

        function b=isPrototypeType(prototype,appliesToElem)
            if isempty(prototype.appliesTo.toArray)
                b=false;
            else
                b=ismember(prototype.appliesTo.toArray,appliesToElem);
            end
            if~b
                parent=prototype;
                while~b&&~isempty(parent)
                    parent=parent.parent;
                    if~isempty(parent)
                        if~isempty(parent.appliesTo.toArray)
                            b=ismember(parent.appliesTo.toArray,appliesToElem);
                        end
                    end
                end
            end
        end

        function entries=getMetaclassEntries()
            entries={...
            'all',...
'Component'...
            ,'Port',...
            'Connector',...
'Interface'...
            };
        end
        function base=getPrototypeExtendsValue(prototype)
            base=prototype.getExtendedElement();
        end

        function val=getPrototypeBaseValue(prototype)


            if isempty(prototype.parent)
                val='';
            else
                base=prototype.parent.fullyQualifiedName;
                entries=systemcomposer.internal.profile.ProfileEditor.getBasePrototypeEntries(prototype);
                val=find(strcmp(base,entries),1);
                if isempty(val)

                    val='not found';
                else
                    val=base;
                end
            end
        end

        function entries=getBasePrototypeEntries(prototype)

            entries={'nothing'};
            models=systemcomposer.internal.profile.ProfileEditor.getProfileModels();
            for idx=1:length(models)
                m=models(idx);
                p=systemcomposer.internal.profile.Profile.getProfile(m);
                prototypeFQNs=arrayfun(@(x)x.fullyQualifiedName,p.prototypes.toArray,'uniformoutput',false);
                entries=[entries,prototypeFQNs];
            end



            currentPrototype=prototype.fullyQualifiedName;
            entries(strcmp(currentPrototype,entries))=[];
        end

        function yesno=currentPrototypeAppliesToComponentOrArchitecture(prototype)


            list=prototype.getCumulativeAppliesTo();
            yesno=any(strcmpi(list,'Component'))||...
            any(strcmpi(list,'Architecture'));
        end
        function yesno=currentPrototypeAppliesToPort(prototype)


            list=prototype.getCumulativeAppliesTo();
            yesno=any(strcmpi(list,'Port'));
        end
        function yesno=currentPrototypeAppliesToComponent(prototype)


            element=prototype.getExtendedElement();
            yesno=strcmpi(element,'Component');
        end
        function filepath=getCurrentPrototypeIcon(prototype)
            iconName=systemcomposer.internal.profile.internal.PrototypeIconPicker.iconEnum2Name(prototype.icon);
            filepath=systemcomposer.internal.profile.internal.PrototypeIconPicker.iconName2FilePath(iconName,prototype.getExtendedElement);
        end
        function RGBValue=getCurrentRGBValue(prototype)
            RGBValue=systemcomposer.internal.profile.internal.PrototypeColorPicker.colorEnumToRGBValue(prototype.color);
        end

        function valTypes=getValueTypes()



            valTypes={};
            profiles=systemcomposer.internal.profile.ProfileEditor.allProfiles;
            if~isempty(profiles)
                valTypes=profiles(1).valueTypes;
            end
        end

    end

    methods(Static)

        function allOpenMdls=getOpenModels()
            allOpenMdls={};
            allmdls=find_system('Type','block_diagram','BlockDiagramType','model');

            allmdls=sort(allmdls);
            for idx=1:length(allmdls)
                mdl=allmdls{idx};
                isArch=systemcomposer.internal.isSystemComposerModel(mdl);
                if isArch

                    allOpenMdls=[allOpenMdls;{mdl}];
                end
            end
        end

        function allOpenIntfs=getOpenInterfaces()
            allOpenIntfs={};
            allmdls=find_system('Type','block_diagram','BlockDiagramType','model');

            allmdls=sort(allmdls);
            for idx=1:length(allmdls)
                mdl=allmdls{idx};
                isArch=systemcomposer.internal.isSystemComposerModel(mdl);
                if isArch

                    ddName=get_param(mdl,'DataDictionary');
                    if~isempty(ddName)&&~systemcomposer.internal.modelHasLocallyScopedInterfaces(get_param(mdl,'Handle'))
                        [~,fName,~]=fileparts(ddName);
                        allOpenIntfs=[allOpenIntfs;{fName}];
                    end
                end
            end
        end

        function importProfileIntoOpenModelOrDD(profileName,fileName)





            [isModel,modelOrDDName]=systemcomposer.internal.profile.ProfileEditor.isModelContext(fileName);

            if isModel
                bdH=get_param(modelOrDDName,'handle');
                zcModel=get_param(bdH,'SystemComposerModel');
                rootArch=zcModel.Architecture.getImpl;
                mfModel=mf.zero.getModel(rootArch);
                txn=mfModel.beginTransaction;
                rootArch.p_Model.addProfile(profileName);
                txn.commit;
            else
                ddConn=Simulink.data.dictionary.open(fileName);
                mf0Model=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddConn.filepath());
                zcModel=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(mf0Model);
                piCatalog=zcModel.getPortInterfaceCatalog;
                piCatalog.addProfile(profileName);
            end
        end


        function[isModel,modelOrDDName]=isModelContext(fileName)


            [~,modelOrDDName,ext]=fileparts(fileName);
            isModel=~strcmpi(ext,'.sldd');
        end

        function profileNames=allProfileNames()

            profileNames=[];
            models=systemcomposer.internal.profile.ProfileEditor.getProfileModels();
            for idx=1:length(models)
                m=models(idx);
                profile=systemcomposer.internal.profile.Profile.getProfile(m);
                profileNames=[profileNames;profile.getName];
            end

        end

    end
end

