function[blockHandles,archPrt]=getBlockHandleFromPortHandle(portHandles)





    blockHandles=[];
    for portHandle=portHandles
        compPrt=systemcomposer.utils.getArchitecturePeer(portHandle);
        archPrt=systemcomposer.internal.getArchitecturePortInContext(compPrt);
        portBlkHdls=systemcomposer.utils.getSimulinkPeer(archPrt);
        for portBlkHdl=portBlkHdls
            blockHandles(end+1)=portBlkHdl;
        end
    end
end