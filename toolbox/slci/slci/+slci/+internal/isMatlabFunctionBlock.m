

function isMatlabFunction=isMatlabFunctionBlock(blkObj)

    oldf=slfeature('EngineInterface',Simulink.EngineInterfaceVal.byFiat);
    isSynthesized=blkObj.isSynthesized;
    slfeature('EngineInterface',oldf);

    if isSynthesized
        isMatlabFunction=false;
    else
        blkHdl=blkObj.Handle;
        isMatlabFunction=slci.internal.isStateflowBasedBlock(blkHdl)&&...
        sfprivate('is_eml_chart_block',blkHdl);
    end


end
