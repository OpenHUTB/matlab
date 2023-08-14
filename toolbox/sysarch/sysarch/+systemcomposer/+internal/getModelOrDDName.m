function[bdOrDDName,interfaceCatalogStorageContext]=getModelOrDDName(studioOrHdl)








    if isa(studioOrHdl,'DAS.Studio')
        bdH=studioOrHdl.App.blockDiagramHandle;
    else
        bdH=studioOrHdl;
    end

    bdOrDDName=get_param(bdH,'Name');
    interfaceCatalogStorageContext=...
    systemcomposer.architecture.model.interface.Context.MODEL;
    dd=get_param(bdH,'DataDictionary');
    try
        if~isempty(dd)
            interfaceCatalogStorageContext=systemcomposer.architecture.model.interface.Context.DICTIONARY;
            ddObj=Simulink.data.dictionary.open(dd);
            ddFilePath=ddObj.filepath();
            [~,bdOrDDName,~]=fileparts(ddFilePath);
        end
    catch ex


        diagnosticViewerStage=sldiagviewer.createStage(message('SystemArchitecture:Interfaces:InterfaceAccess').getString(),'ModelName',get_param(bdH,'Name'));%#ok
        sldiagviewer.reportError(ex);
    end
    interfaceCatalogStorageContext=...
    systemcomposer.InterfaceEditor.TranslateContextEnumToStr(interfaceCatalogStorageContext);
end
