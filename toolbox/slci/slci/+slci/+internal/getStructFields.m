
function[fields]=getStructFields(config,blk_obj,dialog_name)


    fields=[];

    fields_struct_tab=config.getStructFieldsTable();

    key=slci.internal.constructKeyForStructFieldsTable(blk_obj,dialog_name);

    if(isKey(fields_struct_tab,key))
        fields=fields_struct_tab(key);
    end

end
