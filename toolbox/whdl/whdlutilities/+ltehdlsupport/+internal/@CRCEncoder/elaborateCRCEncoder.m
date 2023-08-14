function elaborateCRCEncoder(this,topNet,blockInfo,insignals,outsignals)







    ufix1Type=pir_ufixpt_t(1,0);



    datain_top=insignals(1);
    startin_top=insignals(2);
    endin_top=insignals(3);
    validin_top=insignals(4);
    inRate=datain_top.SimulinkRate;


    dataOutff=outsignals(1);
    startOutff=outsignals(2);
    endOutff=outsignals(3);
    validOutff=outsignals(4);

    dataType=datain_top.Type;
    ctlType=startin_top.Type;


    dataoutgen=topNet.addSignal(dataType,'dataoutgen');
    startoutgen=topNet.addSignal(ctlType,'startoutgen');
    endoutgen=topNet.addSignal(ctlType,'endoutgen');
    validoutgen=topNet.addSignal(ctlType,'validoutgen');


    genNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CRCGenerator',...
    'InportNames',{'dataIn','startIn','endIn','validIn'},...
    'InportTypes',[dataType,ufix1Type,ufix1Type,ufix1Type],...
    'InportRates',[inRate,inRate,inRate,inRate],...
    'OutportNames',{'dataOut','startOut','endOut','validOut'},...
    'OutportTypes',[dataType,ufix1Type,ufix1Type,ufix1Type]...
    );


    datain=genNet.PirInputSignals(1);
    sofin=genNet.PirInputSignals(2);
    eofin=genNet.PirInputSignals(3);
    validin=genNet.PirInputSignals(4);

    dataout=genNet.PirOutputSignals(1);
    sofout=genNet.PirOutputSignals(2);
    eofout=genNet.PirOutputSignals(3);
    validout=genNet.PirOutputSignals(4);

    insig=[datain,sofin,eofin,validin];
    outsig=[dataout,sofout,eofout,validout];


    this.elaborateCRCGen(genNet,blockInfo,insig,outsig,false);
    genoutports=[dataoutgen,startoutgen,endoutgen,validoutgen];
    ncomp=pirelab.instantiateNetwork(topNet,genNet,[datain_top,startin_top,endin_top,validin_top],...
    genoutports,'HDLCRCGen_inst');
    ncomp.addComment(' HDL CRC Generator');

    pirelab.getIntDelayComp(topNet,dataoutgen,dataOutff,1,'dataReg',0);
    pirelab.getIntDelayComp(topNet,startoutgen,startOutff,1,'startReg',0);
    pirelab.getIntDelayComp(topNet,endoutgen,endOutff,1,'endReg',0);
    pirelab.getIntDelayComp(topNet,validoutgen,validOutff,1,'validReg',0);

end