function buffInpGenAddrQPSK=elabBuffInpGenAddrQPSK(~,topNet,~,rate)






    pirTyp2=pir_boolean_t;
    pirTyp1=pir_ufixpt_t(1,0);
    pirTyp3=pir_ufixpt_t(2,0);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,1,0);
    nt2=numerictype(0,2,0);

    inBuffInpGenQPSKAddr={'dataIn','validIn','resetIn'};
    controlType=pir_ufixpt_t(1,0);
    inTypeBuffInpGenQPSKAddr=[controlType,controlType,controlType];
    inRateBuffInpGenQPSKAddr=[rate,rate,rate];

    outBuffInpGenQPSKAddr={'addrQPSK','addrQPSKValidOut'};
    outTypeBuffInpGenQPSKAddr=[pir_ufixpt_t(2,0),controlType];

    buffInpGenAddrQPSK=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','buffInpGenAddrQPSK',...
    'InportNames',inBuffInpGenQPSKAddr,...
    'InportTypes',inTypeBuffInpGenQPSKAddr,...
    'InportRates',inRateBuffInpGenQPSKAddr,...
    'OutportNames',outBuffInpGenQPSKAddr,...
    'OutportTypes',outTypeBuffInpGenQPSKAddr...
    );


    dataIn_s0=buffInpGenAddrQPSK.PirInputSignals(1);
    validIn_s1=buffInpGenAddrQPSK.PirInputSignals(2);
    resetIn_s2=buffInpGenAddrQPSK.PirInputSignals(3);

    addrQPSK=buffInpGenAddrQPSK.PirOutputSignals(1);
    addrQPSKValidOut=buffInpGenAddrQPSK.PirOutputSignals(2);

    slRate1=rate;

    Switch3_out1_s29=addSignal(buffInpGenAddrQPSK,'Switch3_out1',pirTyp3,slRate1);

    LogicalOperator2_out1_s20=addSignal(buffInpGenAddrQPSK,sprintf('Logical\nOperator2_out1'),pirTyp2,slRate1);

    CompareToConstant_out1_s3=addSignal(buffInpGenAddrQPSK,sprintf('Compare\nTo Constant_out1'),pirTyp2,slRate1);
    CompareToConstant5_out1_s4=addSignal(buffInpGenAddrQPSK,sprintf('Compare\nTo Constant5_out1'),pirTyp2,slRate1);
    CompareToConstant8_out1_s5=addSignal(buffInpGenAddrQPSK,sprintf('Compare\nTo Constant8_out1'),pirTyp2,slRate1);
    Constant_out1_s6=addSignal(buffInpGenAddrQPSK,'Constant_out1',pirTyp3,slRate1);
    Constant3_out1_s7=addSignal(buffInpGenAddrQPSK,'Constant3_out1',pirTyp1,slRate1);
    Delay_out1_s8=addSignal(buffInpGenAddrQPSK,'Delay_out1',pirTyp3,slRate1);
    Delay1_out1_s9=addSignal(buffInpGenAddrQPSK,'Delay1_out1',pirTyp1,slRate1);
    Delay2_out1_s10=addSignal(buffInpGenAddrQPSK,'Delay2_out1',pirTyp1,slRate1);
    Delay3_out1_s11=addSignal(buffInpGenAddrQPSK,'Delay3_out1',pirTyp2,slRate1);
    Delay4_out1_s12=addSignal(buffInpGenAddrQPSK,'Delay4_out1',pirTyp2,slRate1);
    Delay7_out1_s13=addSignal(buffInpGenAddrQPSK,'Delay7_out1',pirTyp3,slRate1);
    Delay8_out1_s14=addSignal(buffInpGenAddrQPSK,'Delay8_out1',pirTyp3,slRate1);
    HDLCounter_out1_s15=addSignal(buffInpGenAddrQPSK,'HDL Counter_out1',pirTyp3,slRate1);
    LogicalOperator_out1_s16=addSignal(buffInpGenAddrQPSK,sprintf('Logical\nOperator_out1'),pirTyp2,slRate1);
    LogicalOperator1_out1_s17=addSignal(buffInpGenAddrQPSK,sprintf('Logical\nOperator1_out1'),pirTyp2,slRate1);
    LogicalOperator12_out1_s18=addSignal(buffInpGenAddrQPSK,sprintf('Logical\nOperator12_out1'),pirTyp2,slRate1);
    LogicalOperator14_out1_s19=addSignal(buffInpGenAddrQPSK,sprintf('Logical\nOperator14_out1'),pirTyp2,slRate1);
    LogicalOperator3_out1_s21=addSignal(buffInpGenAddrQPSK,sprintf('Logical\nOperator3_out1'),pirTyp2,slRate1);
    LogicalOperator4_out1_s22=addSignal(buffInpGenAddrQPSK,sprintf('Logical\nOperator4_out1'),pirTyp2,slRate1);
    LogicalOperator5_out1_s23=addSignal(buffInpGenAddrQPSK,sprintf('Logical\nOperator5_out1'),pirTyp2,slRate1);
    LogicalOperator6_out1_s24=addSignal(buffInpGenAddrQPSK,sprintf('Logical\nOperator6_out1'),pirTyp2,slRate1);
    LogicalOperator7_out1_s25=addSignal(buffInpGenAddrQPSK,sprintf('Logical\nOperator7_out1'),pirTyp2,slRate1);
    QPSK_out1_s26=addSignal(buffInpGenAddrQPSK,'QPSK_out1',pirTyp3,slRate1);
    RelationalOperator_out1_s27=addSignal(buffInpGenAddrQPSK,sprintf('Relational\nOperator_out1'),pirTyp2,slRate1);
    RelationalOperator1_out1_s28=addSignal(buffInpGenAddrQPSK,sprintf('Relational\nOperator1_out1'),pirTyp2,slRate1);
    BitConcat_out1_s33=addSignal(buffInpGenAddrQPSK,'Bit Concat_out1',pirTyp3,slRate1);
    BitConcat1_out1_s34=addSignal(buffInpGenAddrQPSK,'Bit Concat1_out1',pirTyp3,slRate1);
    Constant_out1_s35=addSignal(buffInpGenAddrQPSK,'Constant_out1',pirTyp1,slRate1);
    Constant1_out1_s36=addSignal(buffInpGenAddrQPSK,'Constant1_out1',pirTyp1,slRate1);
    Switch1_out1_s37=addSignal(buffInpGenAddrQPSK,'Switch1_out1',pirTyp3,slRate1);
    HDLCounter_out1_s43=addSignal(buffInpGenAddrQPSK,'HDL Counter_out1',pirTyp3,slRate1);
    count_s44=addSignal(buffInpGenAddrQPSK,'count',pirTyp3,slRate1);
    count_reset_s45=addSignal(buffInpGenAddrQPSK,'count_reset',pirTyp3,slRate1);
    count_step_s46=addSignal(buffInpGenAddrQPSK,'count_step',pirTyp3,slRate1);
    count_from_s47=addSignal(buffInpGenAddrQPSK,'count_from',pirTyp3,slRate1);
    count_value_s48=addSignal(buffInpGenAddrQPSK,'count_value',pirTyp3,slRate1);
    need_to_wrap_s49=addSignal(buffInpGenAddrQPSK,'need_to_wrap',pirTyp2,slRate1);
    count_s50=addSignal(buffInpGenAddrQPSK,'count',pirTyp3,slRate1);
    count_s51=addSignal(buffInpGenAddrQPSK,'count',pirTyp3,slRate1);
    HDLCounter_out_s52=addSignal(buffInpGenAddrQPSK,'HDL Counter_out',pirTyp3,slRate1);
    HDLCounter_Initial_Val_out_s53=addSignal(buffInpGenAddrQPSK,'HDL Counter_Initial_Val_out',pirTyp3,slRate1);
    HDLCounter_ctrl_const_out_s54=addSignal(buffInpGenAddrQPSK,'HDL Counter_ctrl_const_out',pirTyp2,slRate1);
    HDLCounter_ctrl_delay_out_s55=addSignal(buffInpGenAddrQPSK,'HDL Counter_ctrl_delay_out',pirTyp2,slRate1);
    Delay1_delOut_s56=addSignal(buffInpGenAddrQPSK,'Delay1_delOut',pirTyp1,slRate1);
    Delay1_ectrl_s57=addSignal(buffInpGenAddrQPSK,'Delay1_ectrl',pirTyp1,slRate1);
    Delay1_last_value_s58=addSignal(buffInpGenAddrQPSK,'Delay1_last_value',pirTyp1,slRate1);
    Delay2_delOut_s59=addSignal(buffInpGenAddrQPSK,'Delay2_delOut',pirTyp1,slRate1);
    Delay2_ectrl_s60=addSignal(buffInpGenAddrQPSK,'Delay2_ectrl',pirTyp1,slRate1);
    Delay2_last_value_s61=addSignal(buffInpGenAddrQPSK,'Delay2_last_value',pirTyp1,slRate1);

    pirelab.getConstComp(buffInpGenAddrQPSK,...
    Constant_out1_s35,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant','on',1,'','','');

    pirelab.getConstComp(buffInpGenAddrQPSK,...
    Constant1_out1_s36,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant1','on',1,'','','');

    pirelab.getConstComp(buffInpGenAddrQPSK,...
    Constant_out1_s6,...
    fi(0,nt2,fiMath1,'hex','2'),...
    'Constant','on',0,'','','');

    pirelab.getConstComp(buffInpGenAddrQPSK,...
    Constant3_out1_s7,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant3','on',1,'','','');

    pirelab.getIntDelayComp(buffInpGenAddrQPSK,...
    HDLCounter_out1_s15,...
    Delay_out1_s8,...
    1,'Delay',...
    fi(0,nt2,fiMath1,'hex','0'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(buffInpGenAddrQPSK,...
    validIn_s1,...
    Delay3_out1_s11,...
    1,'Delay3',...
    false,...
    0,0,[],0,0);

    pirelab.getIntDelayComp(buffInpGenAddrQPSK,...
    LogicalOperator6_out1_s24,...
    Delay4_out1_s12,...
    1,'Delay4',...
    false,...
    0,0,[],0,0);

    pirelab.getIntDelayComp(buffInpGenAddrQPSK,...
    Constant_out1_s6,...
    Delay7_out1_s13,...
    1,'Delay7',...
    fi(0,nt2,fiMath1,'hex','0'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(buffInpGenAddrQPSK,...
    Constant_out1_s6,...
    Delay8_out1_s14,...
    1,'Delay8',...
    fi(0,nt2,fiMath1,'hex','0'),...
    0,0,[],0,0);

    hC_10=pirelab.getConstComp(buffInpGenAddrQPSK,...
    count_step_s46,...
    fi(0,nt2,fiMath1,'hex','1'),...
    'step_value','off',0,'','','');

    hC_10.addComment(sprintf(['  // Count limited, Unsigned Counter\n  //  initial value   = 1\n'...
    ,'  //  step value      = 1\n  //  count to value  = 2']));

    pirelab.getAddComp(buffInpGenAddrQPSK,...
    [HDLCounter_out1_s43,count_step_s46],...
    count_s44,...
    'Floor','Wrap','adder',pirTyp3,'++');

    pirelab.getConstComp(buffInpGenAddrQPSK,...
    count_from_s47,...
    fi(0,nt2,fiMath1,'hex','1'),...
    'countFrom','off',0,'','','');

    pirelab.getSwitchComp(buffInpGenAddrQPSK,...
    [count_from_s47,count_s44],...
    count_value_s48,...
    need_to_wrap_s49,'switch',...
    '~=',0,'Floor','Wrap');

    pirelab.getCompareToValueComp(buffInpGenAddrQPSK,...
    HDLCounter_out1_s43,...
    need_to_wrap_s49,...
    '==',fi(0,nt2,fiMath1,'hex','2'),...
    'compare',0);

    pirelab.getMultiPortSwitchComp(buffInpGenAddrQPSK,...
    [validIn_s1,HDLCounter_out1_s43,count_value_s48],...
    count_s50,...
    1,'Zero-based contiguous','Floor','Wrap','switchEnable',[]);

    pirelab.getConstComp(buffInpGenAddrQPSK,...
    count_reset_s45,...
    fi(0,nt2,fiMath1,'hex','1'),...
    'const','off',0,'','','');

    pirelab.getSwitchComp(buffInpGenAddrQPSK,...
    [count_reset_s45,count_s50],...
    count_s51,...
    LogicalOperator12_out1_s18,'switchReset',...
    '~=',0,'Floor','Wrap');

    pirelab.getIntDelayComp(buffInpGenAddrQPSK,...
    count_s51,...
    HDLCounter_out_s52,...
    1,'HDL Counter',...
    double(0),...
    0,0,[],0,0);

    pirelab.getWireComp(buffInpGenAddrQPSK,...
    HDLCounter_out1_s43,...
    HDLCounter_out1_s15,...
    'HDL Counter_out1');

    pirelab.getWireComp(buffInpGenAddrQPSK,...
    Switch1_out1_s37,...
    QPSK_out1_s26,...
    'QPSK_out1');

    pirelab.getConstComp(buffInpGenAddrQPSK,...
    HDLCounter_Initial_Val_out_s53,...
    fi(0,nt2,fiMath1,'hex','1'),...
    'HDL Counter_Initial_Val','on',0,'','','');

    pirelab.getConstComp(buffInpGenAddrQPSK,...
    HDLCounter_ctrl_const_out_s54,...
    1,...
    'HDL Counter_ctrl_const');

    pirelab.getIntDelayComp(buffInpGenAddrQPSK,...
    HDLCounter_ctrl_const_out_s54,...
    HDLCounter_ctrl_delay_out_s55,...
    1,'HDL Counter_ctrl_delay',...
    double(0),...
    0,0,[],0,0);

    pirelab.getSwitchComp(buffInpGenAddrQPSK,...
    [HDLCounter_out_s52,HDLCounter_Initial_Val_out_s53],...
    HDLCounter_out1_s43,...
    HDLCounter_ctrl_delay_out_s55,'HDL Counter_switch',...
    '~=',0,'Floor','Wrap');

    pirelab.getSwitchComp(buffInpGenAddrQPSK,...
    [dataIn_s0,Delay1_delOut_s56],...
    Delay1_ectrl_s57,...
    LogicalOperator4_out1_s22,'Delay_Switch',...
    '~=',0,'Floor','Wrap');

    pirelab.getIntDelayComp(buffInpGenAddrQPSK,...
    Delay1_ectrl_s57,...
    Delay1_delOut_s56,...
    1,'Delay1_lowered',...
    fi(0,nt1,fiMath1,'hex','0'),...
    0,0,[],0,0);

    pirelab.getSwitchComp(buffInpGenAddrQPSK,...
    [Delay1_delOut_s56,Delay1_last_value_s58],...
    Delay1_out1_s9,...
    LogicalOperator4_out1_s22,'bypass_out',...
    '~=',0,'Floor','Wrap');

    pirelab.getIntDelayComp(buffInpGenAddrQPSK,...
    Delay1_out1_s9,...
    Delay1_last_value_s58,...
    1,'Delay1_bypass',...
    double(0),...
    0,0,[],0,0);

    pirelab.getSwitchComp(buffInpGenAddrQPSK,...
    [dataIn_s0,Delay2_delOut_s59],...
    Delay2_ectrl_s60,...
    LogicalOperator3_out1_s21,'Delay_Switch',...
    '~=',0,'Floor','Wrap');

    pirelab.getIntDelayComp(buffInpGenAddrQPSK,...
    Delay2_ectrl_s60,...
    Delay2_delOut_s59,...
    1,'Delay2_lowered',...
    fi(0,nt1,fiMath1,'hex','0'),...
    0,0,[],0,0);

    pirelab.getSwitchComp(buffInpGenAddrQPSK,...
    [Delay2_delOut_s59,Delay2_last_value_s61],...
    Delay2_out1_s10,...
    LogicalOperator3_out1_s21,'bypass_out',...
    '~=',0,'Floor','Wrap');

    pirelab.getIntDelayComp(buffInpGenAddrQPSK,...
    Delay2_out1_s10,...
    Delay2_last_value_s61,...
    1,'Delay2_bypass',...
    double(0),...
    0,0,[],0,0);


    pirelab.getCompareToValueComp(buffInpGenAddrQPSK,...
    HDLCounter_out1_s15,...
    CompareToConstant_out1_s3,...
    '==',fi(0,nt2,fiMath1,'hex','2'),...
    sprintf('Compare\nTo Constant'),0);


    pirelab.getCompareToValueComp(buffInpGenAddrQPSK,...
    HDLCounter_out1_s15,...
    CompareToConstant5_out1_s4,...
    '==',fi(0,nt2,fiMath1,'hex','1'),...
    sprintf('Compare\nTo Constant5'),0);


    pirelab.getCompareToValueComp(buffInpGenAddrQPSK,...
    Delay7_out1_s13,...
    CompareToConstant8_out1_s5,...
    '==',fi(0,nt2,fiMath1,'hex','2'),...
    sprintf('Compare\nTo Constant8'),0);


    pirelab.getLogicComp(buffInpGenAddrQPSK,...
    [validIn_s1,CompareToConstant5_out1_s4],...
    LogicalOperator_out1_s16,...
    'and',sprintf('Logical\nOperator'));


    pirelab.getLogicComp(buffInpGenAddrQPSK,...
    [validIn_s1,CompareToConstant_out1_s3],...
    LogicalOperator1_out1_s17,...
    'and',sprintf('Logical\nOperator1'));


    pirelab.getLogicComp(buffInpGenAddrQPSK,...
    [LogicalOperator5_out1_s23,resetIn_s2],...
    LogicalOperator12_out1_s18,...
    'or',sprintf('Logical\nOperator12'));


    pirelab.getLogicComp(buffInpGenAddrQPSK,...
    [LogicalOperator2_out1_s20,CompareToConstant8_out1_s5],...
    LogicalOperator14_out1_s19,...
    'and',sprintf('Logical\nOperator14'));


    pirelab.getLogicComp(buffInpGenAddrQPSK,...
    [RelationalOperator1_out1_s28,LogicalOperator7_out1_s25],...
    LogicalOperator2_out1_s20,...
    'and',sprintf('Logical\nOperator2'));


    pirelab.getLogicComp(buffInpGenAddrQPSK,...
    [LogicalOperator2_out1_s20,LogicalOperator1_out1_s17],...
    LogicalOperator3_out1_s21,...
    'or',sprintf('Logical\nOperator3'));


    pirelab.getLogicComp(buffInpGenAddrQPSK,...
    [LogicalOperator2_out1_s20,LogicalOperator_out1_s16],...
    LogicalOperator4_out1_s22,...
    'or',sprintf('Logical\nOperator4'));


    pirelab.getLogicComp(buffInpGenAddrQPSK,...
    [RelationalOperator_out1_s27,validIn_s1],...
    LogicalOperator5_out1_s23,...
    'and',sprintf('Logical\nOperator5'));


    pirelab.getLogicComp(buffInpGenAddrQPSK,...
    resetIn_s2,...
    LogicalOperator6_out1_s24,...
    'not',sprintf('Logical\nOperator6'));


    pirelab.getLogicComp(buffInpGenAddrQPSK,...
    [Delay3_out1_s11,Delay4_out1_s12],...
    LogicalOperator7_out1_s25,...
    'and',sprintf('Logical\nOperator7'));


    pirelab.getBitConcatComp(buffInpGenAddrQPSK,...
    [Delay1_out1_s9,Delay2_out1_s10],...
    BitConcat_out1_s33,...
    'Bit Concat');


    pirelab.getBitConcatComp(buffInpGenAddrQPSK,...
    [Constant_out1_s35,Constant1_out1_s36],...
    BitConcat1_out1_s34,...
    'Bit Concat1');


    pirelab.getSwitchComp(buffInpGenAddrQPSK,...
    [BitConcat_out1_s33,BitConcat1_out1_s34],...
    Switch1_out1_s37,...
    LogicalOperator2_out1_s20,'Switch1',...
    '>',0,'Floor','Wrap');


    pirelab.getRelOpComp(buffInpGenAddrQPSK,...
    [Constant_out1_s6,HDLCounter_out1_s15],...
    RelationalOperator_out1_s27,...
    '==',0,sprintf('Relational\nOperator'));


    pirelab.getRelOpComp(buffInpGenAddrQPSK,...
    [Delay8_out1_s14,Delay_out1_s8],...
    RelationalOperator1_out1_s28,...
    '==',0,sprintf('Relational\nOperator1'));


    pirelab.getSwitchComp(buffInpGenAddrQPSK,...
    [QPSK_out1_s26,Constant3_out1_s7],...
    Switch3_out1_s29,...
    LogicalOperator14_out1_s19,'Switch3',...
    '>',0,'Floor','Wrap');



    pirelab.getWireComp(buffInpGenAddrQPSK,Switch3_out1_s29,addrQPSK);
    pirelab.getWireComp(buffInpGenAddrQPSK,LogicalOperator2_out1_s20,addrQPSKValidOut);
end

function hS=addSignal(buffInpGenAddrQPSK,sigName,pirTyp,simulinkRate)
    hS=buffInpGenAddrQPSK.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end