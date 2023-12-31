function hBWCtlN=matrixBMemoryWriteControl(~,hBMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)



    hBoolT=pir_boolean_t;
    inputDataT=hInSigs(1).Type;
    bCol=blockInfo.bColumnSize;
    bRow=blockInfo.aColumnSize;
    hbRowCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.aColumnSize))+1,0);
    hbColCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.bColumnSize))+1,0);

    hBWCtlN=pirelab.createNewNetwork(...
    'Name','matrixBMemoryWriteControl',...
    'InportNames',{'bData','bValid','bColCount','bRowCount'},...
    'InportTypes',[inputDataT,hBoolT,hbColCounterT,hbRowCounterT],...
    'InportRates',slRate*ones(1,4),...
    'OutportNames',{'bWrData','bWrAddr','bWrEn','bRowCountReg','bStoreDone'},...
    'OutportTypes',[inputDataT,hbColCounterT,hBoolT,hbRowCounterT,hBoolT]);
    hBWCtlN.setTargetCompReplacementCandidate(true);
    for ii=1:numel(hBWCtlN.PirOutputSignals)
        hBWCtlN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    pirelab.instantiateNetwork(hBMemCtlN,hBWCtlN,hInSigs,hOutSigs,...
    [hBWCtlN.Name,'_inst']);

    bDataS=hBWCtlN.PirInputSignals(1);
    bValidS=hBWCtlN.PirInputSignals(2);
    bColCountS=hBWCtlN.PirInputSignals(3);
    bRowCountS=hBWCtlN.PirInputSignals(4);
    bWrDataS=hBWCtlN.PirOutputSignals(1);
    bWrAddrS=hBWCtlN.PirOutputSignals(2);
    bWrEnS=hBWCtlN.PirOutputSignals(3);
    bRowCountRegS=hBWCtlN.PirOutputSignals(4);
    bStoreDoneS=hBWCtlN.PirOutputSignals(5);
    compareToConstantS=l_addSignal(hBWCtlN,'isEqToColCount',hBoolT,slRate);
    CompareToConstantS2=l_addSignal(hBWCtlN,'isEqToRowCount',hBoolT,slRate);
    constantS=l_addSignal(hBWCtlN,'constantOne',hbColCounterT,slRate);
    DelayS=l_addSignal(hBWCtlN,'bColCountDelay',hbColCounterT,slRate);
    SubtractS=l_addSignal(hBWCtlN,'bColCountTemp',hbColCounterT,slRate);

    pirelab.getConstComp(hBWCtlN,...
    constantS,...
    1,...
    'Constant','on',0,'','','');

    pirelab.getIntDelayComp(hBWCtlN,...
    bColCountS,...
    DelayS,...
    2,'Delay',...
    0,...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hBWCtlN,...
    bDataS,...
    bWrDataS,...
    1,'Delay1',...
    single(0),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hBWCtlN,...
    bValidS,...
    bWrEnS,...
    1,'Delay2',...
    false,...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hBWCtlN,...
    bRowCountS,...
    bRowCountRegS,...
    2,'Delay3',...
    0,...
    0,0,[],0,0);

    pirelab.getCompareToValueComp(hBWCtlN,...
    bWrAddrS,...
    compareToConstantS,...
    '==',bCol-1,...
    sprintf('Compare\nTo Constant'),0);

    pirelab.getCompareToValueComp(hBWCtlN,...
    bRowCountRegS,...
    CompareToConstantS2,...
    '==',bRow,...
    sprintf('Compare\nTo Constant1'),0);

    pirelab.getDTCComp(hBWCtlN,...
    SubtractS,...
    bWrAddrS,...
    'Floor','Wrap','RWV','Data Type Conversion');


    pirelab.getLogicComp(hBWCtlN,...
    [bWrEnS,compareToConstantS,CompareToConstantS2],...
    bStoreDoneS,...
    'and',sprintf('Logical\nOperator'));


    pirelab.getAddComp(hBWCtlN,...
    [DelayS,constantS],...
    SubtractS,...
    'Floor','Wrap','Subtract',hbColCounterT,'+-');

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


