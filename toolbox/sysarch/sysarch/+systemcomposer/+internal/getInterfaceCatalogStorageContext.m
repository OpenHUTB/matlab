function context=getInterfaceCatalogStorageContext(studioOrHdl)





    if isa(studioOrHdl,'DAS.Studio')
        bdH=studioOrHdl.App.blockDiagramHandle;
    else
        bdH=studioOrHdl;
    end

    context=...
    systemcomposer.architecture.model.interface.Context.MODEL;
    dd=get_param(bdH,'DataDictionary');
    if~isempty(dd)
        context=systemcomposer.architecture.model.interface.Context.DICTIONARY;
    end
    context=...
    systemcomposer.InterfaceEditor.TranslateContextEnumToStr(context);
end
