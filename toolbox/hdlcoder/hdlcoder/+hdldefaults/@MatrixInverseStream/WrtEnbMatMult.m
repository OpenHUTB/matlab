

function WrtEnbMatMult(~,hN,WrtEnbMultInSigs,WrtEnbMultOutSigs,...
    slRate,blockInfo)


    hWrtEnbMultN=pirelab.createNewNetwork(...
    'Name','WrtEnbMatMult',...
    'InportNames',{'rowCountOut','prodValid','colCountOut'},...
    'InportTypes',[WrtEnbMultInSigs(1).Type,WrtEnbMultInSigs(2).Type,...
    WrtEnbMultInSigs(3).Type],...
    'InportRates',slRate*ones(1,3),...
    'OutportNames',{'wrtEnbMatMult'},...
    'OutportTypes',WrtEnbMultOutSigs(1).Type);

    hWrtEnbMultN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hWrtEnbMultN.PirOutputSignals)
        hWrtEnbMultN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hWrtEnbMultNinSigs=hWrtEnbMultN.PirInputSignals;
    hWrtEnbMultNoutSigs=hWrtEnbMultN.PirOutputSignals;


    hBoolT=pir_boolean_t;



    rowCountOut=hWrtEnbMultNinSigs(1);
    prodValid=hWrtEnbMultNinSigs(2);
    colCountOut=hWrtEnbMultNinSigs(3);

    wrtEnbMatMult=hWrtEnbMultNoutSigs(1);


    LogicalAndOutArray=hdlhandles(blockInfo.RowSize,1);

    compareToConstantRowS=hdlhandles(blockInfo.RowSize,1);
    compareToConstantColS=hdlhandles(blockInfo.RowSize,1);
    LogicalOeratorOrS=hdlhandles(blockInfo.RowSize,1);
    LogicalOperatorAndS=hdlhandles(blockInfo.RowSize,1);



    for itr=1:blockInfo.RowSize

        suffix=['_',int2str(itr)];
        compareToConstantRowS(itr)=l_addSignal(hWrtEnbMultN,['compareToConstantRow',suffix],...
        hBoolT,slRate);
        compareToConstantColS(itr)=l_addSignal(hWrtEnbMultN,['compareToConstantCol',suffix],...
        hBoolT,slRate);
        LogicalOeratorOrS(itr)=l_addSignal(hWrtEnbMultN,['LogicalOperatorOr',suffix],hBoolT,...
        slRate);

        LogicalOperatorAndS(itr)=l_addSignal(hWrtEnbMultN,['LogicalOperatorAnd',suffix],hBoolT,...
        slRate);

        pirelab.getCompareToValueComp(hWrtEnbMultN,...
        rowCountOut,...
        compareToConstantRowS(itr),...
        '==',itr,...
        sprintf(['Compare\nTo ConstantRow',suffix]),0);

        pirelab.getCompareToValueComp(hWrtEnbMultN,...
        colCountOut,...
        compareToConstantColS(itr),...
        '==',itr,...
        sprintf(['Compare\nTo ConstantCol',suffix]),0);

        pirelab.getLogicComp(hWrtEnbMultN,...
        [compareToConstantColS(itr),compareToConstantRowS(itr)],...
        LogicalOeratorOrS(itr),...
        'or',sprintf(['Logical\nOperatorOr',suffix]));

        pirelab.getLogicComp(hWrtEnbMultN,...
        [LogicalOeratorOrS(itr),prodValid],...
        LogicalOperatorAndS(itr),...
        'and',sprintf(['Logical\nOperatorAnd',suffix]));


        LogicalAndOutArray(itr)=LogicalOperatorAndS(itr);
    end

    pirelab.getMuxComp(hWrtEnbMultN,...
    LogicalAndOutArray(1:end),...
    wrtEnbMatMult,...
    'concatenate');

    pirelab.instantiateNetwork(hN,hWrtEnbMultN,WrtEnbMultInSigs,...
    WrtEnbMultOutSigs,[hWrtEnbMultN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
