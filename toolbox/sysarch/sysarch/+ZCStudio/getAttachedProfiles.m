
function[valid,invalid,profiles]=getAttachedProfiles(archOrDD)


    valid={};
    invalid={};
    profiles={};
    try

        if isa(archOrDD,'systemcomposer.architecture.model.design.Architecture')

            profiles=archOrDD.p_Model.getProfiles;
        elseif ischar(archOrDD)

            [~,~,ext]=fileparts(archOrDD);
            assert(strcmp(ext,'.sldd'),'Only SLDD are supported');
            ddObj=Simulink.data.dictionary.open(archOrDD);
            interfaceSemanticModel=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddObj.filepath());
            zcModel=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(interfaceSemanticModel);
            pic=zcModel.getPortInterfaceCatalog;
            profiles=pic.getProfiles;
        else

            return;
        end
        allProfs=arrayfun(@(x)x.getName,profiles,'UniformOutput',false);
        baseProfIdx=cellfun(@isequal,repmat({'systemcomposer'},size(allProfs)),allProfs);
        valid=allProfs(~baseProfIdx);


        if isa(archOrDD,'systemcomposer.architecture.model.design.Architecture')
            mdl=mf.zero.getModel(archOrDD);
            for elem=mdl.topLevelElements
                if elem.StaticMetaClass.isA(systemcomposer.internal.profile.ProfileResolver.StaticMetaClass)
                    if~any(strcmp(elem.URI,['systemcomposer',valid]))
                        invalid{end+1}=elem.URI;
                    end
                end
            end
        end


    catch ME

        if isa(archOrDD,'systemcomposer.architecture.model.design.Architecture')
            profProxy=archOrDD.p_Model.getProfileNamespace.ProfileProxy.toArray;

            for pp=profProxy
                if~isempty(pp.Proxy.Target)
                    profName=pp.Proxy.Target.realElement.getName;
                    if~strcmp(profName,'systemcomposer')
                        valid{end+1}=pp.Proxy.Target.realElement.getName;
                    end
                else
                    resolver=pp.Proxy.Resolver.URI;
                    if~strcmp(resolver,'systemcomposer')
                        valid{end+1}=resolver;
                    end
                end
            end


            mdl=mf.zero.getModel(archOrDD);
            for elem=mdl.topLevelElements
                if elem.StaticMetaClass.isA(systemcomposer.internal.profile.ProfileResolver.StaticMetaClass)
                    if~any(strcmp(elem.URI,['systemcomposer',valid]))
                        invalid{end+1}=elem.URI;
                    end
                end
            end
        end

    end

end
