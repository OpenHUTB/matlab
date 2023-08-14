function hTopN=getHalfUminusComp(hN,slRate)
    p=pir(hN.getCtxName);
    hTopN=addNetworks(p);
    createNetworks(p,slRate);
end


function hTopN=addNetworks(p)
    hN=p.addNetwork;
    hN.Name='NEG';
    hN.FullPath='NEG_single/NEG';
    hTopN=hN;
end

function createNetworks(p,slRate)
    hN_n0=p.findNetwork('fullname','NEG_single/NEG');
    createNetwork_n0(p,hN_n0,slRate);
end

function hN=createNetwork_n0(~,hN,slRate1)
    pirTyp1=pir_ufixpt_t(1,0);
    pirTyp3=pir_ufixpt_t(10,0);
    pirTyp2=pir_ufixpt_t(5,0);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,1,0);


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
    Switch_out1_s5=addSignal(hN,'Switch_out1',pirTyp1,slRate1);
    Switch_out1_s5.addReceiver(hN,0);

    hN.addOutputPort('-XE');
    XE_s1.addReceiver(hN,1);

    hN.addOutputPort('-XM');
    XM_s2.addReceiver(hN,2);

    Constant_out1_s3=addSignal(hN,'Constant_out1',pirTyp1,slRate1);
    Constant1_out1_s4=addSignal(hN,'Constant1_out1',pirTyp1,slRate1);


    pirelab.getConstComp(hN,...
    Constant_out1_s3,...
    fi(0,nt1,fiMath1),...
    'Constant','on',1,'','','');


    pirelab.getConstComp(hN,...
    Constant1_out1_s4,...
    fi(1,nt1,fiMath1),...
    'Constant1','on',0,'','','');


    pirelab.getSwitchComp(hN,...
    [Constant_out1_s3,Constant1_out1_s4],...
    Switch_out1_s5,...
    XS_s0,'Switch',...
    '~=',0,'Floor','Wrap');


end

function hS=addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end


