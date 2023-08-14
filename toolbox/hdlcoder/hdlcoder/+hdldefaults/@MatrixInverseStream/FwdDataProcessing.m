

function FwdDataProcessing(this,hN,FwdProcessingInSigs,FwdProcessingOutSigs,hBoolT,...
    hCounterT,hInputDataT,slRate,blockInfo)


    hFwdProcessingN=pirelab.createNewNetwork(...
    'Name','FwdDataProcessing',...
    'InportNames',{'rowCount','diagValidIn','mRdEn','rdData'},...
    'InportTypes',[hCounterT,hBoolT,hBoolT,pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize+1,0])],...
    'InportRates',slRate*ones(1,4),...
    'OutportNames',{'fwdSubDone','fwdDataValid','fwdData','rowProcDone'},...
    'OutportTypes',[hBoolT,hBoolT,hInputDataT,hBoolT]);

    hFwdProcessingN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hFwdProcessingN.PirOutputSignals)
        hFwdProcessingN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hFwdProcessingNinSigs=hFwdProcessingN.PirInputSignals;
    hFwdProcessingNoutSigs=hFwdProcessingN.PirOutputSignals;


    rowCountRegS=l_addSignal(hFwdProcessingN,'rowCountReg',hCounterT,slRate);
    colCountRegS=l_addSignal(hFwdProcessingN,'colCountReg',hCounterT,slRate);
    reciprocalDataS=l_addSignal(hFwdProcessingN,'rowCountReg',hInputDataT,slRate);
    rdDataNonDiagS=l_addSignal(hFwdProcessingN,'rdDataNonDiag',...
    pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize+1,0]),slRate);

    diagOutValidS=l_addSignal(hFwdProcessingN,'diagValidOut',hBoolT,slRate);
    diagOutDataS=l_addSignal(hFwdProcessingN,'diagOutData',hInputDataT,slRate);
    nonDiagOutValidS=l_addSignal(hFwdProcessingN,'nonDiagOutValid',hBoolT,slRate);
    nonDiagOutDataS=l_addSignal(hFwdProcessingN,'nonDiagOutData',hInputDataT,slRate);
    Delay_out1_s7=l_addSignal(hFwdProcessingN,'Delay_out1',hBoolT,slRate);

    pirelab.getIntDelayComp(hFwdProcessingN,...
    hFwdProcessingNinSigs(3),...
    Delay_out1_s7,...
    1,'Delay',...
    false,...
    0,0,[],0,0);


    RowCntRegInSigs=[hFwdProcessingNinSigs(1),hFwdProcessingNoutSigs(4)];
    RowCntRegOutSigs=rowCountRegS;

    this.RowCountReg(hFwdProcessingN,RowCntRegInSigs,RowCntRegOutSigs,hCounterT,...
    hBoolT,slRate);


    DataDemuxInSigs=hFwdProcessingNinSigs(4);
    DataDemuxOutSigs=[reciprocalDataS,rdDataNonDiagS];

    this.DataDemux(hFwdProcessingN,DataDemuxInSigs,DataDemuxOutSigs,hInputDataT,slRate,blockInfo);


    FwdSubDiagCompInSigs=[hFwdProcessingNinSigs(2),reciprocalDataS];
    FwdSubDiagCompOutSigs=[diagOutValidS,diagOutDataS];

    this.FwdSubDiagComputation(hFwdProcessingN,FwdSubDiagCompInSigs,FwdSubDiagCompOutSigs,...
    hBoolT,hInputDataT,slRate);


    FwdNonDiagCompInSigs=[Delay_out1_s7,rowCountRegS,colCountRegS,rdDataNonDiagS,...
    hFwdProcessingNoutSigs(4)];
    FwdNonDiagCompOutSigs=[nonDiagOutValidS,nonDiagOutDataS];

    this.FwdSubNonDiagComputation(hFwdProcessingN,FwdNonDiagCompInSigs,FwdNonDiagCompOutSigs,...
    hBoolT,hCounterT,hInputDataT,slRate,blockInfo);


    ProcDataControlInSigs=[diagOutValidS,nonDiagOutValidS];
    ProcDataControlOutSigs=[hFwdProcessingNoutSigs(2),hFwdProcessingNoutSigs(1),...
    hFwdProcessingNoutSigs(4),colCountRegS];
    this.ProcDataControl(hFwdProcessingN,ProcDataControlInSigs,ProcDataControlOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo);


    FwdDataSelInSigs=[diagOutDataS,nonDiagOutValidS,nonDiagOutDataS];
    FwdDataSelOutSigs=hFwdProcessingNoutSigs(3);

    this.FwdDataSelector(hFwdProcessingN,FwdDataSelInSigs,FwdDataSelOutSigs,hBoolT,...
    hInputDataT,slRate);

    pirelab.instantiateNetwork(hN,hFwdProcessingN,FwdProcessingInSigs,FwdProcessingOutSigs,...
    [hFwdProcessingN.Name,'_inst']);

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


