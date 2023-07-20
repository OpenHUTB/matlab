function p=getLinkableCompositionPort(zcPort)




    p=zcPort;
    if~sysarch.isZCPort(zcPort)
        return;
    end
    if zcPort.isComponentPort
        parentComp=zcPort.getComponent;
        isSFBehavior=systemcomposer.internal.isStateflowBehaviorComponent(systemcomposer.utils.getSimulinkPeer(parentComp));
        if~parentComp.isReferenceComponent&&(~parentComp.isImplComponent||isSFBehavior)
            p=zcPort.getArchitecturePort;
        end
    end
end
