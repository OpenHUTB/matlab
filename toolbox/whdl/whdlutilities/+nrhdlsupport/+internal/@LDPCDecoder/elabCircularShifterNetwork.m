function cNet=elabCircularShifterNetwork(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    vType=pir_ufixpt_t(9,0);
    selType=pir_ufixpt_t(1,0);

    sType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    sVType=pirelab.getPirVectorType(sType,384);
    sV1Type=pirelab.getPirVectorType(sType,384);
    selVType=pirelab.getPirVectorType(selType,384);


    cNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CircularShifter',...
    'Inportnames',{'data','liftsize','shift','valid'},...
    'InportTypes',[sVType,vType,vType,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'shiftData','shiftValid'},...
    'OutportTypes',[sVType,ufix1Type]...
    );



    data=cNet.PirInputSignals(1);
    liftsize=cNet.PirInputSignals(2);
    shift=cNet.PirInputSignals(3);
    valid=cNet.PirInputSignals(4);

    dataout=cNet.PirOutputSignals(1);
    validout=cNet.PirOutputSignals(2);


    shift1=cNet.addSignal(vType,'shift_1');
    shift2=cNet.addSignal(vType,'shift_2');
    shifttmp=cNet.addSignal(vType,'shiftTmp');

    const384=cNet.addSignal(vType,'const384');
    pirelab.getConstComp(cNet,const384,384);

    const1=cNet.addSignal(vType,'const1');
    pirelab.getConstComp(cNet,const1,0);

    Z_shift=cNet.addSignal(vType,'shift_Z');
    pirelab.getSubComp(cNet,[liftsize,shift],Z_shift,'Floor','Wrap','Sub_Comp');

    pirelab.getSubComp(cNet,[const384,Z_shift],shifttmp,'Floor','Wrap','Sub_Comp1');
    pirelab.getAddComp(cNet,[shifttmp,const1],shift1,'Floor','Wrap','Sub_Comp2');
    pirelab.getWireComp(cNet,shift,shift2,'');

    seladdr=cNet.addSignal(vType,'selAddr');

    sel_lut=cNet.addSignal(selVType,'selLUT');

    shift1_reg=cNet.addSignal(vType,'shift1Reg');
    shift2_reg=cNet.addSignal(vType,'shift2Reg');
    valid_reg=cNet.addSignal(ufix1Type,'validReg');
    datamux=cNet.addSignal(data.Type,'dataReg');

    pirelab.getUnitDelayComp(cNet,data,datamux,'dataReg',0);
    pirelab.getUnitDelayComp(cNet,Z_shift,seladdr,'seladdr',0);
    pirelab.getUnitDelayComp(cNet,shift1,shift1_reg,'shift1',0);
    pirelab.getUnitDelayComp(cNet,shift2,shift2_reg,'shift2',0);
    pirelab.getUnitDelayComp(cNet,valid,valid_reg,'valid',0);


    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','shiftValuesLUT.m'),'r');
    shiftValuesLUT=fread(fid,Inf,'char=>char');
    fclose(fid);

    cNet.addComponent2(...
    'kind','cgireml',...
    'Name','shiftValuesLUT',...
    'InputSignals',seladdr,...
    'OutputSignals',sel_lut,...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','shiftValuesLUT',...
    'EMLFileBody',shiftValuesLUT,...
    'EMLFlag_TreatInputIntsAsFixpt',true);


    sdata1=cNet.addSignal(sVType,'sData1');
    sdata2=cNet.addSignal(sVType,'sData2');

    shiftdata1=cNet.addSignal(sVType,'shiftData1');
    shiftdata2=cNet.addSignal(sVType,'shiftData2');


    br1Net=this.elabBarrelRotatorUnitNetwork(cNet,blockInfo,dataRate);
    br1Net.addComment('Barrel Rotator Unit');
    pirelab.instantiateNetwork(cNet,br1Net,[datamux,shift1_reg],...
    sdata1,'Barrel Rotator Unit1');


    br2Net=this.elabBarrelRotatorUnitNetwork(cNet,blockInfo,dataRate);
    br2Net.addComment('Barrel Rotator Unit');
    pirelab.instantiateNetwork(cNet,br2Net,[datamux,shift2_reg],...
    sdata2,'Barrel Rotator Unit2');

    pirelab.getUnitDelayEnabledComp(cNet,sdata1,shiftdata1,valid_reg,'',0);
    pirelab.getUnitDelayEnabledComp(cNet,sdata2,shiftdata2,valid_reg,'',0);


    d1array=this.demuxSignal(cNet,shiftdata1,'sd1Array');
    d2array=this.demuxSignal(cNet,shiftdata2,'sd2Array');
    selarray=this.demuxSignal(cNet,sel_lut,'selArray');

    for index=1:384
        doutarray(index)=cNet.addSignal(sType,['dOutArray_',num2str(index)]);
        pirelab.getSwitchComp(cNet,[d2array(index),d1array(index)],doutarray(index),selarray(index),'sel','~=',0,'Floor','Wrap');
    end

    datao=cNet.addSignal(dataout.Type,'dataOutD');

    this.muxSignal(cNet,doutarray,datao);

    pirelab.getWireComp(cNet,datao,dataout,'');
    pirelab.getUnitDelayComp(cNet,valid_reg,validout,'',0);

end
