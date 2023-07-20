

function gaussJordanMemReadControl(this,hN,LTMemRdControlInSigs,LTMemRdControlOutSigs,...
    slRate,blockInfo)




    hLTMemRdControlN=pirelab.createNewNetwork(...
    'Name','gaussJordanMemReadControl',...
    'InportNames',{'invFinish','storeDone','rowCount','colCount','swapEnb','swapDone','rowFinish'},...
    'InportTypes',[LTMemRdControlInSigs(1).Type,LTMemRdControlInSigs(2).Type,...
    LTMemRdControlInSigs(3).Type,LTMemRdControlInSigs(4).Type,LTMemRdControlInSigs(5).Type,...
    LTMemRdControlInSigs(6).Type,LTMemRdControlInSigs(7).Type],...
    'InportRates',slRate*ones(1,7),...
    'OutportNames',{'processingEnb','readEnable','diagValidIn','nonDiagValidIn','swapReadEnable'},...
    'OutportTypes',[LTMemRdControlOutSigs(1).Type,LTMemRdControlOutSigs(2).Type,...
    LTMemRdControlOutSigs(3).Type,LTMemRdControlOutSigs(4).Type,...
    LTMemRdControlOutSigs(5).Type]);

    hLTMemRdControlN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTMemRdControlN.PirOutputSignals)
        hLTMemRdControlN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTMemRdControlNinSigs=hLTMemRdControlN.PirInputSignals;
    hLTMemRdControlNoutSigs=hLTMemRdControlN.PirOutputSignals;


    invFinish=hLTMemRdControlNinSigs(1);
    storeDone=hLTMemRdControlNinSigs(2);
    rowCount=hLTMemRdControlNinSigs(3);
    colCount=hLTMemRdControlNinSigs(4);
    swapEnb=hLTMemRdControlNinSigs(5);
    swapDone=hLTMemRdControlNinSigs(6);
    rowFinish=hLTMemRdControlNinSigs(7);




    processingEnb=hLTMemRdControlNoutSigs(1);
    readEnable=hLTMemRdControlNoutSigs(2);
    diagValidIn=hLTMemRdControlNoutSigs(3);
    nonDiagValidIn=hLTMemRdControlNoutSigs(4);
    swapReadEnable=hLTMemRdControlNoutSigs(5);



    LTEnableInSigs=[invFinish,storeDone];
    LTEnableOutSigs=processingEnb;

    this.gaussJordanEnable(hLTMemRdControlN,LTEnableInSigs,LTEnableOutSigs,...
    slRate);


    LTRdEnableInSigs=[invFinish,storeDone,rowFinish,swapDone,diagValidIn];
    LTRdEnableOutSigs=[readEnable,swapReadEnable];

    this.gaussJordanReadEnable(hLTMemRdControlN,LTRdEnableInSigs,LTRdEnableOutSigs,...
    slRate,blockInfo)

    LTDataValidInInSigs=[processingEnb,readEnable,...
    rowCount,colCount,swapEnb];
    LTDataValidInOutSigs=[diagValidIn,nonDiagValidIn];

    this.gaussJordanDataValidIn(hLTMemRdControlN,LTDataValidInInSigs,LTDataValidInOutSigs,...
    slRate);



    pirelab.instantiateNetwork(hN,hLTMemRdControlN,LTMemRdControlInSigs,LTMemRdControlOutSigs,...
    [hLTMemRdControlN.Name,'_inst']);
end
