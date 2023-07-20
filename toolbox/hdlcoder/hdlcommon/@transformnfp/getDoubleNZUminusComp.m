function hTopN=getDoubleNZUminusComp(hN,uniqNtwkName,slRate)



    p=pir(hN.getCtxName);
    hTopN=addNetworks(p,uniqNtwkName);
    createNetworks(p,uniqNtwkName,slRate);
end

function hTopN=addNetworks(p,ntwkName)
    hN=p.addNetwork;
    hN.Name=ntwkName;
    hN.FullPath=ntwkName;
    hTopN=hN;
end

function createNetworks(p,ntwkName,slRate)
    hN_n0=p.findNetwork('fullname',ntwkName);
    createNetwork_n0(p,hN_n0,slRate);
end

function hN=createNetwork_n0(~,hN,slRate1)
    pirTyp1=pir_ufixpt_t(1,0);
    pirTyp3=pir_ufixpt_t(52,0);
    pirTyp2=pir_ufixpt_t(11,0);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt3=numerictype(0,1,0);
    nt2=numerictype(0,52,0);
    nt1=numerictype(0,11,0);


    hN.addInputPort('XS');
    XS_s0=addSignal(hN,'XS',pirTyp1,slRate1);
    XS_s0.addDriver(hN,0);

    hN.addInputPort('XE');
    XE_s1=addSignal(hN,'XE',pirTyp2,slRate1);
    XE_s1.addDriver(hN,1);

    hN.addInputPort('XM');
    XM_s2=addSignal(hN,'XM',pirTyp3,slRate1);
    XM_s2.addDriver(hN,2);

    hN.addOutputPort('-XS');
    Switch_out1_s7=addSignal(hN,'Switch_out1',pirTyp1,slRate1);
    Switch_out1_s7.addReceiver(hN,0);

    hN.addOutputPort('-XE');
    XE_s1.addReceiver(hN,1);

    hN.addOutputPort('-XM');
    XM_s2.addReceiver(hN,2);

    EqE1_out1_s3=addSignal(hN,'EqE1_out1',pirTyp1,slRate1);
    EqM_out1_s4=addSignal(hN,'EqM_out1',pirTyp1,slRate1);
    Inv_out1_s5=addSignal(hN,'Inv_out1',pirTyp1,slRate1);
    LogicalOperator_out1_s6=addSignal(hN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate1);
    Zero_out1_s8=addSignal(hN,'Zero_out1',pirTyp2,slRate1);
    Zero0_out1_s9=addSignal(hN,'Zero0_out1',pirTyp3,slRate1);
    Zero1_out1_s10=addSignal(hN,'Zero1_out1',pirTyp1,slRate1);


    pirelab.getConstComp(hN,...
    Zero_out1_s8,...
    fi(0,nt1,fiMath1),...
    'Zero','on',1,'','','');


    pirelab.getConstComp(hN,...
    Zero0_out1_s9,...
    fi(0,nt2,fiMath1),...
    'Zero0','on',1,'','','');


    pirelab.getConstComp(hN,...
    Zero1_out1_s10,...
    fi(0,nt3,fiMath1),...
    'Zero1','on',1,'','','');


    pirelab.getRelOpComp(hN,...
    [Zero_out1_s8,XE_s1],...
    EqE1_out1_s3,...
    '==',0,'EqE1');


    pirelab.getRelOpComp(hN,...
    [Zero0_out1_s9,XM_s2],...
    EqM_out1_s4,...
    '==',0,'EqM');


    pirelab.getLogicComp(hN,...
    XS_s0,...
    Inv_out1_s5,...
    'not','Inv');


    pirelab.getLogicComp(hN,...
    [EqE1_out1_s3,EqM_out1_s4],...
    LogicalOperator_out1_s6,...
    'and',sprintf('Logical\nOperator'));


    pirelab.getSwitchComp(hN,...
    [Zero1_out1_s10,Inv_out1_s5],...
    Switch_out1_s7,...
    LogicalOperator_out1_s6,'Switch',...
    '~=',0,'Floor','Wrap');


end

function hS=addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end


