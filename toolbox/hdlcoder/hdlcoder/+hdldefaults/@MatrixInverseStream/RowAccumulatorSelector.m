
function RowAccumulatorSelector(~,hN,RowAccumSelInSigs,RowAccumSelOutSigs,...
    hAddrT,hInputDataT,slRate,blockInfo)



    hRowAccumSelN=pirelab.createNewNetwork(...
    'Name','RowAccumulatorSelector',...
    'InportNames',{'nonDiagCount','accumOutVector'},...
    'InportTypes',[hAddrT,RowAccumSelInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'multiplyAccumOut'},...
    'OutportTypes',hInputDataT);

    hRowAccumSelN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hRowAccumSelN.PirOutputSignals)
        hRowAccumSelN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hRowAccumSelNinSigs=hRowAccumSelN.PirInputSignals;
    hRowAccumSelNoutSigs=hRowAccumSelN.PirOutputSignals;

    Constant_out1_s2=l_addSignal(hRowAccumSelN,'Constant_out1',hInputDataT,slRate);

    if blockInfo.RowSize>3
        accumOutSplitS=hRowAccumSelNinSigs(2).split;
        accumOutSplitSigS=accumOutSplitS.PirOutputSignals;
    else
        accumOutSplitS=hRowAccumSelNinSigs(2);
        accumOutSplitSigS=accumOutSplitS;
    end
    hTypeConvT=hRowAccumSelN.getType('FixedPoint','Signed',false,'WordLength',...
    ceil(log2(blockInfo.RowSize)+1),'FractionLength',0);

    nonDiagCountTypeCnvS=l_addSignal(hRowAccumSelN,'nonDiagCountTypeCnv',hTypeConvT,slRate);

    pirelab.getDTCComp(hRowAccumSelN,...
    hRowAccumSelNinSigs(1),...
    nonDiagCountTypeCnvS,...
    'Floor','Wrap','RWV','Data Type Conversion');


    pirelab.getConstComp(hRowAccumSelN,...
    Constant_out1_s2,...
    single(0),...
    'Constant','on',1,'','','');


    pirelab.getMultiPortSwitchComp(hRowAccumSelN,...
    [nonDiagCountTypeCnvS,Constant_out1_s2,(accumOutSplitSigS(1:end))',...
    Constant_out1_s2],hRowAccumSelNoutSigs(1),...
    1,'One-based contiguous','Floor','Wrap',sprintf('Multiport\nSwitch'),[]);


    pirelab.instantiateNetwork(hN,hRowAccumSelN,RowAccumSelInSigs,...
    RowAccumSelOutSigs,[hRowAccumSelN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


