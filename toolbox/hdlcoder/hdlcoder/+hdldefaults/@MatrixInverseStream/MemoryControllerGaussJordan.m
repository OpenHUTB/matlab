

function MemoryControllerGaussJordan(this,hN,MemControlInSigs,MemControlOutSigs,hBoolT,...
    hAddrT,hInputDataT,slRate,blockInfo)






    hMemoryControllerN=pirelab.createNewNetwork(...
    'Name','MemoryControllerGaussJordan',...
    'InportNames',{'hOutSigs(3)','hInSigs(2)','wrEnbStore','wrAddrStore','wrDataStore',...
    'processingEnb','wrEnbLT','wrAddrLT','wrDataLT','rdAddrLT',...
    'outStreamEnb','rdAddrOut'},...
    'InportTypes',[hBoolT,hBoolT,MemControlInSigs(3).Type,...
    MemControlInSigs(4).Type,...
    MemControlInSigs(5).Type,...
    MemControlInSigs(6).Type,MemControlInSigs(7).Type,...
    MemControlInSigs(8).Type,...
    MemControlInSigs(9).Type,...
    MemControlInSigs(10).Type,MemControlInSigs(11).Type,...
    MemControlInSigs(12).Type],...
    'InportRates',slRate*ones(1,12),...
    'OutportNames',{'readData'},...
    'OutportTypes',pirelab.createPirArrayType(hInputDataT,[blockInfo.MatrixSize*2,0]));

    hMemoryControllerN.setTargetCompReplacementCandidate(true);

    for ii=1:numel(hMemoryControllerN.PirOutputSignals)
        hMemoryControllerN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hMemControlNinSigs=hMemoryControllerN.PirInputSignals;
    hMemControlNoutSigs=hMemoryControllerN.PirOutputSignals;

    ready=hMemControlNinSigs(1);
    validIn=hMemControlNinSigs(2);
    wrEnbStore=hMemControlNinSigs(3);
    wrAddrStore=hMemControlNinSigs(4);
    wrDataStore=hMemControlNinSigs(5);
    processingEnb=hMemControlNinSigs(6);
    wrEnbLT=hMemControlNinSigs(7);
    wrAddrLT=hMemControlNinSigs(8);
    wrDataLT=hMemControlNinSigs(9);
    rdAddrLT=hMemControlNinSigs(10);
    outStreamEnb=hMemControlNinSigs(11);
    rdAddrOut=hMemControlNinSigs(12);

    readData=hMemControlNoutSigs(1);




    wrtEnbS=l_addSignal(hMemoryControllerN,'wrtEnb',...
    pirelab.createPirArrayType(hBoolT,[blockInfo.MatrixSize*2,0]),slRate);
    wrtAddrS=l_addSignal(hMemoryControllerN,'wrtAddr',...
    pirelab.createPirArrayType(hAddrT,[blockInfo.MatrixSize*2,0]),slRate);
    wrtDataS=l_addSignal(hMemoryControllerN,'wrtData',...
    pirelab.createPirArrayType(hInputDataT,[blockInfo.MatrixSize*2,0]),slRate);
    rdAddrS=l_addSignal(hMemoryControllerN,'rdAddr',...
    pirelab.createPirArrayType(hAddrT,[blockInfo.MatrixSize*2,0]),slRate);



    MemMuxInSigs=[validIn,ready,processingEnb,wrEnbStore,wrEnbLT,wrAddrStore,wrAddrLT,...
    wrDataStore,wrDataLT,rdAddrLT,rdAddrOut,outStreamEnb];
    MemMuxOutSigs=[wrtEnbS,wrtAddrS,wrtDataS,rdAddrS];


    this.MemoryMuxingGaussJordan(hMemoryControllerN,MemMuxInSigs,MemMuxOutSigs,hBoolT,hAddrT,...
    hInputDataT,slRate,blockInfo);


    MemoriesInSigs=[wrtEnbS,wrtAddrS,wrtDataS,rdAddrS];
    MemoriesOutSigs=readData;

    this.MemoriesGaussJordan(hMemoryControllerN,MemoriesInSigs,MemoriesOutSigs,...
    hBoolT,hAddrT,hInputDataT,slRate,blockInfo);

    pirelab.instantiateNetwork(hN,hMemoryControllerN,MemControlInSigs,MemControlOutSigs,...
    [hMemoryControllerN.Name,'_inst']);

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


