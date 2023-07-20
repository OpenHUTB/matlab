function[res,propInstances]=isFilteredBySubProp(this,ssid)




    res=false;
    propInstances=[];

    props=this.getProperties(ssid);

    for idx=1:numel(props)
        if this.isSubProperty(props(idx))&&this.isFilteredByProp(props(idx))
            propI=this.filterState(this.getPropKey(props(idx)));
            if isempty(propInstances)
                propInstances=propI;
            else
                propInstances(end+1)=propI;
            end
            res=true;
        end
    end
    if res
        this.removeFromCache(ssid);
    end


