function itemFactory=createSignalItemFactory(name,data)




    if isStringScalar(name)
        name=char(name);
    end

    pluginManager=starepository.factory.FactoryPluginManager();
    itemFactory=pluginManager.getSupportedFactory(name,data);

