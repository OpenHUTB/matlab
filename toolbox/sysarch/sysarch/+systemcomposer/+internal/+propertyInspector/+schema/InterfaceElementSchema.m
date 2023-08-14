classdef InterfaceElementSchema<systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema




    properties
        schema;
    end

    methods
        function obj=InterfaceElementSchema(elemWrap)


            schemaFile='propertyInspectorSchema.json';

            obj=obj@systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema(elemWrap,schemaFile);
        end
        function element=getPropElement(obj)
            element=obj.elementWrapper.getPropElement;
        end
        function name=getObjectType(obj)
            name=['Interface : ',obj.elementWrapper.interface.getName(),' | Element : ',obj.elementWrapper.element.getName()];
        end
        function schema=getPropertySchema(this)
            schema=this;
        end
    end
end

