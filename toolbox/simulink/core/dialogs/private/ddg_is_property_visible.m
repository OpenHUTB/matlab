function result=ddg_is_property_visible(obj,property)




    if ddg_object_has_method(obj,'isValidProperty',2,1)
        result=isValidProperty(obj,property.Name);
        return;
    end

    switch Simulink.data.getScalarObjectLevel(property)
    case 1
        result=(strcmp(property.Visible,'on')&&...
        strcmp(property.AccessFlags.PublicGet,'on'));
    case 2
        result=((property.Hidden==false)&&...
        (strcmp(property.GetAccess,'public')));
    otherwise
        assert(false);
    end


