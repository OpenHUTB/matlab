
function swapDoneSubsystem(~,hN,swapDoneInSigs,swapDoneOutSigs,...
    hBoolT,slRate)





    hswapDoneN=pirelab.createNewNetwork(...
    'Name','swapDoneSubsystem',...
    'InportNames',{'swapEnb','swapEnableOut'},...
    'InportTypes',[hBoolT,hBoolT],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'swapDone'},...
    'OutportTypes',hBoolT);

    hswapDoneN.setTargetCompReplacementCandidate(true);
    for ii=1:numel(hswapDoneN.PirOutputSignals)
        hswapDoneN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hswapDoneNinSigs=hswapDoneN.PirInputSignals;
    hswapDoneNoutSigs=hswapDoneN.PirOutputSignals;

    swapEnb=hswapDoneNinSigs(1);
    swapEnableOut=hswapDoneNinSigs(2);

    swapDone=hswapDoneNoutSigs(1);


    pirTyp1=pir_boolean_t;








    Constant_out1_s2=l_addSignal(hswapDoneN,'Constant_out1',pirTyp1,slRate);
    Constant1_out1_s3=l_addSignal(hswapDoneN,'Constant1_out1',pirTyp1,slRate);
    LogicalOperator_out1_s5=l_addSignal(hswapDoneN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate);
    LogicalOperator1_out1_s6=l_addSignal(hswapDoneN,sprintf('Logical\nOperator1_out1'),pirTyp1,slRate);
    Switch_out1_s7=l_addSignal(hswapDoneN,'Switch_out1',pirTyp1,slRate);


    pirelab.getConstComp(hswapDoneN,...
    Constant_out1_s2,...
    1,...
    'Constant','on',0,'','','');




    pirelab.getConstComp(hswapDoneN,...
    Constant1_out1_s3,...
    0,...
    'Constant1','on',1,'','','');



    pirelab.getIntDelayComp(hswapDoneN,...
    Switch_out1_s7,...
    swapDone,...
    1,'Delay',...
    false,...
    0,0,[],0,0);



    pirelab.getLogicComp(hswapDoneN,...
    [swapEnb,swapEnableOut,LogicalOperator1_out1_s6],...
    LogicalOperator_out1_s5,...
    'and',sprintf('Logical\nOperator'));



    pirelab.getLogicComp(hswapDoneN,...
    swapDone,...
    LogicalOperator1_out1_s6,...
    'not',sprintf('Logical\nOperator1'));



    pirelab.getSwitchComp(hswapDoneN,...
    [Constant_out1_s2,Constant1_out1_s3],...
    Switch_out1_s7,...
    LogicalOperator_out1_s5,'Switch',...
    '~=',0,'Floor','Wrap');


    pirelab.instantiateNetwork(hN,hswapDoneN,swapDoneInSigs,...
    swapDoneOutSigs,[hswapDoneN.Name,'_inst']);


end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


