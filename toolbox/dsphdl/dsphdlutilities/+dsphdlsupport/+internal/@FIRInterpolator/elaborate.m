function nComp=elaborate(this,hN,hC)






    blockInfo=getBlockInfo(this,hC);
    blockInfo.inResetSS=hN.isInResettableHierarchy;

    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;

    if blockInfo.ResetInputPort
        inportNames={'dataIn','validIn','syncReset'};
    else
        inportNames={'dataIn','validIn'};
    end

    outportNames={'dataOut','validOut'};
    if length(hC.PirOutputPorts)==3
        outportNames={'dataOut','validOut','ready'};
    end

    FIRInterpImpl=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportNames,...
    'OutportNames',outportNames);

    FIRInterpImpl.addComment('HDLFIRInterpolation');

    this.elabHDLFIRInterpolation(FIRInterpImpl,blockInfo,hN);

    if blockInfo.inResetSS
        FIRInterpImpl.setTreatNetworkAsResettableBlock;
    end



    for loop=2:length(hC.PirInputSignals)
        hC.PirInputSignals(loop).SimulinkRate=hC.PirInputSignals(1).SimulinkRate;
    end
    nComp=pirelab.instantiateNetwork(hN,FIRInterpImpl,hCInSignal,hCOutSignal,hC.Name);


    function hNewNet=createNetworkWithComponent(hN,hC,blockInfo)






        inportnames{1}='dataIn';
        index=2;
        if blockInfo.inMode(1)
            inportnames{index}='validIn';
            index=index+1;
        end
        if blockInfo.inMode(2)
            inportnames{index}='softReset';
            index=index+1;
        end




        outportnames{1}='dataOut';
        index=2;
        outportnames{index}='validOut';

        hNewNet=pirelab.createNewNetworkWithInterface(...
        'Network',hN,...
        'RefComponent',hC,...
        'InportNames',inportnames,...
        'OutportNames',outportnames);



        for ii=1:length(hC.PirInputSignals)
            hNewNet.PirInputSignals(ii).SimulinkRate=hC.PirInputSignals(ii).SimulinkRate;
        end

        for ii=1:length(hC.PirOutputSignals)
            hNewNet.PirOutputSignals(ii).SimulinkRate=hC.PirOutputSignals(ii).SimulinkRate;
        end
