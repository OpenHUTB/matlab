
function[indices]=getStructIndices(config,blk_obj,dialog_name)




    indices=[];

    indices_struct_tab=config.getStructIndicesTable();

    key=slci.internal.constructKeyForStructFieldsTable(blk_obj,dialog_name);

    if(isKey(indices_struct_tab,key))
        indices=indices_struct_tab(key);
    end

end
