function updateError(obj,error,flag)






    s.name=error.name;
    if flag
        s.error=error.error;
    end
    if isa(error.data,'configset.internal.data.WidgetStaticData')
        s.parameter=error.data.Parameter.Name;
    end

    obj.publish('err',s);

