function dropOntoComponentFromReq(params,diagramUuid,modelName)
    semElem=systemcomposer.internal.getArchitectureElementFromDiagram(modelName,diagramUuid);
    if~isempty(semElem)
        slBlkH=systemcomposer.utils.getSimulinkPeer(semElem);
    end

    for i=1:length(params)
        slreq.utils.nativeDropOntoBlock(params(i),slBlkH);
    end
end