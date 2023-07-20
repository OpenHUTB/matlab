function res=isFilteredWithDescendants(this,ssid)





    res=false;
    [r,props]=this.isFiltered(ssid);
    if r
        if~isempty(props)
            res=any([props.includeChildren]);
        end
    end
