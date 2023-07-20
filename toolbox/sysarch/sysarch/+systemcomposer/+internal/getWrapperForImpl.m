function wrapperObj=getWrapperForImpl(implObj,wrapperClassName)




    if(isempty(implObj))
        wrapperObj=[];
        return;
    end


    if isa(implObj,'systemcomposer.architecture.model.interface.InterfaceCatalog')


        wrapperObj=[];
    else
        wrapperObj=implObj.cachedWrapper;
    end

    needsFlush=false;
    if isempty(wrapperObj)||~isvalid(wrapperObj)
        if nargin>1&&~isempty(wrapperClassName)&&wrapperClassName~=""
            wrapperObj=feval(wrapperClassName,implObj);
        else
            if isa(implObj,'systemcomposer.architecture.model.design.Architecture')
                wrapperObj=systemcomposer.arch.Architecture(implObj);
                needsFlush=true;
            elseif isa(implObj,'systemcomposer.architecture.model.design.Component')
                wrapperObj=systemcomposer.arch.Component(implObj);
                needsFlush=true;
            elseif isa(implObj,'systemcomposer.architecture.model.design.VariantComponent')
                wrapperObj=systemcomposer.arch.VariantComponent(implObj);
                needsFlush=true;
            elseif isa(implObj,'systemcomposer.architecture.model.design.ArchitecturePort')
                wrapperObj=systemcomposer.arch.ArchitecturePort(implObj);
                needsFlush=true;
            elseif isa(implObj,'systemcomposer.architecture.model.design.ComponentPort')
                wrapperObj=systemcomposer.arch.ComponentPort(implObj);
                needsFlush=true;
            elseif isa(implObj,'systemcomposer.architecture.model.design.BinaryConnector')
                wrapperObj=systemcomposer.arch.Connector(implObj);
                needsFlush=true;
            elseif isa(implObj,'systemcomposer.architecture.model.design.NAryConnector')
                wrapperObj=systemcomposer.arch.PhysicalConnector(implObj);
                needsFlush=true;
            elseif isa(implObj,'systemcomposer.architecture.model.interface.ValueTypeInterface')
                wrapperObj=systemcomposer.ValueType(implObj);
            elseif isa(implObj,'systemcomposer.architecture.model.interface.AtomicPhysicalInterface')
                wrapperObj=systemcomposer.interface.PhysicalDomain(implObj);
            elseif isa(implObj,'systemcomposer.architecture.model.interface.DataInterface')
                wrapperObj=systemcomposer.interface.DataInterface(implObj);
            elseif isa(implObj,'systemcomposer.architecture.model.swarch.ServiceInterface')
                wrapperObj=systemcomposer.interface.ServiceInterface(implObj);
            elseif isa(implObj,'systemcomposer.architecture.model.interface.CompositePhysicalInterface')
                wrapperObj=systemcomposer.interface.PhysicalInterface(implObj);
            elseif isa(implObj,'systemcomposer.architecture.model.interface.DataElement')
                wrapperObj=systemcomposer.interface.DataElement(implObj);
            elseif isa(implObj,'systemcomposer.architecture.model.interface.PhysicalElement')
                wrapperObj=systemcomposer.interface.PhysicalElement(implObj);
            elseif isa(implObj,'systemcomposer.architecture.model.swarch.FunctionElement')
                wrapperObj=systemcomposer.interface.FunctionElement(implObj);
            elseif isa(implObj,'systemcomposer.architecture.model.swarch.FunctionArgument')
                wrapperObj=systemcomposer.interface.FunctionArgument(implObj);
            elseif isa(implObj,'systemcomposer.architecture.model.interface.InterfaceCatalog')
                wrapperObj=systemcomposer.interface.Dictionary(implObj);
            elseif isa(implObj,'systemcomposer.architecture.model.views.View')
                wrapperObj=systemcomposer.view.View(implObj);
            elseif isa(implObj,'systemcomposer.architecture.model.views.ElementGroup')
                wrapperObj=systemcomposer.view.ElementGroup(implObj);
            elseif isa(implObj,'systemcomposer.architecture.model.SystemComposerModel')
                wrapperObj=systemcomposer.arch.Model(implObj.getName);
            elseif isa(implObj,'systemcomposer.architecture.model.swarch.Function')
                wrapperObj=systemcomposer.arch.Function(implObj);
            else
                wrapperObj=[];
            end
        end
    end

    if(needsFlush)

        modelId=systemcomposer.services.proxy.ModelIdentifier.getModelIdentifier(mf.zero.getModel(implObj));
        if(bdIsLoaded(modelId.URI))
            slmdlHdl=get_param(modelId.URI,'Handle');
            if any(strcmpi(get_param(slmdlHdl,'SimulinkSubdomain'),{'Architecture','SoftwareArchitecture'}))
                systemcomposer.internal.arch.internal.processBatchedPluginEvents(...
                slmdlHdl);
            end
        end
    end


end
