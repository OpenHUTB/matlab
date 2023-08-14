function spec=getStereotypeOwner(this)

    if isa(this,'systemcomposer.internal.analysis.NodeInstance')
        if isempty(this.parent)

            spec=this.instanceModel.specification;
        else
            spec=this.specification.getArchitecture;
        end
    elseif isa(this,'systemcomposer.internal.analysis.PortInstance')
        spec=this.specification;
        if isa(spec,'systemcomposer.architecture.model.design.ComponentPort')
            spec=spec.getArchitecturePort;
        end
    else
        spec=this.specification;
    end


