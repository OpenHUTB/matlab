classdef PreferencesDataStore<simmanager.designview.internal.PlotConfigDataStore











    properties(Constant)
        Config=simmanager.designview.internal.PreferencesConfig
    end



    methods
        function obj=PreferencesDataStore()



            obj@simmanager.designview.internal.PlotConfigDataStore();
        end
    end



    methods

        function persist(~,configRegistry)



            import simmanager.designview.internal.PreferencesDataStore

            serializer=PreferencesDataStore.Config.JSONSerializer;
            configRegistryJSON=...
            serializer.serializeToString(configRegistry);

            if~ispref(PreferencesDataStore.Config.Group,...
                PreferencesDataStore.Config.Preference)

                addpref(PreferencesDataStore.Config.Group,...
                PreferencesDataStore.Config.Preference,...
                configRegistryJSON);
            else
                setpref(PreferencesDataStore.Config.Group,...
                PreferencesDataStore.Config.Preference,...
                configRegistryJSON);
            end
        end


        function configRegistry=load(~,dataModel)
            import simmanager.designview.internal.PreferencesDataStore

            if ispref(PreferencesDataStore.Config.Group,...
                PreferencesDataStore.Config.Preference)

                configRegistryJSON=getpref(...
                PreferencesDataStore.Config.Group,...
                PreferencesDataStore.Config.Preference);

                parser=PreferencesDataStore.Config.JSONParser;
                parser.Model=dataModel;

                configRegistry=parser.parseString(configRegistryJSON);
            else
                configRegistry=...
                slsim.design.internal.PlotConfigRegistry(dataModel);
            end
        end


        function clear(~)
            import simmanager.designview.internal.PreferencesDataStore

            rmpref(PreferencesDataStore.Config.Group,...
            PreferencesDataStore.Config.Preference);
        end

    end



end

