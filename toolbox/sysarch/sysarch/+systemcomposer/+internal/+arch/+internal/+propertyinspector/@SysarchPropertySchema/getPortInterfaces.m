function portInterfaceNames=getPortInterfaces(this,archName,port)




    intrfKinds='';
    if nargin>2
        if port.getPortAction==systemcomposer.architecture.model.core.PortAction.PHYSICAL
            intrfKinds='Physical';
        elseif(port.getPortAction==systemcomposer.architecture.model.core.PortAction.CLIENT||...
            port.getPortAction==systemcomposer.architecture.model.core.PortAction.SERVER)
            intrfKinds='Service';
        else
            intrfKinds='Data';
        end
    end


    try
        bdH=get_param(archName,'handle');
        dd=get_param(bdH,'DataDictionary');

        if~isempty(dd)
            [isInterfaceDict,interfaceDicts]=...
            Simulink.interface.dictionary.internal.DictionaryClosureUtils.isModelLinkedToInterfaceDict(...
            bdH);
            if isInterfaceDict



                portInterfaceNames={};
                for dictIdx=1:length(interfaceDicts)
                    interfaceDict=interfaceDicts{dictIdx};
                    interfaceDictAPI=Simulink.interface.dictionary.open(interfaceDict);
                    interfaceNames=interfaceDictAPI.getInterfaceNames();
                    isPrimaryDict=strcmp(dd,interfaceDictAPI.DictionaryFileName);
                    if~isPrimaryDict
                        [~,prefix]=fileparts(interfaceDictAPI.DictionaryFileName);
                        interfaceNames=strcat([prefix,'::'],interfaceNames);
                    end
                    portInterfaceNames=[portInterfaceNames,interfaceNames];%#ok<AGROW> 
                end
            else
                ddObj=Simulink.data.dictionary.open(dd);
                mf0Model=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddObj.filepath());
                portInterfaceCatalog=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(mf0Model);
                portInterfaces=portInterfaceCatalog.getPortInterfacesInClosure(intrfKinds);
                primaryNames={};
                referenceNames={};
                for idx=1:numel(portInterfaces)
                    intrf=portInterfaces(idx);
                    piCatalog=intrf.getCatalog;
                    if piCatalog==portInterfaceCatalog

                        primaryNames=[primaryNames,intrf.getName];
                    else


                        referenceNames=[referenceNames,[piCatalog.getStorageSource,'::',intrf.getName]];
                    end
                end
                portInterfaceNames=[primaryNames,referenceNames];
            end
        else

            app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
            mf0Model=app.getCompositionArchitectureModel;
            portInterfaceCatalog=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(mf0Model);
            portInterfaceNames=portInterfaceCatalog.getPortInterfaceNamesInClosure(intrfKinds);
        end
    catch
        portInterfaceNames={};
    end
end

