function compPort=getComponentPortFromCbinfo(cbinfo)




    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if isa(target,'SLM3I.Port')
        compPortImpl=systemcomposer.utils.getArchitecturePeer(target.handle);
    else
        archPortImpl=systemcomposer.utils.getArchitecturePeer(target.handle);
        compPortImpl=archPortImpl.getParentComponentPort;
    end

    compPort=[];
    if~isempty(compPortImpl)
        compPort=systemcomposer.internal.getWrapperForImpl(compPortImpl);
    end

end