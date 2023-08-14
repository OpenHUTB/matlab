function deleteInterfaceOrInterfaceElement(this,portElementUUID,parentElementUUID)






    systemcomposer.InterfaceEditor.NotifyPropertyInspectorOfElementDeletion(...
    this.contextName,this.context)

    portElement=this.mf0Model.findElement(portElementUUID);






    if~isempty(portElement)&&isa(portElement,'systemcomposer.architecture.model.interface.PortInterface')

        if~isempty(portElement.getPorts())

            confirm=questdlg(...
            message('SystemArchitecture:Interfaces:ConfirmInterfaceDelete',portElement.getName()).string,...
            message('SystemArchitecture:Interfaces:ConfirmInterfaceDeleteTitle').string,...
            message('SystemArchitecture:Interfaces:ConfirmInterfaceDelete_Yes').string,...
            message('SystemArchitecture:Interfaces:ConfirmInterfaceDelete_No').string,...
            message('SystemArchitecture:Interfaces:ConfirmInterfaceDelete_Help').string,...
            message('SystemArchitecture:Interfaces:ConfirmInterfaceDelete_No').string);
            if isempty(confirm)||strcmp(confirm,message('SystemArchitecture:Interfaces:ConfirmInterfaceDelete_No').string)

                return;
            end
        end

        systemcomposer.BusObjectManager.DeleteInterface(this.getContextName,this.isModelContext,portElement.getName);


        systemcomposer.InterfaceEditor.ClearSelection(this.contextName,this.context);

    elseif~isempty(portElement)&&~isa(portElement,'systemcomposer.architecture.model.interface.InterfaceCatalog')&&~isempty(parentElementUUID)
        portInterface=this.mf0Model.findElement(parentElementUUID);

        if(~isempty(portInterface))
            systemcomposer.BusObjectManager.DeleteInterfaceElement(this.getContextName,...
            this.isModelContext,portInterface.getName,portElement.getName);
        end
    elseif~isempty(portElement)&&isa(portElement,'systemcomposer.architecture.model.interface.InterfaceElement')&&isempty(parentElementUUID)

        if isa(portElement,'systemcomposer.architecture.model.interface.DataElement')&&portElement.p_ParentDataInterface.isAnonymous
            aPort=portElement.p_ParentDataInterface.p_AnonymousUsage.p_Port;
            systemcomposer.AnonymousInterfaceManager.DeleteInlinedInterfaceElement(aPort,portElement.getName);
        elseif isa(portElement,'systemcomposer.architecture.model.interface.PhysicalElement')&&portElement.p_PhysicalInterface.isAnonymous
            aPort=portElement.p_PhysicalInterface.p_AnonymousUsage.p_Port;
            systemcomposer.AnonymousInterfaceManager.DeleteInlinedInterfaceElement(aPort,portElement.getName);
        end
    end

end
