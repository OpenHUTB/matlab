function me=transferCauses(meFrom,meTo)



    me=meTo;
    cs=meFrom.cause;
    for i=1:numel(cs)
        me=me.addCause(cs{i});
    end