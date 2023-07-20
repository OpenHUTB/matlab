
function gaussJordanDataValidIn(~,hN,LTDataValidInInSigs,LTDataValidInOutSigs,...
    slRate)





    hLTDataValidInN=pirelab.createNewNetwork(...
    'Name','gaussJordanDataValidIn',...
    'InportNames',{'processingEnb','readEnable','rowCount','colCount','swapEnb'},...
    'InportTypes',[LTDataValidInInSigs(1).Type,LTDataValidInInSigs(2).Type,...
    LTDataValidInInSigs(3).Type,LTDataValidInInSigs(4).Type,LTDataValidInInSigs(5).Type],...
    'InportRates',slRate*ones(1,5),...
    'OutportNames',{'diagValidIn','nonDiagValidIn'},...
    'OutportTypes',[LTDataValidInOutSigs(1).Type,LTDataValidInOutSigs(2).Type]);

    hLTDataValidInN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTDataValidInN.PirOutputSignals)
        hLTDataValidInN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTDataValidInNinSigs=hLTDataValidInN.PirInputSignals;
    hLTDataValidInNoutSigs=hLTDataValidInN.PirOutputSignals;


    processingEnb=hLTDataValidInNinSigs(1);
    readEnable=hLTDataValidInNinSigs(2);
    rowCount=hLTDataValidInNinSigs(3);
    colCount=hLTDataValidInNinSigs(4);
    swapEnb=hLTDataValidInNinSigs(5);

    diagValidIn=hLTDataValidInNoutSigs(1);
    nonDiagValidIn=hLTDataValidInNoutSigs(2);

    pirTyp1=pir_boolean_t;






    LogicalOperator_out1_s7=l_addSignal(hLTDataValidInN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate);
    LogicalOperator1_out1_s8=l_addSignal(hLTDataValidInN,sprintf('Logical\nOperator1_out1'),pirTyp1,slRate);
    LogicalOperator7_out1_s9=l_addSignal(hLTDataValidInN,sprintf('Logical\nOperator7_out1'),pirTyp1,slRate);
    RelationalOperator_out1_s10=l_addSignal(hLTDataValidInN,sprintf('Relational\nOperator_out1'),pirTyp1,slRate);
    RelationalOperator1_out1_s11=l_addSignal(hLTDataValidInN,sprintf('Relational\nOperator1_out1'),pirTyp1,slRate);


    pirelab.getIntDelayComp(hLTDataValidInN,...
    LogicalOperator_out1_s7,...
    diagValidIn,...
    1,'Delay',...
    false,...
    0,0,[],0,0);



    pirelab.getIntDelayComp(hLTDataValidInN,...
    LogicalOperator1_out1_s8,...
    nonDiagValidIn,...
    1,'Delay1',...
    false,...
    0,0,[],0,0);



    pirelab.getLogicComp(hLTDataValidInN,...
    [processingEnb,readEnable,RelationalOperator_out1_s10,LogicalOperator7_out1_s9],...
    LogicalOperator_out1_s7,...
    'and',sprintf('Logical\nOperator'));



    pirelab.getLogicComp(hLTDataValidInN,...
    [processingEnb,readEnable,RelationalOperator1_out1_s11,LogicalOperator7_out1_s9],...
    LogicalOperator1_out1_s8,...
    'and',sprintf('Logical\nOperator1'));



    pirelab.getLogicComp(hLTDataValidInN,...
    swapEnb,...
    LogicalOperator7_out1_s9,...
    'not',sprintf('Logical\nOperator7'));



    pirelab.getRelOpComp(hLTDataValidInN,...
    [rowCount,colCount],...
    RelationalOperator_out1_s10,...
    '==',0,sprintf('Relational\nOperator'));



    pirelab.getRelOpComp(hLTDataValidInN,...
    [rowCount,colCount],...
    RelationalOperator1_out1_s11,...
    '~=',0,sprintf('Relational\nOperator1'));




    pirelab.instantiateNetwork(hN,hLTDataValidInN,LTDataValidInInSigs,LTDataValidInOutSigs,...
    [hLTDataValidInN.Name,'_inst']);


end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
