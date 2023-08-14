

function FwdWriteEnable(~,hN,FwdWrtEnbInSigs,FwdWrtEnbOutSigs,hBoolT,...
    hCounterT,slRate,blockInfo)


    hFwdWrtEnbN=pirelab.createNewNetwork(...
    'Name','FwdWriteEnable',...
    'InportNames',{'colCountOut','rowCountOut','dataOutValid'},...
    'InportTypes',[hCounterT,hCounterT,hBoolT],...
    'InportRates',slRate*ones(1,3),...
    'OutportNames',{'wrtEnbFwdSub'},...
    'OutportTypes',FwdWrtEnbOutSigs(1).Type);

    hFwdWrtEnbN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hFwdWrtEnbN.PirOutputSignals)
        hFwdWrtEnbN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hFwdWrtEnbNinSigs=hFwdWrtEnbN.PirInputSignals;
    hFwdWrtEnbNoutSigs=hFwdWrtEnbN.PirOutputSignals;


    DelayOutArray=hdlhandles(blockInfo.RowSize,1);

    compareToConstantRowS=hdlhandles(blockInfo.RowSize,1);
    compareToConstantColS=hdlhandles(blockInfo.RowSize,1);
    LogicalOeratorOrS=hdlhandles(blockInfo.RowSize,1);
    LogicalOperatorAndS=hdlhandles(blockInfo.RowSize,1);
    DelayS=hdlhandles(blockInfo.RowSize,1);



    for itr=1:blockInfo.RowSize

        suffix=['_',int2str(itr)];

        compareToConstantRowS(itr)=l_addSignal(hFwdWrtEnbN,['compareToConstantRow',suffix],...
        hBoolT,slRate);
        compareToConstantColS(itr)=l_addSignal(hFwdWrtEnbN,['compareToConstantCol',suffix],...
        hBoolT,slRate);
        LogicalOeratorOrS(itr)=l_addSignal(hFwdWrtEnbN,['LogicalOperatorOr',suffix],hBoolT,...
        slRate);

        LogicalOperatorAndS(itr)=l_addSignal(hFwdWrtEnbN,['LogicalOperatorAnd',suffix],hBoolT,...
        slRate);
        DelayS(itr)=l_addSignal(hFwdWrtEnbN,['Delay',suffix],hBoolT,...
        slRate);

        pirelab.getCompareToValueComp(hFwdWrtEnbN,...
        hFwdWrtEnbNinSigs(2),...
        compareToConstantRowS(itr),...
        '==',itr,...
        sprintf(['Compare\nTo ConstantRow',suffix]),0);

        pirelab.getCompareToValueComp(hFwdWrtEnbN,...
        hFwdWrtEnbNinSigs(1),...
        compareToConstantColS(itr),...
        '==',itr,...
        sprintf(['Compare\nTo ConstantCol',suffix]),0);

        pirelab.getLogicComp(hFwdWrtEnbN,...
        [compareToConstantColS(itr),compareToConstantRowS(itr)],...
        LogicalOeratorOrS(itr),...
        'or',sprintf(['Logical\nOperatorOr',suffix]));

        pirelab.getLogicComp(hFwdWrtEnbN,...
        [LogicalOeratorOrS(itr),hFwdWrtEnbNinSigs(3)],...
        LogicalOperatorAndS(itr),...
        'and',sprintf(['Logical\nOperatorAnd',suffix]));

        pirelab.getIntDelayComp(hFwdWrtEnbN,...
        LogicalOperatorAndS(itr),...
        DelayS(itr),...
        1,['Delay',suffix],...
        false,...
        0,0,[],0,0);

        DelayOutArray(itr)=DelayS(itr);
    end

    pirelab.getMuxComp(hFwdWrtEnbN,...
    DelayOutArray(1:end),...
    hFwdWrtEnbNoutSigs(1),...
    'concatenate');

    pirelab.instantiateNetwork(hN,hFwdWrtEnbN,FwdWrtEnbInSigs,...
    FwdWrtEnbOutSigs,[hFwdWrtEnbN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
