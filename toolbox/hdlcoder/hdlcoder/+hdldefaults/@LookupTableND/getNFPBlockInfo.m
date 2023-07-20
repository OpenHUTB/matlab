function nfpOptions=getNFPBlockInfo(this)




    nfpOptions=this.getNFPBlockInfo@hdlimplbase.EmlImplBase;
    nfpOptions.PrecomputeCoefficients=strcmp(getImplParams(this,'PrecomputeCoefficients'),'on');
    nfpOptions.AreaOptimization=getImplParams(this,'AreaOptimization');
end

