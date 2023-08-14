function summary=getSummary(iZCIdentifier,mdlName)

    summary='';
    if sysarch.isZCElement(iZCIdentifier)
        viewElem=sysarch.resolveZCElement(iZCIdentifier,mdlName);
        if isa(viewElem,'systemcomposer.architecture.model.design.Port')
            name=viewElem.getName;
            if viewElem.isArchitecturePort
                parentArch=viewElem.getArchitecture;
                parent=parentArch.getParentComponent;
                if isempty(parent)
                    parent=parentArch;
                end
            else
                parent=viewElem.getComponent;
            end
            parentName=parent.getName;
            summary=[parentName,':',name];
        else
            summary=viewElem.getName;
        end
    end
end

