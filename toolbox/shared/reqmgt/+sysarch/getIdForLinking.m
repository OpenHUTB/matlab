function zcID=getIdForLinking(obj)



    zcID='';
    if isnumeric(obj)
        zcID=obj;
        archElem=systemcomposer.utils.getArchitecturePeer(obj);
        if isa(archElem,'systemcomposer.architecture.model.design.Port')
            archElem=sysarch.getLinkableCompositionPort(archElem);
            zcID=archElem.getZCIdentifier;
        end
    end