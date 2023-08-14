function gt=anchor_getGenericType(c)












    gt=c.ObjectType;
    if strncmpi(gt,'auto',4)
        gt=getContextType(rptgen_sl.appdata_sl,c,logical(1));
    end
