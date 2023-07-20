function intrf=resolvePortInterfaceAssociationUsingName(archPort,ddFileSpec)

    intrf=[];
    mf0Model=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddFileSpec);
    if~isempty(mf0Model)
        catalogImpl=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(mf0Model);
        piUsage=archPort.p_InterfaceUsage;
        if~isempty(catalogImpl)&&~isempty(piUsage)
            piName=piUsage.p_InterfaceName;
            if~isempty(piName)
                intrf=catalogImpl.getPortInterfaceInClosureByName('',piName);
                if~isempty(intrf)
                    txn=mf.zero.getModel(catalogImpl).beginTransaction;
                    piUsage.setPropertyValue('p_SharedInterface',intrf);
                    txn.commit;
                end
            end
        end
    end

end

