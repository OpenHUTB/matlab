function value=isDlgProperty(blk_obj,property_str)



    all_props=blk_obj.getSLBlockProperties;
    value=any(strcmp(all_props,property_str));
end

