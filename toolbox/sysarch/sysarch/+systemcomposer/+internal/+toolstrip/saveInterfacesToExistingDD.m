
function saveInterfacesToExistingDD(cbinfo)
    studio=cbinfo.studio;
    [bdOrDDName,interfaceCatalogStorageContext]=...
    systemcomposer.internal.getModelOrDDName(studio);
    systemcomposer.InterfaceEditor.saveInterfacesToExistingDD(...
    bdOrDDName,...
    interfaceCatalogStorageContext);
end