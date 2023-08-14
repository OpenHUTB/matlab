function setFunctionArgumentProperty(this,portElementUUID,propertyType,propertyValue)




    interfaceElemWrapper=systemcomposer.internal.propertyInspector.getElementWrapperFromType('FunctionArgument',portElementUUID,this.mf0Model);
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

end

