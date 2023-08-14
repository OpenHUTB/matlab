

function LTMemReadControl(this,hN,LTMemRdControlInSigs,LTMemRdControlOutSigs,...
    slRate,blockInfo)


    hLTMemRdControlN=pirelab.createNewNetwork(...
    'Name','LTMemReadControl',...
    'InportNames',{'storeDone','rowCount','colCount','rowDone'},...
    'InportTypes',[LTMemRdControlInSigs(1).Type,LTMemRdControlInSigs(2).Type,...
    LTMemRdControlInSigs(3).Type,LTMemRdControlInSigs(4).Type],...
    'InportRates',slRate*ones(1,4),...
    'OutportNames',{'lowerTriangDone','lowerTriangEnb','readEnable','diagValidIn',...
    'nonDiagValidIn'},...
    'OutportTypes',[LTMemRdControlOutSigs(1).Type,LTMemRdControlOutSigs(2).Type,...
    LTMemRdControlOutSigs(3).Type,LTMemRdControlOutSigs(4).Type,...
    LTMemRdControlOutSigs(5).Type]);

    hLTMemRdControlN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTMemRdControlN.PirOutputSignals)
        hLTMemRdControlN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTMemRdControlNinSigs=hLTMemRdControlN.PirInputSignals;
    hLTMemRdControlNoutSigs=hLTMemRdControlN.PirOutputSignals;


    storeDone=hLTMemRdControlNinSigs(1);
    rowCount=hLTMemRdControlNinSigs(2);
    colCount=hLTMemRdControlNinSigs(3);
    rowDone=hLTMemRdControlNinSigs(4);

    lowerTriangDone=hLTMemRdControlNoutSigs(1);
    lowerTriangEnb=hLTMemRdControlNoutSigs(2);
    readEnable=hLTMemRdControlNoutSigs(3);
    diagValidIn=hLTMemRdControlNoutSigs(4);
    nonDiagValidIn=hLTMemRdControlNoutSigs(5);



    LTEnableInSigs=[storeDone,rowDone,rowCount];
    LTEnableOutSigs=[lowerTriangDone,lowerTriangEnb];

    this.LowerTriangEnable(hLTMemRdControlN,LTEnableInSigs,LTEnableOutSigs,...
    slRate,blockInfo);


    LTRdEnableInSigs=[storeDone,rowDone,rowCount,nonDiagValidIn];
    LTRdEnableOutSigs=readEnable;

    this.LowerTriangReadEnable(hLTMemRdControlN,LTRdEnableInSigs,LTRdEnableOutSigs,...
    slRate,blockInfo)

    LTDataValidInInSigs=[lowerTriangEnb,readEnable,...
    rowCount,colCount];
    LTDataValidInOutSigs=[diagValidIn,nonDiagValidIn];

    this.LowerTriangDataValidIn(hLTMemRdControlN,LTDataValidInInSigs,LTDataValidInOutSigs,...
    slRate);



    pirelab.instantiateNetwork(hN,hLTMemRdControlN,LTMemRdControlInSigs,LTMemRdControlOutSigs,...
    [hLTMemRdControlN.Name,'_inst']);
end
