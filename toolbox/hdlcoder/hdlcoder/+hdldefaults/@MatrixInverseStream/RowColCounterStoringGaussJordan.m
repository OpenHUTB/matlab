
function RowColCounterStoringGaussJordan(~,hN,RowColCounterInSigs,RowColCounterOutSigs,...
    slRate,blockInfo)




    hRowColCounterN=pirelab.createNewNetwork(...
    'Name','RowColCounterStoringGaussJordan',...
    'InportNames',{'enable','storeDone'},...
    'InportTypes',[RowColCounterInSigs(1).Type,RowColCounterInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'rowCount','colCount'},...
    'OutportTypes',[RowColCounterOutSigs(1).Type,RowColCounterOutSigs(2).Type]);

    hRowColCounterN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hRowColCounterN.PirOutputSignals)
        hRowColCounterN.PirOutputSignals(ii).SimulinkRate=slRate;
    end
    hRowColCounterinSigs=hRowColCounterN.PirInputSignals;
    hRowColCounteroutSigs=hRowColCounterN.PirOutputSignals;


    enable=hRowColCounterinSigs(1);
    storeDone=hRowColCounterinSigs(2);


    rowCount=hRowColCounteroutSigs(1);
    colCount=hRowColCounteroutSigs(2);

    pirTyp1=pir_boolean_t;
    pirTyp2=pir_ufixpt_t(ceil(log2(blockInfo.MatrixSize))+1,0);






    Constant_out1_s1=l_addSignal(hRowColCounterN,'Constant_out1',pirTyp2,slRate);
    LogicalOperator_out1_s4=l_addSignal(hRowColCounterN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate);
    RelationalOperator_out1_s5=l_addSignal(hRowColCounterN,sprintf('Relational\nOperator_out1'),pirTyp1,slRate);
    rowCountOutS=l_addSignal(hRowColCounterN,'rowCountOut',pirTyp2,slRate);

    pirelab.getConstComp(hRowColCounterN,...
    Constant_out1_s1,...
    blockInfo.MatrixSize,...
    'Constant','on',0,'','','');



    pirelab.getCounterComp(hRowColCounterN,...
    [storeDone,enable],...
    colCount,...
    'Count limited',1,1,blockInfo.MatrixSize,1,0,1,0,'HDL Counter',1);



    pirelab.getCounterComp(hRowColCounterN,...
    [storeDone,LogicalOperator_out1_s4],...
    rowCountOutS,...
    'Count limited',1,1,blockInfo.MatrixSize,1,0,1,0,'HDL Counter1',1);

    pirelab.getWireComp(hRowColCounterN,rowCountOutS,rowCount,'rowCount');

    pirelab.getLogicComp(hRowColCounterN,...
    [enable,RelationalOperator_out1_s5],...
    LogicalOperator_out1_s4,...
    'and',sprintf('Logical\nOperator'));


    pirelab.getRelOpComp(hRowColCounterN,...
    [colCount,Constant_out1_s1],...
    RelationalOperator_out1_s5,...
    '==',1,sprintf('Relational\nOperator'));

    pirelab.instantiateNetwork(hN,hRowColCounterN,RowColCounterInSigs,RowColCounterOutSigs,...
    [hRowColCounterN.Name,'_inst']);

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


