function nComp=elaborate(this,hN,hC)






    blockInfo=getBlockInfo(this,hC);
    blockInfo.inResetSS=hN.isInResettableHierarchy;

    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;

    ChannelizerImpl=createNetworkWithComponent(hN,hC,blockInfo);

    ChannelizerImpl.addComment('HDLChannelizer');

    this.elabHDLChannelizer(ChannelizerImpl,blockInfo);

    if blockInfo.inResetSS
        ChannelizerImpl.setTreatNetworkAsResettableBlock;
    end



    for loop=2:length(hC.PirInputSignals)
        hC.PirInputSignals(loop).SimulinkRate=hC.PirInputSignals(1).SimulinkRate;
    end
    nComp=pirelab.instantiateNetwork(hN,ChannelizerImpl,hCInSignal,hCOutSignal,hC.Name);


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
        if blockInfo.outMode(1)
            outportnames{index}='startOut';
            index=index+1;
        end
        if blockInfo.outMode(2)
            outportnames{index}='endOut';
            index=index+1;
        end
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
