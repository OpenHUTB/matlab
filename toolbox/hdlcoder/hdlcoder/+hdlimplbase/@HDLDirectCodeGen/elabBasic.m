function hBBC=elabBasic(this,hN,hC)





    if hdlgetparameter('debug')>=3
        this.displayEmlCodegenMessage(hC);
    end

    optimizeMdlGen=optimizeForModelGen(this,hN,hC);

















    hBBC=this.baseElaborate(hN,hC);



    hBBC.elaborationHelper(true);



    hBBC.optimizeBBoxModelGen(optimizeMdlGen);





end



