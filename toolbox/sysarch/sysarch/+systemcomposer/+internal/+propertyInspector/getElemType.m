function[elemType]=getElemType(input)
    if ischar(input)
        displayClass=input;
        element='';
    else
        element=input;
        displayClass=class(input);
    end

    switch(displayClass)
    case{'Simulink.SubSystem','Simulink.ModelReference','systemcomposer.architecture.model.design.Component','systemcomposer.architecture.model.design.VariantComponent'}
        elemType='Component';
    case 'Simulink.BlockDiagram'
        elemType='Architecture';
    case 'systemcomposer.architecture.model.design.Architecture'
        elemType='Architecture';
        if~isempty(input.p_View)
            elemType='ViewArchitecture';
        end
    case{'Simulink.Inport','Simulink.Outport','Simulink.Port','systemcomposer.architecture.model.design.ArchitecturePort'}
        elemType='Port';
    case 'systemcomposer.architecture.model.design.ComponentPort'
        if isa(element.getComponent,'systemcomposer.architecture.model.views.ComponentGroup')
            elemType='View Port';
        else
            elemType='Port';
        end
    case{'Simulink.Line'}
        elemType='Connector';
    case{'systemcomposer.architecture.model.design.BinaryConnector'}
        if~isempty(input.getTopLevelArchitecture.p_View)
            elemType='ViewConnector';
        else
            elemType='Connector';
        end
    case{'systemcomposer.architecture.model.design.NAryConnector'}
        if~isempty(input.getTopLevelArchitecture.p_View)
            elemType='ViewConnector';
        else
            elemType='NAryConnector';
        end
    case 'systemcomposer.architecture.model.views.ComponentGroup'
        elemType='ComponentGroup';
    case 'systemcomposer.allocation.model.AllocationSet'
        elemType='AllocationSet';
    case 'systemcomposer.allocation.model.AllocationScenario'
        elemType='AllocationScenario';
    case{'systemcomposer.allocation.model.AllocationSource','systemcomposer.allocation.model.AllocationTarget'}
        elemType='Allocation';
    case 'systemcomposer.internal.profile.Profile'
        elemType='Profile';
    case 'systemcomposer.internal.profile.Prototype'
        elemType='Stereotype';
    otherwise

        elemType='';
    end
end

