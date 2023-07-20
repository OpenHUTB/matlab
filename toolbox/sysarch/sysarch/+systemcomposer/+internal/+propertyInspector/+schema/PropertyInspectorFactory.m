classdef PropertyInspectorFactory





    properties
    end

    methods(Static,Access=public)
        function propertyInspector=createPropertyInspectorSchema(elemWrap)

            switch(elemWrap.schemaType)
            case{'Architecture','Component','Port','ArchitectureType','RootArchitectureType'}
                propertyInspector=systemcomposer.internal.propertyInspector.schema.SysarchPropertyInspectorSchema(elemWrap);
            case 'InterfaceElement'
                propertyInspector=systemcomposer.internal.propertyInspector.schema.InterfaceElementSchema(elemWrap);
            case{'View','SequenceDiagram','SequenceDiagramMessage','ComponentGroup','View Port','Connector','AUTOSARComponent','Adapter','AdapterPort','AUTOSARCompPort','AUTOSARConnector','NAryConnector'}
                propertyInspector=systemcomposer.internal.propertyInspector.schema.ViewPropertyInspectorSchema(elemWrap);
            case{'AllocationSet','AllocationScenario','Allocation'}
                propertyInspector=systemcomposer.internal.propertyInspector.schema.AllocationPropertyInspectorSchema(elemWrap);
            case{'AllocationElement'}
                propertyInspector=systemcomposer.internal.propertyInspector.schema.AllocationElementPropertyInspectorSchema(elemWrap);
            case{'Profile','Stereotype'}
                propertyInspector=systemcomposer.internal.propertyInspector.schema.ProfilePropertyInspectorSchema(elemWrap);
            end
        end
    end

    methods
    end
end
