function postConstructionPhase(this)




    p=this.hPir;


    obj=this.SimulinkConnection.Model;
    p.setSampleTimeIndependent(obj.isSampleTimeInherited);




    if this.HDLCoder.isDutModelRef&&obj.isSampleTimeInherited
        this.HDLCoder.PirInstance.overwriteCtxRatesForSTI(this.HDLCoder.DutSTIRate);
    end

    hdlcoder.TransformDriver.propagateEnabledFlags(p);
    hdlcoder.TransformDriver.propagateResettableFlags(p);
    hdlcoder.TransformDriver.propagateTriggeredFlags(p);

    arrayfun(@setMaskedSubsystemLibBlock,this.MaskedSubsystemLibraryBlocks);

end

function setMaskedSubsystemLibBlock(hNtwk)
    hNtwk.setMaskedSubsystemLibBlock(true);
end
