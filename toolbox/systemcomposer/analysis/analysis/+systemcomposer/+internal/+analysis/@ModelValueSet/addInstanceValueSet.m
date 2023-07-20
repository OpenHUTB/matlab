function vs=addInstanceValueSet(this,instance)


    if isempty(instance.propertyValues.getByKey(this.UUID))
        model=mf.zero.getModel(this);
        vs=systemcomposer.internal.analysis.ValueSet(model);
        this.valueSets.add(vs);

        vs.populate(instance);
    end

    if(isa(instance,'systemcomposer.internal.analysis.NodeInstance'))

        connectors=instance.connectors.toArray;
        for ci=1:length(connectors)
            this.addInstanceValueSet(connectors(ci));
        end

        ports=instance.ports.toArray;
        for ci=1:length(ports)
            this.addInstanceValueSet(ports(ci));
        end

        nodes=instance.children.toArray;
        for ci=1:length(nodes)
            this.addInstanceValueSet(nodes(ci));
        end
    end
end