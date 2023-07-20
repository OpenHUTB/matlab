function generateClocks(this,hN,hC)



    if isfield(hC.HDLUserData,'FilterObject')
        hF=hC.HDLUserData.FilterObject;
    else
        hF=this.getHDLFilterObj(hC);
    end
    s=this.applyFilterImplParams(hF,hC);
    hF.setimplementation;


    if(hC.SimulinkHandle~=-1)
        numChannel=hF.HDLParameters.INI.getProp('filter_generate_multichannel');
    else
        numChannel=hF.numChannel;
    end

    Up=numChannel*hF.getFoldingFactor;
    this.unApplyParams(s.pcache);
    Down=1;

    if hdlgetparameter('clockinputs')>1
        Phase=0;
    else
        Phase=1;
    end

    if Up>1
        hS=this.findSignalWithValidRate(hC.Owner,hC,...
        [hC.PirInputPorts(1).Signal,...
        hC.PirOutputPorts(1).Signal]);


        if hdlgetparameter('clockinputs')>1
            hdlgetclockbundle(hN,hC,hC.PirOutputSignals(1),1,1,0);
        else
            hdlgetclockbundle(hN,hC,hC.PirOutputSignals(1),Up,1,1);
        end

    else
        hS=this.findSignalWithValidRate(hN,hC,[hC.PirInputSignals(1),...
        hC.PirOutputSignals(1)]);
        hdlgetclockbundle(hN,hC,hS,1,1,0);
    end
