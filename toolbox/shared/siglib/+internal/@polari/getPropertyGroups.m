function group=getPropertyGroups(obj)


    if~isvalid(obj)
keyboard
        s=matlab.mixin.CustomDisplay.getDeletedHandleText(obj);
        group=matlab.mixin.util.PropertyGroup('','Invalid or deleted object.');
        return
    end
    if~isscalar(obj)

        group=getPropertyGroups@matlab.mixin.CustomDisplay(obj);
        return
    end
    if obj.pShowAllProperties
        group=displayGroupLong(obj);
    else
        group=displayGroupShort(obj,inputname(1));
    end
