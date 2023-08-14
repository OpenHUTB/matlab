

function gaussJordanRowCounter(~,hN,LTRowCounterInSigs,LTRowCounterOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo)




    hLTRowCounterN=pirelab.createNewNetwork(...
    'Name','gaussJordanRowCounter',...
    'InportNames',{'colCount','rowFinish','invFinish'},...
    'InportTypes',[hCounterT,hBoolT,hBoolT],...
    'InportRates',slRate*ones(1,3),...
    'OutportNames',{'rowCount'},...
    'OutportTypes',hCounterT);

    hLTRowCounterN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTRowCounterN.PirOutputSignals)
        hLTRowCounterN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTRowCounterNinSigs=hLTRowCounterN.PirInputSignals;
    hLTRowCounterNoutSigs=hLTRowCounterN.PirOutputSignals;

    colCount=hLTRowCounterNinSigs(1);
    rowFinish=hLTRowCounterNinSigs(2);
    invFinish=hLTRowCounterNinSigs(3);

    rowCount=hLTRowCounterNoutSigs(1);



    pirTyp2=pir_boolean_t;
    pirTyp1=pir_ufixpt_t(ceil(log2(blockInfo.MatrixSize))+1,0);
    pirTyp3=pir_ufixpt_t(ceil(log2(blockInfo.MatrixSize))+2,0);


    Add_out1_s3=l_addSignal(hLTRowCounterN,'Add_out1',pirTyp1,slRate);
    CompareToConstant_out1_s4=l_addSignal(hLTRowCounterN,sprintf('Compare\nTo Constant_out1'),pirTyp2,slRate);
    CompareToConstant2_out1_s5=l_addSignal(hLTRowCounterN,sprintf('Compare\nTo Constant2_out1'),pirTyp2,slRate);
    CompareToConstant3_out1_s6=l_addSignal(hLTRowCounterN,sprintf('Compare\nTo Constant3_out1'),pirTyp2,slRate);
    Constant1_out1_s7=l_addSignal(hLTRowCounterN,'Constant1_out1',pirTyp1,slRate);
    Constant2_out1_s8=l_addSignal(hLTRowCounterN,'Constant2_out1',pirTyp1,slRate);
    LogicalOperator_out1_s10=l_addSignal(hLTRowCounterN,sprintf('Logical\nOperator_out1'),pirTyp2,slRate);
    LogicalOperator1_out1_s11=l_addSignal(hLTRowCounterN,sprintf('Logical\nOperator1_out1'),pirTyp2,slRate);
    LogicalOperator2_out1_s12=l_addSignal(hLTRowCounterN,sprintf('Logical\nOperator2_out1'),pirTyp2,slRate);
    Switch_out1_s13=l_addSignal(hLTRowCounterN,'Switch_out1',pirTyp1,slRate);
    Switch1_out1_s14=l_addSignal(hLTRowCounterN,'Switch1_out1',pirTyp1,slRate);
    Delay_out_s15=l_addSignal(hLTRowCounterN,'Delay_out',pirTyp1,slRate);
    Delay_Initial_Val_out_s16=l_addSignal(hLTRowCounterN,'Delay_Initial_Val_out',pirTyp1,slRate);
    Delay_ctrl_const_out_s17=l_addSignal(hLTRowCounterN,'Delay_ctrl_const_out',pirTyp2,slRate);
    Delay_ctrl_delay_out_s18=l_addSignal(hLTRowCounterN,'Delay_ctrl_delay_out',pirTyp2,slRate);

    pirelab.getConstComp(hLTRowCounterN,...
    Constant1_out1_s7,...
    1,...
    'Constant1','on',0,'','','');


    pirelab.getConstComp(hLTRowCounterN,...
    Constant2_out1_s8,...
    1,...
    'Constant2','on',0,'','','');


    pirelab.getIntDelayComp(hLTRowCounterN,...
    Switch_out1_s13,...
    Delay_out_s15,...
    1,'Delay',...
    double(0),...
    0,0,[],0,0);


    pirelab.getConstComp(hLTRowCounterN,...
    Delay_Initial_Val_out_s16,...
    1,...
    'Delay_Initial_Val','on',0,'','','');

    pirelab.getConstComp(hLTRowCounterN,...
    Delay_ctrl_const_out_s17,...
    1,...
    'Delay_ctrl_const');

    pirelab.getIntDelayComp(hLTRowCounterN,...
    Delay_ctrl_const_out_s17,...
    Delay_ctrl_delay_out_s18,...
    1,'Delay_ctrl_delay',...
    double(0),...
    0,0,[],0,0);

    pirelab.getSwitchComp(hLTRowCounterN,...
    [Delay_out_s15,Delay_Initial_Val_out_s16],...
    rowCount,...
    Delay_ctrl_delay_out_s18,'Delay_switch',...
    '~=',0,'Floor','Wrap');


    pirelab.getAddComp(hLTRowCounterN,...
    [rowCount,Constant2_out1_s8],...
    Add_out1_s3,...
    'Floor','Wrap','Add',pirTyp3,'++');



    pirelab.getCompareToValueComp(hLTRowCounterN,...
    rowCount,...
    CompareToConstant_out1_s4,...
    '==',blockInfo.MatrixSize,...
    sprintf('Compare\nTo Constant'),0);


    pirelab.getCompareToValueComp(hLTRowCounterN,...
    colCount,...
    CompareToConstant2_out1_s5,...
    '==',blockInfo.MatrixSize-1,...
    sprintf('Compare\nTo Constant2'),0);



    pirelab.getCompareToValueComp(hLTRowCounterN,...
    rowCount,...
    CompareToConstant3_out1_s6,...
    '~=',blockInfo.MatrixSize,...
    sprintf('Compare\nTo Constant3'),0);



    pirelab.getLogicComp(hLTRowCounterN,...
    [CompareToConstant_out1_s4,rowFinish,CompareToConstant2_out1_s5],...
    LogicalOperator_out1_s10,...
    'and',sprintf('Logical\nOperator'));



    pirelab.getLogicComp(hLTRowCounterN,...
    [rowFinish,CompareToConstant3_out1_s6],...
    LogicalOperator1_out1_s11,...
    'and',sprintf('Logical\nOperator1'));



    pirelab.getLogicComp(hLTRowCounterN,...
    [invFinish,LogicalOperator_out1_s10],...
    LogicalOperator2_out1_s12,...
    'or',sprintf('Logical\nOperator2'));



    pirelab.getSwitchComp(hLTRowCounterN,...
    [Constant1_out1_s7,Switch1_out1_s14],...
    Switch_out1_s13,...
    LogicalOperator2_out1_s12,'Switch',...
    '~=',0,'Floor','Wrap');



    pirelab.getSwitchComp(hLTRowCounterN,...
    [Add_out1_s3,rowCount],...
    Switch1_out1_s14,...
    LogicalOperator1_out1_s11,'Switch1',...
    '~=',0,'Floor','Wrap');



    pirelab.instantiateNetwork(hN,hLTRowCounterN,LTRowCounterInSigs,LTRowCounterOutSigs,...
    [hLTRowCounterN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
