function propertyInspector=getPropertyInspector(varargin)



    if nargin==1
        elementWrapper=systemcomposer.internal.propertyInspector.wrappers.ElementWrapper.getWrapperFromHandle(varargin{:});
    elseif nargin>1
        elementWrapper=systemcomposer.internal.propertyInspector.wrappers.ElementWrapper.getWrapperFromUUID(varargin{:});
    end
    if isempty(elementWrapper)
        propertyInspector='';
    else

        propertyInspector=systemcomposer.internal.propertyInspector.schema.PropertyInspectorFactory.createPropertyInspectorSchema(elementWrapper);

    end
end