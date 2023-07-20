function port=addPortFromSpecification(this,specification)

    port=this.instanceModel.addInstanceForSpecification(specification);

    port.populate(specification);
    this.ports.add(port);
end

