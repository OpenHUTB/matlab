function portHandles=getPortHandleForReqHighlighting(zcPortID,modelName)




    srcObj=sysarch.resolveZCElement(zcPortID,modelName);
    if sysarch.isZCPort(srcObj)
        portHandles=sysarch.getPortHandleForMarkup(zcPortID,modelName);
        if isempty(portHandles)
            portHandles=systemcomposer.utils.getSimulinkPeer(srcObj);
        end

    end