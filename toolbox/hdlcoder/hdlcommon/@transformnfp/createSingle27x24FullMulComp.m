function hN=createSingle27x24FullMulComp(~,hN,slRate1)
    pirTyp2=pir_ufixpt_t(24,0);
    pirTyp1=pir_ufixpt_t(27,0);
    pirTyp3=pir_ufixpt_t(51,0);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,24,0);
    nt3=numerictype(0,27,0);
    nt2=numerictype(0,51,0);

    hN.addInputPort('In1');
    In1_s0=addSignal(hN,'In1',pirTyp1,slRate1);
    In1_s0.addDriver(hN,0);

    hN.addInputPort('In2');
    In2_s1=addSignal(hN,'In2',pirTyp2,slRate1);
    In2_s1.addDriver(hN,1);

    hN.addOutputPort('Out1');
    Delay3_out1_s3=addSignal(hN,'Delay3_out1',pirTyp3,slRate1);
    Delay3_out1_s3.addReceiver(hN,0);

    Delay1_out1_s2=addSignal(hN,'Delay1_out1',pirTyp2,slRate1);
    Delay5_out1_s4=addSignal(hN,'Delay5_out1',pirTyp1,slRate1);
    z0_out1_s5=addSignal(hN,'z0_out1',pirTyp3,slRate1);


    pirelab.getIntDelayComp(hN,...
    In2_s1,...
    Delay1_out1_s2,...
    transformnfp.Delay1,'Delay1',...
    fi(0,nt1,fiMath1,'hex','000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    z0_out1_s5,...
    Delay3_out1_s3,...
    transformnfp.Delay1,'Delay3',...
    fi(0,nt2,fiMath1,'hex','0000000000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    In1_s0,...
    Delay5_out1_s4,...
    transformnfp.Delay1,'Delay5',...
    fi(0,nt3,fiMath1,'hex','0000000'),...
    0,0,[],0,0);


    pirelab.getMulComp(hN,...
    [Delay5_out1_s4,Delay1_out1_s2],...
    z0_out1_s5,...
    'Floor','Wrap','z0','**','',-1,0);


end

function hS=addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end
