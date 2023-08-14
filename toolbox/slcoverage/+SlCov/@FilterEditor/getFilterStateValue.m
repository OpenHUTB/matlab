function text=getFilterStateValue(this,ssid,fieldName)




    text=[];
    [isCached,~,props]=this.isCached(ssid);
    if~isCached
        props=this.getProperties(ssid);
    end

    for idx=1:numel(props)
        cp=props(idx);
        if this.isFilteredByProp(cp)
            value=this.filterState(this.getPropKey(cp));
            if isfield(cp,fieldName)
                text=value.(fieldName);
            end
            return;
        end
    end


