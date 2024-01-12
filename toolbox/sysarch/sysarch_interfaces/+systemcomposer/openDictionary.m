function idict=openDictionary(dictionaryName)
    ddConn=Simulink.data.dictionary.open(dictionaryName);
    idictImplMF0Model=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(...
    ddConn.filepath());
    idictImpl=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(idictImplMF0Model);
    idict=systemcomposer.interface.Element.getObjFromImpl(idictImpl);

end