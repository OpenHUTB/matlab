function postElab(this,hN,hPreElabC,hPostElabC)


    if ishandle(hPostElabC)&&ishandle(hPreElabC)
        hPostElabC.OrigModelHandle=hPreElabC.SimulinkHandle;
    end

    hPostElabC.copyComment(hPreElabC);
    setDelayTags(this,hPreElabC,hPostElabC);
    p=pir(hN.getCtxName());
    p.registerAsAncestor(hPreElabC,hPostElabC);
end
