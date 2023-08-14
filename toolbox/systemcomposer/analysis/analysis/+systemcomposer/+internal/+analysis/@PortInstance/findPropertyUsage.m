function usage=findPropertyUsage(this,requiredUsage)


    usage=[];

    if~isempty(this.specification)

        usage=this.specification.getPropertySet(requiredUsage.getName);
        if isempty(usage)&&isa(this.specification,'systemcomposer.architecture.model.design.ComponentPort')
            source=this.specification.getArchitecturePort;

            usage=source.getPropertySet(requiredUsage.getName);
        end
    end
end

