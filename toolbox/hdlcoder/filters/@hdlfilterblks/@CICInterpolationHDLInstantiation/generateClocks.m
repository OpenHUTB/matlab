function generateClocks(this,hN,hC)






    hS=hC.PirOutputSignals(1);

    if hdlgetparameter('clockinputs')>1

        hdlgetclockbundle(hN,hC,hS,1,1,0);
        hf=createHDLFilterObj(this,hC);
        InterpolationFactor=hf.InterpolationFactor;

        hdlgetclockbundle(hN,hC,hS,1,InterpolationFactor,0);
    else
        hdlgetclockbundle(hN,hC,hS,1,1,1);
        hSin=hC.PirInputSignals(4);
        hN.getClockBundle(hSin,1,1,1);
    end


