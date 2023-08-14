function portInterfaceNames=getPortInterfaces(archName)
    try
        bdH=get_param(archName,'handle');
        dd=get_param(bdH,'DataDictionary');

        if~isempty(dd)
            ddObj=Simulink.data.dictionary.open(dd);
            mf0Model=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddObj.filepath());
        else
            app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
            mf0Model=app.getCompositionArchitectureModel;
        end

        portInterfaceCatalog=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(mf0Model);
        portInterfaceNames=portInterfaceCatalog.getPortInterfaceNames();
    catch
        portInterfaceNames={};
    end
end

