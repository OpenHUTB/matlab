function copyRulesFrom(this,anotherFilter)




    keys=anotherFilter.filterState.keys;
    for idx=1:numel(keys)
        prop=anotherFilter.filterState(keys{idx});
        if anotherFilter.isMetricProperty(prop)
            values=prop.value;
            for jdx=1:numel(values)
                this.addMetricFilter(values(jdx).ssid,values(jdx).name,values(jdx).idx,...
                values(jdx).outcomeIdx,values(jdx).mode,values(jdx).rationale,values(jdx).valueDesc);
            end
        elseif anotherFilter.isRteProperty(prop)
            values=prop.value;
            for jdx=1:numel(values)
                this.addRteFilter(values(jdx).ssid,values(jdx).name,values(jdx).idx,...
                values(jdx).outcomeIdx,values(jdx).mode,values(jdx).rationale,values(jdx).valueDesc);
            end
        else
            this.setFilterByProp(prop,prop.Rationale);
        end
    end
end

