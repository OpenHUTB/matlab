function onModelStart(this)





    [validSigs,invalidSigs]=this.validateBoundSignals();



    updateOnly=true;

    this.updateBoundSignals(validSigs,invalidSigs,updateOnly);

