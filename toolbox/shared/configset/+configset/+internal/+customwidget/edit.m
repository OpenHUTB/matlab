function updateDeps=edit(cs,msg)


    updateDeps=false;
    name=msg.name;
    mcs=configset.internal.getConfigSetStaticData;
    pName=mcs.WidgetNameMap(name);
    val=cs.getProp(pName);

    if~isempty(val)
        edit(val);
    end

