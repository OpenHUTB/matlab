function update(this,usage,instance,reset)

    sourceUsage=usage;

    specUsage=instance.getSpecificationUsage(usage.getName);
    if~isempty(specUsage)
        sourceUsage=specUsage;
    end

    for u=usage.properties.toArray
        su=sourceUsage.getPropertyUsage(u.getName);

        pv=this.values.getByKey(su.getName);
        if isempty(pv)
            pv=systemcomposer.internal.analysis.PropertyValue.createFromUsage(su,mf.zero.getModel(this));
            this.value.add(pv);
        else
            try

                oldUsage=pv.usage;
            catch ex
                oldUsage=su;
            end
            if oldUsage~=su
                reset=true;
            end

            pv.update(instance,su,reset,instance.instanceModel.normalizeUnits);
        end
    end
end

