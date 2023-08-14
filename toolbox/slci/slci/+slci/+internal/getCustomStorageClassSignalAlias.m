





function id=getCustomStorageClassSignalAlias(config,blk_obj,sig_obj,sig_name)


    id=[];

    ws_vars=config.getWSVarInfoTable;
    if(isKey(ws_vars,sig_name))
        blk_full_name=blk_obj.getFullName;
        vars=ws_vars(sig_name);
        if(isKey(vars,blk_full_name)&&strcmpi(vars(blk_full_name).StorageClass,'Custom'))
            id=vars(blk_full_name).Alias;
        end
    end

    if(isempty(id)&&~isempty(sig_obj)&&strcmpi(sig_obj.CoderInfo.StorageClass,'Custom'))

        prop=slci.internal.extractDataObjectInfo(config.getModelName,sig_obj);

        if(~isempty(prop)&&~isempty(prop.Alias))
            id=prop.Alias;
        end
    end

end

