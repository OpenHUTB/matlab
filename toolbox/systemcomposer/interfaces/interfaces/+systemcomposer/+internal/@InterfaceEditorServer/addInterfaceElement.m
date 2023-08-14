function obj=addInterfaceElement(this,semanticElemUUID)




    semanticElem=this.mf0Model.findElement(semanticElemUUID);

    obj=[];
    if(isempty(semanticElem))
        return;
    end

    if isa(semanticElem,'systemcomposer.architecture.model.design.ArchitecturePort')


        elementName=getElementName(semanticElem.getPortInterface(),'elem');

        systemcomposer.AnonymousInterfaceManager.AddInlinedInterfaceElement(semanticElem,elementName);

        obj=struct('UUID',semanticElem.getPortInterface.getElement(elementName).UUID);

    elseif isa(semanticElem,'systemcomposer.architecture.model.design.ComponentPort')


        elementName=getElementName(semanticElem.getPortInterface(),'elem');

        systemcomposer.AnonymousInterfaceManager.AddInlinedInterfaceElement(semanticElem.getArchitecturePort,elementName);

        obj=struct('UUID',semanticElem.getArchitecturePort.getPortInterface.getElement(elementName).UUID);

    elseif isa(semanticElem,'systemcomposer.architecture.model.swarch.ServiceInterface')
        elementName=getElementName(semanticElem,'f');

        systemcomposer.BusObjectManager.AddFunctionElement(this.getContextName,...
        this.isModelContext,semanticElem.getName,elementName);

        interfaceElement=semanticElem.getElement(elementName);
        obj=struct('UUID',interfaceElement.UUID);

    else
        assert(isa(semanticElem,'systemcomposer.architecture.model.interface.PortInterface'));

        elementName=getElementName(semanticElem,'elem');

        systemcomposer.BusObjectManager.AddInterfaceElement(this.getContextName,...
        this.isModelContext,semanticElem.getName,elementName);

        interfaceElement=semanticElem.getElement(elementName);
        obj=struct('UUID',interfaceElement.UUID);
    end

end

function elementName=getElementName(intrf,elementNameBase)
    elementNameSuffix=0;
    elementName=strcat(elementNameBase,num2str(elementNameSuffix));

    if isempty(intrf)
        return;
    end

    currentInterfaceElementNames=intrf.getElementNames();

    while any(strcmp(currentInterfaceElementNames,elementName))
        elementName=strcat(elementNameBase,num2str(elementNameSuffix));
        elementNameSuffix=elementNameSuffix+1;
    end
end
