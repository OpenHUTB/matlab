function simulinkObjectHandle=getSimulinkPeer(archElem)













    if(archElem.isvalid&&(isa(archElem,'systemcomposer.architecture.model.design.Component')...
        ||isa(archElem,'systemcomposer.architecture.model.design.Architecture')...
        ||isa(archElem,'systemcomposer.architecture.model.design.VariantComponent')...
        ||isa(archElem,'systemcomposer.architecture.model.design.ComponentPort')...
        ||isa(archElem,'systemcomposer.architecture.model.design.ArchitecturePort')...
        ||isa(archElem,'systemcomposer.architecture.model.design.BaseConnector')))

        switch class(archElem)
        case{'systemcomposer.architecture.model.design.Component'}
            simulinkObjectHandle=Simulink.SystemArchitecture.internal.ApplicationManager.getBlockHandleForComponent(archElem);
            return;
        case 'systemcomposer.architecture.model.design.VariantComponent'
            simulinkObjectHandle=Simulink.SystemArchitecture.internal.ApplicationManager.getBlockHandleForComponent(archElem);
            return;
        case 'systemcomposer.architecture.model.design.ArchitecturePort'
            simulinkObjectHandle=Simulink.SystemArchitecture.internal.ApplicationManager.getBlockHandleForArchPort(archElem);
            return;
        case 'systemcomposer.architecture.model.design.ComponentPort'
            simulinkObjectHandle=Simulink.SystemArchitecture.internal.ApplicationManager.getPortHandleForCompPort(archElem);
            return;
        case{'systemcomposer.architecture.model.design.BinaryConnector',...
            'systemcomposer.architecture.model.design.NAryConnector'}
            simulinkObjectHandle=Simulink.SystemArchitecture.internal.ApplicationManager.getSegmentHandlesForConnector(archElem);
            return;
        otherwise
            error('SystemComposer element not supported for getSimulinkPeer');
        end
    else

        error('Input element invalid. Pass in a valid systemcomposer element');
    end

end


