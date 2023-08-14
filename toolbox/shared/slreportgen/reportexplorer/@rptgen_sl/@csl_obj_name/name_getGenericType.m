function gt=name_getGenericType(c)












    if strncmpi(c.ObjectType,'auto',4)
        gt=getContextType(rptgen_sl.appdata_sl,c,logical(0));
    else
        gt=c.ObjectType;
    end
