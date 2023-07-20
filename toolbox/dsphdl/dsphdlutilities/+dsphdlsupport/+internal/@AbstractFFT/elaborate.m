function nComp=elaborate(this,hN,hC)






    blockInfo=this.getBlockInfo(hC);

    inportnames{1}='dataIn';
    index=2;
    if blockInfo.inMode(1)
        inportnames{index}='validIn';
        index=index+1;
    end
    if blockInfo.inMode(2)
        inportnames{index}='syncReset';
    end


    for loop=2:length(hC.PirInputSignals)
        hC.PirInputSignals(loop).SimulinkRate=hC.PirInputSignals(1).SimulinkRate;
    end

    index=1;
    outportnames{index}='dataOut';

    if blockInfo.outMode(1)
        index=index+1;
        outportnames{index}='startOut';
    end
    if blockInfo.outMode(2)
        index=index+1;
        outportnames{index}='endOut';
    end
    index=index+1;
    outportnames{index}='validOut';

    if strcmpi(blockInfo.Architecture,'Burst Radix 2')
        index=index+1;
        outportnames{index}='ready';
    end

    FFTImpl=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportnames,...
    'OutportNames',outportnames...
    );
    FFTImpl.addComment('FFT');

    blockInfo.inResetSS=hN.isInResettableHierarchy;
    if strcmpi(blockInfo.Architecture,'Streaming Radix 2^2')||blockInfo.FFTLength<8
        this.elaborateHDLFFTP(FFTImpl,blockInfo);
    elseif strcmpi(blockInfo.Architecture,'Burst Radix 2')
        this.elaborateHDLFFTM(FFTImpl,blockInfo);
    else
        this.elaborateHDLFFT(FFTImpl,blockInfo);
    end




    if blockInfo.inResetSS
        FFTImpl.setTreatNetworkAsResettableBlock;
    end


    nComp=pirelab.instantiateNetwork(hN,FFTImpl,hC.PirInputSignals,...
    hC.PirOutputSignals,hC.Name);
end
