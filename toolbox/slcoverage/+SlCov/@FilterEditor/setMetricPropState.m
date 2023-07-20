function setMetricPropState(this,prop)




    prop=findMetricProp(this,prop);

    if~isempty(prop)
        this.setFilterByProp(prop,'');
    end
end

function prop=findMetricProp(this,tprop)
    propKey=this.getPropKey(tprop);
    prop=tprop;
    if this.filterState.isKey(propKey)
        prop=this.filterState(propKey);
    else
        return;
    end

    tv=tprop.value;

    for fidx=1:numel(prop.value)
        if(prop.value(fidx).idx==tv.idx)
            if~isempty(prop.value(fidx).outcomeIdx)&&...
                prop.value(fidx).outcomeIdx~=tv.outcomeIdx
                continue;
            end
            assert(isequal(prop.value(fidx).name,tv.name));
            prop.value(fidx).mode=tv.mode;
            prop.value(fidx).rationale=tv.rationale;
        end
    end
end

