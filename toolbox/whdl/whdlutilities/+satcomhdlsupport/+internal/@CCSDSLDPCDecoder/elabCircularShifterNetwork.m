function cNet=elabCircularShifterNetwork(this,topNet,blockInfo,dataRate)





    ufix1Type=pir_boolean_t;
    sType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    sVType=pirelab.getPirVectorType(sType,blockInfo.memDepth);
    vType=pir_ufixpt_t(blockInfo.vWL,0);


    cNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CircularShifter',...
    'Inportnames',{'data','valid','shift'},...
    'InportTypes',[sVType,ufix1Type,vType],...
    'InportRates',[dataRate,dataRate,dataRate],...
    'Outportnames',{'data','valid'},...
    'OutportTypes',[sVType,ufix1Type]...
    );



    data=cNet.PirInputSignals(1);
    valid=cNet.PirInputSignals(2);
    shift=cNet.PirInputSignals(3);

    dataout=cNet.PirOutputSignals(1);
    validout=cNet.PirOutputSignals(2);


    sdata=cNet.addSignal(sVType,'sData');



    brNet=this.elabBarrelRotatorUnitNetwork(cNet,blockInfo,dataRate);
    brNet.addComment('Barrel Rotator Unit');
    pirelab.instantiateNetwork(cNet,brNet,[data,shift],...
    sdata,'Barrel Rotator Unit');

    pirelab.getUnitDelayEnabledComp(cNet,sdata,dataout,valid,'',0);
    pirelab.getUnitDelayComp(cNet,valid,validout,'',0);

end


