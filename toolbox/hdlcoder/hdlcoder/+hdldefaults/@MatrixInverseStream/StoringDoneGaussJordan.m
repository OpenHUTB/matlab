

function StoringDoneGaussJordan(~,hN,StoringDoneInSigs,StoringDoneOutSigs,...
    slRate,blockInfo)





    hStoringDoneN=pirelab.createNewNetwork(...
    'Name','StoringDoneGaussJordan',...
    'InportNames',{'ready','validIn','rowCount','colCount'},...
    'InportTypes',[StoringDoneInSigs(1).Type,StoringDoneInSigs(2).Type,...
    StoringDoneInSigs(3).Type,StoringDoneInSigs(4).Type],...
    'InportRates',slRate*ones(1,4),...
    'OutportNames',{'storeDone'},...
    'OutportTypes',StoringDoneOutSigs(1).Type);

    hStoringDoneN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hStoringDoneN.PirOutputSignals)
        hStoringDoneN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hStoringDoneNinSigs=hStoringDoneN.PirInputSignals;
    hStoringDoneNoutSigs=hStoringDoneN.PirOutputSignals;


    ready=hStoringDoneNinSigs(1);
    validIn=hStoringDoneNinSigs(2);
    rowCount=hStoringDoneNinSigs(3);
    colCount=hStoringDoneNinSigs(4);


    hBoolT=pir_boolean_t;

    storeDone=hStoringDoneNoutSigs(1);


    CompareToConstant_out1_s4=l_addSignal(hStoringDoneN,sprintf('Compare\nTo Constant_out1'),hBoolT,slRate);
    CompareToConstant1_out1_s5=l_addSignal(hStoringDoneN,sprintf('Compare\nTo Constant1_out1'),hBoolT,slRate);
    Constant_out1_s6=l_addSignal(hStoringDoneN,'Constant_out1',hBoolT,slRate);
    Constant1_out1_s7=l_addSignal(hStoringDoneN,'Constant1_out1',hBoolT,slRate);
    LogicalOperator1_out1_s8=l_addSignal(hStoringDoneN,sprintf('Logical\nOperator1_out1'),hBoolT,slRate);
    LogicalOperator2_out1_s9=l_addSignal(hStoringDoneN,sprintf('Logical\nOperator2_out1'),hBoolT,slRate);


    pirelab.getConstComp(hStoringDoneN,...
    Constant_out1_s6,...
    1,...
    'Constant','on',0,'','','');


    pirelab.getConstComp(hStoringDoneN,...
    Constant1_out1_s7,...
    0,...
    'Constant1','on',1,'','','');



    pirelab.getCompareToValueComp(hStoringDoneN,...
    rowCount,...
    CompareToConstant_out1_s4,...
    '==',blockInfo.MatrixSize,...
    sprintf('Compare\nTo Constant'),0);


    pirelab.getCompareToValueComp(hStoringDoneN,...
    colCount,...
    CompareToConstant1_out1_s5,...
    '==',blockInfo.MatrixSize,...
    sprintf('Compare\nTo Constant1'),0);


    pirelab.getLogicComp(hStoringDoneN,...
    [ready,validIn],...
    LogicalOperator1_out1_s8,...
    'and',sprintf('Logical\nOperator1'));


    pirelab.getLogicComp(hStoringDoneN,...
    [LogicalOperator1_out1_s8,CompareToConstant_out1_s4,CompareToConstant1_out1_s5],...
    LogicalOperator2_out1_s9,...
    'and',sprintf('Logical\nOperator2'));


    pirelab.getSwitchComp(hStoringDoneN,...
    [Constant_out1_s6,Constant1_out1_s7],...
    storeDone,...
    LogicalOperator2_out1_s9,'Switch',...
    '~=',0,'Floor','Wrap');




    pirelab.instantiateNetwork(hN,hStoringDoneN,StoringDoneInSigs,StoringDoneOutSigs,...
    [hStoringDoneN.Name,'_inst']);

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


