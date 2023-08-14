function wrapper=getElementWrapperFromType(elemType,varargin)




    switch(elemType)
    case 'Architecture'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.ArchitectureElementWrapper(varargin{:});
    case 'Component'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.ComponentElementWrapper(varargin{:});
    case 'Port'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.PortElementWrapper(varargin{:});
    case 'Connector'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.ConnectorElementWrapper(varargin{:});
    case 'NAryConnector'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.NaryConnectorElementWrapper(varargin{:});
    case 'Interface'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.InterfaceWrapper(varargin{:});
    case 'InterfaceElement'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.InterfaceElementWrapper(varargin{:});
    case 'FunctionArgument'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.FunctionArgumentWrapper(varargin{:});
    case 'ComponentOccurence'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.ComponentOccurrenceWrapper(varargin{:});
    case 'DesignComponentPort'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.DesignComponentPortWrapper(varargin{:});
    case 'View Port'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.PortElementWrapper(varargin{:});
    case 'ViewArchitecture'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.ViewArchitectureWrapper(varargin{:});
    case 'ComponentGroup'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.ComponentGroupWrapper(varargin{:});
    case 'ViewConnector'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.ViewConnectorWrapper(varargin{:});
    case 'AllocationSet'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.AllocationSetWrapper(varargin{:});
    case 'AllocationScenario'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.AllocationScenarioWrapper(varargin{:});
    case 'Allocation'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.AllocationWrapper(varargin{:});
    case 'Profile'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.ProfileWrapper(varargin{:});
    case 'Stereotype'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.StereotypeWrapper(varargin{:});
    case 'Property'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.StereotypePropertyWrapper(varargin{:});
    case 'SequenceDiagram'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.SequenceDiagramWrapper(varargin{:});
    case 'SequenceDiagramMessage'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.SequenceDiagramMessageWrapper(varargin{:});
    case 'RootArchitectureType'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.RootArchitectureTypeWrapper(varargin{:});
    case 'ArchitectureType'
        wrapper=systemcomposer.internal.propertyInspector.wrappers.ArchitectureTypeWrapper(varargin{:});
    end
    if~isempty(wrapper)&&isprop(wrapper,'elemType')
        wrapper.elemType=elemType;
    end
end

