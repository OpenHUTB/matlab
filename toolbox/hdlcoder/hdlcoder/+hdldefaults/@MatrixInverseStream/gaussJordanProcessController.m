

function gaussJordanProcessController(this,hN,LTProcControlInSigs,LTProcControlOutSigs,...
    slRate,blockInfo)





    hLTProcControlN=pirelab.createNewNetwork(...
    'Name','gaussJordanProcessController',...
    'InportNames',{'invFinish','swapDone','storeDone','swapEnb','isDiagZero','rowFinish'},...
    'InportTypes',[LTProcControlInSigs(1).Type,LTProcControlInSigs(2).Type,LTProcControlInSigs(3).Type,...
    LTProcControlInSigs(4).Type,LTProcControlInSigs(5).Type,LTProcControlInSigs(6).Type],...
    'InportRates',[slRate,slRate,slRate,slRate,slRate,slRate],...
    'OutportNames',{'processingEnb','colCount','diagValidIn','nonDiagValidIn',...
    'rowCount','swapReadEnable'},...
    'OutportTypes',[LTProcControlOutSigs(1).Type,LTProcControlOutSigs(2).Type,...
    LTProcControlOutSigs(3).Type,LTProcControlOutSigs(4).Type,...
    LTProcControlOutSigs(5).Type,LTProcControlOutSigs(6).Type]);

    hLTProcControlN.setTargetCompReplacementCandidate(true);

    for ii=1:numel(hLTProcControlN.PirOutputSignals)
        hLTProcControlN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTProcControlNinSigs=hLTProcControlN.PirInputSignals;
    hLTProcControlNoutSigs=hLTProcControlN.PirOutputSignals;


    invFinish=hLTProcControlNinSigs(1);
    swapDone=hLTProcControlNinSigs(2);
    storeDone=hLTProcControlNinSigs(3);
    swapEnb=hLTProcControlNinSigs(4);
    isDiagZero=hLTProcControlNinSigs(5);
    rowFinish=hLTProcControlNinSigs(6);




    processingEnb=hLTProcControlNoutSigs(1);
    colCount=hLTProcControlNoutSigs(2);
    diagValidIn=hLTProcControlNoutSigs(3);
    nonDiagValidIn=hLTProcControlNoutSigs(4);
    rowCount=hLTProcControlNoutSigs(5);
    swapReadEnable=hLTProcControlNoutSigs(6);


    hBoolT=pir_boolean_t;

    hCounterT=hN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize))+1,...
    'FractionLength',0);


    readEnable=l_addSignal(hLTProcControlN,'readEnable',hBoolT,slRate);



    LTMemRdControlInSigs=[invFinish,storeDone,...
    rowCount,colCount,swapEnb,swapDone,rowFinish];
    LTMemRdControlOutSigs=[processingEnb,readEnable,...
    diagValidIn,nonDiagValidIn,swapReadEnable];

    this.gaussJordanMemReadControl(hLTProcControlN,LTMemRdControlInSigs,LTMemRdControlOutSigs,...
    slRate,blockInfo);


    LTRowColCounterInSigs=[readEnable,rowFinish,swapDone,invFinish,isDiagZero,swapReadEnable];
    LTRowColCounterOutSigs=[rowCount,colCount];

    this.gaussJordanRowColCounter(hLTProcControlN,LTRowColCounterInSigs,LTRowColCounterOutSigs,...
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


