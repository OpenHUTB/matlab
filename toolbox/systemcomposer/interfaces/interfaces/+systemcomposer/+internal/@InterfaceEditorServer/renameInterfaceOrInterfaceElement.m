function renameInterfaceOrInterfaceElement(this,portElementUUID,newName)




    portElement=this.mf0Model.findElement(portElementUUID);

    if~isempty(portElement)
        if isa(portElement,'systemcomposer.architecture.model.interface.DataElement')
            if(portElement.p_ParentDataInterface.isAnonymous)
                aPort=portElement.p_ParentDataInterface.p_AnonymousUsage.p_Port;
                systemcomposer.AnonymousInterfaceManager.RenameInlinedInterfaceElement(aPort,portElement.getName,newName);
                return;
            end
        elseif isa(portElement,'systemcomposer.architecture.model.interface.PhysicalElement')
            if(portElement.p_PhysicalInterface.isAnonymous)
                aPort=portElement.p_PhysicalInterface.p_AnonymousUsage.p_Port;
                systemcomposer.AnonymousInterfaceManager.RenameInlinedInterfaceElement(aPort,portElement.getName,newName);
                return;
            end
        end
    end


    if isa(portElement,'systemcomposer.architecture.model.interface.DataInterface')||...
        isa(portElement,'systemcomposer.architecture.model.interface.PhysicalInterface')||...
        isa(portElement,'systemcomposer.architecture.model.swarch.ServiceInterface')
        systemcomposer.BusObjectManager.RenameInterface(this.getContextName,...
        this.isModelContext,portElement.getName,newName);
    elseif isa(portElement,'systemcomposer.architecture.model.interface.DataElement')||...
        isa(portElement,'systemcomposer.architecture.model.interface.PhysicalElement')
        systemcomposer.BusObjectManager.RenameInterfaceElement(this.getContextName,...
        this.isModelContext,portElement.getInterface().getName,...
        portElement.getName,newName);
    elseif isa(portElement,'systemcomposer.architecture.model.swarch.FunctionElement')
        systemcomposer.BusObjectManager.RenameFunctionElement(this.getContextName,...
        this.isModelContext,portElement.getInterface().getName,...
        portElement.getName,newName);
    elseif isa(portElement,'systemcomposer.architecture.model.swarch.FunctionArgument')
        systemcomposer.BusObjectManager.RenameFunctionArgument(this.getContextName,...
        this.isModelContext,portElement.getFunctionElement().getInterface().getName,...
        portElement.getFunctionElement().getName,portElement.getName(),newName);
    end

end
