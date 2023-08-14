function setFilter(this,ssid,rationale)




    props=this.getProperties(ssid);
    if numel(props)==1
        this.setFilterByProp(props,rationale);
    else
        for idx=1:numel(props)
            if this.hasSSID(props(idx))
                this.setFilterByProp(props(idx),rationale);
                break;
            end
        end
    end


