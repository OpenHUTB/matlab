function hTopN=getSingleSignumComp(hN,slRate)
    p=pir(hN.getCtxName);
    hTopN=addNetworks(p);
    createNetworks(p,slRate);
end

function hTopN=addNetworks(p)
    hN=p.addNetwork;
    hN.Name='Sign';
    hN.FullPath='Sign';
    hTopN=hN;
end

function createNetworks(p,slRate)
    hN_n0=p.findNetwork('fullname','Sign');
    createNetwork_n0(p,hN_n0,slRate);
end

function hN=createNetwork_n0(~,hN,slRate1)
    pirTyp1=pir_ufixpt_t(1,0);
    pirTyp3=pir_ufixpt_t(23,0);
    pirTyp2=pir_ufixpt_t(8,0);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt2=numerictype(0,1,0);
    nt3=numerictype(0,23,0);
    nt1=numerictype(0,8,0);

    hN.addInputPort('X_S');
    X_S_s0=addSignal(hN,'X_S',pirTyp1,slRate1);
    X_S_s0.addDriver(hN,0);

    hN.addInputPort('X_E');
    X_E_s1=addSignal(hN,'X_E',pirTyp2,slRate1);
    X_E_s1.addDriver(hN,1);

    hN.addInputPort('X_M');
    X_M_s2=addSignal(hN,'X_M',pirTyp3,slRate1);
    X_M_s2.addDriver(hN,2);

    hN.addOutputPort('Y_S');
    Switch1_out1_s11=addSignal(hN,'Switch1_out1',pirTyp1,slRate1);
    Switch1_out1_s11.addReceiver(hN,0);

    hN.addOutputPort('Y_E');
    Switch2_out1_s15=addSignal(hN,'Switch2_out1',pirTyp2,slRate1);
    Switch2_out1_s15.addReceiver(hN,1);

    hN.addOutputPort('Y_M');
    Switch3_out1_s16=addSignal(hN,'Switch3_out1',pirTyp3,slRate1);
    Switch3_out1_s16.addReceiver(hN,2);

    CompareToZero_out1_s3=addSignal(hN,sprintf('Compare\nTo Zero_out1'),pirTyp1,slRate1);
    CompareToZero1_out1_s4=addSignal(hN,sprintf('Compare\nTo Zero1_out1'),pirTyp1,slRate1);
    Constant_out1_s5=addSignal(hN,'Constant_out1',pirTyp2,slRate1);
    Constant1_out1_s6=addSignal(hN,'Constant1_out1',pirTyp2,slRate1);
    Constant2_out1_s7=addSignal(hN,'Constant2_out1',pirTyp1,slRate1);
    Constant3_out1_s8=addSignal(hN,'Constant3_out1',pirTyp3,slRate1);
    LogicalOperator_out1_s9=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate1);
    Switch_out1_s10=addSignal(hN,'Switch_out1',pirTyp2,slRate1);

    CompareToConstant_out1_s12=addSignal(hN,sprintf('Compare\nTo Constant_out1'),pirTyp1,slRate1);
    LogicalOperator_out1_s13=addSignal(hN,sprintf('Logical\nOperator1_out1'),pirTyp1,slRate1);
    LogicalOperator_out1_s14=addSignal(hN,sprintf('Logical\nOperator2_out1'),pirTyp1,slRate1);


    pirelab.getConstComp(hN,...
    Constant_out1_s5,...
    fi(0,nt1,fiMath1,'hex','7f'),...
    'Constant','on',0,'','','');


    pirelab.getConstComp(hN,...
    Constant1_out1_s6,...
    fi(0,nt1,fiMath1,'hex','00'),...
    'Constant1','on',1,'','','');


    pirelab.getConstComp(hN,...
    Constant2_out1_s7,...
    fi(0,nt2,fiMath1,'hex','0'),...
    'Constant2','on',1,'','','');


    pirelab.getConstComp(hN,...
    Constant3_out1_s8,...
    fi(0,nt3,fiMath1,'hex','000000'),...
    'Constant3','on',1,'','','');


    pirelab.getCompareToValueComp(hN,...
    X_M_s2,...
    CompareToZero_out1_s3,...
    '==',double(0),...
    sprintf('Compare\nTo Zero'),0);


    pirelab.getCompareToValueComp(hN,...
    X_E_s1,...
    CompareToZero1_out1_s4,...
    '==',double(0),...
    sprintf('Compare\nTo Zero1'),0);


    pirelab.getLogicComp(hN,...
    [CompareToZero1_out1_s4,CompareToZero_out1_s3],...
    LogicalOperator_out1_s9,...
    'and',sprintf('Logical\nOperator'));


    pirelab.getSwitchComp(hN,...
    [Constant1_out1_s6,Constant_out1_s5],...
    Switch_out1_s10,...
    LogicalOperator_out1_s9,'Switch',...
    '~=',0,'Floor','Wrap');


    pirelab.getSwitchComp(hN,...
    [Constant2_out1_s7,X_S_s0],...
    Switch1_out1_s11,...
    LogicalOperator_out1_s9,'Switch1',...
    '~=',0,'Floor','Wrap');



    pirelab.getBitReduceComp(hN,...
    X_E_s1,...
    CompareToConstant_out1_s12,...
    'and',...
    sprintf('Compare\nTo Constant'));


    pirelab.getLogicComp(hN,...
    CompareToZero_out1_s3,...
    LogicalOperator_out1_s13,...
    'not',sprintf('Logical\nOperator1'));


    pirelab.getLogicComp(hN,...
    [CompareToConstant_out1_s12,LogicalOperator_out1_s13],...
    LogicalOperator_out1_s14,...
    'and',sprintf('Logical\nOperator2'));


    pirelab.getSwitchComp(hN,...
    [X_E_s1,Switch_out1_s10],...
    Switch2_out1_s15,...
    LogicalOperator_out1_s14,'Switch2',...
    '~=',0,'Floor','Wrap');


    pirelab.getSwitchComp(hN,...
    [X_M_s2,Constant3_out1_s8],...
    Switch3_out1_s16,...
    LogicalOperator_out1_s14,'Switch2',...
    '~=',0,'Floor','Wrap');



end

function hS=addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end