function compatible=isAdaptivePipeliningCompatible(this,hC)










    compatible=~targetmapping.mode(hC.PirOutputSignals(1))&&...
    this.getPotentiallyInsertsPipelines(hC);
