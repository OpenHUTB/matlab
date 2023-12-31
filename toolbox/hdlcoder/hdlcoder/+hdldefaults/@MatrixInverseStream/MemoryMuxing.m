

function MemoryMuxing(this,hN,MemMuxInSigs,MemMuxOutSigs,hBoolT,hAddrT,...
    hInputDataT,slRate,blockInfo)


    hMemMuxN=pirelab.createNewNetwork(...
    'Name','MemoryMuxing',...
    'InportNames',{'validIn','ready','lowerTriangEnb','fwdSubEnb','matMultEnb',...
    'wrEnbStore','wrEnbLT','wrEnbFwdSub','wrEnbMatMult','wrAddrStore','wrAddrLT',...
    'wrAddrFwdSub','wrAddrMatMult','wrDataStore','wrDataLT','wrDataFwdSub',...
    'wrDataMatMult','rdAddrLT','rdAddrFwdSub','rdAddrMatMult','rdAddrOut','outStreamEnb'},...
    'InportTypes',[hBoolT,hBoolT,hBoolT,hBoolT,hBoolT,...
    MemMuxInSigs(6).Type,...
    MemMuxInSigs(7).Type,...
    MemMuxInSigs(8).Type,...
    MemMuxInSigs(9).Type,...
    MemMuxInSigs(10).Type,...
    MemMuxInSigs(11).Type,...
    MemMuxInSigs(12).Type,...
    MemMuxInSigs(13).Type,...
    MemMuxInSigs(14).Type,...
    MemMuxInSigs(15).Type,...
    MemMuxInSigs(16).Type,...
    MemMuxInSigs(17).Type,...
    MemMuxInSigs(18).Type,...
    MemMuxInSigs(19).Type,...
    MemMuxInSigs(20).Type,hAddrT,hBoolT],...
    'InportRates',slRate*ones(1,22),...
    'OutportNames',{'wrtEnb','wrtAddr','wrtData','rdAddr'},...
    'OutportTypes',[pirelab.createPirArrayType(hBoolT,[blockInfo.RowSize+1,0]),...
    pirelab.createPirArrayType(hAddrT,[blockInfo.RowSize+1,0]),...
    pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize+1,0]),...
    pirelab.createPirArrayType(hAddrT,[blockInfo.RowSize+1,0])]);

    hMemMuxN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hMemMuxN.PirOutputSignals)
        hMemMuxN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hMemMuxNinSigs=hMemMuxN.PirInputSignals;
    hMemMuxNoutSigs=hMemMuxN.PirOutputSignals;



    WrtEnbGenInSigs=[hMemMuxNinSigs(1),hMemMuxNinSigs(2),hMemMuxNinSigs(3),...
    hMemMuxNinSigs(4),hMemMuxNinSigs(5),hMemMuxNinSigs(6),...
    hMemMuxNinSigs(7),hMemMuxNinSigs(8),hMemMuxNinSigs(9)];

    WrtEnbGenOutSigs=hMemMuxNoutSigs(1);

    this.WrtEnbGenerator(hMemMuxN,WrtEnbGenInSigs,WrtEnbGenOutSigs,hBoolT,slRate,...
    blockInfo);



    WrtAddrGenInSigs=[hMemMuxNinSigs(1),hMemMuxNinSigs(2),hMemMuxNinSigs(3),...
    hMemMuxNinSigs(4),hMemMuxNinSigs(5),hMemMuxNinSigs(10),...
    hMemMuxNinSigs(11),hMemMuxNinSigs(12),hMemMuxNinSigs(13)];

    WrtAddrGenOutSigs=hMemMuxNoutSigs(2);

    this.WrtAddrGenerator(hMemMuxN,WrtAddrGenInSigs,WrtAddrGenOutSigs,hBoolT,hAddrT,...
    slRate,blockInfo);



    WrtDataGenInSigs=[hMemMuxNinSigs(1),hMemMuxNinSigs(2),hMemMuxNinSigs(3),...
    hMemMuxNinSigs(4),hMemMuxNinSigs(5),hMemMuxNinSigs(14),...
    hMemMuxNinSigs(15),hMemMuxNinSigs(16),hMemMuxNinSigs(17)];

    WrtDataGenOutSigs=hMemMuxNoutSigs(3);

    this.WrtDataGenerator(hMemMuxN,WrtDataGenInSigs,WrtDataGenOutSigs,hBoolT,hInputDataT,...
    slRate,blockInfo);


    RdAddrGenInSigs=[hMemMuxNinSigs(3),hMemMuxNinSigs(4),hMemMuxNinSigs(5),...
    hMemMuxNinSigs(21),hMemMuxNinSigs(18),hMemMuxNinSigs(19),...
    hMemMuxNinSigs(20),hMemMuxNinSigs(22)];

    RdAddrGenOutSigs=hMemMuxNoutSigs(4);

    this.RdAddrGenerator(hMemMuxN,RdAddrGenInSigs,RdAddrGenOutSigs,hBoolT,hAddrT,...
    slRate,blockInfo);

    pirelab.instantiateNetwork(hN,hMemMuxN,MemMuxInSigs,MemMuxOutSigs,...
    [hMemMuxN.Name,'_inst']);

end
