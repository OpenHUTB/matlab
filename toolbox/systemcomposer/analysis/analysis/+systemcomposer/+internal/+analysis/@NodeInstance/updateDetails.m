function updateDetails(this)

    spec=this.getSpec();

    if isempty(spec)
        return;
    end

    mvs=this.instanceModel.modelValueSets.toArray;

    if isa(spec,'systemcomposer.architecture.model.design.BaseComponent')

        parentComponent=spec.getParentArchitecture().getParentComponent();
        if isa(parentComponent,...
            'systemcomposer.architecture.model.design.VariantComponent')
            specName=parentComponent.getName();
        else
            specName=spec.getName();
        end
        if~strcmp(this.getName,specName)
            this.changeName(specName);
        end
        arch=spec.getArchitecture();

        try
            currentArch=this.getArchitecture();
        catch
            currentArch=[];
        end

        if isempty(currentArch)||currentArch~=arch







            for port=this.ports.toArray
                port.destroy;
            end
            for connector=this.connectors.toArray
                connector.destroy;
            end
            for child=this.children.toArray
                child.destroy;
            end


            this.specification=spec;

            this.populateDescendants();
            mvs.addInstanceValueSet(this);
        else

            for component=arch.getComponents
                if~this.instanceExists(component)
                    newInstance=this.addNodeFromSpecification(component);
                    mvs.addInstanceValueSet(newInstance);
                end
            end


            ports=spec.getPorts;
            for port=ports
                if~this.instanceExists(port)
                    newInstance=this.addPortFromSpecification(port);
                    mvs.addInstanceValueSet(newInstance);
                end
            end


            for connector=arch.getConnectors
                if~this.instanceExists(connector)
                    newInstance=this.addConnectorFromSpecification(connector);
                    if~isempty(newInstance)
                        mvs.addInstanceValueSet(newInstance);
                    end
                end
            end
        end
    else

        for component=spec.getComponents
            if~this.instanceExists(component)
                newInstance=this.addNodeFromSpecification(component);
                mvs.addInstanceValueSet(newInstance);
            end
        end

        ports=spec.getPorts;
        for port=ports
            if~this.instanceExists(port)
                newInstance=this.addPortFromSpecification(port);
                mvs.addInstanceValueSet(newInstance);
            end
        end


        for connector=spec.getConnectors
            if~this.instanceExists(connector)
                newInstance=this.addConnectorFromSpecification(connector);
                if~isempty(newInstance)
                    mvs.addInstanceValueSet(newInstance);
                end
            end
        end

    end
end
