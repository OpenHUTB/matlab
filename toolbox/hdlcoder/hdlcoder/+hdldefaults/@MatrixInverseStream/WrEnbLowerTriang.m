
function WrEnbLowerTriang(~,hN,WrEnbLTInSigs,WrEnbLTOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo)


    hWrEnbLTN=pirelab.createNewNetwork(...
    'Name','WrEnbLowerTriang',...
    'InportNames',{'lowerTriangEnb','diagValidOut','nonDiagValidOut','rowCount',...
    'reciprocalValid'},...
    'InportTypes',[hBoolT,hBoolT,hBoolT,hCounterT,hBoolT],...
    'InportRates',slRate*ones(1,5),...
    'OutportNames',{'wrEnbLT'},...
    'OutportTypes',pirelab.createPirArrayType(hBoolT,[blockInfo.RowSize+1,0]));

    hWrEnbLTN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hWrEnbLTN.PirOutputSignals)
        hWrEnbLTN.PirOutputSignals(ii).SimulinkRate=slRate;
    end



    hWrEnbLTNinSigs=hWrEnbLTN.PirInputSignals;
    hWrEnbLTNoutSigs=hWrEnbLTN.PirOutputSignals;

    LogicalOperator_out1_s9=l_addSignal(hWrEnbLTN,sprintf('Logical\nOperator_out1'),...
    hBoolT,slRate);
    LogicalOperator1_out1_s10=l_addSignal(hWrEnbLTN,sprintf('Logical\nOperator1_out1'),...
    hBoolT,slRate);


    pirelab.getLogicComp(hWrEnbLTN,...
    [hWrEnbLTNinSigs(2),hWrEnbLTNinSigs(3)],...
    LogicalOperator_out1_s9,...
    'or',sprintf('Logical\nOperator'));


    pirelab.getLogicComp(hWrEnbLTN,...
    [hWrEnbLTNinSigs(1),LogicalOperator_out1_s9],...
    LogicalOperator1_out1_s10,...
    'and',sprintf('Logical\nOperator1'));

    LogicalOut=hdlhandles(blockInfo.RowSize,1);

    CompareToConstantS=hdlhandles(blockInfo.RowSize,1);
    LogicalOperatorS=hdlhandles(blockInfo.RowSize,1);

    for itr=1:blockInfo.RowSize

        suffix=['_',int2str(itr)];

        CompareToConstantS(itr)=l_addSignal(hWrEnbLTN,['CompareToConstant',suffix],hBoolT,slRate);
        LogicalOperatorS(itr)=l_addSignal(hWrEnbLTN,['LogicalOperator',suffix],hBoolT,slRate);


        pirelab.getCompareToValueComp(hWrEnbLTN,...
        hWrEnbLTNinSigs(4),...
        CompareToConstantS(itr),...
        '==',itr,...
        sprintf('Compare\nTo Constant'),0);

        pirelab.getLogicComp(hWrEnbLTN,...
        [LogicalOperator1_out1_s10,CompareToConstantS(itr)],...
        LogicalOperatorS(itr),...
        'and',sprintf('Logical\nOperator2'));
        LogicalOut(itr)=LogicalOperatorS(itr);
    end

    pirelab.getMuxComp(hWrEnbLTN,...
    [(LogicalOut(1:end))',hWrEnbLTNinSigs(5)],...
    hWrEnbLTNoutSigs(1),...
    'concatenate');




    pirelab.instantiateNetwork(hN,hWrEnbLTN,WrEnbLTInSigs,WrEnbLTOutSigs,...
    [hWrEnbLTN.Name,'_inst']);
end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


