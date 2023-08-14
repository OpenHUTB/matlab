function tf=isInlineSoftwareComponent(comp)





    if comp.isServiceComponent()
        tf=false;
    else
        blockHandle=systemcomposer.utils.getSimulinkPeer(comp);
        tf=swarch.utils.isInlineSoftwareComponentBlock(blockHandle);
    end
end
