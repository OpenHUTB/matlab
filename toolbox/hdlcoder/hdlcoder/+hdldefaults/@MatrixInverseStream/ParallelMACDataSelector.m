

function ParallelMACDataSelector(~,hN,MacDataSelInSigs,MacDataSelOutSigs,...
    hCounterT,hInputDataT,slRate,blockInfo)


    hMacDataSelN=pirelab.createNewNetwork(...
    'Name','ParallelMACDataSelector',...
    'InportNames',{'rowCount','rdDataPipeline'},...
    'InportTypes',[hCounterT,...
    MacDataSelInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'pipelineData2'},...
    'OutportTypes',MacDataSelOutSigs(1).Type);

    hMacDataSelN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hMacDataSelN.PirOutputSignals)
        hMacDataSelN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hMacDataSelNinSigs=hMacDataSelN.PirInputSignals;
    hMacDataSelNoutSigs=hMacDataSelN.PirOutputSignals;


    Constant_out1_s3=l_addSignal(hMacDataSelN,'Constant_out1',hInputDataT,slRate);

    pirelab.getConstComp(hMacDataSelN,...
    Constant_out1_s3,...
    single(0),...
    'Constant','on',1,'','','');


    if blockInfo.RowSize>2
        rdDataSelSplit=hMacDataSelNinSigs(2).split;
        rdDataSelSplitSigS=rdDataSelSplit.PirOutputSignals;
    else
        rdDataSelSplit=hMacDataSelNinSigs(2);
        rdDataSelSplitSigS=rdDataSelSplit;
    end

    pirelab.getMultiPortSwitchComp(hMacDataSelN,...
    [hMacDataSelNinSigs(1),Constant_out1_s3,Constant_out1_s3,(rdDataSelSplitSigS(1:end))',...
    Constant_out1_s3],...
    hMacDataSelNoutSigs(1),...
    1,'Zero-based contiguous','Floor','Wrap',sprintf('Multiport\nSwitch'),[]);


    pirelab.instantiateNetwork(hN,hMacDataSelN,MacDataSelInSigs,...
    MacDataSelOutSigs,[hMacDataSelN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end

