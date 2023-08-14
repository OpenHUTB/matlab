function propertyInspectorSchema=getPropertyInspectorSchema(varargin)



    if nargin==1
        elementWrapper=systemcomposer.internal.propertyInspector.wrappers.ElementWrapper.getWrapperFromHandle(varargin{:});
    elseif nargin>1
        elementWrapper=systemcomposer.internal.propertyInspector.wrappers.ElementWrapper.getWrapperFromUUID(varargin{:});
    end
    if isempty(elementWrapper)
        propertyInspectorSchema='';
    else

        propertyInspectorSchemaClass=systemcomposer.internal.propertyInspector.schema.PropertyInspectorFactory.createPropertyInspectorSchema(elementWrapper);


        propertyInspectorSchema=propertyInspectorSchemaClass.propertyInspectorSchema;
        propertyInspectorSchema.PropertySpecMap=propertyInspectorSchemaClass.propertyIDMap;
    end
end

