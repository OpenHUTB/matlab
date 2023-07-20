function[res,propInstance]=isFilteredByRte(this,ssid,rteObjType)





    propInstance=[];

    v.ssid=ssid;
    v.type='rte';
    v.name=rteObjType;
    prop.value=v;
    res=this.isFilteredByProp(prop);
    if res
        propInstance=this.filterState(this.getPropKey(prop));
    end

