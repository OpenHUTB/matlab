function result=ddg_is_property_enabled(obj,property)




    result=false;

    if~ddg_is_property_visible(obj,property)
        return;
    end

    if ddg_object_has_method(obj,'isReadonlyProperty',2,1)
        result=~isReadonlyProperty(obj,property.Name);
        return;
    end

    switch Simulink.data.getScalarObjectLevel(property)
    case 1
        result=strcmp(property.AccessFlags.PublicSet,'on');
    case 2
        result=strcmp(property.SetAccess,'public');
    otherwise
        assert(false);
    end


