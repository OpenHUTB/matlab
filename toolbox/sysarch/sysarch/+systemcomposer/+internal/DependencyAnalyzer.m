classdef DependencyAnalyzer<handle

    properties
        models={};
        profiles={};
        interfaceDictionaries={};
    end


    methods(Static)
        function obj=getDependencies(filePath)



            obj=systemcomposer.internal.DependencyAnalyzer;

            [~,name,ext]=fileparts(filePath);

            if strcmpi(ext,'.slx')
                obj.buildModelDependencies(name,true);
            elseif strcmpi(ext,'.xml')
                obj.buildProfileDependencies(name);
            elseif strcmpi(ext,'.sldd')
                obj.buildIntrfDictionaryDependencies(name);
            else
                error('Unsupported artifact type');
            end
        end
    end

    methods(Access=private)
        function buildModelDependencies(obj,modelName,isTop)
            mf0Model=obj.getArchMF0Model(modelName,isTop);
            if(~isempty(mf0Model)&&obj.addModel(modelName))

                resolvers=obj.getResolvers(mf0Model);
                for resolver=resolvers
                    obj.buildDepenencyForResolver(resolver);
                end
            end
        end


        function buildProfileDependencies(obj,profileName)
            if(obj.addProfile(profileName))
                mf0Model=obj.getProfileMF0Model(profileName);
                resolvers=obj.getResolvers(mf0Model);
                for resolver=resolvers
                    obj.buildDepenencyForResolver(resolver);
                end
            end
        end

        function buildIntrfDictionaryDependencies(obj,ddName)
            if(obj.addDD(ddName))
                mf0Model=obj.getDDMF0Model(ddName);
                resolvers=obj.getResolvers(mf0Model);
                for resolver=resolvers
                    obj.buildDepenencyForResolver(resolver);
                end
            end
        end

        function buildDepenencyForResolver(obj,resolver)
            if isa(resolver,'systemcomposer.services.proxy.SysArchCompModelResolver')
                obj.buildModelDependencies(resolver.getFileName,false);
            elseif isa(resolver,'systemcomposer.internal.profile.ProfileResolver')
                obj.buildProfileDependencies(resolver.getFileName);
            elseif isa(resolver,'systemcomposer.services.proxy.DictionaryResolver')
                obj.buildIntrfDictionaryDependencies(resolver.getFileName);
            elseif isa(resolver,'systemcomposer.services.proxy.SysArchProtectedCompModelResolver')
                obj.addModel([resolver.getFileName,'.slxp']);
            end
        end

        function tf=addModel(obj,modelName)
            tf=false;
            if~any(contains(obj.models,modelName))
                tf=true;
                obj.models=[obj.models,modelName];
            end
        end

        function tf=addProfile(obj,profileName)
            tf=false;
            if~any(contains(obj.profiles,profileName))
                tf=true;
                obj.profiles=[obj.profiles,profileName];
            end
        end

        function tf=addDD(obj,ddName)
            tf=false;
            if~any(contains(obj.interfaceDictionaries,ddName))
                tf=true;
                obj.interfaceDictionaries=[obj.interfaceDictionaries,ddName];
            end
        end

        function mfModel=getArchMF0Model(~,modelName,isTop)
            mfModel=[];
            if isTop



                try
                    h=load_system(modelName);
                    mfModel=get_param(h,'SystemComposerMF0Model');
                catch
                end
            else

                zcModel=systemcomposer.architecture.model.SystemComposerModel.findSystemComposerModel(modelName,false);
                if~isempty(zcModel)
                    mfModel=mf.zero.getModel(zcModel);
                    return;
                end


                zcModel=systemcomposer.architecture.model.SystemComposerModel.findSystemComposerModel(modelName,true);
                if~isempty(zcModel)
                    mfModel=mf.zero.getModel(zcModel);
                    return;
                end
            end
        end

        function mfModel=getProfileMF0Model(~,profileName)
            p=systemcomposer.profile.Profile.load(profileName);
            mfModel=mf.zero.getModel(p.getImpl);
        end

        function mfModel=getDDMF0Model(~,ddName)
            ddConn=Simulink.data.dictionary.open([ddName,'.sldd']);
            mfModel=...
            Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(...
            ddConn.filepath());
        end

        function resolvers=getResolvers(~,model)
            topElems=model.topLevelElements;
            resolvers=[];
            for topElem=topElems
                if(isa(topElem,'systemcomposer.services.proxy.ModelResolver')&&...
                    ~isa(topElem,'systemcomposer.services.proxy.CurrentModelResolver'))
                    resolvers=[resolvers,topElem];%#ok<AGROW>
                end
            end
        end
    end

end




