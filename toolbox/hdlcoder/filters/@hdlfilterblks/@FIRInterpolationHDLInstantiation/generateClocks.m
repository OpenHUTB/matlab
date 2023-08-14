function generateClocks(this,hN,hC)











    hF=this.createHDLFilterObj(hC);
    s=this.applyFilterImplParams(hF,hC);
    hF.setimplementation;

    Up=hF.getHDLParameter('foldingfactor');
    this.unApplyParams(s.pcache);

    Down=1;
    Phase=1;

    if Up>1&&(strcmpi(hF.Implementation,'serial')||...
        strcmpi(hF.Implementation,'distributedarithmetic'))

        hSo=this.findSignalWithValidRate(hC.Owner,hC,...
        hC.PirOutputPorts(1).Signal);
        hdlgetclockbundle(hN,hC,hSo,Up,Down,0);
        hSi=this.findSignalWithValidRate(hC.Owner,hC,...
        hC.PirInputPorts(1).Signal);
        hN.getClockBundle(hSi,1,1,1);

    elseif Up==1&&(strcmpi(hF.Implementation,'serial')||...
        strcmpi(hF.Implementation,'distributedarithmetic'))






        hS=hC.PirOutputSignals(1);
        hdlgetclockbundle(hN,hC,hS,1,1,0);
        hSin=hC.PirInputSignals(4);
        hN.getClockBundle(hSin,1,1,0);
    else
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

    end


