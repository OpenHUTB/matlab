
function[key]=constructKeyForStructFieldsTable(blk_obj,dialog_name)



    blk_full_name=blk_obj.getFullName;

    key=[blk_full_name,':',dialog_name];

end

