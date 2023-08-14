function pu=getPropertyUsagesForInstance(this,instance)




    candidates=systemcomposer.property.PropertySetUsage.empty;

    if isempty(instance.specification)

        spec=this.specification;
        instanceKind='Component';
    else


        if isa(instance,'systemcomposer.internal.analysis.NodeInstance')
            instanceKind='Component';
            if(isa(instance.specification,'systemcomposer.architecture.model.design.VariantComponent'))
                wrapper=systemcomposer.internal.getWrapperForImpl(instance.specification);
                comp=wrapper.getActiveChoice().getImpl;
            else
                comp=instance.specification;
            end
            spec=comp.getArchitecture();

        elseif isa(instance,'systemcomposer.internal.analysis.PortInstance')
            instanceKind='Port';
            if isa(instance.specification,'systemcomposer.architecture.model.design.ComponentPort')
                spec=instance.specification.getArchitecturePort;
            else
                spec=instance.specification;
            end
        elseif isa(instance,'systemcomposer.internal.analysis.ConnectorInstance')
            instanceKind='Connector';
            spec=instance.specification;
        else
            pu=candidates;
            return;
        end
    end


    m=this.mapping.getByKey(instanceKind);
    if~isempty(m)
        candidates=m.usages.toArray;
    end

    if this.isStrict
        pu=systemcomposer.property.PropertySetUsage.empty;


        for c=candidates
            if~isempty(spec.getPropertySet(c.getName))
                pu(end+1)=c;
            end
        end
    else
        pu=candidates;
    end
end
