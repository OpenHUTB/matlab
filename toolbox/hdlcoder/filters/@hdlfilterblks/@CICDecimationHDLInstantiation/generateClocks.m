function generateClocks(this,hN,hC)




    hS=this.findSignalWithValidRate(hN,hC,hC.PirInputSignals(1));

    if hdlgetparameter('clockinputs')>1

        hdlgetclockbundle(hN,hC,hS,1,1,0);
        hf=createHDLFilterObj(this,hC);
        DecimationFactor=hf.DecimationFactor;

        hdlgetclockbundle(hN,hC,hS,1,DecimationFactor,0);
    else
        hdlgetclockbundle(hN,hC,hS,1,1,1);
    end

