

function MemoryMuxingGaussJordan(this,hN,MemMuxInSigs,MemMuxOutSigs,hBoolT,hAddrT,...
    hInputDataT,slRate,blockInfo)




    hMemMuxN=pirelab.createNewNetwork(...
    'Name','MemoryMuxingGaussJordan',...
    'InportNames',{'validIn','ready','processingEnb','wrEnbStore','wrEnbLT','wrAddrStore','wrAddrLT',...
    'wrDataStore','wrDataLT','rdAddrLT','rdAddrOut','outStreamEnb'},...
    'InportTypes',[hBoolT,hBoolT,hBoolT,...
    MemMuxInSigs(4).Type,...
    MemMuxInSigs(5).Type,...
    MemMuxInSigs(6).Type,...
    MemMuxInSigs(7).Type,...
    MemMuxInSigs(8).Type,...
    MemMuxInSigs(9).Type,...
    MemMuxInSigs(10).Type,...
    MemMuxInSigs(11).Type,...
    MemMuxInSigs(12).Type],...
    'InportRates',slRate*ones(1,12),...
    'OutportNames',{'wrEnb','wrAddr','wrData','rdAddr'},...
    'OutportTypes',[pirelab.createPirArrayType(hBoolT,[blockInfo.MatrixSize*2,0]),...
    pirelab.createPirArrayType(hAddrT,[blockInfo.MatrixSize*2,0]),...
    pirelab.createPirArrayType(hInputDataT,[blockInfo.MatrixSize*2,0]),...
    pirelab.createPirArrayType(hAddrT,[blockInfo.MatrixSize*2,0])]);

    hMemMuxN.setTargetCompReplacementCandidate(true);

    for ii=1:numel(hMemMuxN.PirOutputSignals)
        hMemMuxN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hMemMuxNinSigs=hMemMuxN.PirInputSignals;
    hMemMuxNoutSigs=hMemMuxN.PirOutputSignals;


    validIn=hMemMuxNinSigs(1);
    ready=hMemMuxNinSigs(2);
    processingEnb=hMemMuxNinSigs(3);
    wrEnbStore=hMemMuxNinSigs(4);
    wrEnbLT=hMemMuxNinSigs(5);
    wrAddrStore=hMemMuxNinSigs(6);
    wrAddrLT=hMemMuxNinSigs(7);
    wrDataStore=hMemMuxNinSigs(8);
    wrDataLT=hMemMuxNinSigs(9);
    rdAddrLT=hMemMuxNinSigs(10);
    rdAddrOut=hMemMuxNinSigs(11);
    outStreamEnb=hMemMuxNinSigs(12);

    wrEnb=hMemMuxNoutSigs(1);
    wrAddr=hMemMuxNoutSigs(2);
    wrData=hMemMuxNoutSigs(3);
    rdAddr=hMemMuxNoutSigs(4);




    WrtEnbGenInSigs=[validIn,ready,processingEnb,wrEnbStore,wrEnbLT];

    WrtEnbGenOutSigs=wrEnb;

    this.WrtEnbGeneratorGaussJordan(hMemMuxN,WrtEnbGenInSigs,WrtEnbGenOutSigs,hBoolT,slRate,...
    blockInfo);



    WrtAddrGenInSigs=[validIn,ready,processingEnb,wrAddrStore,wrAddrLT];

    WrtAddrGenOutSigs=wrAddr;

    this.WrtAddrGeneratorGaussJordan(hMemMuxN,WrtAddrGenInSigs,WrtAddrGenOutSigs,hBoolT,hAddrT,...
    slRate,blockInfo);



    WrtDataGenInSigs=[validIn,ready,processingEnb,wrDataStore,wrDataLT];

    WrtDataGenOutSigs=wrData;

    this.WrtDataGeneratorGaussJordan(hMemMuxN,WrtDataGenInSigs,WrtDataGenOutSigs,hBoolT,hInputDataT,...
    slRate,blockInfo);


    RdAddrGenInSigs=[processingEnb,rdAddrOut,rdAddrLT,outStreamEnb];

    RdAddrGenOutSigs=rdAddr;

    this.RdAddrGeneratorGaussJordan(hMemMuxN,RdAddrGenInSigs,RdAddrGenOutSigs,hBoolT,hAddrT,...
    slRate,blockInfo);

    pirelab.instantiateNetwork(hN,hMemMuxN,MemMuxInSigs,MemMuxOutSigs,...
    [hMemMuxN.Name,'_inst']);

end


