function setInterfaceElementType(this,intrfElementUUID,newType)





    intrfElement=this.mf0Model.findElement(intrfElementUUID);


    newIntrf=this.piCatalog.getPortInterfaceInClosureByName('',newType);
    if isa(newIntrf,'systemcomposer.architecture.model.interface.CompositeDataInterface')||...
        isa(newIntrf,'systemcomposer.architecture.model.interface.CompositePhysicalInterface')
        typeStr=['Bus: ',newType];
    else
        assert(isa(newIntrf,'systemcomposer.architecture.model.interface.ValueTypeInterface'));
        typeStr=['ValueType: ',newType];
    end

    if isa(intrfElement,'systemcomposer.architecture.model.swarch.FunctionArgument')
        assert(~isa(newIntrf,'systemcomposer.architecture.model.interface.CompositePhysicalInterface'));
        systemcomposer.BusObjectManager.SetFunctionArgumentProperty(this.getContextName,...
        this.isModelContext,intrfElement.getInterface.getName,intrfElement.getFunctionElement.getName,...
        intrfElement.getName,'Type',typeStr);
    else
        systemcomposer.BusObjectManager.SetInterfaceElementProperty(this.getContextName,...
        this.isModelContext,intrfElement.getInterface.getName,...
        intrfElement.getName,'Type',typeStr);
    end

end
