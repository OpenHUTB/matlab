function buffInpGenAddr16APSK=elabBuffInpGenAddr16APSK(~,topNet,~,rate)






    pirTyp2=pir_boolean_t;
    pirTyp1=pir_ufixpt_t(1,0);
    pirTyp4=pir_ufixpt_t(3,0);
    pirTyp3=pir_ufixpt_t(4,0);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,1,0);
    nt2=numerictype(0,3,0);

    inBuffInpGen16APSKAddr={'dataIn','validIn','resetIn'};
    controlType=pir_ufixpt_t(1,0);
    inTypeBuffInpGen16APSKAddr=[controlType,controlType,controlType];
    inRateBuffInpGen16APSKAddr=[rate,rate,rate];

    outBuffInpGen16APSKAddr={'addr16APSK','addr16APSKValidOut'};
    outTypeBuffInpGen16APSKAddr=[pir_ufixpt_t(4,0),controlType];

    buffInpGenAddr16APSK=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','buffInpGenAddr16APSK',...
    'InportNames',inBuffInpGen16APSKAddr,...
    'InportTypes',inTypeBuffInpGen16APSKAddr,...
    'InportRates',inRateBuffInpGen16APSKAddr,...
    'OutportNames',outBuffInpGen16APSKAddr,...
    'OutportTypes',outTypeBuffInpGen16APSKAddr...
    );


    dataIn_s0=buffInpGenAddr16APSK.PirInputSignals(1);
    validIn_s1=buffInpGenAddr16APSK.PirInputSignals(2);
    resetIn_s2=buffInpGenAddr16APSK.PirInputSignals(3);

    addr16APSK=buffInpGenAddr16APSK.PirOutputSignals(1);
    addr16APSKValidOut=buffInpGenAddr16APSK.PirOutputSignals(2);

    slRate1=rate;


    Switch1_out1_s37=addSignal(buffInpGenAddr16APSK,'Switch1_out1',pirTyp3,slRate1);

    LogicalOperator2_out1_s27=addSignal(buffInpGenAddr16APSK,sprintf('Logical\nOperator2_out1'),pirTyp2,slRate1);

    APSK16_out1_s3=addSignal(buffInpGenAddr16APSK,'APSK16_out1',pirTyp3,slRate1);
    CompareToConstant_out1_s4=addSignal(buffInpGenAddr16APSK,sprintf('Compare\nTo Constant_out1'),pirTyp2,slRate1);
    CompareToConstant1_out1_s5=addSignal(buffInpGenAddr16APSK,sprintf('Compare\nTo Constant1_out1'),pirTyp2,slRate1);
    CompareToConstant2_out1_s6=addSignal(buffInpGenAddr16APSK,sprintf('Compare\nTo Constant2_out1'),pirTyp2,slRate1);
    CompareToConstant5_out1_s7=addSignal(buffInpGenAddr16APSK,sprintf('Compare\nTo Constant5_out1'),pirTyp2,slRate1);
    CompareToConstant6_out1_s8=addSignal(buffInpGenAddr16APSK,sprintf('Compare\nTo Constant6_out1'),pirTyp2,slRate1);
    Constant_out1_s9=addSignal(buffInpGenAddr16APSK,'Constant_out1',pirTyp4,slRate1);
    Constant2_out1_s10=addSignal(buffInpGenAddr16APSK,'Constant2_out1',pirTyp1,slRate1);
    Delay_out1_s11=addSignal(buffInpGenAddr16APSK,'Delay_out1',pirTyp4,slRate1);
    Delay1_out1_s12=addSignal(buffInpGenAddr16APSK,'Delay1_out1',pirTyp1,slRate1);
    Delay2_out1_s13=addSignal(buffInpGenAddr16APSK,'Delay2_out1',pirTyp1,slRate1);
    Delay3_out1_s14=addSignal(buffInpGenAddr16APSK,'Delay3_out1',pirTyp2,slRate1);
    Delay4_out1_s15=addSignal(buffInpGenAddr16APSK,'Delay4_out1',pirTyp1,slRate1);
    Delay5_out1_s16=addSignal(buffInpGenAddr16APSK,'Delay5_out1',pirTyp1,slRate1);
    Delay6_out1_s17=addSignal(buffInpGenAddr16APSK,'Delay6_out1',pirTyp2,slRate1);
    Delay7_out1_s18=addSignal(buffInpGenAddr16APSK,'Delay7_out1',pirTyp4,slRate1);
    Delay8_out1_s19=addSignal(buffInpGenAddr16APSK,'Delay8_out1',pirTyp4,slRate1);
    HDLCounter_out1_s20=addSignal(buffInpGenAddr16APSK,'HDL Counter_out1',pirTyp4,slRate1);
    LogicalOperator_out1_s21=addSignal(buffInpGenAddr16APSK,sprintf('Logical\nOperator_out1'),pirTyp2,slRate1);
    LogicalOperator1_out1_s22=addSignal(buffInpGenAddr16APSK,sprintf('Logical\nOperator1_out1'),pirTyp2,slRate1);
    LogicalOperator10_out1_s23=addSignal(buffInpGenAddr16APSK,sprintf('Logical\nOperator10_out1'),pirTyp2,slRate1);
    LogicalOperator11_out1_s24=addSignal(buffInpGenAddr16APSK,sprintf('Logical\nOperator11_out1'),pirTyp2,slRate1);
    LogicalOperator12_out1_s25=addSignal(buffInpGenAddr16APSK,sprintf('Logical\nOperator12_out1'),pirTyp2,slRate1);
    LogicalOperator16_out1_s26=addSignal(buffInpGenAddr16APSK,sprintf('Logical\nOperator16_out1'),pirTyp2,slRate1);
    LogicalOperator3_out1_s28=addSignal(buffInpGenAddr16APSK,sprintf('Logical\nOperator3_out1'),pirTyp2,slRate1);
    LogicalOperator4_out1_s29=addSignal(buffInpGenAddr16APSK,sprintf('Logical\nOperator4_out1'),pirTyp2,slRate1);
    LogicalOperator5_out1_s30=addSignal(buffInpGenAddr16APSK,sprintf('Logical\nOperator5_out1'),pirTyp2,slRate1);
    LogicalOperator6_out1_s31=addSignal(buffInpGenAddr16APSK,sprintf('Logical\nOperator6_out1'),pirTyp2,slRate1);
    LogicalOperator7_out1_s32=addSignal(buffInpGenAddr16APSK,sprintf('Logical\nOperator7_out1'),pirTyp2,slRate1);
    LogicalOperator8_out1_s33=addSignal(buffInpGenAddr16APSK,sprintf('Logical\nOperator8_out1'),pirTyp2,slRate1);
    LogicalOperator9_out1_s34=addSignal(buffInpGenAddr16APSK,sprintf('Logical\nOperator9_out1'),pirTyp2,slRate1);
    RelationalOperator_out1_s35=addSignal(buffInpGenAddr16APSK,sprintf('Relational\nOperator_out1'),pirTyp2,slRate1);
    RelationalOperator1_out1_s36=addSignal(buffInpGenAddr16APSK,sprintf('Relational\nOperator1_out1'),pirTyp2,slRate1);
    y_s43=addSignal(buffInpGenAddr16APSK,'y',pirTyp3,slRate1);
    y_s44=addSignal(buffInpGenAddr16APSK,'y',pirTyp3,slRate1);
    Constant_out1_s45=addSignal(buffInpGenAddr16APSK,'Constant_out1',pirTyp1,slRate1);
    Constant1_out1_s46=addSignal(buffInpGenAddr16APSK,'Constant1_out1',pirTyp1,slRate1);
    Constant2_out1_s47=addSignal(buffInpGenAddr16APSK,'Constant2_out1',pirTyp1,slRate1);
    Constant3_out1_s48=addSignal(buffInpGenAddr16APSK,'Constant3_out1',pirTyp1,slRate1);
    Switch1_out1_s49=addSignal(buffInpGenAddr16APSK,'Switch1_out1',pirTyp3,slRate1);
    HDLCounter_out1_s55=addSignal(buffInpGenAddr16APSK,'HDL Counter_out1',pirTyp4,slRate1);
    count_s56=addSignal(buffInpGenAddr16APSK,'count',pirTyp4,slRate1);
    count_reset_s57=addSignal(buffInpGenAddr16APSK,'count_reset',pirTyp4,slRate1);
    count_step_s58=addSignal(buffInpGenAddr16APSK,'count_step',pirTyp4,slRate1);
    count_from_s59=addSignal(buffInpGenAddr16APSK,'count_from',pirTyp4,slRate1);
    count_value_s60=addSignal(buffInpGenAddr16APSK,'count_value',pirTyp4,slRate1);
    need_to_wrap_s61=addSignal(buffInpGenAddr16APSK,'need_to_wrap',pirTyp2,slRate1);
    count_s62=addSignal(buffInpGenAddr16APSK,'count',pirTyp4,slRate1);
    count_s63=addSignal(buffInpGenAddr16APSK,'count',pirTyp4,slRate1);
    HDLCounter_out_s64=addSignal(buffInpGenAddr16APSK,'HDL Counter_out',pirTyp4,slRate1);
    HDLCounter_Initial_Val_out_s65=addSignal(buffInpGenAddr16APSK,'HDL Counter_Initial_Val_out',pirTyp4,slRate1);
    HDLCounter_ctrl_const_out_s66=addSignal(buffInpGenAddr16APSK,'HDL Counter_ctrl_const_out',pirTyp2,slRate1);
    HDLCounter_ctrl_delay_out_s67=addSignal(buffInpGenAddr16APSK,'HDL Counter_ctrl_delay_out',pirTyp2,slRate1);
    Delay1_delOut_s68=addSignal(buffInpGenAddr16APSK,'Delay1_delOut',pirTyp1,slRate1);
    Delay1_ectrl_s69=addSignal(buffInpGenAddr16APSK,'Delay1_ectrl',pirTyp1,slRate1);
    Delay1_last_value_s70=addSignal(buffInpGenAddr16APSK,'Delay1_last_value',pirTyp1,slRate1);
    Delay2_delOut_s71=addSignal(buffInpGenAddr16APSK,'Delay2_delOut',pirTyp1,slRate1);
    Delay2_ectrl_s72=addSignal(buffInpGenAddr16APSK,'Delay2_ectrl',pirTyp1,slRate1);
    Delay2_last_value_s73=addSignal(buffInpGenAddr16APSK,'Delay2_last_value',pirTyp1,slRate1);
    Delay4_delOut_s74=addSignal(buffInpGenAddr16APSK,'Delay4_delOut',pirTyp1,slRate1);
    Delay4_ectrl_s75=addSignal(buffInpGenAddr16APSK,'Delay4_ectrl',pirTyp1,slRate1);
    Delay4_last_value_s76=addSignal(buffInpGenAddr16APSK,'Delay4_last_value',pirTyp1,slRate1);
    Delay5_delOut_s77=addSignal(buffInpGenAddr16APSK,'Delay5_delOut',pirTyp1,slRate1);
    Delay5_ectrl_s78=addSignal(buffInpGenAddr16APSK,'Delay5_ectrl',pirTyp1,slRate1);
    Delay5_last_value_s79=addSignal(buffInpGenAddr16APSK,'Delay5_last_value',pirTyp1,slRate1);

    pirelab.getConstComp(buffInpGenAddr16APSK,...
    Constant_out1_s45,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant','on',1,'','','');

    pirelab.getConstComp(buffInpGenAddr16APSK,...
    Constant1_out1_s46,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant1','on',1,'','','');

    pirelab.getConstComp(buffInpGenAddr16APSK,...
    Constant2_out1_s47,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant2','on',1,'','','');

    pirelab.getConstComp(buffInpGenAddr16APSK,...
    Constant3_out1_s48,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant3','on',1,'','','');

    pirelab.getConstComp(buffInpGenAddr16APSK,...
    Constant_out1_s9,...
    fi(0,nt2,fiMath1,'hex','4'),...
    'Constant','on',0,'','','');

    pirelab.getConstComp(buffInpGenAddr16APSK,...
    Constant2_out1_s10,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant2','on',1,'','','');

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    HDLCounter_out1_s20,...
    Delay_out1_s11,...
    1,'Delay',...
    fi(0,nt2,fiMath1,'hex','0'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    validIn_s1,...
    Delay3_out1_s14,...
    1,'Delay3',...
    false,...
    0,0,[],0,0);

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    LogicalOperator11_out1_s24,...
    Delay6_out1_s17,...
    1,'Delay6',...
    false,...
    0,0,[],0,0);

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    Constant_out1_s9,...
    Delay7_out1_s18,...
    1,'Delay7',...
    fi(0,nt2,fiMath1,'hex','0'),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    Constant_out1_s9,...
    Delay8_out1_s19,...
    1,'Delay8',...
    fi(0,nt2,fiMath1,'hex','0'),...
    0,0,[],0,0);

    hC_12=pirelab.getConstComp(buffInpGenAddr16APSK,...
    count_step_s58,...
    fi(0,nt2,fiMath1,'hex','1'),...
    'step_value','off',0,'','','');

    hC_12.addComment(sprintf(['  // Count limited, Unsigned Counter\n  //  initial value   = 1\n'...
    ,'  //  step value      = 1\n  //  count to value  = 4']));

    pirelab.getAddComp(buffInpGenAddr16APSK,...
    [HDLCounter_out1_s55,count_step_s58],...
    count_s56,...
    'Floor','Wrap','adder',pirTyp4,'++');

    pirelab.getConstComp(buffInpGenAddr16APSK,...
    count_from_s59,...
    fi(0,nt2,fiMath1,'hex','1'),...
    'countFrom','off',0,'','','');

    pirelab.getSwitchComp(buffInpGenAddr16APSK,...
    [count_from_s59,count_s56],...
    count_value_s60,...
    need_to_wrap_s61,'switch',...
    '~=',0,'Floor','Wrap');

    pirelab.getCompareToValueComp(buffInpGenAddr16APSK,...
    HDLCounter_out1_s55,...
    need_to_wrap_s61,...
    '==',fi(0,nt2,fiMath1,'hex','4'),...
    'compare',0);

    pirelab.getMultiPortSwitchComp(buffInpGenAddr16APSK,...
    [validIn_s1,HDLCounter_out1_s55,count_value_s60],...
    count_s62,...
    1,'Zero-based contiguous','Floor','Wrap','switchEnable',[]);

    pirelab.getConstComp(buffInpGenAddr16APSK,...
    count_reset_s57,...
    fi(0,nt2,fiMath1,'hex','1'),...
    'const','off',0,'','','');

    pirelab.getSwitchComp(buffInpGenAddr16APSK,...
    [count_reset_s57,count_s62],...
    count_s63,...
    LogicalOperator12_out1_s25,'switchReset',...
    '~=',0,'Floor','Wrap');

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    count_s63,...
    HDLCounter_out_s64,...
    1,'HDL Counter',...
    double(0),...
    0,0,[],0,0);

    pirelab.getWireComp(buffInpGenAddr16APSK,...
    HDLCounter_out1_s55,...
    HDLCounter_out1_s20,...
    'HDL Counter_out1');

    pirelab.getWireComp(buffInpGenAddr16APSK,...
    Switch1_out1_s49,...
    APSK16_out1_s3,...
    'APSK16_out1');

    pirelab.getConstComp(buffInpGenAddr16APSK,...
    HDLCounter_Initial_Val_out_s65,...
    fi(0,nt2,fiMath1,'hex','1'),...
    'HDL Counter_Initial_Val','on',0,'','','');

    pirelab.getConstComp(buffInpGenAddr16APSK,...
    HDLCounter_ctrl_const_out_s66,...
    1,...
    'HDL Counter_ctrl_const');

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    HDLCounter_ctrl_const_out_s66,...
    HDLCounter_ctrl_delay_out_s67,...
    1,'HDL Counter_ctrl_delay',...
    double(0),...
    0,0,[],0,0);

    pirelab.getSwitchComp(buffInpGenAddr16APSK,...
    [HDLCounter_out_s64,HDLCounter_Initial_Val_out_s65],...
    HDLCounter_out1_s55,...
    HDLCounter_ctrl_delay_out_s67,'HDL Counter_switch',...
    '~=',0,'Floor','Wrap');

    pirelab.getSwitchComp(buffInpGenAddr16APSK,...
    [dataIn_s0,Delay1_delOut_s68],...
    Delay1_ectrl_s69,...
    LogicalOperator4_out1_s29,'Delay_Switch',...
    '~=',0,'Floor','Wrap');

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    Delay1_ectrl_s69,...
    Delay1_delOut_s68,...
    1,'Delay1_lowered',...
    fi(0,nt1,fiMath1,'hex','0'),...
    0,0,[],0,0);

    pirelab.getSwitchComp(buffInpGenAddr16APSK,...
    [Delay1_delOut_s68,Delay1_last_value_s70],...
    Delay1_out1_s12,...
    LogicalOperator4_out1_s29,'bypass_out',...
    '~=',0,'Floor','Wrap');

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    Delay1_out1_s12,...
    Delay1_last_value_s70,...
    1,'Delay1_bypass',...
    double(0),...
    0,0,[],0,0);

    pirelab.getSwitchComp(buffInpGenAddr16APSK,...
    [dataIn_s0,Delay2_delOut_s71],...
    Delay2_ectrl_s72,...
    LogicalOperator3_out1_s28,'Delay_Switch',...
    '~=',0,'Floor','Wrap');

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    Delay2_ectrl_s72,...
    Delay2_delOut_s71,...
    1,'Delay2_lowered',...
    fi(0,nt1,fiMath1,'hex','0'),...
    0,0,[],0,0);

    pirelab.getSwitchComp(buffInpGenAddr16APSK,...
    [Delay2_delOut_s71,Delay2_last_value_s73],...
    Delay2_out1_s13,...
    LogicalOperator3_out1_s28,'bypass_out',...
    '~=',0,'Floor','Wrap');

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    Delay2_out1_s13,...
    Delay2_last_value_s73,...
    1,'Delay2_bypass',...
    double(0),...
    0,0,[],0,0);

    pirelab.getSwitchComp(buffInpGenAddr16APSK,...
    [dataIn_s0,Delay4_delOut_s74],...
    Delay4_ectrl_s75,...
    LogicalOperator8_out1_s33,'Delay_Switch',...
    '~=',0,'Floor','Wrap');

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    Delay4_ectrl_s75,...
    Delay4_delOut_s74,...
    1,'Delay4_lowered',...
    fi(0,nt1,fiMath1,'hex','0'),...
    0,0,[],0,0);

    pirelab.getSwitchComp(buffInpGenAddr16APSK,...
    [Delay4_delOut_s74,Delay4_last_value_s76],...
    Delay4_out1_s15,...
    LogicalOperator8_out1_s33,'bypass_out',...
    '~=',0,'Floor','Wrap');

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    Delay4_out1_s15,...
    Delay4_last_value_s76,...
    1,'Delay4_bypass',...
    double(0),...
    0,0,[],0,0);

    pirelab.getSwitchComp(buffInpGenAddr16APSK,...
    [dataIn_s0,Delay5_delOut_s77],...
    Delay5_ectrl_s78,...
    LogicalOperator7_out1_s32,'Delay_Switch',...
    '~=',0,'Floor','Wrap');

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    Delay5_ectrl_s78,...
    Delay5_delOut_s77,...
    1,'Delay5_lowered',...
    fi(0,nt1,fiMath1,'hex','0'),...
    0,0,[],0,0);

    pirelab.getSwitchComp(buffInpGenAddr16APSK,...
    [Delay5_delOut_s77,Delay5_last_value_s79],...
    Delay5_out1_s16,...
    LogicalOperator7_out1_s32,'bypass_out',...
    '~=',0,'Floor','Wrap');

    pirelab.getIntDelayComp(buffInpGenAddr16APSK,...
    Delay5_out1_s16,...
    Delay5_last_value_s79,...
    1,'Delay5_bypass',...
    double(0),...
    0,0,[],0,0);


    pirelab.getBitConcatComp(buffInpGenAddr16APSK,...
    [Delay1_out1_s12,Delay2_out1_s13,Delay4_out1_s15,Delay5_out1_s16],...
    y_s43,...
    'Bit Concat');


    pirelab.getBitConcatComp(buffInpGenAddr16APSK,...
    [Constant_out1_s45,Constant1_out1_s46,Constant2_out1_s47,Constant3_out1_s48],...
    y_s44,...
    'Bit Concat1');


    pirelab.getSwitchComp(buffInpGenAddr16APSK,...
    [y_s43,y_s44],...
    Switch1_out1_s49,...
    LogicalOperator2_out1_s27,'Switch1',...
    '>',0,'Floor','Wrap');


    pirelab.getCompareToValueComp(buffInpGenAddr16APSK,...
    HDLCounter_out1_s20,...
    CompareToConstant_out1_s4,...
    '==',fi(0,nt2,fiMath1,'hex','2'),...
    sprintf('Compare\nTo Constant'),0);


    pirelab.getCompareToValueComp(buffInpGenAddr16APSK,...
    HDLCounter_out1_s20,...
    CompareToConstant1_out1_s5,...
    '==',fi(0,nt2,fiMath1,'hex','3'),...
    sprintf('Compare\nTo Constant1'),0);


    pirelab.getCompareToValueComp(buffInpGenAddr16APSK,...
    HDLCounter_out1_s20,...
    CompareToConstant2_out1_s6,...
    '==',fi(0,nt2,fiMath1,'hex','4'),...
    sprintf('Compare\nTo Constant2'),0);


    pirelab.getCompareToValueComp(buffInpGenAddr16APSK,...
    HDLCounter_out1_s20,...
    CompareToConstant5_out1_s7,...
    '==',fi(0,nt2,fiMath1,'hex','1'),...
    sprintf('Compare\nTo Constant5'),0);


    pirelab.getCompareToValueComp(buffInpGenAddr16APSK,...
    Delay7_out1_s18,...
    CompareToConstant6_out1_s8,...
    '==',fi(0,nt2,fiMath1,'hex','4'),...
    sprintf('Compare\nTo Constant6'),0);


    pirelab.getLogicComp(buffInpGenAddr16APSK,...
    [validIn_s1,CompareToConstant5_out1_s7],...
    LogicalOperator_out1_s21,...
    'and',sprintf('Logical\nOperator'));


    pirelab.getLogicComp(buffInpGenAddr16APSK,...
    [validIn_s1,CompareToConstant_out1_s4],...
    LogicalOperator1_out1_s22,...
    'and',sprintf('Logical\nOperator1'));


    pirelab.getLogicComp(buffInpGenAddr16APSK,...
    [Delay3_out1_s14,Delay6_out1_s17],...
    LogicalOperator10_out1_s23,...
    'and',sprintf('Logical\nOperator10'));


    pirelab.getLogicComp(buffInpGenAddr16APSK,...
    resetIn_s2,...
    LogicalOperator11_out1_s24,...
    'not',sprintf('Logical\nOperator11'));


    pirelab.getLogicComp(buffInpGenAddr16APSK,...
    [LogicalOperator5_out1_s30,resetIn_s2],...
    LogicalOperator12_out1_s25,...
    'or',sprintf('Logical\nOperator12'));


    pirelab.getLogicComp(buffInpGenAddr16APSK,...
    [LogicalOperator2_out1_s27,CompareToConstant6_out1_s8],...
    LogicalOperator16_out1_s26,...
    'and',sprintf('Logical\nOperator16'));


    pirelab.getLogicComp(buffInpGenAddr16APSK,...
    [RelationalOperator1_out1_s36,LogicalOperator10_out1_s23],...
    LogicalOperator2_out1_s27,...
    'and',sprintf('Logical\nOperator2'));


    pirelab.getLogicComp(buffInpGenAddr16APSK,...
    [LogicalOperator2_out1_s27,LogicalOperator1_out1_s22],...
    LogicalOperator3_out1_s28,...
    'or',sprintf('Logical\nOperator3'));


    pirelab.getLogicComp(buffInpGenAddr16APSK,...
    [LogicalOperator2_out1_s27,LogicalOperator_out1_s21],...
    LogicalOperator4_out1_s29,...
    'or',sprintf('Logical\nOperator4'));


    pirelab.getLogicComp(buffInpGenAddr16APSK,...
    [RelationalOperator_out1_s35,validIn_s1],...
    LogicalOperator5_out1_s30,...
    'and',sprintf('Logical\nOperator5'));


    pirelab.getLogicComp(buffInpGenAddr16APSK,...
    [validIn_s1,CompareToConstant1_out1_s5],...
    LogicalOperator6_out1_s31,...
    'and',sprintf('Logical\nOperator6'));


    pirelab.getLogicComp(buffInpGenAddr16APSK,...
    [LogicalOperator2_out1_s27,LogicalOperator9_out1_s34],...
    LogicalOperator7_out1_s32,...
    'or',sprintf('Logical\nOperator7'));


    pirelab.getLogicComp(buffInpGenAddr16APSK,...
    [LogicalOperator2_out1_s27,LogicalOperator6_out1_s31],...
    LogicalOperator8_out1_s33,...
    'or',sprintf('Logical\nOperator8'));


    pirelab.getLogicComp(buffInpGenAddr16APSK,...
    [validIn_s1,CompareToConstant2_out1_s6],...
    LogicalOperator9_out1_s34,...
    'and',sprintf('Logical\nOperator9'));


    pirelab.getRelOpComp(buffInpGenAddr16APSK,...
    [Constant_out1_s9,HDLCounter_out1_s20],...
    RelationalOperator_out1_s35,...
    '==',0,sprintf('Relational\nOperator'));


    pirelab.getRelOpComp(buffInpGenAddr16APSK,...
    [Delay8_out1_s19,Delay_out1_s11],...
    RelationalOperator1_out1_s36,...
    '==',0,sprintf('Relational\nOperator1'));


    pirelab.getSwitchComp(buffInpGenAddr16APSK,...
    [APSK16_out1_s3,Constant2_out1_s10],...
    Switch1_out1_s37,...
    LogicalOperator16_out1_s26,'Switch1',...
    '>',0,'Floor','Wrap');



    pirelab.getWireComp(buffInpGenAddr16APSK,Switch1_out1_s37,addr16APSK);
    pirelab.getWireComp(buffInpGenAddr16APSK,LogicalOperator2_out1_s27,addr16APSKValidOut);
end

function hS=addSignal(buffInpGenAddr16APSK,sigName,pirTyp,simulinkRate)
    hS=buffInpGenAddr16APSK.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end