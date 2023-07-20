function archPort=getArchitecturePortFromCbinfo(cbinfo)




    target=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if isa(target,'SLM3I.Block')
        archPortImpl=systemcomposer.utils.getArchitecturePeer(target.handle);
    else
        [~,archPortImpl]=systemcomposer.internal.getBlockHandleFromPortHandle(target.handle);
    end

    archPort=systemcomposer.internal.getWrapperForImpl(archPortImpl);

end