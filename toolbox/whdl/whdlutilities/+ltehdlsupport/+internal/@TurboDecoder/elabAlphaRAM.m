function alphaRAMNet=elabAlphaRAM(~,topNet,blockInfo,dataRate)





    boolType=pir_boolean_t();
    smetType=blockInfo.smetType;
    smetVType8=pirelab.getPirVectorType(smetType,8);
    extrinaddrType=pir_ufixpt_t(log2(2*blockInfo.winSize),0);




    inportNames={'data','w_addr','w_en','r_addr'};
    inTypes=[smetVType8,extrinaddrType,boolType,extrinaddrType];
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'alphaRAMOut'};

    outTypes=smetVType8;

    alphaRAMNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','AlphaRAM',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    dataIn=alphaRAMNet.PirInputSignals(1);
    w_addr=alphaRAMNet.PirInputSignals(2);
    w_en=alphaRAMNet.PirInputSignals(3);
    r_addr=alphaRAMNet.PirInputSignals(4);

    alphaRAMOut=alphaRAMNet.PirOutputSignals(1);



    dataInsplit=dataIn.split;



    for i=1:8
        ramout(i)=alphaRAMNet.addSignal(smetType,['ramout',num2str(i-1)]);
        ramout_delay(i)=alphaRAMNet.addSignal(smetType,['ramout_delay',num2str(i-1)]);
        pirelab.getSimpleDualPortRamComp(alphaRAMNet,...
        [dataInsplit.PirOutputSignals(i),w_addr,w_en,r_addr],...
        ramout(i),['alphaRAM_bank',num2str(i)]);
        pirelab.getUnitDelayComp(alphaRAMNet,ramout(i),ramout_delay(i));


    end

    pirelab.getMuxComp(alphaRAMNet,ramout_delay,alphaRAMOut);




