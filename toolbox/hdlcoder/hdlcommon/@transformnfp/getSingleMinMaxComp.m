function hTopN=getSingleMinMaxComp(hN,slRate)
    p=pir(hN.getCtxName);
    hTopN=addNetworks(p);
    createNetworks(p,slRate);
end

function hTopN=addNetworks(p)
    hN=p.addNetwork;
    hN.Name='MIN_MAX';
    hN.FullPath='MIN_MAX';
    hTopN=hN;
    hN=p.addNetwork;
    hN.Name='double';
    hN.FullPath='MIN_MAX/NFP_MathWorks_MAX_MIN_Single//double';
    hN=p.addNetwork;
    hN.Name='Compare_A_and_B';
    hN.FullPath='MIN_MAX/NFP_MathWorks_MAX_MIN_Single//double/Compare_A_and_B';
    hN=p.addNetwork;
    hN.Name='A=B';
    hN.FullPath='MIN_MAX/NFP_MathWorks_MAX_MIN_Single//double/Compare_A_and_B/A=B';
    hN=p.addNetwork;
    hN.Name='A>B';
    hN.FullPath='MIN_MAX/NFP_MathWorks_MAX_MIN_Single//double/Compare_A_and_B/A>B';
end

function createNetworks(p,slRate)
    hN_n4=p.findNetwork('fullname','MIN_MAX/NFP_MathWorks_MAX_MIN_Single//double/Compare_A_and_B/A>B');
    createNetwork_n4(p,hN_n4,slRate);
    hN_n3=p.findNetwork('fullname','MIN_MAX/NFP_MathWorks_MAX_MIN_Single//double/Compare_A_and_B/A=B');
    createNetwork_n3(p,hN_n3,slRate);
    hN_n2=p.findNetwork('fullname','MIN_MAX/NFP_MathWorks_MAX_MIN_Single//double/Compare_A_and_B');
    createNetwork_n2(p,hN_n2,slRate);
    hN_n1=p.findNetwork('fullname','MIN_MAX/NFP_MathWorks_MAX_MIN_Single//double');
    createNetwork_n1(p,hN_n1,slRate);
    hN_n0=p.findNetwork('fullname','MIN_MAX');
    createNetwork_n0(p,hN_n0,slRate);
end

function hN=createNetwork_n4(~,hN,slRate1)
    pirTyp1=pir_boolean_t;
    pirTyp3=pir_ufixpt_t(23,0);
    pirTyp2=pir_unsigned_t(8);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,1,0);



    hN.addInputPort('AS');
    AS_s0=addSignal(hN,'AS',pirTyp1,slRate1);
    AS_s0.addDriver(hN,0);

    hN.addInputPort('AE');
    AE_s1=addSignal(hN,'AE',pirTyp2,slRate1);
    AE_s1.addDriver(hN,1);

    hN.addInputPort('AM');
    AM_s2=addSignal(hN,'AM',pirTyp3,slRate1);
    AM_s2.addDriver(hN,2);

    hN.addInputPort('BS');
    BS_s3=addSignal(hN,'BS',pirTyp1,slRate1);
    BS_s3.addDriver(hN,3);

    hN.addInputPort('BE');
    BE_s4=addSignal(hN,'BE',pirTyp2,slRate1);
    BE_s4.addDriver(hN,4);

    hN.addInputPort('BM');
    BM_s5=addSignal(hN,'BM',pirTyp3,slRate1);
    BM_s5.addDriver(hN,5);

    hN.addOutputPort('AGB');
    LogicalOperator4_out1_s11=addSignal(hN,sprintf('Logical\nOperator4_out1'),pirTyp1,slRate1);
    LogicalOperator4_out1_s11.addReceiver(hN,0);

    CompareToConstant_out1_s6=addSignal(hN,sprintf('Compare\nTo Constant_out1'),pirTyp1,slRate1);
    LogicalOperator_out1_s7=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate1);
    LogicalOperator1_out1_s8=addSignal(hN,sprintf('Logical\nOperator1_out1'),pirTyp1,slRate1);
    LogicalOperator2_out1_s9=addSignal(hN,sprintf('Logical\nOperator2_out1'),pirTyp1,slRate1);
    LogicalOperator3_out1_s10=addSignal(hN,sprintf('Logical\nOperator3_out1'),pirTyp1,slRate1);
    LogicalOperator5_out1_s12=addSignal(hN,sprintf('Logical\nOperator5_out1'),pirTyp1,slRate1);
    RelationalOperator_out1_s13=addSignal(hN,sprintf('Relational\nOperator_out1'),pirTyp1,slRate1);
    RelationalOperator1_out1_s14=addSignal(hN,sprintf('Relational\nOperator1_out1'),pirTyp1,slRate1);
    RelationalOperator2_out1_s15=addSignal(hN,sprintf('Relational\nOperator2_out1'),pirTyp1,slRate1);
    RelationalOperator3_out1_s16=addSignal(hN,sprintf('Relational\nOperator3_out1'),pirTyp1,slRate1);
    RelationalOperator4_out1_s17=addSignal(hN,sprintf('Relational\nOperator4_out1'),pirTyp1,slRate1);
    Switch_out1_s18=addSignal(hN,'Switch_out1',pirTyp1,slRate1);


    pirelab.getCompareToValueComp(hN,...
    BS_s3,...
    CompareToConstant_out1_s6,...
    '==',fi(1,nt1,fiMath1),...
    sprintf('Compare\nTo Constant'),0);


    pirelab.getLogicComp(hN,...
    [RelationalOperator3_out1_s16,RelationalOperator4_out1_s17],...
    LogicalOperator_out1_s7,...
    'and',sprintf('Logical\nOperator'));


    pirelab.getLogicComp(hN,...
    [RelationalOperator2_out1_s15,LogicalOperator2_out1_s9],...
    LogicalOperator1_out1_s8,...
    'and',sprintf('Logical\nOperator1'));


    pirelab.getLogicComp(hN,...
    [RelationalOperator1_out1_s14,LogicalOperator_out1_s7],...
    LogicalOperator2_out1_s9,...
    'or',sprintf('Logical\nOperator2'));


    pirelab.getLogicComp(hN,...
    [CompareToConstant_out1_s6,RelationalOperator2_out1_s15],...
    LogicalOperator3_out1_s10,...
    'and',sprintf('Logical\nOperator3'));


    pirelab.getLogicComp(hN,...
    [RelationalOperator_out1_s13,Switch_out1_s18],...
    LogicalOperator4_out1_s11,...
    'or',sprintf('Logical\nOperator4'));


    pirelab.getLogicComp(hN,...
    LogicalOperator1_out1_s8,...
    LogicalOperator5_out1_s12,...
    'not',sprintf('Logical\nOperator5'));


    pirelab.getRelOpComp(hN,...
    [AS_s0,BS_s3],...
    RelationalOperator_out1_s13,...
    '<',0,sprintf('Relational\nOperator'));


    pirelab.getRelOpComp(hN,...
    [AE_s1,BE_s4],...
    RelationalOperator1_out1_s14,...
    '>',0,sprintf('Relational\nOperator1'));


    pirelab.getRelOpComp(hN,...
    [AS_s0,BS_s3],...
    RelationalOperator2_out1_s15,...
    '==',0,sprintf('Relational\nOperator2'));


    pirelab.getRelOpComp(hN,...
    [AE_s1,BE_s4],...
    RelationalOperator3_out1_s16,...
    '==',0,sprintf('Relational\nOperator3'));


    pirelab.getRelOpComp(hN,...
    [AM_s2,BM_s5],...
    RelationalOperator4_out1_s17,...
    '>',0,sprintf('Relational\nOperator4'));


    pirelab.getSwitchComp(hN,...
    [LogicalOperator5_out1_s12,LogicalOperator1_out1_s8],...
    Switch_out1_s18,...
    LogicalOperator3_out1_s10,'Switch',...
    '>',0,'Floor','Wrap');


end

function hN=createNetwork_n3(~,hN,slRate1)
    pirTyp1=pir_boolean_t;
    pirTyp3=pir_ufixpt_t(23,0);
    pirTyp2=pir_unsigned_t(8);





    hN.addInputPort('AS');
    AS_s0=addSignal(hN,'AS',pirTyp1,slRate1);
    AS_s0.addDriver(hN,0);

    hN.addInputPort('AE');
    AE_s1=addSignal(hN,'AE',pirTyp2,slRate1);
    AE_s1.addDriver(hN,1);

    hN.addInputPort('AM');
    AM_s2=addSignal(hN,'AM',pirTyp3,slRate1);
    AM_s2.addDriver(hN,2);

    hN.addInputPort('BS');
    BS_s3=addSignal(hN,'BS',pirTyp1,slRate1);
    BS_s3.addDriver(hN,3);

    hN.addInputPort('BE');
    BE_s4=addSignal(hN,'BE',pirTyp2,slRate1);
    BE_s4.addDriver(hN,4);

    hN.addInputPort('BM');
    BM_s5=addSignal(hN,'BM',pirTyp3,slRate1);
    BM_s5.addDriver(hN,5);

    hN.addOutputPort('AEB');
    LogicalOperator_out1_s6=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate1);
    LogicalOperator_out1_s6.addReceiver(hN,0);

    RelationalOperator_out1_s7=addSignal(hN,sprintf('Relational\nOperator_out1'),pirTyp1,slRate1);
    RelationalOperator1_out1_s8=addSignal(hN,sprintf('Relational\nOperator1_out1'),pirTyp1,slRate1);
    RelationalOperator2_out1_s9=addSignal(hN,sprintf('Relational\nOperator2_out1'),pirTyp1,slRate1);


    pirelab.getLogicComp(hN,...
    [RelationalOperator_out1_s7,RelationalOperator1_out1_s8,RelationalOperator2_out1_s9],...
    LogicalOperator_out1_s6,...
    'and',sprintf('Logical\nOperator'));


    pirelab.getRelOpComp(hN,...
    [AS_s0,BS_s3],...
    RelationalOperator_out1_s7,...
    '==',0,sprintf('Relational\nOperator'));


    pirelab.getRelOpComp(hN,...
    [AE_s1,BE_s4],...
    RelationalOperator1_out1_s8,...
    '==',0,sprintf('Relational\nOperator1'));


    pirelab.getRelOpComp(hN,...
    [AM_s2,BM_s5],...
    RelationalOperator2_out1_s9,...
    '==',0,sprintf('Relational\nOperator2'));


end

function hN=createNetwork_n2(p,hN,slRate1)
    pirTyp1=pir_boolean_t;
    pirTyp3=pir_ufixpt_t(23,0);
    pirTyp2=pir_unsigned_t(8);





    hN.addInputPort('AS');
    AS_s0=addSignal(hN,'AS',pirTyp1,slRate1);
    AS_s0.addDriver(hN,0);

    hN.addInputPort('AE');
    AE_s1=addSignal(hN,'AE',pirTyp2,slRate1);
    AE_s1.addDriver(hN,1);

    hN.addInputPort('AM');
    AM_s2=addSignal(hN,'AM',pirTyp3,slRate1);
    AM_s2.addDriver(hN,2);

    hN.addInputPort('BS');
    BS_s3=addSignal(hN,'BS',pirTyp1,slRate1);
    BS_s3.addDriver(hN,3);

    hN.addInputPort('BE');
    BE_s4=addSignal(hN,'BE',pirTyp2,slRate1);
    BE_s4.addDriver(hN,4);

    hN.addInputPort('BM');
    BM_s5=addSignal(hN,'BM',pirTyp3,slRate1);
    BM_s5.addDriver(hN,5);

    hN.addOutputPort('AGEB');
    LogicalOperator_out1_s8=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate1);
    LogicalOperator_out1_s8.addReceiver(hN,0);

    A_B_out1_s6=addSignal(hN,'A=B_out1',pirTyp1,slRate1);
    A_B_out1_s7=addSignal(hN,'A>B_out1',pirTyp1,slRate1);

    hRefN=p.findNetwork('fullname','MIN_MAX/NFP_MathWorks_MAX_MIN_Single//double/Compare_A_and_B/A=B');
    A_B=hN.addComponent('ntwk_instance_comp',hRefN);
    A_B.Name='A=B';
    pirelab.connectNtwkInstComp(A_B,...
    [AS_s0,AE_s1,AM_s2,BS_s3,BE_s4,BM_s5],...
    A_B_out1_s6);

    hRefN=p.findNetwork('fullname','MIN_MAX/NFP_MathWorks_MAX_MIN_Single//double/Compare_A_and_B/A>B');
    A_B=hN.addComponent('ntwk_instance_comp',hRefN);
    A_B.Name='A>B';
    pirelab.connectNtwkInstComp(A_B,...
    [AS_s0,AE_s1,AM_s2,BS_s3,BE_s4,BM_s5],...
    A_B_out1_s7);


    pirelab.getLogicComp(hN,...
    [A_B_out1_s7,A_B_out1_s6],...
    LogicalOperator_out1_s8,...
    'or',sprintf('Logical\nOperator'));


end

function hN=createNetwork_n1(p,hN,slRate1)
    pirTyp1=pir_boolean_t;
    pirTyp3=pir_ufixpt_t(23,0);
    pirTyp2=pir_unsigned_t(8);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,23,0);



    hN.addInputPort('AS');
    AS_s0=addSignal(hN,'AS',pirTyp1,slRate1);
    AS_s0.addDriver(hN,0);

    hN.addInputPort('AE');
    AE_s1=addSignal(hN,'AE',pirTyp2,slRate1);
    AE_s1.addDriver(hN,1);

    hN.addInputPort('AM');
    AM_s2=addSignal(hN,'AM',pirTyp3,slRate1);
    AM_s2.addDriver(hN,2);

    hN.addInputPort('BS');
    BS_s3=addSignal(hN,'BS',pirTyp1,slRate1);
    BS_s3.addDriver(hN,3);

    hN.addInputPort('BE');
    BE_s4=addSignal(hN,'BE',pirTyp2,slRate1);
    BE_s4.addDriver(hN,4);

    hN.addInputPort('BM');
    BM_s5=addSignal(hN,'BM',pirTyp3,slRate1);
    BM_s5.addDriver(hN,5);

    hN.addOutputPort('MAX_S');
    Delay13_out1_s12=addSignal(hN,'Delay13_out1',pirTyp1,slRate1);
    Delay13_out1_s12.addReceiver(hN,0);

    hN.addOutputPort('MAX_E');
    Delay11_out1_s10=addSignal(hN,'Delay11_out1',pirTyp2,slRate1);
    Delay11_out1_s10.addReceiver(hN,1);

    hN.addOutputPort('MAX_M');
    Delay6_out1_s22=addSignal(hN,'Delay6_out1',pirTyp3,slRate1);
    Delay6_out1_s22.addReceiver(hN,2);

    hN.addOutputPort('MIN_S');
    Delay10_out1_s9=addSignal(hN,'Delay10_out1',pirTyp1,slRate1);
    Delay10_out1_s9.addReceiver(hN,3);

    hN.addOutputPort('MIN_E');
    Delay15_out1_s14=addSignal(hN,'Delay15_out1',pirTyp2,slRate1);
    Delay15_out1_s14.addReceiver(hN,4);

    hN.addOutputPort('MIN_M');
    Delay17_out1_s16=addSignal(hN,'Delay17_out1',pirTyp3,slRate1);
    Delay17_out1_s16.addReceiver(hN,5);

    Compare_A_and_B_out1_s6=addSignal(hN,'Compare_A_and_B_out1',pirTyp1,slRate1);
    S_s7=addSignal(hN,'S',pirTyp1,slRate1);
    E_s8=addSignal(hN,'E',pirTyp2,slRate1);
    Delay12_out1_s11=addSignal(hN,'Delay12_out1',pirTyp2,slRate1);
    Delay14_out1_s13=addSignal(hN,'Delay14_out1',pirTyp1,slRate1);
    Delay16_out1_s15=addSignal(hN,'Delay16_out1',pirTyp2,slRate1);
    Delay18_out1_s17=addSignal(hN,'Delay18_out1',pirTyp3,slRate1);
    M_s18=addSignal(hN,'M',pirTyp3,slRate1);
    S_s19=addSignal(hN,'S',pirTyp1,slRate1);
    E_s20=addSignal(hN,'E',pirTyp2,slRate1);
    M_s21=addSignal(hN,'M',pirTyp3,slRate1);
    Delay7_out1_s23=addSignal(hN,'Delay7_out1',pirTyp3,slRate1);
    Delay8_out1_s24=addSignal(hN,'Delay8_out1',pirTyp1,slRate1);
    Delay9_out1_s25=addSignal(hN,'Delay9_out1',pirTyp1,slRate1);
    Switch1_out1_s26=addSignal(hN,'Switch1_out1',pirTyp3,slRate1);
    Switch2_out1_s27=addSignal(hN,'Switch2_out1',pirTyp1,slRate1);
    Switch3_out1_s28=addSignal(hN,'Switch3_out1',pirTyp2,slRate1);
    Switch4_out1_s29=addSignal(hN,'Switch4_out1',pirTyp1,slRate1);
    Switch5_out1_s30=addSignal(hN,'Switch5_out1',pirTyp2,slRate1);
    Switch6_out1_s31=addSignal(hN,'Switch6_out1',pirTyp3,slRate1);

    hRefN=p.findNetwork('fullname','MIN_MAX/NFP_MathWorks_MAX_MIN_Single//double/Compare_A_and_B');
    Compare_A_and_B=hN.addComponent('ntwk_instance_comp',hRefN);
    Compare_A_and_B.Name='Compare_A_and_B';
    pirelab.connectNtwkInstComp(Compare_A_and_B,...
    [S_s7,E_s8,M_s18,S_s19,E_s20,M_s21],...
    Compare_A_and_B_out1_s6);


    pirelab.getIntDelayComp(hN,...
    AS_s0,...
    S_s7,...
    transformnfp.Delay1,'Delay',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    AE_s1,...
    E_s8,...
    transformnfp.Delay1,'Delay1',...
    uint8(0),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    Switch2_out1_s27,...
    Delay10_out1_s9,...
    transformnfp.Delay1,'Delay10',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    Switch3_out1_s28,...
    Delay11_out1_s10,...
    transformnfp.Delay1,'Delay11',...
    uint8(0),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    E_s8,...
    Delay12_out1_s11,...
    transformnfp.Delay1,'Delay12',...
    uint8(0),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    Switch4_out1_s29,...
    Delay13_out1_s12,...
    transformnfp.Delay1,'Delay13',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    S_s7,...
    Delay14_out1_s13,...
    transformnfp.Delay1,'Delay14',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    Switch5_out1_s30,...
    Delay15_out1_s14,...
    transformnfp.Delay1,'Delay15',...
    uint8(0),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    E_s20,...
    Delay16_out1_s15,...
    transformnfp.Delay1,'Delay16',...
    uint8(0),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    Switch6_out1_s31,...
    Delay17_out1_s16,...
    transformnfp.Delay1,'Delay17',...
    fi(0,nt1,fiMath1),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    M_s21,...
    Delay18_out1_s17,...
    transformnfp.Delay1,'Delay18',...
    fi(0,nt1,fiMath1),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    AM_s2,...
    M_s18,...
    transformnfp.Delay1,'Delay2',...
    fi(0,nt1,fiMath1),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    BS_s3,...
    S_s19,...
    transformnfp.Delay1,'Delay3',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    BE_s4,...
    E_s20,...
    transformnfp.Delay1,'Delay4',...
    uint8(0),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    BM_s5,...
    M_s21,...
    transformnfp.Delay1,'Delay5',...
    fi(0,nt1,fiMath1),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    Switch1_out1_s26,...
    Delay6_out1_s22,...
    transformnfp.Delay1,'Delay6',...
    fi(0,nt1,fiMath1),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    M_s18,...
    Delay7_out1_s23,...
    transformnfp.Delay1,'Delay7',...
    fi(0,nt1,fiMath1),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    Compare_A_and_B_out1_s6,...
    Delay8_out1_s24,...
    transformnfp.Delay1,'Delay8',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    S_s19,...
    Delay9_out1_s25,...
    transformnfp.Delay1,'Delay9',...
    false,...
    0,0,[],0,0);


    pirelab.getSwitchComp(hN,...
    [Delay7_out1_s23,Delay18_out1_s17],...
    Switch1_out1_s26,...
    Delay8_out1_s24,'Switch1',...
    '~=',0,'Floor','Wrap');


    pirelab.getSwitchComp(hN,...
    [Delay9_out1_s25,Delay14_out1_s13],...
    Switch2_out1_s27,...
    Delay8_out1_s24,'Switch2',...
    '~=',0,'Floor','Wrap');


    pirelab.getSwitchComp(hN,...
    [Delay12_out1_s11,Delay16_out1_s15],...
    Switch3_out1_s28,...
    Delay8_out1_s24,'Switch3',...
    '~=',0,'Floor','Wrap');


    pirelab.getSwitchComp(hN,...
    [Delay14_out1_s13,Delay9_out1_s25],...
    Switch4_out1_s29,...
    Delay8_out1_s24,'Switch4',...
    '~=',0,'Floor','Wrap');


    pirelab.getSwitchComp(hN,...
    [Delay16_out1_s15,Delay12_out1_s11],...
    Switch5_out1_s30,...
    Delay8_out1_s24,'Switch5',...
    '~=',0,'Floor','Wrap');


    pirelab.getSwitchComp(hN,...
    [Delay18_out1_s17,Delay7_out1_s23],...
    Switch6_out1_s31,...
    Delay8_out1_s24,'Switch6',...
    '~=',0,'Floor','Wrap');


end

function hN=createNetwork_n0(p,hN,slRate1)
    pirTyp1=pir_ufixpt_t(1,0);
    pirTyp3=pir_ufixpt_t(23,0);
    pirTyp2=pir_ufixpt_t(8,0);





    hN.addInputPort('AS');
    AS_s0=addSignal(hN,'AS',pirTyp1,slRate1);
    AS_s0.addDriver(hN,0);

    hN.addInputPort('AE');
    AE_s1=addSignal(hN,'AE',pirTyp2,slRate1);
    AE_s1.addDriver(hN,1);

    hN.addInputPort('AM');
    AM_s2=addSignal(hN,'AM',pirTyp3,slRate1);
    AM_s2.addDriver(hN,2);

    hN.addInputPort('BS');
    BS_s3=addSignal(hN,'BS',pirTyp1,slRate1);
    BS_s3.addDriver(hN,3);

    hN.addInputPort('BE');
    BE_s4=addSignal(hN,'BE',pirTyp2,slRate1);
    BE_s4.addDriver(hN,4);

    hN.addInputPort('BM');
    BM_s5=addSignal(hN,'BM',pirTyp3,slRate1);
    BM_s5.addDriver(hN,5);

    hN.addOutputPort('MAXS');
    S_s6=addSignal(hN,'S',pirTyp1,slRate1);
    S_s6.addReceiver(hN,0);

    hN.addOutputPort('MAXE');
    E_s7=addSignal(hN,'E',pirTyp2,slRate1);
    E_s7.addReceiver(hN,1);

    hN.addOutputPort('MAXM');
    M_s8=addSignal(hN,'M',pirTyp3,slRate1);
    M_s8.addReceiver(hN,2);

    hN.addOutputPort('MINS');
    S_s9=addSignal(hN,'S',pirTyp1,slRate1);
    S_s9.addReceiver(hN,3);

    hN.addOutputPort('MINE');
    E_s10=addSignal(hN,'E',pirTyp2,slRate1);
    E_s10.addReceiver(hN,4);

    hN.addOutputPort('MINM');
    M_s11=addSignal(hN,'M',pirTyp3,slRate1);
    M_s11.addReceiver(hN,5);


    hRefN=p.findNetwork('fullname','MIN_MAX/NFP_MathWorks_MAX_MIN_Single//double');
    NFP_MathWorks_MAX_MIN_Single__double=hN.addComponent('ntwk_instance_comp',hRefN);
    NFP_MathWorks_MAX_MIN_Single__double.Name='NFP_MathWorks_MAX_MIN_Single//double';
    pirelab.connectNtwkInstComp(NFP_MathWorks_MAX_MIN_Single__double,...
    [AS_s0,AE_s1,AM_s2,BS_s3,BE_s4,BM_s5],...
    [S_s6,E_s7,M_s8,S_s9,E_s10,M_s11]);


end

function hS=addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end
