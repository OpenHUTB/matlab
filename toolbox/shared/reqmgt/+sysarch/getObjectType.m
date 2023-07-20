function objectType=getObjectType(iZCIdentifier,mdlName)

    objectType='';
    if sysarch.isZCElement(iZCIdentifier)
        viewElem=sysarch.resolveZCElement(iZCIdentifier,mdlName);
        if isa(viewElem,'systemcomposer.architecture.model.design.ComponentGroup')
            objectType='Element Group';
        elseif isa(viewElem,'systemcomposer.architecture.model.design.Port')
            objectType='Port';
        elseif isa(viewElem,'systemcomposer.architecture.model.design.Component')
            objectType='Component';
        elseif isa(viewElem,'systemcomposer.architecture.model.design.VariantComponent')
            objectType='Variant Component';
        end
    end
end

