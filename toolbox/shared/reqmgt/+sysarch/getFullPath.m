function paths=getFullPath(iZCIdentifier,modelName)






    paths={};
    if sysarch.isZCElement(iZCIdentifier)
        viewElem=sysarch.resolveZCElement(iZCIdentifier,modelName);
        if isa(viewElem,'systemcomposer.architecture.model.views.ElementGroup')
            paths={viewElem.getName};
            return;
        elseif isa(viewElem,'systemcomposer.architecture.model.views.View')
            paths={viewElem.getName};
            return;
        elseif isa(viewElem,'systemcomposer.architecture.model.design.Port')
            if viewElem.isArchitecturePort
                parentArch=viewElem.getArchitecture;
                parent=parentArch.getParentComponent;
            else
                parent=viewElem.getComponent;
            end
            if~isempty(parent)
                paths={[parent.getQualifiedName,':',viewElem.getName]};
            else
                paths={viewElem.getName};
            end


            return;
        end
        paths=[paths,viewElem.getQualifiedName];
    end
end

