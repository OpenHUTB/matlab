
function gaussJordanMemoryControl(this,hN,LTMemoryControlInSigs,LTMemoryControlOutSigs,...
    hBoolT,hAddrT,hCounterT,hInputDataT,slRate,blockInfo)






    hLTMemoryControlN=pirelab.createNewNetwork(...
    'Name','gaussJordanMemoryControl',...
    'InportNames',{'processingEnb','colCount','nonDiagValidOut','nonDiagDataOut1','diagValidOut',...
    'swapDataOut1','swapAddrOut','swapEnb','swapEnableOut',...
    'rowCountOut','colCountOut','swapDataOut2','nonDiagDataOut2','diagDataOut1','diagDataOut2'},...
    'InportTypes',[hBoolT,hCounterT,hBoolT,hInputDataT,hBoolT,LTMemoryControlInSigs(6).Type,hCounterT,hBoolT,...
    hBoolT,hCounterT,hCounterT,LTMemoryControlInSigs(12).Type,hInputDataT,hInputDataT,hInputDataT],...
    'InportRates',slRate*ones(1,15),...
    'OutportNames',{'wrEnbGJ','wrAddrGJ','wrDataGJ','rdAddrGJ'},...
    'OutportTypes',[pirelab.createPirArrayType(hBoolT,[blockInfo.MatrixSize*2,0]),...
    pirelab.createPirArrayType(hAddrT,[blockInfo.MatrixSize*2,0]),...
    pirelab.createPirArrayType(hInputDataT,[blockInfo.MatrixSize*2,0]),...
    pirelab.createPirArrayType(hAddrT,[blockInfo.MatrixSize*2,0])]);

    hLTMemoryControlN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTMemoryControlN.PirOutputSignals)
        hLTMemoryControlN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTMemoryControlNinSigs=hLTMemoryControlN.PirInputSignals;
    hLTMemoryControlNoutSigs=hLTMemoryControlN.PirOutputSignals;

    processingEnb=hLTMemoryControlNinSigs(1);
    colCount=hLTMemoryControlNinSigs(2);
    nonDiagValidOut=hLTMemoryControlNinSigs(3);
    nonDiagDataOut1=hLTMemoryControlNinSigs(4);
    diagValidOut=hLTMemoryControlNinSigs(5);
    swapDataOut1=hLTMemoryControlNinSigs(6);
    swapAddrOut=hLTMemoryControlNinSigs(7);
    swapEnb=hLTMemoryControlNinSigs(8);
    swapEnableOut=hLTMemoryControlNinSigs(9);
    rowCountOut=hLTMemoryControlNinSigs(10);
    colCountOut=hLTMemoryControlNinSigs(11);
    swapDataOut2=hLTMemoryControlNinSigs(12);
    nonDiagDataOut2=hLTMemoryControlNinSigs(13);
    diagDataOut1=hLTMemoryControlNinSigs(14);
    diagDataOut2=hLTMemoryControlNinSigs(15);

    wrEnbGJ=hLTMemoryControlNoutSigs(1);
    wrAddrGJ=hLTMemoryControlNoutSigs(2);
    wrDataGJ=hLTMemoryControlNoutSigs(3);
    rdAddrGJ=hLTMemoryControlNoutSigs(4);




    WrEnbLTInSigs=[rowCountOut,processingEnb,nonDiagValidOut,diagValidOut,swapEnb,swapEnableOut];
    WrEnbLTOutSigs=wrEnbGJ;

    this.wrEnbGaussJordan(hLTMemoryControlN,WrEnbLTInSigs,WrEnbLTOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo);


    WrAddrLTInSigs=[processingEnb,swapAddrOut,swapEnb,colCountOut];
    WrAddrLTOutSigs=wrAddrGJ;


    this.wrAddrGaussJordan(hLTMemoryControlN,WrAddrLTInSigs,WrAddrLTOutSigs,...
    hBoolT,hCounterT,hAddrT,slRate,blockInfo);

    WrDataLTInSigs=[nonDiagValidOut,nonDiagDataOut1,swapDataOut1,diagValidOut,swapEnb,swapDataOut2,...
    nonDiagDataOut2,diagDataOut1,diagDataOut2];
    WrDataLTOutSigs=wrDataGJ;

    this.wrDataGaussJordan(hLTMemoryControlN,WrDataLTInSigs,WrDataLTOutSigs,...
    hBoolT,hInputDataT,slRate,blockInfo);


    RdAddrLTInSigs=[processingEnb,colCount];
    RdAddrLTOutSigs=rdAddrGJ;

    this.rdAddrGaussJordan(hLTMemoryControlN,RdAddrLTInSigs,RdAddrLTOutSigs,hBoolT,hCounterT,...
    hAddrT,slRate,blockInfo);


    pirelab.instantiateNetwork(hN,hLTMemoryControlN,LTMemoryControlInSigs,LTMemoryControlOutSigs,...
    [hLTMemoryControlN.Name,'_inst']);

end


