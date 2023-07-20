

function MultBuffer(~,hN,MultBufInSigs,MultBufOutSigs,...
    slRate,blockInfo)


    hMultBufN=pirelab.createNewNetwork(...
    'Name','MultBuffer',...
    'InportNames',{'compareIndexFlag','colData'},...
    'InportTypes',[MultBufInSigs(1).Type,MultBufInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'MultDataIn'},...
    'OutportTypes',MultBufOutSigs(1).Type);

    hMultBufN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hMultBufN.PirOutputSignals)
        hMultBufN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hMultBufNinSigs=hMultBufN.PirInputSignals;
    hMultBufNoutSigs=hMultBufN.PirOutputSignals;


    hInputDataT=pir_single_t;
    colData=hMultBufNinSigs(2);

    if blockInfo.RowSize>1
        colDataSplitS=colData.split;
        colDataSplitSigS=colDataSplitS.PirOutputSignals;
    else
        colDataSplitS=colData;
        colDataSplitSigS=colDataSplitS;
    end


    compareToIndexFlag=hMultBufNinSigs(1);
    MultDataIn=hMultBufNoutSigs(1);


    MultDataInArray=hdlhandles(blockInfo.RowSize*2,1);

    aDelayS=hdlhandles(blockInfo.RowSize,1);
    bDelayS=hdlhandles(blockInfo.RowSize,1);
    SwitchS=hdlhandles(blockInfo.RowSize,1);

    offSet=0;
    for itr=1:blockInfo.RowSize
        suffix=['_',int2str(itr)];

        aDelayS(itr)=l_addSignal(hMultBufN,['aDelay',suffix],hInputDataT,slRate);
        bDelayS(itr)=l_addSignal(hMultBufN,['bDelay',suffix],hInputDataT,slRate);
        SwitchS(itr)=l_addSignal(hMultBufN,['Switch',suffix],hInputDataT,slRate);


        pirelab.getIntDelayComp(hMultBufN,...
        SwitchS(itr),...
        aDelayS(itr),...
        1,['aDelay',suffix],...
        single(0),...
        0,0,[],0,0);

        pirelab.getIntDelayComp(hMultBufN,...
        colDataSplitSigS(itr),...
        bDelayS(itr),...
        1,['bDelay',suffix],...
        single(0),...
        0,0,[],0,0);

        pirelab.getSwitchComp(hMultBufN,...
        [colDataSplitSigS(itr),aDelayS(itr)],...
        SwitchS(itr),...
        compareToIndexFlag,['Switch',suffix],...
        '~=',0,'Floor','Wrap');
        MultDataInArray(itr+offSet)=aDelayS(itr);
        offSet=offSet+1;
        MultDataInArray(itr+offSet)=bDelayS(itr);
    end

    pirelab.getMuxComp(hMultBufN,...
    MultDataInArray(1:end),...
    MultDataIn,...
    'concatenate');

    pirelab.instantiateNetwork(hN,hMultBufN,MultBufInSigs,MultBufOutSigs,...
    [hMultBufN.Name,'_inst']);


end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
