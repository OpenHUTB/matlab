function setFunctionElementProperty(this,functionElementUUID,propertyType,propertyValue)




    functionElemWrapper=systemcomposer.internal.propertyInspector.getElementWrapperFromType('InterfaceElement',functionElementUUID,this.mf0Model);
    element=systemcomposer.internal.getWrapperForImpl(functionElemWrapper.element);

    switch(propertyType)
    case 'Name'
        element.setFunctionPrototype(propertyValue);
    case 'Asynchronous'
        element.setAsynchronous(propertyValue);
    end

end
