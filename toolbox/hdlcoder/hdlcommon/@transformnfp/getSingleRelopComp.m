

function hTopN=getSingleRelopComp(hOrigN,opName,latency,slRate)



    p=pir(hOrigN.getCtxName);
    hTopN=addNetworks(p,opName);
    pipestage=zeros(1,3);
    switch latency
    case 0
        pipestage=zeros(1,3);
    case 1
        pipestage(1)=1;
    case 2
        pipestage=[1,0,1];
    case 3
        pipestage=[1,1,1];
    otherwise
        assert(false,'Illegal latency number in nfp_relop_comp.');
    end

    createNetworks(p,opName,pipestage,latency,slRate);
end

function hTopN=addNetworks(p,opName)
    hN=p.addNetwork;
    hN.Name='Relops_Single';
    hN.FullPath='Relops_Single';
    hTopN=hN;
    hN=p.addNetwork;
    hN.Name='NFP_MathWorks_Relops_Single';
    hN.FullPath='Relops_Single/NFP_MathWorks_Relops_Single';
    hN=p.addNetwork;
    hN.Name='CheckZeroNaN';
    hN.FullPath='Relops_Single/NFP_MathWorks_Relops_Single/CheckZeroNaN';
    hN=p.addNetwork;
    hN.Name='Greater_Or_Equal';
    hN.FullPath='Relops_Single/NFP_MathWorks_Relops_Single/Greater_Or_Equal';
    hN=p.addNetwork;
    hN.Name='InitialSequenceLogic';
    hN.FullPath='Relops_Single/NFP_MathWorks_Relops_Single/InitialSequenceLogic';
    switch opName
    case{'==','~='}
        hN=p.addNetwork;
        hN.Name='SSAEB';
        hN.FullPath='Relops_Single/NFP_MathWorks_Relops_Single/SSAEB';
    case{'<','>='}
        hN=p.addNetwork;
        hN.Name='SSAGB';
        hN.FullPath='Relops_Single/NFP_MathWorks_Relops_Single/SSAGB';
    case{'>','<='}
        hN=p.addNetwork;
        hN.Name='SSALB';
        hN.FullPath='Relops_Single/NFP_MathWorks_Relops_Single/SSALB';
    end
end

function createNetworks(p,opName,pipestage,latency,slRate)
    switch opName
    case{'>','<='}
        hN_n7=p.findNetwork('fullname','Relops_Single/NFP_MathWorks_Relops_Single/SSALB');
        createNetwork_n7(p,hN_n7,opName,pipestage,slRate);
    case{'<','>='}
        hN_n6=p.findNetwork('fullname','Relops_Single/NFP_MathWorks_Relops_Single/SSAGB');
        createNetwork_n6(p,hN_n6,opName,pipestage,slRate);
    case{'==','~='}
        hN_n5=p.findNetwork('fullname','Relops_Single/NFP_MathWorks_Relops_Single/SSAEB');
        createNetwork_n5(p,hN_n5,opName,pipestage,slRate);
    end
    hN_n4=p.findNetwork('fullname','Relops_Single/NFP_MathWorks_Relops_Single/InitialSequenceLogic');
    createNetwork_n4(p,hN_n4,latency,slRate);
    hN_n3=p.findNetwork('fullname','Relops_Single/NFP_MathWorks_Relops_Single/Greater_Or_Equal');
    createNetwork_n3(p,hN_n3,pipestage,slRate);
    hN_n2=p.findNetwork('fullname','Relops_Single/NFP_MathWorks_Relops_Single/CheckZeroNaN');
    createNetwork_n2(p,hN_n2,pipestage,slRate);
    hN_n1=p.findNetwork('fullname','Relops_Single/NFP_MathWorks_Relops_Single');
    createNetwork_n1(p,hN_n1,opName,pipestage,slRate);
    hN_n0=p.findNetwork('fullname','Relops_Single');
    createNetwork_n0(p,hN_n0,opName,slRate);
end

function hN=createNetwork_n7(~,hN,opName,pipestage,slRate1)
    pirTyp1=pir_boolean_t;

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,1,0);


    hN.addInputPort('AEBI');
    AEBI_s0=addSignal(hN,'AEBI',pirTyp1,slRate1);
    AEBI_s0.addDriver(hN,0);

    hN.addInputPort('Init');
    Init_s1=addSignal(hN,'Init',pirTyp1,slRate1);
    Init_s1.addDriver(hN,1);

    hN.addInputPort('AGBI');
    AGBI_s2=addSignal(hN,'AGBI',pirTyp1,slRate1);
    AGBI_s2.addDriver(hN,2);

    hN.addInputPort('isNaN');
    isNaN_s3=addSignal(hN,'isNaN',pirTyp1,slRate1);
    isNaN_s3.addDriver(hN,3);


    Constant1_out1_s4=addSignal(hN,'Constant1_out1',pirTyp1,slRate1);
    Delay5_out1_s6=addSignal(hN,'Delay5_out1',pirTyp1,slRate1);
    LogicalOperator_out1_s7=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate1);

    if strcmpi(opName,'>')
        hN.addOutputPort('AGB');
        Switch1_out1_s12=addSignal(hN,'Switch1_out1',pirTyp1,slRate1);
        Switch1_out1_s12.addReceiver(hN,0);

        pirelab.getSwitchComp(hN,...
        [Constant1_out1_s4,Delay5_out1_s6],...
        Switch1_out1_s12,...
        LogicalOperator_out1_s7,'Switch1',...
        '~=',0,'Floor','Wrap');
    else
        hN.addOutputPort('ALEB');
        Switch4_out1_s13=addSignal(hN,'Switch4_out1',pirTyp1,slRate1);
        Switch4_out1_s13.addReceiver(hN,0);
        LogicalOperator2_out1_s9=addSignal(hN,sprintf('Logical\nOperator2_out1'),pirTyp1,slRate1);

        pirelab.getLogicComp(hN,...
        Delay5_out1_s6,...
        LogicalOperator2_out1_s9,...
        'not',sprintf('Logical\nOperator2'));

        pirelab.getSwitchComp(hN,...
        [Constant1_out1_s4,LogicalOperator2_out1_s9],...
        Switch4_out1_s13,...
        LogicalOperator_out1_s7,'Switch4',...
        '~=',0,'Floor','Wrap');
    end

    Delay1_out1_s5=addSignal(hN,'Delay1_out1',pirTyp1,slRate1);
    LogicalOperator1_out1_s8=addSignal(hN,sprintf('Logical\nOperator1_out1'),pirTyp1,slRate1);
    LogicalOperator5_out1_s10=addSignal(hN,sprintf('Logical\nOperator5_out1'),pirTyp1,slRate1);
    LogicalOperator6_out1_s11=addSignal(hN,sprintf('Logical\nOperator6_out1'),pirTyp1,slRate1);


    pirelab.getConstComp(hN,...
    Constant1_out1_s4,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant1','on',1,'','','');


    pirelab.getIntDelayComp(hN,...
    isNaN_s3,...
    Delay1_out1_s5,...
    pipestage(3),'Delay1',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    LogicalOperator5_out1_s10,...
    Delay5_out1_s6,...
    pipestage(3),'Delay5',...
    false,...
    0,0,[],0,0);


    pirelab.getLogicComp(hN,...
    [LogicalOperator1_out1_s8,Delay1_out1_s5],...
    LogicalOperator_out1_s7,...
    'or',sprintf('Logical\nOperator'));


    pirelab.getLogicComp(hN,...
    Init_s1,...
    LogicalOperator1_out1_s8,...
    'not',sprintf('Logical\nOperator1'));


    pirelab.getLogicComp(hN,...
    [LogicalOperator6_out1_s11,AGBI_s2],...
    LogicalOperator5_out1_s10,...
    'and',sprintf('Logical\nOperator5'));


    pirelab.getLogicComp(hN,...
    AEBI_s0,...
    LogicalOperator6_out1_s11,...
    'not',sprintf('Logical\nOperator6'));



end

function hN=createNetwork_n6(~,hN,opName,pipestage,slRate1)
    pirTyp1=pir_boolean_t;

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,1,0);


    hN.addInputPort('AEB');
    AEB_s0=addSignal(hN,'AEB',pirTyp1,slRate1);
    AEB_s0.addDriver(hN,0);

    hN.addInputPort('Init');
    Init_s1=addSignal(hN,'Init',pirTyp1,slRate1);
    Init_s1.addDriver(hN,1);

    hN.addInputPort('AGB');
    AGB_s2=addSignal(hN,'AGB',pirTyp1,slRate1);
    AGB_s2.addDriver(hN,2);

    hN.addInputPort('isNaN');
    isNaN_s3=addSignal(hN,'isNaN',pirTyp1,slRate1);
    isNaN_s3.addDriver(hN,3);
    LogicalOperator1_out1_s7=addSignal(hN,sprintf('Logical\nOperator1_out1'),pirTyp1,slRate1);
    Delay10_out1_s6=addSignal(hN,'Delay10_out1',pirTyp1,slRate1);
    Constant1_out1_s4=addSignal(hN,'Constant1_out1',pirTyp1,slRate1);


    if strcmpi(opName,'<')
        hN.addOutputPort('ALB');
        Switch4_out1_s11=addSignal(hN,'Switch4_out1',pirTyp1,slRate1);
        Switch4_out1_s11.addReceiver(hN,0);
        LogicalOperator4_out1_s10=addSignal(hN,sprintf('Logical\nOperator4_out1'),pirTyp1,slRate1);

        pirelab.getSwitchComp(hN,...
        [Constant1_out1_s4,LogicalOperator4_out1_s10],...
        Switch4_out1_s11,...
        LogicalOperator1_out1_s7,'Switch4',...
        '~=',0,'Floor','Wrap');

        pirelab.getLogicComp(hN,...
        Delay10_out1_s6,...
        LogicalOperator4_out1_s10,...
        'not',sprintf('Logical\nOperator4'));
    else
        hN.addOutputPort('AGEB');
        Switch6_out1_s12=addSignal(hN,'Switch6_out1',pirTyp1,slRate1);
        Switch6_out1_s12.addReceiver(hN,0);

        pirelab.getSwitchComp(hN,...
        [Constant1_out1_s4,Delay10_out1_s6],...
        Switch6_out1_s12,...
        LogicalOperator1_out1_s7,'Switch6',...
        '~=',0,'Floor','Wrap');
    end

    Delay1_out1_s5=addSignal(hN,'Delay1_out1',pirTyp1,slRate1);
    LogicalOperator2_out1_s8=addSignal(hN,sprintf('Logical\nOperator2_out1'),pirTyp1,slRate1);
    LogicalOperator3_out1_s9=addSignal(hN,sprintf('Logical\nOperator3_out1'),pirTyp1,slRate1);

    pirelab.getConstComp(hN,...
    Constant1_out1_s4,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant1','on',1,'','','');


    pirelab.getIntDelayComp(hN,...
    isNaN_s3,...
    Delay1_out1_s5,...
    pipestage(3),'Delay1',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    LogicalOperator3_out1_s9,...
    Delay10_out1_s6,...
    pipestage(3),'Delay10',...
    false,...
    0,0,[],0,0);


    pirelab.getLogicComp(hN,...
    [LogicalOperator2_out1_s8,Delay1_out1_s5],...
    LogicalOperator1_out1_s7,...
    'or',sprintf('Logical\nOperator1'));


    pirelab.getLogicComp(hN,...
    Init_s1,...
    LogicalOperator2_out1_s8,...
    'not',sprintf('Logical\nOperator2'));


    pirelab.getLogicComp(hN,...
    [AEB_s0,AGB_s2],...
    LogicalOperator3_out1_s9,...
    'or',sprintf('Logical\nOperator3'));


end

function hN=createNetwork_n5(~,hN,opName,pipestage,slRate1)
    pirTyp1=pir_boolean_t;

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,1,0);



    hN.addInputPort('Val');
    Val_s0=addSignal(hN,'Val',pirTyp1,slRate1);
    Val_s0.addDriver(hN,0);

    hN.addInputPort('Init');
    Init_s1=addSignal(hN,'Init',pirTyp1,slRate1);
    Init_s1.addDriver(hN,1);

    hN.addInputPort('isNaN');
    isNaN_s2=addSignal(hN,'isNaN',pirTyp1,slRate1);
    isNaN_s2.addDriver(hN,2);

    Delay6_out1_s6=addSignal(hN,'Delay6_out1',pirTyp1,slRate1);
    Constant6_out1_s4=addSignal(hN,'Constant6_out1',pirTyp1,slRate1);
    LogicalOperator_out1_s7=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate1);
    Delay1_out1_s5=addSignal(hN,'Delay1_out1',pirTyp1,slRate1);
    LogicalOperator2_out1_s8=addSignal(hN,sprintf('Logical\nOperator2_out1'),pirTyp1,slRate1);

    if strcmpi(opName,'==')
        hN.addOutputPort('AEB');
        Switch6_out1_s12=addSignal(hN,'Switch6_out1',pirTyp1,slRate1);
        Switch6_out1_s12.addReceiver(hN,0);

        pirelab.getSwitchComp(hN,...
        [Constant6_out1_s4,Delay6_out1_s6],...
        Switch6_out1_s12,...
        LogicalOperator_out1_s7,'Switch6',...
        '~=',0,'Floor','Wrap');
    else
        hN.addOutputPort('ANEB');
        Switch1_out1_s10=addSignal(hN,'Switch1_out1',pirTyp1,slRate1);
        Switch1_out1_s10.addReceiver(hN,0);
        Switch2_out1_s11=addSignal(hN,'Switch2_out1',pirTyp1,slRate1);
        Constant1_out1_s3=addSignal(hN,'Constant1_out1',pirTyp1,slRate1);
        LogicalOperator3_out1_s9=addSignal(hN,sprintf('Logical\nOperator3_out1'),pirTyp1,slRate1);

        pirelab.getSwitchComp(hN,...
        [Constant6_out1_s4,Switch2_out1_s11],...
        Switch1_out1_s10,...
        LogicalOperator2_out1_s8,'Switch1',...
        '~=',0,'Floor','Wrap');

        pirelab.getSwitchComp(hN,...
        [Constant1_out1_s3,LogicalOperator3_out1_s9],...
        Switch2_out1_s11,...
        Delay1_out1_s5,'Switch2',...
        '~=',0,'Floor','Wrap');

        pirelab.getLogicComp(hN,...
        Delay6_out1_s6,...
        LogicalOperator3_out1_s9,...
        'not',sprintf('Logical\nOperator3'));


        pirelab.getConstComp(hN,...
        Constant1_out1_s3,...
        fi(0,nt1,fiMath1,'hex','1'),...
        'Constant1','on',0,'','','');
    end

    pirelab.getConstComp(hN,...
    Constant6_out1_s4,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant6','on',1,'','','');


    pirelab.getIntDelayComp(hN,...
    isNaN_s2,...
    Delay1_out1_s5,...
    pipestage(3),'Delay1',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    Val_s0,...
    Delay6_out1_s6,...
    pipestage(3),'Delay6',...
    false,...
    0,0,[],0,0);


    pirelab.getLogicComp(hN,...
    [LogicalOperator2_out1_s8,Delay1_out1_s5],...
    LogicalOperator_out1_s7,...
    'or',sprintf('Logical\nOperator'));


    pirelab.getLogicComp(hN,...
    Init_s1,...
    LogicalOperator2_out1_s8,...
    'not',sprintf('Logical\nOperator2'));

end

function hN=createNetwork_n4(~,hN,latency,slRate1)
    pirTyp1=pir_boolean_t;
    pirTyp3=pir_ufixpt_t(1,0);
    pirTyp2=pir_ufixpt_t(3,0);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt2=numerictype(0,1,0);
    nt1=numerictype(0,3,0);


    hN.addOutputPort('Out1');
    RelationalOperator_out1_s7=addSignal(hN,sprintf('Relational\nOperator_out1'),pirTyp1,slRate1);
    Add_out1_s0=addSignal(hN,'Add_out1',pirTyp2,slRate1);
    Constant7_out1_s1=addSignal(hN,'Constant7_out1',pirTyp2,slRate1);
    Constant8_out1_s2=addSignal(hN,'Constant8_out1',pirTyp3,slRate1);
    Delay12_out1_s3=addSignal(hN,'Delay12_out1',pirTyp2,slRate1);
    Delay13_out1_s4=addSignal(hN,'Delay13_out1',pirTyp1,slRate1);
    LogicalOperator_out1_s5=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp3,slRate1);
    LogicalOperator2_out1_s6=addSignal(hN,sprintf('Logical\nOperator2_out1'),pirTyp1,slRate1);

    pirelab.getConstComp(hN,...
    Constant8_out1_s2,...
    fi(0,nt2,fiMath1,'hex','1'),...
    'Constant8','on',0,'','','');

    if transformnfp.Delay1<1
        Constant8_out1_s2.addReceiver(hN,0);

    else

        RelationalOperator_out1_s7.addReceiver(hN,0);
        pirelab.getConstComp(hN,...
        Constant7_out1_s1,...
        fi(0,nt1,fiMath1,'hex',dec2hex(latency)),...
        'Constant7','on',0,'','','');


        pirelab.getIntDelayComp(hN,...
        Add_out1_s0,...
        Delay12_out1_s3,...
        transformnfp.Delay1,'Delay12',...
        fi(0,nt1,fiMath1,'hex','0'),...
        0,0,[],0,0);


        pirelab.getIntDelayComp(hN,...
        RelationalOperator_out1_s7,...
        Delay13_out1_s4,...
        transformnfp.Delay1,'Delay13',...
        false,...
        0,0,[],0,0);


        pirelab.getAddComp(hN,...
        [Delay12_out1_s3,LogicalOperator_out1_s5],...
        Add_out1_s0,...
        'Floor','Wrap','Add',pirTyp2,'++');


        pirelab.getLogicComp(hN,...
        [Constant8_out1_s2,LogicalOperator2_out1_s6],...
        LogicalOperator_out1_s5,...
        'and',sprintf('Logical\nOperator'));


        pirelab.getLogicComp(hN,...
        Delay13_out1_s4,...
        LogicalOperator2_out1_s6,...
        'not',sprintf('Logical\nOperator2'));


        pirelab.getRelOpComp(hN,...
        [Add_out1_s0,Constant7_out1_s1],...
        RelationalOperator_out1_s7,...
        '>',0,sprintf('Relational\nOperator'));

    end
end

function hN=createNetwork_n3(~,hN,pipestage,slRate1)
    pirTyp4=pir_boolean_t;
    pirTyp1=pir_ufixpt_t(1,0);
    pirTyp3=pir_ufixpt_t(23,0);
    pirTyp2=pir_unsigned_t(8);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,1,0);


    hN.addInputPort('AS');
    AS_s0=addSignal(hN,'AS',pirTyp1,slRate1);
    AS_s0.addDriver(hN,0);

    hN.addInputPort('BS');
    BS_s1=addSignal(hN,'BS',pirTyp1,slRate1);
    BS_s1.addDriver(hN,1);

    hN.addInputPort('AE');
    AE_s2=addSignal(hN,'AE',pirTyp2,slRate1);
    AE_s2.addDriver(hN,2);

    hN.addInputPort('AM');
    AM_s3=addSignal(hN,'AM',pirTyp3,slRate1);
    AM_s3.addDriver(hN,3);

    hN.addInputPort('BE');
    BE_s4=addSignal(hN,'BE',pirTyp2,slRate1);
    BE_s4.addDriver(hN,4);

    hN.addInputPort('BM');
    BM_s5=addSignal(hN,'BM',pirTyp3,slRate1);
    BM_s5.addDriver(hN,5);

    hN.addOutputPort('AGB');
    LogicalOperator4_out1_s17=addSignal(hN,sprintf('Logical\nOperator4_out1'),pirTyp4,slRate1);
    LogicalOperator4_out1_s17.addReceiver(hN,0);

    hN.addOutputPort('AEB');
    LogicalOperator6_out1_s19=addSignal(hN,sprintf('Logical\nOperator6_out1'),pirTyp4,slRate1);
    LogicalOperator6_out1_s19.addReceiver(hN,1);

    CompareToConstant_out1_s6=addSignal(hN,sprintf('Compare\nTo Constant_out1'),pirTyp4,slRate1);
    Delay1_out1_s7=addSignal(hN,'Delay1_out1',pirTyp4,slRate1);
    Delay2_out1_s8=addSignal(hN,'Delay2_out1',pirTyp4,slRate1);
    Delay3_out1_s9=addSignal(hN,'Delay3_out1',pirTyp4,slRate1);
    Delay4_out1_s10=addSignal(hN,'Delay4_out1',pirTyp4,slRate1);
    Delay5_out1_s11=addSignal(hN,'Delay5_out1',pirTyp4,slRate1);
    Delay6_out1_s12=addSignal(hN,'Delay6_out1',pirTyp4,slRate1);
    Delay7_out1_s13=addSignal(hN,'Delay7_out1',pirTyp4,slRate1);
    LogicalOperator1_out1_s14=addSignal(hN,sprintf('Logical\nOperator1_out1'),pirTyp4,slRate1);
    LogicalOperator2_out1_s15=addSignal(hN,sprintf('Logical\nOperator2_out1'),pirTyp4,slRate1);
    LogicalOperator3_out1_s16=addSignal(hN,sprintf('Logical\nOperator3_out1'),pirTyp4,slRate1);
    LogicalOperator5_out1_s18=addSignal(hN,sprintf('Logical\nOperator5_out1'),pirTyp4,slRate1);
    LogicalOperator7_out1_s20=addSignal(hN,sprintf('Logical\nOperator7_out1'),pirTyp4,slRate1);
    RelationalOperator1_out1_s21=addSignal(hN,sprintf('Relational\nOperator1_out1'),pirTyp4,slRate1);
    RelationalOperator2_out1_s22=addSignal(hN,sprintf('Relational\nOperator2_out1'),pirTyp4,slRate1);
    RelationalOperator3_out1_s23=addSignal(hN,sprintf('Relational\nOperator3_out1'),pirTyp4,slRate1);
    RelationalOperator4_out1_s24=addSignal(hN,sprintf('Relational\nOperator4_out1'),pirTyp4,slRate1);
    RelationalOperator5_out1_s25=addSignal(hN,sprintf('Relational\nOperator5_out1'),pirTyp4,slRate1);
    RelationalOperator6_out1_s26=addSignal(hN,sprintf('Relational\nOperator6_out1'),pirTyp4,slRate1);
    Switch_out1_s27=addSignal(hN,'Switch_out1',pirTyp4,slRate1);


    pirelab.getIntDelayComp(hN,...
    RelationalOperator3_out1_s23,...
    Delay1_out1_s7,...
    pipestage(2),'Delay1',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    CompareToConstant_out1_s6,...
    Delay2_out1_s8,...
    pipestage(2),'Delay2',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    RelationalOperator2_out1_s22,...
    Delay3_out1_s9,...
    pipestage(2),'Delay3',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    RelationalOperator1_out1_s21,...
    Delay4_out1_s10,...
    pipestage(2),'Delay4',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    RelationalOperator4_out1_s24,...
    Delay5_out1_s11,...
    pipestage(2),'Delay5',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    RelationalOperator5_out1_s25,...
    Delay6_out1_s12,...
    pipestage(2),'Delay6',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    RelationalOperator6_out1_s26,...
    Delay7_out1_s13,...
    pipestage(2),'Delay7',...
    false,...
    0,0,[],0,0);


    pirelab.getCompareToValueComp(hN,...
    BS_s1,...
    CompareToConstant_out1_s6,...
    '==',fi(0,nt1,fiMath1,'hex','1'),...
    sprintf('Compare\nTo Constant'),0);


    pirelab.getLogicComp(hN,...
    [Delay5_out1_s11,Delay1_out1_s7],...
    LogicalOperator1_out1_s14,...
    'and',sprintf('Logical\nOperator1'));


    pirelab.getLogicComp(hN,...
    [Delay4_out1_s10,LogicalOperator1_out1_s14],...
    LogicalOperator2_out1_s15,...
    'or',sprintf('Logical\nOperator2'));


    pirelab.getLogicComp(hN,...
    [Delay2_out1_s8,Delay3_out1_s9],...
    LogicalOperator3_out1_s16,...
    'and',sprintf('Logical\nOperator3'));


    pirelab.getLogicComp(hN,...
    [Delay6_out1_s12,Switch_out1_s27],...
    LogicalOperator4_out1_s17,...
    'or',sprintf('Logical\nOperator4'));


    pirelab.getLogicComp(hN,...
    LogicalOperator7_out1_s20,...
    LogicalOperator5_out1_s18,...
    'not',sprintf('Logical\nOperator5'));


    pirelab.getLogicComp(hN,...
    [Delay3_out1_s9,Delay5_out1_s11,Delay7_out1_s13],...
    LogicalOperator6_out1_s19,...
    'and',sprintf('Logical\nOperator6'));


    pirelab.getLogicComp(hN,...
    [Delay3_out1_s9,LogicalOperator2_out1_s15],...
    LogicalOperator7_out1_s20,...
    'and',sprintf('Logical\nOperator7'));


    pirelab.getRelOpComp(hN,...
    [AE_s2,BE_s4],...
    RelationalOperator1_out1_s21,...
    '>',0,sprintf('Relational\nOperator1'));


    pirelab.getRelOpComp(hN,...
    [AS_s0,BS_s1],...
    RelationalOperator2_out1_s22,...
    '==',0,sprintf('Relational\nOperator2'));


    pirelab.getRelOpComp(hN,...
    [AM_s3,BM_s5],...
    RelationalOperator3_out1_s23,...
    '>',0,sprintf('Relational\nOperator3'));


    pirelab.getRelOpComp(hN,...
    [AE_s2,BE_s4],...
    RelationalOperator4_out1_s24,...
    '==',0,sprintf('Relational\nOperator4'));


    pirelab.getRelOpComp(hN,...
    [AS_s0,BS_s1],...
    RelationalOperator5_out1_s25,...
    '<',0,sprintf('Relational\nOperator5'));


    pirelab.getRelOpComp(hN,...
    [AM_s3,BM_s5],...
    RelationalOperator6_out1_s26,...
    '==',0,sprintf('Relational\nOperator6'));


    pirelab.getSwitchComp(hN,...
    [LogicalOperator5_out1_s18,LogicalOperator7_out1_s20],...
    Switch_out1_s27,...
    LogicalOperator3_out1_s16,'Switch',...
    '>',0,'Floor','Wrap');


end

function hN=createNetwork_n2(~,hN,pipestage,slRate1)
    pirTyp3=pir_boolean_t;
    pirTyp2=pir_ufixpt_t(23,0);
    pirTyp1=pir_unsigned_t(8);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt2=numerictype(0,23,0);
    nt1=numerictype(0,8,0);


    hN.addInputPort('AE');
    AE_s0=addSignal(hN,'AE',pirTyp1,slRate1);
    AE_s0.addDriver(hN,0);

    hN.addInputPort('AM');
    AM_s1=addSignal(hN,'AM',pirTyp2,slRate1);
    AM_s1.addDriver(hN,1);

    hN.addInputPort('BE');
    BE_s2=addSignal(hN,'BE',pirTyp1,slRate1);
    BE_s2.addDriver(hN,2);

    hN.addInputPort('BM');
    BM_s3=addSignal(hN,'BM',pirTyp2,slRate1);
    BM_s3.addDriver(hN,3);

    hN.addOutputPort('AIsZero');
    LogicalOperator_out1_s13=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp3,slRate1);
    LogicalOperator_out1_s13.addReceiver(hN,0);

    hN.addOutputPort('AIsNaN');
    LogicalOperator3_out1_s16=addSignal(hN,sprintf('Logical\nOperator3_out1'),pirTyp3,slRate1);
    LogicalOperator3_out1_s16.addReceiver(hN,1);

    Constant_out1_s4=addSignal(hN,'Constant_out1',pirTyp1,slRate1);
    Constant1_out1_s5=addSignal(hN,'Constant1_out1',pirTyp2,slRate1);
    Constant2_out1_s6=addSignal(hN,'Constant2_out1',pirTyp1,slRate1);
    Delay1_out1_s7=addSignal(hN,'Delay1_out1',pirTyp3,slRate1);
    Delay2_out1_s8=addSignal(hN,'Delay2_out1',pirTyp3,slRate1);
    Delay3_out1_s9=addSignal(hN,'Delay3_out1',pirTyp3,slRate1);
    Delay4_out1_s10=addSignal(hN,'Delay4_out1',pirTyp3,slRate1);
    Delay5_out1_s11=addSignal(hN,'Delay5_out1',pirTyp3,slRate1);
    Delay6_out1_s12=addSignal(hN,'Delay6_out1',pirTyp3,slRate1);
    LogicalOperator1_out1_s14=addSignal(hN,sprintf('Logical\nOperator1_out1'),pirTyp3,slRate1);
    LogicalOperator2_out1_s15=addSignal(hN,sprintf('Logical\nOperator2_out1'),pirTyp3,slRate1);
    LogicalOperator4_out1_s17=addSignal(hN,sprintf('Logical\nOperator4_out1'),pirTyp3,slRate1);
    LogicalOperator5_out1_s18=addSignal(hN,sprintf('Logical\nOperator5_out1'),pirTyp3,slRate1);
    RelationalOperator1_out1_s19=addSignal(hN,sprintf('Relational\nOperator1_out1'),pirTyp3,slRate1);
    RelationalOperator2_out1_s20=addSignal(hN,sprintf('Relational\nOperator2_out1'),pirTyp3,slRate1);
    RelationalOperator3_out1_s21=addSignal(hN,sprintf('Relational\nOperator3_out1'),pirTyp3,slRate1);
    RelationalOperator4_out1_s22=addSignal(hN,sprintf('Relational\nOperator4_out1'),pirTyp3,slRate1);
    RelationalOperator5_out1_s23=addSignal(hN,sprintf('Relational\nOperator5_out1'),pirTyp3,slRate1);
    RelationalOperator6_out1_s24=addSignal(hN,sprintf('Relational\nOperator6_out1'),pirTyp3,slRate1);


    pirelab.getConstComp(hN,...
    Constant_out1_s4,...
    fi(0,nt1,fiMath1,'hex','00'),...
    'Constant','on',1,'','','');


    pirelab.getConstComp(hN,...
    Constant1_out1_s5,...
    fi(0,nt2,fiMath1,'hex','000000'),...
    'Constant1','on',1,'','','');


    pirelab.getConstComp(hN,...
    Constant2_out1_s6,...
    fi(0,nt1,fiMath1,'hex','ff'),...
    'Constant2','on',0,'','','');


    pirelab.getIntDelayComp(hN,...
    RelationalOperator3_out1_s21,...
    Delay1_out1_s7,...
    pipestage(2),'Delay1',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    RelationalOperator2_out1_s20,...
    Delay2_out1_s8,...
    pipestage(2),'Delay2',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    RelationalOperator4_out1_s22,...
    Delay3_out1_s9,...
    pipestage(2),'Delay3',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    RelationalOperator1_out1_s19,...
    Delay4_out1_s10,...
    pipestage(2),'Delay4',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    RelationalOperator5_out1_s23,...
    Delay5_out1_s11,...
    pipestage(2),'Delay5',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    RelationalOperator6_out1_s24,...
    Delay6_out1_s12,...
    pipestage(2),'Delay6',...
    false,...
    0,0,[],0,0);


    pirelab.getLogicComp(hN,...
    [Delay2_out1_s8,Delay1_out1_s7,Delay4_out1_s10,Delay3_out1_s9],...
    LogicalOperator_out1_s13,...
    'and',sprintf('Logical\nOperator'));


    pirelab.getLogicComp(hN,...
    [Delay5_out1_s11,LogicalOperator4_out1_s17],...
    LogicalOperator1_out1_s14,...
    'and',sprintf('Logical\nOperator1'));


    pirelab.getLogicComp(hN,...
    [Delay6_out1_s12,LogicalOperator5_out1_s18],...
    LogicalOperator2_out1_s15,...
    'and',sprintf('Logical\nOperator2'));


    pirelab.getLogicComp(hN,...
    [LogicalOperator1_out1_s14,LogicalOperator2_out1_s15],...
    LogicalOperator3_out1_s16,...
    'or',sprintf('Logical\nOperator3'));


    pirelab.getLogicComp(hN,...
    Delay3_out1_s9,...
    LogicalOperator4_out1_s17,...
    'not',sprintf('Logical\nOperator4'));


    pirelab.getLogicComp(hN,...
    Delay2_out1_s8,...
    LogicalOperator5_out1_s18,...
    'not',sprintf('Logical\nOperator5'));


    pirelab.getRelOpComp(hN,...
    [Constant_out1_s4,AE_s0],...
    RelationalOperator1_out1_s19,...
    '==',0,sprintf('Relational\nOperator1'));


    pirelab.getRelOpComp(hN,...
    [Constant1_out1_s5,BM_s3],...
    RelationalOperator2_out1_s20,...
    '==',0,sprintf('Relational\nOperator2'));


    pirelab.getRelOpComp(hN,...
    [Constant_out1_s4,BE_s2],...
    RelationalOperator3_out1_s21,...
    '==',0,sprintf('Relational\nOperator3'));


    pirelab.getRelOpComp(hN,...
    [Constant1_out1_s5,AM_s1],...
    RelationalOperator4_out1_s22,...
    '==',0,sprintf('Relational\nOperator4'));


    pirelab.getRelOpComp(hN,...
    [AE_s0,Constant2_out1_s6],...
    RelationalOperator5_out1_s23,...
    '==',0,sprintf('Relational\nOperator5'));


    pirelab.getRelOpComp(hN,...
    [BE_s2,Constant2_out1_s6],...
    RelationalOperator6_out1_s24,...
    '==',0,sprintf('Relational\nOperator6'));


end

function hN=createNetwork_n1(p,hN,opName,pipestage,slRate1)
    pirTyp4=pir_boolean_t;
    pirTyp1=pir_ufixpt_t(1,0);
    pirTyp3=pir_ufixpt_t(23,0);
    pirTyp2=pir_unsigned_t(8);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,1,0);
    nt2=numerictype(0,23,0);


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



    switch opName
    case '=='
        outName='AEB';
    case '~='
        outName='ANEB';
    case '<'
        outName='ALB';
    case '<='
        outName='ALEB';
    case '>'
        outName='AGB';
    case '>='
        outName='AGEB';
    end
    hN.addOutputPort(outName);
    outSig=addSignal(hN,outName,pirTyp1,slRate1);
    outSig.addReceiver(hN,0);


    CheckZeroNaN_out1_s6=addSignal(hN,'CheckZeroNaN_out1',pirTyp4,slRate1);
    CheckZeroNaN_out2_s7=addSignal(hN,'CheckZeroNaN_out2',pirTyp4,slRate1);
    Delay_out1_s8=addSignal(hN,'Delay_out1',pirTyp1,slRate1);
    Delay1_out1_s9=addSignal(hN,'Delay1_out1',pirTyp1,slRate1);
    Delay2_out1_s10=addSignal(hN,'Delay2_out1',pirTyp2,slRate1);
    Delay3_out1_s11=addSignal(hN,'Delay3_out1',pirTyp3,slRate1);
    Delay4_out1_s12=addSignal(hN,'Delay4_out1',pirTyp2,slRate1);
    Delay5_out1_s13=addSignal(hN,'Delay5_out1',pirTyp3,slRate1);
    Greater_Or_Equal_out1_s14=addSignal(hN,'Greater_Or_Equal_out1',pirTyp4,slRate1);
    Greater_Or_Equal_out2_s15=addSignal(hN,'Greater_Or_Equal_out2',pirTyp4,slRate1);
    InitialSequenceLogic_out1_s16=addSignal(hN,'InitialSequenceLogic_out1',pirTyp4,slRate1);
    LogicalOperator4_out1_s17=addSignal(hN,sprintf('Logical\nOperator4_out1'),pirTyp4,slRate1);

    hRefN=p.findNetwork('fullname','Relops_Single/NFP_MathWorks_Relops_Single/CheckZeroNaN');
    CheckZeroNaN=hN.addComponent('ntwk_instance_comp',hRefN);
    CheckZeroNaN.Name='CheckZeroNaN';
    pirelab.connectNtwkInstComp(CheckZeroNaN,...
    [Delay2_out1_s10,Delay3_out1_s11,Delay4_out1_s12,Delay5_out1_s13],...
    [CheckZeroNaN_out1_s6,CheckZeroNaN_out2_s7]);

    hRefN=p.findNetwork('fullname','Relops_Single/NFP_MathWorks_Relops_Single/Greater_Or_Equal');
    Greater_Or_Equal=hN.addComponent('ntwk_instance_comp',hRefN);
    Greater_Or_Equal.Name='Greater_Or_Equal';
    pirelab.connectNtwkInstComp(Greater_Or_Equal,...
    [Delay_out1_s8,Delay1_out1_s9,Delay2_out1_s10,Delay3_out1_s11,Delay4_out1_s12,Delay5_out1_s13],...
    [Greater_Or_Equal_out1_s14,Greater_Or_Equal_out2_s15]);

    hRefN=p.findNetwork('fullname','Relops_Single/NFP_MathWorks_Relops_Single/InitialSequenceLogic');
    InitialSequenceLogic=hN.addComponent('ntwk_instance_comp',hRefN);
    InitialSequenceLogic.Name='InitialSequenceLogic';
    pirelab.connectNtwkInstComp(InitialSequenceLogic,...
    [],...
    InitialSequenceLogic_out1_s16);

    switch opName
    case{'==','~='}
        hRefN=p.findNetwork('fullname','Relops_Single/NFP_MathWorks_Relops_Single/SSAEB');
        SSAEB=hN.addComponent('ntwk_instance_comp',hRefN);
        SSAEB.Name='SSAEB';
        pirelab.connectNtwkInstComp(SSAEB,...
        [LogicalOperator4_out1_s17,InitialSequenceLogic_out1_s16,CheckZeroNaN_out2_s7],...
        outSig);
    case{'<','>='}
        hRefN=p.findNetwork('fullname','Relops_Single/NFP_MathWorks_Relops_Single/SSAGB');
        SSAGB=hN.addComponent('ntwk_instance_comp',hRefN);
        SSAGB.Name='SSAGB';
        pirelab.connectNtwkInstComp(SSAGB,...
        [LogicalOperator4_out1_s17,InitialSequenceLogic_out1_s16,Greater_Or_Equal_out1_s14,CheckZeroNaN_out2_s7],...
        outSig);
    case{'>','<='}
        hRefN=p.findNetwork('fullname','Relops_Single/NFP_MathWorks_Relops_Single/SSALB');
        SSALB=hN.addComponent('ntwk_instance_comp',hRefN);
        SSALB.Name='SSALB';
        pirelab.connectNtwkInstComp(SSALB,...
        [LogicalOperator4_out1_s17,InitialSequenceLogic_out1_s16,Greater_Or_Equal_out1_s14,CheckZeroNaN_out2_s7],...
        outSig);
    end

    pirelab.getIntDelayComp(hN,...
    AS_s0,...
    Delay_out1_s8,...
    pipestage(1),'Delay',...
    fi(0,nt1,fiMath1,'hex','0'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    BS_s3,...
    Delay1_out1_s9,...
    pipestage(1),'Delay1',...
    fi(0,nt1,fiMath1,'hex','0'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    AE_s1,...
    Delay2_out1_s10,...
    pipestage(1),'Delay2',...
    uint8(0),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    AM_s2,...
    Delay3_out1_s11,...
    pipestage(1),'Delay3',...
    fi(0,nt2,fiMath1,'hex','000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    BE_s4,...
    Delay4_out1_s12,...
    pipestage(1),'Delay4',...
    uint8(0),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    BM_s5,...
    Delay5_out1_s13,...
    pipestage(1),'Delay5',...
    fi(0,nt2,fiMath1,'hex','000000'),...
    0,0,[],0,0);


    pirelab.getLogicComp(hN,...
    [CheckZeroNaN_out1_s6,Greater_Or_Equal_out2_s15],...
    LogicalOperator4_out1_s17,...
    'or',sprintf('Logical\nOperator4'));


end

function hN=createNetwork_n0(p,hN,opName,slRate1)
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



    switch opName
    case '=='
        outName='AEB';
    case '~='
        outName='ANEB';
    case '<'
        outName='ALB';
    case '<='
        outName='ALEB';
    case '>'
        outName='AGB';
    case '>='
        outName='AGEB';
    end
    hN.addOutputPort(outName);
    outSig=addSignal(hN,outName,pirTyp1,slRate1);
    outSig.addReceiver(hN,0);


    hRefN=p.findNetwork('fullname','Relops_Single/NFP_MathWorks_Relops_Single');
    NFP_MathWorks_Relops_Single=hN.addComponent('ntwk_instance_comp',hRefN);
    NFP_MathWorks_Relops_Single.Name='NFP_MathWorks_Relops_Single';
    pirelab.connectNtwkInstComp(NFP_MathWorks_Relops_Single,...
    [AS_s0,AE_s1,AM_s2,BS_s3,BE_s4,BM_s5],...
    outSig);


end

function hS=addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end
