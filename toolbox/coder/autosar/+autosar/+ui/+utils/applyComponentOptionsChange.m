function applyComponentOptionsChange(dlg,m3iComp)





    newCompPackage=dlg.getWidgetValue('CompPkgTextTag');
    newInternalBehaviorName=dlg.getWidgetValue('CompIBQName');
    newImplName=dlg.getWidgetValue('CompImpQName');


    m3iModel=m3iComp.modelM3I;
    m3iRoot=m3iModel.RootPackage.front;
    maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(m3iModel);


    if isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication')

        newValues={newCompPackage};


        newInternalBehaviorName=autosar.mm.util.XmlOptionsAdapter.get(...
        m3iComp,'InternalBehaviorQualifiedName');
        newImplName=autosar.mm.util.XmlOptionsAdapter.get(...
        m3iComp,'ImplementationQualifiedName');
    else
        newValues={newCompPackage,newInternalBehaviorName,newImplName};
    end

    for i=1:length(newValues)
        idcheckmessage=autosar.ui.utils.isValidARIdentifier(newValues{i},'absPath',...
        maxShortNameLength);
        if~isempty(idcheckmessage)
            error(idcheckmessage);
        end
    end


    isRefSharedDict=Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(m3iModel);
    if isRefSharedDict
        sharedM3IModel=autosar.dictionary.Utils.getUniqueReferencedModel(m3iModel);
        m3iRootShared=sharedM3IModel.RootPackage.front;
        datatypePackage=m3iRootShared.DataTypePackage;
        interfacePackage=m3iRootShared.InterfacePackage;
    else
        datatypePackage=m3iRoot.DataTypePackage;
        interfacePackage=m3iRoot.InterfacePackage;
    end

    [foundDuplicate,msg]=autosar.mm.util.checkAmbigousXmlOptions(m3iRoot,...
    newCompPackage,datatypePackage,interfacePackage,newImplName);
    if foundDuplicate
        error(msg);
    end

    domain=m3iRoot.Domain;
    trans=M3I.Transaction(domain);


    try
        oldCompQName=autosar.api.Utils.getQualifiedName(m3iComp);
        [oldCompPackage,compName,~]=fileparts(oldCompQName);
        newCompQName=[newCompPackage,'/',compName];
        if~strcmp(newCompPackage,oldCompPackage)
            try

                autosar.api.Utils.syncComponentQualifiedName(m3iRoot,oldCompQName,newCompQName);
            catch exObj
                DAStudio.error(exObj.identifier,exObj.message)
            end
        end

        oldInternalBehaviorName=autosar.mm.util.XmlOptionsAdapter.get(...
        m3iComp,'InternalBehaviorQualifiedName');
        if~strcmp(oldInternalBehaviorName,newInternalBehaviorName)
            autosar.mm.util.XmlOptionsAdapter.set(...
            m3iComp,'InternalBehaviorQualifiedName',newInternalBehaviorName);
        end

        oldImplName=autosar.mm.util.XmlOptionsAdapter.get(...
        m3iComp,'ImplementationQualifiedName');
        if~strcmp(oldImplName,newImplName)
            autosar.mm.util.XmlOptionsAdapter.set(...
            m3iComp,'ImplementationQualifiedName',newImplName);
        end

    catch e
        trans.cancel();
        DAStudio.error(e.identifier,e.message)
    end

    trans.commit();


    dlg.apply();
end



