function ctx=getCodeInterfaceContext(mdl)





    ecd=get_param(mdl,'EmbeddedCoderDictionary');
    if isempty(ecd)
        ctx='CodeInterface_ModelOwned';
    else
        platform=get_param(mdl,'PlatformDefinition');
        if isempty(platform)
            ctx='CodeInterface_ModelOwned';
        elseif strcmp(platform,'Embedded Code')
            ctx='CodeInterface_DataFunctions';
        else
            ctx='CodeInterface_Services';
        end
    end
