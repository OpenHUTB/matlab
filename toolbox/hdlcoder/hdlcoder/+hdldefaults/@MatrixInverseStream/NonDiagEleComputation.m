
function NonDiagEleComputation(this,hN,NonDiagEleComputationInSigs,NonDiagEleComputationOutSigs,...
    hBoolT,hAddrT,hCounterT,hInputDataT,slRate,blockInfo)


    hNonDiagEleComputationN=pirelab.createNewNetwork(...
    'Name','NonDiagEleComputation',...
    'InportNames',{'nonDiagCount','rowDone','nonDiagValidIn','rowCount','readData'},...
    'InportTypes',[hAddrT,hBoolT,hBoolT,hCounterT,NonDiagEleComputationInSigs(5).Type],...
    'InportRates',slRate*ones(1,5),...
    'OutportNames',{'nonDiagValidOut','nonDiagDataOut','nonDiagCountValid'},...
    'OutportTypes',[hBoolT,hInputDataT,hBoolT]);

    hNonDiagEleComputationN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hNonDiagEleComputationN.PirOutputSignals)
        hNonDiagEleComputationN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hNonDiagEleComputationNinSigs=hNonDiagEleComputationN.PirInputSignals;
    hNonDiagEleComputationNoutSigs=hNonDiagEleComputationN.PirOutputSignals;



    if blockInfo.RowSize>2
        readDataSelS=l_addSignal(hNonDiagEleComputationN,'readDataSel',...
        pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize-1,0]),slRate);
    else
        readDataSelS=l_addSignal(hNonDiagEleComputationN,'readDataSel',...
        hInputDataT,slRate);
    end
    nonDiagDataInS=l_addSignal(hNonDiagEleComputationN,'nonDiagDataIn',hInputDataT,slRate);

    if blockInfo.RowSize>3
        readDataMACS=l_addSignal(hNonDiagEleComputationN,'readDataMAC',...
        pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize-2,0]),slRate);
    else
        readDataMACS=l_addSignal(hNonDiagEleComputationN,'readDataMAC',...
        hInputDataT,slRate);
    end

    accumOutDataS=l_addSignal(hNonDiagEleComputationN,'accumOutData',hInputDataT,slRate);

    if blockInfo.RowSize>1
        RdDataNonDiagS=hNonDiagEleComputationNinSigs(5).split;
        RdDataNonDiagSplitS=RdDataNonDiagS.PirOutputSignals;
    else
        RdDataNonDiagS=hNonDiagEleComputationNinSigs(5);
        RdDataNonDiagSplitS=RdDataNonDiagS;
    end


    if(blockInfo.RowSize>1)
        pirelab.getMuxComp(hNonDiagEleComputationN,...
        RdDataNonDiagSplitS(1:end-1),...
        readDataSelS,...
        'concatenate');
    else
        pirelab.getMuxComp(hNonDiagEleComputationN,...
        RdDataNonDiagSplitS,...
        readDataSelS,...
        'concatenate');
    end


    if(blockInfo.RowSize>2)
        pirelab.getMuxComp(hNonDiagEleComputationN,...
        RdDataNonDiagSplitS(1:end-2),...
        readDataMACS,...
        'concatenate');
    else
        pirelab.getMuxComp(hNonDiagEleComputationN,...
        RdDataNonDiagSplitS(1),...
        readDataMACS,...
        'concatenate');
    end


    NonDiagDataSelectorInSigs=[hNonDiagEleComputationNinSigs(4),readDataSelS];
    NonDiagDataSelectorOutSigs=nonDiagDataInS;

    this.NonDiagDataSelector(hNonDiagEleComputationN,NonDiagDataSelectorInSigs,...
    NonDiagDataSelectorOutSigs,hCounterT,hInputDataT,slRate,blockInfo);


    LTNonDiagMACInSigs=[hNonDiagEleComputationNinSigs(3),hNonDiagEleComputationNinSigs(1),...
    hNonDiagEleComputationNinSigs(2),readDataMACS,hNonDiagEleComputationNoutSigs(2)];
    LTNonDiagMACOutSigs=accumOutDataS;

    this.LTNonDiagMAC(hNonDiagEleComputationN,LTNonDiagMACInSigs,LTNonDiagMACOutSigs,...
    hInputDataT,hAddrT,hBoolT,slRate,blockInfo);


    LTSubMultInSigs=[nonDiagDataInS,accumOutDataS,...
    hNonDiagEleComputationNinSigs(3),RdDataNonDiagSplitS(blockInfo.RowSize)];
    LTSubMultOutSigs=[hNonDiagEleComputationNoutSigs(1),hNonDiagEleComputationNoutSigs(2),...
    hNonDiagEleComputationNoutSigs(3)];

    this.DataSubtractionAndReciprocalMult(hNonDiagEleComputationN,LTSubMultInSigs,...
    LTSubMultOutSigs,hBoolT,hInputDataT,slRate);



    pirelab.instantiateNetwork(hN,hNonDiagEleComputationN,NonDiagEleComputationInSigs,...
    NonDiagEleComputationOutSigs,[hNonDiagEleComputationN.Name,'_inst']);


end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


