function c=setObjectType(c,oType)











    if islogical(oType)
        c.LockType=oType;
        return;
    end

    c.LockType=false;
    termTypes=listTerminalTypes(rptgen_sf.appdata_sf);
    for i=1:length(termTypes)
        set(c,['isReport',termTypes{i}],false);
    end

    set(c,['isReport',oType],true);
    c.LockType=true;