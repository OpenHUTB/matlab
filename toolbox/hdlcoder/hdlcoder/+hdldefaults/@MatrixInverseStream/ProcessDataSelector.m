
function ProcessDataSelector(~,hN,ProcDataSelInSigs,ProcDataSelOutSigs,...
    hCounterT,hInputDataT,slRate,blockInfo)


    hProcDataSelN=pirelab.createNewNetwork(...
    'Name','ProcessDataSelector',...
    'InportNames',{'rowCount','colCount','procData'},...
    'InportTypes',[hCounterT,hCounterT,...
    ProcDataSelInSigs(3).Type],...
    'InportRates',slRate*ones(1,3),...
    'OutportNames',{'nonDiagOutData'},...
    'OutportTypes',hInputDataT);

    hProcDataSelN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hProcDataSelN.PirOutputSignals)
        hProcDataSelN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hProcDataSelNinSigs=hProcDataSelN.PirInputSignals;
    hProcDataSelNoutSigs=hProcDataSelN.PirOutputSignals;

    if bitand(blockInfo.RowSize,blockInfo.RowSize*2-1)==blockInfo.RowSize
        hCounterT=hProcDataSelN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize))+1,...
        'FractionLength',0);
    else
        hCounterT=hProcDataSelN.getType('FixedPoint','Signed',false,'WordLength',ceil(log2(blockInfo.RowSize)),...
        'FractionLength',0);
    end

    Constant3_out1_s3=l_addSignal(hProcDataSelN,'Constant3_out1',hInputDataT,slRate);
    SubtractOutS=l_addSignal(hProcDataSelN,'SubtractOutS',hCounterT,slRate);

    if blockInfo.RowSize>2
        procDataSplitS=hProcDataSelNinSigs(3).split;
        procDataSplitSigS=procDataSplitS.PirOutputSignals;
    else
        procDataSplitS=hProcDataSelNinSigs(3);
        procDataSplitSigS=procDataSplitS;
    end

    pirelab.getConstComp(hProcDataSelN,...
    Constant3_out1_s3,...
    single(0),...
    'Constant','on',1,'','','');

    pirelab.getAddComp(hProcDataSelN,...
    [hProcDataSelNinSigs(1),hProcDataSelNinSigs(2)],...
    SubtractOutS,...
    'Floor','Wrap','Subtract',hCounterT,'+-');

    pirelab.getMultiPortSwitchComp(hProcDataSelN,...
    [SubtractOutS,Constant3_out1_s3,...
    (procDataSplitSigS(1:end))',...
    Constant3_out1_s3],...
    hProcDataSelNoutSigs(1),...
    1,'Zero-based contiguous','Floor','Wrap',sprintf('Multiport\nSwitch4'),[]);


    pirelab.instantiateNetwork(hN,hProcDataSelN,ProcDataSelInSigs,...
    ProcDataSelOutSigs,[hProcDataSelN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


