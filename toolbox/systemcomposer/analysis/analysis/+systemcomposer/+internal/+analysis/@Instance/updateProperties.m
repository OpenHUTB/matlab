function updateProperties(this,vs,reset)
    allowedUsages=this.instanceModel.getPropertyUsagesForInstance(this);
    allowedMap=containers.Map();
    for usage=allowedUsages
        psv=vs.values.getByKey(usage.getName);
        allowedMap(usage.getName)=true;
        if isempty(psv)
            instanceUsage=this.findPropertyUsage(usage);
            if isempty(instanceUsage)
                instanceUsage=usage;
            end
            if(usage.properties.Size>0)
                psv=systemcomposer.internal.analysis.PropertySetValue.createFromUsage(usage,instanceUsage,this);
                vs.values.add(psv);
            end
        else
            psv.update(usage,this,reset);
        end
    end


    for value=vs.values.toArray
        if~allowedMap.isKey(value.getName)
            value.destroy();
        end
    end
end
