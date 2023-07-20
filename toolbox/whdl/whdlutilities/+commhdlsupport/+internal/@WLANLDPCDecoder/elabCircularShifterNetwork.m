function cNet=elabCircularShifterNetwork(this,topNet,blockInfo,dataRate)






    vWL=7;
    ufix1Type=pir_ufixpt_t(1,0);
    ufix3Type=pir_ufixpt_t(3,0);
    vType=pir_ufixpt_t(blockInfo.shiftWL,0);
    selType=pir_ufixpt_t(1,0);

    sType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    sVType=pirelab.getPirVectorType(sType,blockInfo.memDepth1);
    sV1Type=pirelab.getPirVectorType(sType,blockInfo.memDepth1);%#ok<*NASGU> 
    selVType=pirelab.getPirVectorType(selType,blockInfo.memDepth1);


    cNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CircluarShifter',...
    'Inportnames',{'data','smsize','shift','offset','valid'},...
    'InportTypes',[sVType,vType,vType,ufix3Type,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'data','valid'},...
    'OutportTypes',[sVType,ufix1Type]...
    );



    data=cNet.PirInputSignals(1);
    smsize=cNet.PirInputSignals(2);
    shift=cNet.PirInputSignals(3);
    offset=cNet.PirInputSignals(4);
    valid=cNet.PirInputSignals(5);

    dataout=cNet.PirOutputSignals(1);
    validout=cNet.PirOutputSignals(2);


    shift1=cNet.addSignal(vType,'shift_1');
    shift2=cNet.addSignal(vType,'shift_2');
    shift1_tmp=cNet.addSignal(vType,'shiftTmp1');
    shift2_tmp=cNet.addSignal(vType,'shiftTmp2');

    const=cNet.addSignal(vType,'const');
    pirelab.getConstComp(cNet,const,blockInfo.memDepth1);

    const1=cNet.addSignal(vType,'const1');
    pirelab.getConstComp(cNet,const1,1);

    smshift=cNet.addSignal(vType,'smShift');
    pirelab.getSubComp(cNet,[smsize,shift],smshift,'Floor','Wrap','Sub_Comp');

    offdtc=cNet.addSignal(vType,'offDTC');
    pirelab.getDTCComp(cNet,offset,offdtc,'Floor','Saturate');

    pirelab.getSubComp(cNet,[const,smshift],shift1_tmp,'Floor','Wrap','Sub_Comp1');
    pirelab.getAddComp(cNet,[shift1_tmp,offdtc],shift1,'Floor','Wrap','Add_Comp1');

    pirelab.getAddComp(cNet,[shift,offdtc],shift2_tmp,'Floor','Wrap','Add_Comp2');
    pirelab.getWireComp(cNet,shift2_tmp,shift2,'');

    seladdr=cNet.addSignal(vType,'selAddr');
    sel_lut=cNet.addSignal(selVType,'selLUT');
    shift1_reg=cNet.addSignal(vType,'shift1Reg');
    shift2_reg=cNet.addSignal(vType,'shift2Reg');
    valid_reg=cNet.addSignal(ufix1Type,'validReg');
    datamux=cNet.addSignal(data.Type,'dataReg');

    pirelab.getUnitDelayComp(cNet,data,datamux,'dataReg',0);
    pirelab.getUnitDelayComp(cNet,smshift,seladdr,'seladdr',0);
    pirelab.getUnitDelayComp(cNet,shift1,shift1_reg,'shift1',0);
    pirelab.getUnitDelayComp(cNet,shift2,shift2_reg,'shift2',0);
    pirelab.getUnitDelayComp(cNet,valid,valid_reg,'valid',0);


    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+commhdlsupport','+internal','@WLANLDPCDecoder','cgireml','shiftValuesLUT.m'),'r');
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
    'EmlParams',{blockInfo.memDepth1,vWL},...
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

    for index=1:blockInfo.memDepth1
        doutarray(index)=cNet.addSignal(sType,['dOutArray_',num2str(index)]);%#ok<*AGROW> 
        pirelab.getSwitchComp(cNet,[d2array(index),d1array(index)],doutarray(index),selarray(index),'sel','~=',0,'Floor','Wrap');
    end

    datao=cNet.addSignal(dataout.Type,'dataOutD');
    this.muxSignal(cNet,doutarray,datao);
    pirelab.getWireComp(cNet,datao,dataout,'');
    pirelab.getUnitDelayComp(cNet,valid_reg,validout,'',0);

end
