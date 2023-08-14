function hN=createSingle27x27FullMulComp(~,hN,slRate1)

    pirTyp1=pir_ufixpt_t(27,0);
    pirTyp2=pir_ufixpt_t(54,0);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,27,0);
    nt2=numerictype(0,54,0);



    hN.addInputPort('In1');
    In1_s0=addSignal(hN,'In1',pirTyp1,slRate1);
    In1_s0.addDriver(hN,0);

    hN.addInputPort('In2');
    In2_s1=addSignal(hN,'In2',pirTyp1,slRate1);
    In2_s1.addDriver(hN,1);

    hN.addOutputPort('Out1');
    Delay8_out1_s4=addSignal(hN,'Delay8_out1',pirTyp2,slRate1);
    Delay8_out1_s4.addReceiver(hN,0);

    Delay23_out1_s2=addSignal(hN,'Delay23_out1',pirTyp1,slRate1);
    Delay4_out1_s3=addSignal(hN,'Delay4_out1',pirTyp1,slRate1);
    Product1_out1_s5=addSignal(hN,'Product1_out1',pirTyp2,slRate1);


    pirelab.getIntDelayComp(hN,...
    In2_s1,...
    Delay23_out1_s2,...
    transformnfp.Delay1,'Delay23',...
    fi(0,nt1,fiMath1,'hex','0000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    In1_s0,...
    Delay4_out1_s3,...
    transformnfp.Delay1,'Delay4',...
    fi(0,nt1,fiMath1,'hex','0000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    Product1_out1_s5,...
    Delay8_out1_s4,...
    transformnfp.Delay2,'Delay8',...
    fi(0,nt2,fiMath1,'hex','00000000000000'),...
    0,0,[],0,0);


    pirelab.getMulComp(hN,...
    [Delay23_out1_s2,Delay4_out1_s3],...
    Product1_out1_s5,...
    'Floor','Wrap','Product1','**','',-1,0);


end


function hS=addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end
