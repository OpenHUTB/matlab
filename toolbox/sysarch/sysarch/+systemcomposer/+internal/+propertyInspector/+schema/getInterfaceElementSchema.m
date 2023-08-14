function propertyInspectorSchema=getInterfaceElementSchema(elemUUID,mf0Model)



    elementWrapper=systemcomposer.internal.propertyInspector.schema.InterfaceElementWrapper(elemUUID,mf0Model);


    propertyInspectorSchema=systemcomposer.internal.propertyInspector.schema.PropertyInspectorFactory.createPropertyInspector(elementWrapper);
end

