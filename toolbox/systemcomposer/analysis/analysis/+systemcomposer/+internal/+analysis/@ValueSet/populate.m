function populate(this,instance)

    this.parentSetUUID=this.parentSet.UUID;
    this.instance=instance;
    pu=this.parentSet.getPropertyUsagesForInstance(instance);

    if~isempty(pu)

        for ui=1:length(pu)
            usage=pu(ui);

            instanceUsage=instance.findPropertyUsage(usage);
            if isempty(instanceUsage)
                instanceUsage=usage;
            end


            if(usage.properties.Size>0)


                vps=systemcomposer.internal.analysis.PropertySetValue.createFromUsage(usage,instanceUsage,instance);
                this.values.add(vps);
            end
        end
    end
end

