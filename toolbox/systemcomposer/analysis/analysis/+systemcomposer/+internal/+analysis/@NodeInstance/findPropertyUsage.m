function usage=findPropertyUsage(this,requiredUsage)


    usage=[];

    if isempty(this.specification)

        if isempty(this.parent)

            usage=this.instanceModel.specification.getPropertySet(requiredUsage.getName);
        end
    else
        if(isa(this.specification,'systemcomposer.architecture.model.design.VariantComponent'))
            wrapper=systemcomposer.internal.getWrapperForImpl(this.specification);
            spec=wrapper.getActiveChoice().getImpl;
        else
            spec=this.specification;
        end

        usage=spec.getPropertySet(requiredUsage.getName);
        if isempty(usage)

            source=spec.getArchitecture;
            usage=source.getPropertySet(requiredUsage.getName);
        end
    end

end

