function split_entity_arch=set_split_entity_arch(this,split_entity_arch)




    if split_entity_arch&&this.isverilog
        split_entity_arch=false;
        warning(message('HDLShared:CLI:invalidSetting'));
    end
end
