




function hN=create24x24MulComp_FullMultiplier(~,hN,Pipeline1,Pipeline2,slRate1)
    pirTyp1=pir_ufixpt_t(24,0);
    pirTyp2=pir_ufixpt_t(48,0);

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,24,0);
    nt2=numerictype(0,48,0);




    hN.addInputPort('a');
    a_s0=addSignal(hN,'a',pirTyp1,slRate1);
    a_s0.addDriver(hN,0);

    hN.addInputPort('b');
    b_s1=addSignal(hN,'b',pirTyp1,slRate1);
    b_s1.addDriver(hN,1);

    hN.addOutputPort('c');
    Delay_out1_s2=addSignal(hN,'Delay_out1',pirTyp2,slRate1);
    Delay_out1_s2.addReceiver(hN,0);

    Delay1_out1_s3=addSignal(hN,'Delay1_out1',pirTyp1,slRate1);
    Delay2_out1_s4=addSignal(hN,'Delay2_out1',pirTyp1,slRate1);
    Product_out1_s7=addSignal(hN,'Product_out1',pirTyp2,slRate1);


    pirelab.getIntDelayComp(hN,...
    b_s1,...
    Delay1_out1_s3,...
    Pipeline1,'Delay1',...
    fi(0,nt1,fiMath1,'hex','000000'),...
    0,0,[],0,0);


    pirelab.getIntDelayComp(hN,...
    a_s0,...
    Delay2_out1_s4,...
    Pipeline1,'Delay2',...
    fi(0,nt1,fiMath1,'hex','000000'),...
    0,0,[],0,0);



    pirelab.getIntDelayComp(hN,...
    Product_out1_s7,...
    Delay_out1_s2,...
    Pipeline2,'Delay',...
    fi(0,nt2,fiMath1,'hex','000000000000'),...
    0,0,[],0,0);


    pirelab.getMulComp(hN,...
    [Delay2_out1_s4,Delay1_out1_s3],...
    Product_out1_s7,...
    'Floor','Wrap','Product','**','',-1,0);


end

function hS=addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=simulinkRate;
end
