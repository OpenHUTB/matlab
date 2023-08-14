

function LTProcessController(this,hN,LTProcControlInSigs,LTProcControlOutSigs,...
    slRate,blockInfo)



    hLTProcControlN=pirelab.createNewNetwork(...
    'Name','LTProcessController',...
    'InportNames',{'storeDone','rowDone'},...
    'InportTypes',[LTProcControlInSigs(1).Type,LTProcControlInSigs(2).Type],...
    'InportRates',[slRate,slRate],...
    'OutportNames',{'lowerTriangDone','lowerTriangEnb','colCount','diagValidIn',...
    'nonDiagValidIn','rowCount'},...
    'OutportTypes',[LTProcControlOutSigs(1).Type,LTProcControlOutSigs(2).Type,...
    LTProcControlOutSigs(3).Type,LTProcControlOutSigs(4).Type,...
    LTProcControlOutSigs(5).Type,LTProcControlOutSigs(6).Type]);

    hLTProcControlN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTProcControlN.PirOutputSignals)
        hLTProcControlN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTProcControlNinSigs=hLTProcControlN.PirInputSignals;
    hLTProcControlNoutSigs=hLTProcControlN.PirOutputSignals;


    storeDone=hLTProcControlNinSigs(1);
    rowDone=hLTProcControlNinSigs(2);

    lowerTriangDone=hLTProcControlNoutSigs(1);
    lowerTriangEnb=hLTProcControlNoutSigs(2);
    colCount=hLTProcControlNoutSigs(3);
    diagValidIn=hLTProcControlNoutSigs(4);
    nonDiagValidIn=hLTProcControlNoutSigs(5);
    rowCount=hLTProcControlNoutSigs(6);


    hBoolT=pir_boolean_t;

    if bitand(blockInfo.RowSize,blockInfo.RowSize*2-1)==blockInfo.RowSize
        hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize))+1,...
        'FractionLength',0);
    else
        hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize)),...
        'FractionLength',0);
    end


    readEnableS=l_addSignal(hLTProcControlN,'readEnable',hBoolT,slRate);


    LTMemRdControlInSigs=[storeDone,rowCount,...
    colCount,rowDone];
    LTMemRdControlOutSigs=[lowerTriangDone,lowerTriangEnb,...
    readEnableS,diagValidIn,nonDiagValidIn];

    this.LTMemReadControl(hLTProcControlN,LTMemRdControlInSigs,LTMemRdControlOutSigs,...
    slRate,blockInfo);


    LTRowColCounterInSigs=[readEnableS,rowDone];
    LTRowColCounterOutSigs=[rowCount,colCount];

    this.LTRowColCounter(hLTProcControlN,LTRowColCounterInSigs,LTRowColCounterOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo);


    pirelab.instantiateNetwork(hN,hLTProcControlN,LTProcControlInSigs,LTProcControlOutSigs,...
    [hLTProcControlN.Name,'_inst']);

end




function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


