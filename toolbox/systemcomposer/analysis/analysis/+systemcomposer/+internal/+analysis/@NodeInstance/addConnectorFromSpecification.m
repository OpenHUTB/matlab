function connector=addConnectorFromSpecification(this,specification)
    connector=this.instanceModel.addInstanceForSpecification(specification);
    if connector.populate(specification,this)
        this.connectors.add(connector);
    else



        this.instanceModel.deleteInstance(connector);
        connector.destroy();
        connector=systemcomposer.internal.analysis.ConnectorInstance.empty;
    end
end


