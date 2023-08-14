function generateClocks(this,hN,hC)


    hF=this.getHDLFilterObj(hC);
    s=this.applyFilterImplParams(hF,hC);
    hF.setimplementation;

    Up=hF.getFoldingFactor;
    this.unApplyParams(s.pcache);

    Down=1;
    Phase=1;
    if Up>1&&(strcmpi(hF.Implementation,'serial')||...
        strcmpi(hF.Implementation,'distributedarithmetic'))

        hS=this.findSignalWithValidRate(hC.Owner,hC,...
        [hC.PirInputPorts(1).Signal,...
        hC.PirOutputPorts(1).Signal]);
        hdlgetclockbundle(hN,[],hS,Up,Down,0);
        hdlgetclockbundle(hN,hC,hS,Up,Down,Phase);
        hdlgetclockbundle(hN,[],hS,1,1,1);

    else
        hS=this.findSignalWithValidRate(hN,hC,[hC.PirInputSignals(1),...
        hC.PirOutputSignals(1)]);
        if hdlgetparameter('clockinputs')>1

            hdlgetclockbundle(hN,hC,hS,1,1,0);
            hf=createHDLFilterObj(this,hC);
            DecimationFactor=hf.DecimationFactor;

            hdlgetclockbundle(hN,hC,hS,1,DecimationFactor,0);
        else
            hdlgetclockbundle(hN,hC,hS,1,1,1);
        end
    end


