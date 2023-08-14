function setInterfaceElementProperty(this,portElementUUID,propertyType,propertyValue)




    elem=this.mf0Model.findElement(portElementUUID);
    if isa(elem,'systemcomposer.architecture.model.interface.ValueTypeInterface')
        element=systemcomposer.internal.getWrapperForImpl(elem);
        switch(propertyType)
        case 'Type'
            element.setDataType(propertyValue);
        case 'Complexity'
            element.setComplexity(propertyValue);
        case 'Dimensions'
            element.setDimensions(propertyValue);
        case 'Units'
            element.setUnits(propertyValue);
        case 'Minimum'
            element.setMinimum(propertyValue);
        case 'Maximum'
            element.setMaximum(propertyValue);
        case 'Description'
            element.setDescription(propertyValue);
        end
        return;
    elseif isa(elem,'systemcomposer.architecture.model.interface.AtomicPhysicalInterface')
        element=systemcomposer.internal.getWrapperForImpl(elem);
        if strcmpi(propertyType,'Type')
            element.setType(propertyValue);
        end
        return;
    elseif isa(elem,'systemcomposer.architecture.model.design.Port')
        try
            intrf=elem.getPortInterface;
            if(intrf.isAnonymous)
                if isa(intrf,'systemcomposer.architecture.model.interface.CompositeDataInterface')&&...
                    strcmpi(propertyType,'Type')


                    port=systemcomposer.internal.getWrapperForImpl(elem);
                    port.setInterface('');
                    i=port.createInterface('ValueType');
                    i.DataType=propertyValue;
                    return;
                end
                this.setInterfaceElementProperty(intrf.UUID,propertyType,propertyValue);
            end
        catch ME
            disp(ME)

        end
        return;
    end

    interfaceElemWrapper=systemcomposer.internal.propertyInspector.getElementWrapperFromType('InterfaceElement',portElementUUID,this.mf0Model);
    element=systemcomposer.internal.getWrapperForImpl(interfaceElemWrapper.element);
    lastwarn('');
    switch(propertyType)
    case 'Type'
        element.setTypeFromString(propertyValue);
    case 'Complexity'
        element.setComplexity(propertyValue);
    case 'Dimensions'
        element.setDimensions(propertyValue);
    case 'Units'
        element.setUnits(propertyValue);
    case 'Minimum'
        element.setMinimum(propertyValue);
    case 'Maximum'
        element.setMaximum(propertyValue);
    case 'Description'
        element.setDescription(propertyValue);
    end


    [warningMsg,warningId]=lastwarn;

    if any(strcmp(warningId,{'Simulink:DataType:BusDataTypeNotSupportMinMaxOnBusElement',...
        'Simulink:DataType:BusElementMinGreaterThanMax',...
        'Simulink:DataType:BusElementMinIsOutOfDTRange',...
        'Simulink:DataType:BusElementMaxIsOutOfDTRange'}))
        error(warningId,warningMsg);
    end
end
