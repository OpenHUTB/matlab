function refreshDictionaryTool(cbinfo,action)




    if isvalid(action)
        studio=cbinfo.studio;
        context=...
        systemcomposer.internal.getInterfaceCatalogStorageContext(studio);
        if strcmp(context,'Dictionary')
            action.enabled=false;
        else
            action.enabled=true;
        end
    end
end
