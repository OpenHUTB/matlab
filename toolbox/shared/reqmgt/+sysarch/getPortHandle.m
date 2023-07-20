function portHandle=getPortHandle(zcIdentifier,modelName)




    portHandle=[];
    semanticItem=sysarch.resolveZCElement(zcIdentifier,modelName);
    if isa(semanticItem,'systemcomposer.architecture.model.design.Port')
        portHandle=systemcomposer.utils.getSimulinkPeer(semanticItem);
    end

end