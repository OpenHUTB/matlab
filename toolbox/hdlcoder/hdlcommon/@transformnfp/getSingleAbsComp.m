function hTopN=getSingleAbsComp(hN,slRate)
    p=pir(hN.getCtxName);
    hTopN=addNetworks(p);
    createNetworks(p,slRate);
end

function hTopN=addNetworks(p)
    hN=p.addNetwork;
    hN.Name='ABS_Single';
    hN.FullPath='ABS_Single';
    hTopN=hN;
end

function createNetworks(p,slRate)
    hN_n0=p.findNetwork('fullname','ABS_Single');
    createNetwork_n0(p,hN_n0,slRate);
end

function hN=createNetwork_n0(~,hN,slRate1)
    pirTyp1=pir_ufixpt_t(1,0);
    pirTyp4=pir_ufixpt_t(1,0);
    pirTyp3=pir_ufixpt_t(23,0);
    pirTyp2=pir_ufixpt_t(8,0);

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

    hN.addOutputPort('ABS_S');
    Constant_out1_s3=addSignal(hN,'Constant_out1',pirTyp4,slRate1);
    Constant_out1_s3.addReceiver(hN,0);

    hN.addOutputPort('ABS_E');
    XE_s1.addReceiver(hN,1);

    hN.addOutputPort('ABS_M');
    XM_s2.addReceiver(hN,2);



    pirelab.getConstComp(hN,...
    Constant_out1_s3,...
    fi(0,nt1,fiMath1,'hex','0'),...
    'Constant','on',1,'','','');

    pirelab.getAnnotationComp(hN,...
    'Terminator');


end

function hS=addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end

