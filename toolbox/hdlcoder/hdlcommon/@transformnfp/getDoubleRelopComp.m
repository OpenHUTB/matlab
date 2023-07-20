


function hTopN=getDoubleRelopComp(hOrigN,opName,latency,slRate)



    p=pir(hOrigN.getCtxName);
    hTopN=addNetworks(p,opName);
    pipestage=zeros(1,3);
    switch latency
    case 0
        pipestage=zeros(1,3);
    case 1
        pipestage=[1,0,0];
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
    hN.Name='Double_Relational_Operator';
    hN.FullPath='Double_Relational_Operator';
    hTopN=hN;
    hN=p.addNetwork;
    hN.Name='Relational_Operator';
    hN.FullPath='Double_Relational_Operator/Relational_Operator';
    hN=p.addNetwork;
    hN.Name='CheckZeroNaN';
    hN.FullPath='Double_Relational_Operator/Relational_Operator/CheckZeroNaN';
    hN=p.addNetwork;
    hN.Name='Greater_Or_Equal';
    hN.FullPath='Double_Relational_Operator/Relational_Operator/Greater_Or_Equal';
    hN=p.addNetwork;
    hN.Name='InitialSequenceLogic';
    hN.FullPath='Double_Relational_Operator/Relational_Operator/InitialSequenceLogic';

    switch opName
    case{'==','~='}
        hN=p.addNetwork;
        hN.Name='SSAEB';
        hN.FullPath='Double_Relational_Operator/Relational_Operator/SSAEB';
    case{'<','>='}
        hN=p.addNetwork;
        hN.Name='SSAGB';
        hN.FullPath='Double_Relational_Operator/Relational_Operator/SSAGB';
    case{'>','<='}
        hN=p.addNetwork;
        hN.Name='SSALB';
        hN.FullPath='Double_Relational_Operator/Relational_Operator/SSALB';
    end

end

function createNetworks(p,opName,pipestage,latency,slRate)

    switch opName
    case{'>','<='}
        hN_n7=p.findNetwork('fullname','Double_Relational_Operator/Relational_Operator/SSALB');
        createNetwork_n7(p,hN_n7,opName,pipestage,slRate);
    case{'<','>='}
        hN_n6=p.findNetwork('fullname','Double_Relational_Operator/Relational_Operator/SSAGB');
        createNetwork_n6(p,hN_n6,opName,pipestage,slRate);
    case{'==','~='}
        hN_n5=p.findNetwork('fullname','Double_Relational_Operator/Relational_Operator/SSAEB');
        createNetwork_n5(p,hN_n5,opName,pipestage,slRate);
    end

    hN_n4=p.findNetwork('fullname','Double_Relational_Operator/Relational_Operator/InitialSequenceLogic');
    createNetwork_n4(p,hN_n4,latency,slRate);
    hN_n3=p.findNetwork('fullname','Double_Relational_Operator/Relational_Operator/Greater_Or_Equal');
    createNetwork_n3(p,hN_n3,pipestage,slRate);
    hN_n2=p.findNetwork('fullname','Double_Relational_Operator/Relational_Operator/CheckZeroNaN');
    createNetwork_n2(p,hN_n2,pipestage,slRate);
    hN_n1=p.findNetwork('fullname','Double_Relational_Operator/Relational_Operator');
    createNetwork_n1(p,hN_n1,opName,pipestage,slRate);
    hN_n0=p.findNetwork('fullname','Double_Relational_Operator');
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



    Constant_out1_s4=addSignal(hN,'Constant_out1',pirTyp1,slRate1);
    Delay1_PS_3_out1_s5=addSignal(hN,'Delay1_PS_3_out1',pirTyp1,slRate1);
    Delay2_PS_3_out1_s6=addSignal(hN,'Delay2_PS_3_out1',pirTyp1,slRate1);
    Delay_PS_3_out1_s7=addSignal(hN,'Delay_PS_3_out1',pirTyp1,slRate1);
    LogicalOperator_out1_s8=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate1);
    LogicalOperator1_out1_s9=addSignal(hN,sprintf('Logical\nOperator1_out1'),pirTyp1,slRate1);
    LogicalOperator2_out1_s10=addSignal(hN,sprintf('Logical\nOperator2_out1'),pirTyp1,slRate1);
    LogicalOperator3_out1_s11=addSignal(hN,sprintf('Logical\nOperator3_out1'),pirTyp1,slRate1);

    if strcmpi(opName,'>')
        hN.addOutputPort('AGB');
        Switch1_out1_s14=addSignal(hN,'Switch1_out1',pirTyp1,slRate1);
        Switch1_out1_s14.addReceiver(hN,0);

        pirelab.getSwitchComp(hN,...
        [Constant_out1_s4,LogicalOperator3_out1_s11],...
        Switch1_out1_s14,...
        LogicalOperator1_out1_s9,'Switch1',...
        '~=',0,'Floor','Wrap');
    else
        hN.addOutputPort('ALEB');
        Switch_out1_s13=addSignal(hN,'Switch_out1',pirTyp1,slRate1);
        Switch_out1_s13.addReceiver(hN,0);
        LogicalOperator4_out1_s12=addSignal(hN,sprintf('Logical\nOperator4_out1'),pirTyp1,slRate1);

        pirelab.getLogicComp(hN,...
        LogicalOperator3_out1_s11,...
        LogicalOperator4_out1_s12,...
        'not',sprintf('Logical\nOperator4'));

        pirelab.getSwitchComp(hN,...
        [Constant_out1_s4,LogicalOperator4_out1_s12],...
        Switch_out1_s13,...
        LogicalOperator1_out1_s9,'Switch',...
        '~=',0,'Floor','Wrap');
    end


    pirelab.getConstComp(hN,...
    Constant_out1_s4,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant','on',1,'','','');


    pirelab.getIntDelayComp(hN,...
    AGBI_s2,...
    Delay1_PS_3_out1_s5,...
    pipestage(3),'Delay1_PS_3',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    isNaN_s3,...
    Delay2_PS_3_out1_s6,...
    pipestage(3),'Delay2_PS_3',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    AEBI_s0,...
    Delay_PS_3_out1_s7,...
    pipestage(3),'Delay_PS_3',...
    false,...
    0,0,[],0,0);


    pirelab.getLogicComp(hN,...
    Init_s1,...
    LogicalOperator_out1_s8,...
    'not',sprintf('Logical\nOperator'));


    pirelab.getLogicComp(hN,...
    [LogicalOperator_out1_s8,Delay2_PS_3_out1_s6],...
    LogicalOperator1_out1_s9,...
    'or',sprintf('Logical\nOperator1'));


    pirelab.getLogicComp(hN,...
    Delay_PS_3_out1_s7,...
    LogicalOperator2_out1_s10,...
    'not',sprintf('Logical\nOperator2'));


    pirelab.getLogicComp(hN,...
    [LogicalOperator2_out1_s10,Delay1_PS_3_out1_s5],...
    LogicalOperator3_out1_s11,...
    'and',sprintf('Logical\nOperator3'));



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



    Constant_out1_s4=addSignal(hN,'Constant_out1',pirTyp1,slRate1);
    Delay1_PS_3_out1_s5=addSignal(hN,'Delay1_PS_3_out1',pirTyp1,slRate1);
    Delay2_PS_3_out1_s6=addSignal(hN,'Delay2_PS_3_out1',pirTyp1,slRate1);
    Delay_PS_3_out1_s7=addSignal(hN,'Delay_PS_3_out1',pirTyp1,slRate1);
    LogicalOperator_out1_s8=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate1);
    LogicalOperator1_out1_s9=addSignal(hN,sprintf('Logical\nOperator1_out1'),pirTyp1,slRate1);
    LogicalOperator2_out1_s10=addSignal(hN,sprintf('Logical\nOperator2_out1'),pirTyp1,slRate1);

    if strcmpi(opName,'<')
        hN.addOutputPort('ALB');
        Switch1_out1_s13=addSignal(hN,'Switch1_out1',pirTyp1,slRate1);
        Switch1_out1_s13.addReceiver(hN,0);
        LogicalOperator3_out1_s11=addSignal(hN,sprintf('Logical\nOperator3_out1'),pirTyp1,slRate1);

        pirelab.getSwitchComp(hN,...
        [Constant_out1_s4,LogicalOperator3_out1_s11],...
        Switch1_out1_s13,...
        LogicalOperator1_out1_s9,'Switch1',...
        '~=',0,'Floor','Wrap');

        pirelab.getLogicComp(hN,...
        LogicalOperator2_out1_s10,...
        LogicalOperator3_out1_s11,...
        'not',sprintf('Logical\nOperator3'));

    else
        hN.addOutputPort('AGEB');
        Switch_out1_s12=addSignal(hN,'Switch_out1',pirTyp1,slRate1);
        Switch_out1_s12.addReceiver(hN,0);

        pirelab.getSwitchComp(hN,...
        [Constant_out1_s4,LogicalOperator2_out1_s10],...
        Switch_out1_s12,...
        LogicalOperator1_out1_s9,'Switch',...
        '~=',0,'Floor','Wrap');
    end


    pirelab.getConstComp(hN,...
    Constant_out1_s4,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant','on',1,'','','');


    pirelab.getIntDelayComp(hN,...
    AGB_s2,...
    Delay1_PS_3_out1_s5,...
    pipestage(3),'Delay1_PS_3',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    isNaN_s3,...
    Delay2_PS_3_out1_s6,...
    pipestage(3),'Delay2_PS_3',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    AEB_s0,...
    Delay_PS_3_out1_s7,...
    pipestage(3),'Delay_PS_3',...
    false,...
    0,0,[],0,0);


    pirelab.getLogicComp(hN,...
    Init_s1,...
    LogicalOperator_out1_s8,...
    'not',sprintf('Logical\nOperator'));


    pirelab.getLogicComp(hN,...
    [LogicalOperator_out1_s8,Delay2_PS_3_out1_s6],...
    LogicalOperator1_out1_s9,...
    'or',sprintf('Logical\nOperator1'));


    pirelab.getLogicComp(hN,...
    [Delay_PS_3_out1_s7,Delay1_PS_3_out1_s5],...
    LogicalOperator2_out1_s10,...
    'or',sprintf('Logical\nOperator2'));


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



    Constant_out1_s3=addSignal(hN,'Constant_out1',pirTyp1,slRate1);
    Delay1_PS_3_out1_s5=addSignal(hN,'Delay1_PS_3_out1',pirTyp1,slRate1);
    Delay_PS_3_out1_s6=addSignal(hN,'Delay_PS_3_out1',pirTyp1,slRate1);
    LogicalOperator_out1_s7=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate1);
    LogicalOperator1_out1_s8=addSignal(hN,sprintf('Logical\nOperator1_out1'),pirTyp1,slRate1);

    if strcmpi(opName,'==')
        hN.addOutputPort('AEB');
        Switch_out1_s10=addSignal(hN,'Switch_out1',pirTyp1,slRate1);
        Switch_out1_s10.addReceiver(hN,0);

        pirelab.getSwitchComp(hN,...
        [Constant_out1_s3,Delay_PS_3_out1_s6],...
        Switch_out1_s10,...
        LogicalOperator_out1_s7,'Switch',...
        '~=',0,'Floor','Wrap');
    else
        hN.addOutputPort('ANEB');
        Switch1_out1_s11=addSignal(hN,'Switch1_out1',pirTyp1,slRate1);
        Switch1_out1_s11.addReceiver(hN,0);
        Switch2_out1_s12=addSignal(hN,'Switch2_out1',pirTyp1,slRate1);
        Constant1_out1_s4=addSignal(hN,'Constant1_out1',pirTyp1,slRate1);
        LogicalOperator2_out1_s9=addSignal(hN,sprintf('Logical\nOperator2_out1'),pirTyp1,slRate1);

        pirelab.getSwitchComp(hN,...
        [Constant_out1_s3,Switch2_out1_s12],...
        Switch1_out1_s11,...
        LogicalOperator1_out1_s8,'Switch1',...
        '~=',0,'Floor','Wrap');


        pirelab.getSwitchComp(hN,...
        [Constant1_out1_s4,LogicalOperator2_out1_s9],...
        Switch2_out1_s12,...
        Delay1_PS_3_out1_s5,'Switch2',...
        '~=',0,'Floor','Wrap');

        pirelab.getLogicComp(hN,...
        Delay_PS_3_out1_s6,...
        LogicalOperator2_out1_s9,...
        'not',sprintf('Logical\nOperator2'));

        pirelab.getConstComp(hN,...
        Constant1_out1_s4,...
        fi(0,nt1,fiMath1,'hex','1'),...
        'Constant1','on',0,'','','');

    end

    pirelab.getConstComp(hN,...
    Constant_out1_s3,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant','on',1,'','','');


    pirelab.getIntDelayComp(hN,...
    isNaN_s2,...
    Delay1_PS_3_out1_s5,...
    pipestage(3),'Delay1_PS_3',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    Val_s0,...
    Delay_PS_3_out1_s6,...
    pipestage(3),'Delay_PS_3',...
    false,...
    0,0,[],0,0);


    pirelab.getLogicComp(hN,...
    [LogicalOperator1_out1_s8,Delay1_PS_3_out1_s5],...
    LogicalOperator_out1_s7,...
    'or',sprintf('Logical\nOperator'));


    pirelab.getLogicComp(hN,...
    Init_s1,...
    LogicalOperator1_out1_s8,...
    'not',sprintf('Logical\nOperator1'));

end

function hN=createNetwork_n4(~,hN,latency,slRate1)

    pirTyp1=pir_boolean_t;
    pirTyp3=pir_ufixpt_t(1,0);
    pirTyp4=pir_ufixpt_t(9,0);
    pirTyp2=pir_unsigned_t(8);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,3,0);

    hN.addOutputPort('Init');
    RelationalOperator_out1_s7=addSignal(hN,sprintf('Relational\nOperator_out1'),pirTyp1,slRate1);

    Add_out1_s0=addSignal(hN,'Add_out1',pirTyp2,slRate1);
    Constant_out1_s1=addSignal(hN,'Constant_out1',pirTyp3,slRate1);
    Constant1_out1_s2=addSignal(hN,'Constant1_out1',pirTyp2,slRate1);
    Delay_out1_s3=addSignal(hN,'Delay_out1',pirTyp2,slRate1);
    Delay1_out1_s4=addSignal(hN,'Delay1_out1',pirTyp1,slRate1);
    LogicalOperator_out1_s5=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate1);
    LogicalOperator1_out1_s6=addSignal(hN,sprintf('Logical\nOperator1_out1'),pirTyp1,slRate1);

    pirelab.getConstComp(hN,...
    Constant_out1_s1,...
    fi(0,nt1,fiMath1,'hex','1'),...
    'Constant','on',0,'','','');

    if transformnfp.Delay1<1

        Constant_out1_s1.addReceiver(hN,0);

    else

        RelationalOperator_out1_s7.addReceiver(hN,0);

        pirelab.getConstComp(hN,...
        Constant1_out1_s2,...
        fi(0,nt1,fiMath1,'hex',dec2hex(latency)),...
        'Constant1','on',0,'','','');

        pirelab.getIntDelayComp(hN,...
        Add_out1_s0,...
        Delay_out1_s3,...
        1,'Delay',...
        uint8(0),...
        0,0,[],0,0);

        pirelab.getIntDelayComp(hN,...
        RelationalOperator_out1_s7,...
        Delay1_out1_s4,...
        1,'Delay1',...
        false,...
        0,0,[],0,0);

        pirelab.getAddComp(hN,...
        [Delay_out1_s3,LogicalOperator_out1_s5],...
        Add_out1_s0,...
        'Floor','Wrap','Add',pirTyp4,'++');

        pirelab.getLogicComp(hN,...
        [Constant_out1_s1,LogicalOperator1_out1_s6],...
        LogicalOperator_out1_s5,...
        'and',sprintf('Logical\nOperator'));

        pirelab.getLogicComp(hN,...
        Delay1_out1_s4,...
        LogicalOperator1_out1_s6,...
        'not',sprintf('Logical\nOperator1'));

        pirelab.getRelOpComp(hN,...
        [Add_out1_s0,Constant1_out1_s2],...
        RelationalOperator_out1_s7,...
        '>',0,sprintf('Relational\nOperator'));

    end
end

function hN=createNetwork_n3(~,hN,pipestage,slRate1)

    pirTyp4=pir_boolean_t;
    pirTyp1=pir_ufixpt_t(1,0);
    pirTyp2=pir_ufixpt_t(11,0);
    pirTyp3=pir_ufixpt_t(52,0);

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
    Delay_PS_2_out1_s8=addSignal(hN,'Delay_PS_2_out1',pirTyp4,slRate1);
    Delay_PS_2_out1_s8.addReceiver(hN,0);

    hN.addOutputPort('AEB');
    Delay1_PS_2_out1_s7=addSignal(hN,'Delay1_PS_2_out1',pirTyp4,slRate1);
    Delay1_PS_2_out1_s7.addReceiver(hN,1);

    CompareToConstant_out1_s6=addSignal(hN,sprintf('Compare\nTo Constant_out1'),pirTyp4,slRate1);
    LogicalOperator_out1_s9=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp4,slRate1);
    LogicalOperator1_out1_s10=addSignal(hN,sprintf('Logical\nOperator1_out1'),pirTyp4,slRate1);
    LogicalOperator2_out1_s11=addSignal(hN,sprintf('Logical\nOperator2_out1'),pirTyp4,slRate1);
    LogicalOperator3_out1_s12=addSignal(hN,sprintf('Logical\nOperator3_out1'),pirTyp4,slRate1);
    LogicalOperator4_out1_s13=addSignal(hN,sprintf('Logical\nOperator4_out1'),pirTyp4,slRate1);
    LogicalOperator5_out1_s14=addSignal(hN,sprintf('Logical\nOperator5_out1'),pirTyp4,slRate1);
    LogicalOperator6_out1_s15=addSignal(hN,sprintf('Logical\nOperator6_out1'),pirTyp4,slRate1);
    RelationalOperator_out1_s16=addSignal(hN,sprintf('Relational\nOperator_out1'),pirTyp4,slRate1);
    RelationalOperator1_out1_s17=addSignal(hN,sprintf('Relational\nOperator1_out1'),pirTyp4,slRate1);
    RelationalOperator2_out1_s18=addSignal(hN,sprintf('Relational\nOperator2_out1'),pirTyp4,slRate1);
    RelationalOperator3_out1_s19=addSignal(hN,sprintf('Relational\nOperator3_out1'),pirTyp4,slRate1);
    RelationalOperator4_out1_s20=addSignal(hN,sprintf('Relational\nOperator4_out1'),pirTyp4,slRate1);
    RelationalOperator5_out1_s21=addSignal(hN,sprintf('Relational\nOperator5_out1'),pirTyp4,slRate1);
    Switch_out1_s22=addSignal(hN,'Switch_out1',pirTyp4,slRate1);


    pirelab.getIntDelayComp(hN,...
    LogicalOperator6_out1_s15,...
    Delay1_PS_2_out1_s7,...
    pipestage(2),'Delay1_PS_2',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    LogicalOperator_out1_s9,...
    Delay_PS_2_out1_s8,...
    pipestage(2),'Delay_PS_2',...
    false,...
    0,0,[],0,0);


    pirelab.getCompareToValueComp(hN,...
    BS_s1,...
    CompareToConstant_out1_s6,...
    '==',fi(0,nt1,fiMath1,'hex','1'),...
    sprintf('Compare\nTo Constant'),0);


    pirelab.getLogicComp(hN,...
    [RelationalOperator_out1_s16,Switch_out1_s22],...
    LogicalOperator_out1_s9,...
    'or',sprintf('Logical\nOperator'));


    pirelab.getLogicComp(hN,...
    [CompareToConstant_out1_s6,RelationalOperator1_out1_s17],...
    LogicalOperator1_out1_s10,...
    'and',sprintf('Logical\nOperator1'));


    pirelab.getLogicComp(hN,...
    [RelationalOperator2_out1_s18,LogicalOperator3_out1_s12],...
    LogicalOperator2_out1_s11,...
    'or',sprintf('Logical\nOperator2'));


    pirelab.getLogicComp(hN,...
    [RelationalOperator3_out1_s19,RelationalOperator4_out1_s20],...
    LogicalOperator3_out1_s12,...
    'and',sprintf('Logical\nOperator3'));


    pirelab.getLogicComp(hN,...
    [RelationalOperator1_out1_s17,LogicalOperator2_out1_s11],...
    LogicalOperator4_out1_s13,...
    'and',sprintf('Logical\nOperator4'));


    pirelab.getLogicComp(hN,...
    LogicalOperator4_out1_s13,...
    LogicalOperator5_out1_s14,...
    'not',sprintf('Logical\nOperator5'));


    pirelab.getLogicComp(hN,...
    [RelationalOperator1_out1_s17,RelationalOperator3_out1_s19,RelationalOperator5_out1_s21],...
    LogicalOperator6_out1_s15,...
    'and',sprintf('Logical\nOperator6'));


    pirelab.getRelOpComp(hN,...
    [AS_s0,BS_s1],...
    RelationalOperator_out1_s16,...
    '<',0,sprintf('Relational\nOperator'));


    pirelab.getRelOpComp(hN,...
    [AS_s0,BS_s1],...
    RelationalOperator1_out1_s17,...
    '==',0,sprintf('Relational\nOperator1'));


    pirelab.getRelOpComp(hN,...
    [AE_s2,BE_s4],...
    RelationalOperator2_out1_s18,...
    '>',0,sprintf('Relational\nOperator2'));


    pirelab.getRelOpComp(hN,...
    [AE_s2,BE_s4],...
    RelationalOperator3_out1_s19,...
    '==',0,sprintf('Relational\nOperator3'));


    pirelab.getRelOpComp(hN,...
    [AM_s3,BM_s5],...
    RelationalOperator4_out1_s20,...
    '>',0,sprintf('Relational\nOperator4'));


    pirelab.getRelOpComp(hN,...
    [AM_s3,BM_s5],...
    RelationalOperator5_out1_s21,...
    '==',0,sprintf('Relational\nOperator5'));


    pirelab.getSwitchComp(hN,...
    [LogicalOperator5_out1_s14,LogicalOperator4_out1_s13],...
    Switch_out1_s22,...
    LogicalOperator1_out1_s10,'Switch',...
    '~=',0,'Floor','Wrap');


end

function hN=createNetwork_n2(~,hN,pipestage,slRate1)

    pirTyp3=pir_boolean_t;
    pirTyp1=pir_ufixpt_t(11,0);
    pirTyp2=pir_ufixpt_t(52,0);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,11,0);

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
    Delay_PS_2_out1_s11=addSignal(hN,'Delay_PS_2_out1',pirTyp3,slRate1);
    Delay_PS_2_out1_s11.addReceiver(hN,0);

    hN.addOutputPort('AIsNaN');
    Delay1_PS_2_out1_s10=addSignal(hN,'Delay1_PS_2_out1',pirTyp3,slRate1);
    Delay1_PS_2_out1_s10.addReceiver(hN,1);

    CompareToConstant_out1_s4=addSignal(hN,sprintf('Compare\nTo Constant_out1'),pirTyp3,slRate1);
    CompareToConstant1_out1_s5=addSignal(hN,sprintf('Compare\nTo Constant1_out1'),pirTyp3,slRate1);
    CompareToZero_out1_s6=addSignal(hN,sprintf('Compare\nTo Zero_out1'),pirTyp3,slRate1);
    CompareToZero1_out1_s7=addSignal(hN,sprintf('Compare\nTo Zero1_out1'),pirTyp3,slRate1);
    CompareToZero2_out1_s8=addSignal(hN,sprintf('Compare\nTo Zero2_out1'),pirTyp3,slRate1);
    CompareToZero3_out1_s9=addSignal(hN,sprintf('Compare\nTo Zero3_out1'),pirTyp3,slRate1);
    LogicalOperator_out1_s12=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp3,slRate1);
    LogicalOperator1_out1_s13=addSignal(hN,sprintf('Logical\nOperator1_out1'),pirTyp3,slRate1);
    LogicalOperator2_out1_s14=addSignal(hN,sprintf('Logical\nOperator2_out1'),pirTyp3,slRate1);
    LogicalOperator3_out1_s15=addSignal(hN,sprintf('Logical\nOperator3_out1'),pirTyp3,slRate1);
    LogicalOperator4_out1_s16=addSignal(hN,sprintf('Logical\nOperator4_out1'),pirTyp3,slRate1);
    LogicalOperator5_out1_s17=addSignal(hN,sprintf('Logical\nOperator5_out1'),pirTyp3,slRate1);


    pirelab.getIntDelayComp(hN,...
    LogicalOperator5_out1_s17,...
    Delay1_PS_2_out1_s10,...
    pipestage(2),'Delay1_PS_2',...
    false,...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    LogicalOperator_out1_s12,...
    Delay_PS_2_out1_s11,...
    pipestage(2),'Delay_PS_2',...
    false,...
    0,0,[],0,0);


    pirelab.getCompareToValueComp(hN,...
    AE_s0,...
    CompareToConstant_out1_s4,...
    '==',fi(0,nt1,fiMath1,'hex','7ff'),...
    sprintf('Compare\nTo Constant'),0);


    pirelab.getCompareToValueComp(hN,...
    BE_s2,...
    CompareToConstant1_out1_s5,...
    '==',fi(0,nt1,fiMath1,'hex','7ff'),...
    sprintf('Compare\nTo Constant1'),0);


    pirelab.getCompareToValueComp(hN,...
    AE_s0,...
    CompareToZero_out1_s6,...
    '==',double(0),...
    sprintf('Compare\nTo Zero'),0);


    pirelab.getCompareToValueComp(hN,...
    BE_s2,...
    CompareToZero1_out1_s7,...
    '==',double(0),...
    sprintf('Compare\nTo Zero1'),0);


    pirelab.getCompareToValueComp(hN,...
    AM_s1,...
    CompareToZero2_out1_s8,...
    '==',double(0),...
    sprintf('Compare\nTo Zero2'),0);


    pirelab.getCompareToValueComp(hN,...
    BM_s3,...
    CompareToZero3_out1_s9,...
    '==',double(0),...
    sprintf('Compare\nTo Zero3'),0);


    pirelab.getLogicComp(hN,...
    [CompareToZero_out1_s6,CompareToZero1_out1_s7,CompareToZero2_out1_s8,CompareToZero3_out1_s9],...
    LogicalOperator_out1_s12,...
    'and',sprintf('Logical\nOperator'));


    pirelab.getLogicComp(hN,...
    CompareToZero2_out1_s8,...
    LogicalOperator1_out1_s13,...
    'not',sprintf('Logical\nOperator1'));


    pirelab.getLogicComp(hN,...
    [LogicalOperator1_out1_s13,CompareToConstant_out1_s4],...
    LogicalOperator2_out1_s14,...
    'and',sprintf('Logical\nOperator2'));


    pirelab.getLogicComp(hN,...
    [LogicalOperator4_out1_s16,CompareToConstant1_out1_s5],...
    LogicalOperator3_out1_s15,...
    'and',sprintf('Logical\nOperator3'));


    pirelab.getLogicComp(hN,...
    CompareToZero3_out1_s9,...
    LogicalOperator4_out1_s16,...
    'not',sprintf('Logical\nOperator4'));


    pirelab.getLogicComp(hN,...
    [LogicalOperator2_out1_s14,LogicalOperator3_out1_s15],...
    LogicalOperator5_out1_s17,...
    'or',sprintf('Logical\nOperator5'));


end

function hN=createNetwork_n1(p,hN,opName,pipestage,slRate1)

    pirTyp4=pir_boolean_t;
    pirTyp1=pir_ufixpt_t(1,0);
    pirTyp2=pir_ufixpt_t(11,0);
    pirTyp3=pir_ufixpt_t(52,0);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt2=numerictype(0,1,0);
    nt3=numerictype(0,11,0);
    nt1=numerictype(0,52,0);

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
    Delay1_PS_1_out1_s8=addSignal(hN,'Delay1_PS_1_out1',pirTyp3,slRate1);
    Delay2_PS_1_out1_s9=addSignal(hN,'Delay2_PS_1_out1',pirTyp1,slRate1);
    Delay3_PS_1_out1_s10=addSignal(hN,'Delay3_PS_1_out1',pirTyp1,slRate1);
    Delay4_PS_1_out1_s11=addSignal(hN,'Delay4_PS_1_out1',pirTyp2,slRate1);
    Delay5_PS_1_out1_s12=addSignal(hN,'Delay5_PS_1_out1',pirTyp3,slRate1);
    Delay_PS_1_out1_s13=addSignal(hN,'Delay_PS_1_out1',pirTyp2,slRate1);
    Greater_Or_Equal_out1_s14=addSignal(hN,'Greater_Or_Equal_out1',pirTyp4,slRate1);
    Greater_Or_Equal_out2_s15=addSignal(hN,'Greater_Or_Equal_out2',pirTyp4,slRate1);
    InitialSequenceLogic_out1_s16=addSignal(hN,'InitialSequenceLogic_out1',pirTyp4,slRate1);
    LogicalOperator_out1_s17=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp4,slRate1);

    hRefN=p.findNetwork('fullname','Double_Relational_Operator/Relational_Operator/CheckZeroNaN');
    CheckZeroNaN=hN.addComponent('ntwk_instance_comp',hRefN);
    CheckZeroNaN.Name='CheckZeroNaN';
    pirelab.connectNtwkInstComp(CheckZeroNaN,...
    [Delay_PS_1_out1_s13,Delay1_PS_1_out1_s8,Delay4_PS_1_out1_s11,Delay5_PS_1_out1_s12],...
    [CheckZeroNaN_out1_s6,CheckZeroNaN_out2_s7]);

    hRefN=p.findNetwork('fullname','Double_Relational_Operator/Relational_Operator/Greater_Or_Equal');
    Greater_Or_Equal=hN.addComponent('ntwk_instance_comp',hRefN);
    Greater_Or_Equal.Name='Greater_Or_Equal';
    pirelab.connectNtwkInstComp(Greater_Or_Equal,...
    [Delay2_PS_1_out1_s9,Delay3_PS_1_out1_s10,Delay_PS_1_out1_s13,Delay1_PS_1_out1_s8,Delay4_PS_1_out1_s11,Delay5_PS_1_out1_s12],...
    [Greater_Or_Equal_out1_s14,Greater_Or_Equal_out2_s15]);

    hRefN=p.findNetwork('fullname','Double_Relational_Operator/Relational_Operator/InitialSequenceLogic');
    InitialSequenceLogic=hN.addComponent('ntwk_instance_comp',hRefN);
    InitialSequenceLogic.Name='InitialSequenceLogic';
    pirelab.connectNtwkInstComp(InitialSequenceLogic,...
    [],...
    InitialSequenceLogic_out1_s16);

    switch opName
    case{'==','~='}
        hRefN=p.findNetwork('fullname','Double_Relational_Operator/Relational_Operator/SSAEB');
        SSAEB=hN.addComponent('ntwk_instance_comp',hRefN);
        SSAEB.Name='SSAEB';
        pirelab.connectNtwkInstComp(SSAEB,...
        [LogicalOperator_out1_s17,InitialSequenceLogic_out1_s16,CheckZeroNaN_out2_s7],...
        outSig);
    case{'<','>='}
        hRefN=p.findNetwork('fullname','Double_Relational_Operator/Relational_Operator/SSAGB');
        SSAGB=hN.addComponent('ntwk_instance_comp',hRefN);
        SSAGB.Name='SSAGB';
        pirelab.connectNtwkInstComp(SSAGB,...
        [LogicalOperator_out1_s17,InitialSequenceLogic_out1_s16,Greater_Or_Equal_out1_s14,CheckZeroNaN_out2_s7],...
        outSig);
    case{'>','<='}
        hRefN=p.findNetwork('fullname','Double_Relational_Operator/Relational_Operator/SSALB');
        SSALB=hN.addComponent('ntwk_instance_comp',hRefN);
        SSALB.Name='SSALB';
        pirelab.connectNtwkInstComp(SSALB,...
        [LogicalOperator_out1_s17,InitialSequenceLogic_out1_s16,Greater_Or_Equal_out1_s14,CheckZeroNaN_out2_s7],...
        outSig);
    end


    pirelab.getIntDelayComp(hN,...
    AM_s2,...
    Delay1_PS_1_out1_s8,...
    pipestage(1),'Delay1_PS_1',...
    fi(0,nt1,fiMath1,'hex','0000000000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    AS_s0,...
    Delay2_PS_1_out1_s9,...
    pipestage(1),'Delay2_PS_1',...
    fi(0,nt2,fiMath1,'hex','0'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    BS_s3,...
    Delay3_PS_1_out1_s10,...
    pipestage(1),'Delay3_PS_1',...
    fi(0,nt2,fiMath1,'hex','0'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    BE_s4,...
    Delay4_PS_1_out1_s11,...
    pipestage(1),'Delay4_PS_1',...
    fi(0,nt3,fiMath1,'hex','000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    BM_s5,...
    Delay5_PS_1_out1_s12,...
    pipestage(1),'Delay5_PS_1',...
    fi(0,nt1,fiMath1,'hex','0000000000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    AE_s1,...
    Delay_PS_1_out1_s13,...
    pipestage(1),'Delay_PS_1',...
    fi(0,nt3,fiMath1,'hex','000'),...
    0,0,[],0,0);


    pirelab.getLogicComp(hN,...
    [CheckZeroNaN_out1_s6,Greater_Or_Equal_out2_s15],...
    LogicalOperator_out1_s17,...
    'or',sprintf('Logical\nOperator'));

end

function hN=createNetwork_n0(p,hN,opName,slRate1)
    pirTyp1=pir_ufixpt_t(1,0);
    pirTyp3=pir_ufixpt_t(52,0);
    pirTyp2=pir_ufixpt_t(11,0);

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

    hRefN=p.findNetwork('fullname','Double_Relational_Operator/Relational_Operator');
    Relational_Operator=hN.addComponent('ntwk_instance_comp',hRefN);
    Relational_Operator.Name='Relational_Operator';
    pirelab.connectNtwkInstComp(Relational_Operator,...
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


