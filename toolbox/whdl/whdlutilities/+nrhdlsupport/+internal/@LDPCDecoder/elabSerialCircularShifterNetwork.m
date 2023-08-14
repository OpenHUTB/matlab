function cNet=elabSerialCircularShifterNetwork(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    ufix5Type=pir_ufixpt_t(5,0);
    vType=pir_ufixpt_t(9,0);
    sType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    sVType=pirelab.getPirVectorType(sType,384);
    selVType=pirelab.getPirVectorType(ufix1Type,384);


    cNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','SerialCircularShifter',...
    'Inportnames',{'data','liftsize','shift','valid','count','iterdone'},...
    'InportTypes',[sVType,vType,vType,ufix1Type,ufix5Type,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'data','valid',},...
    'OutportTypes',[sVType,ufix1Type]...
    );



    data=cNet.PirInputSignals(1);
    liftsize=cNet.PirInputSignals(2);
    shift=cNet.PirInputSignals(3);
    valid=cNet.PirInputSignals(4);
    count=cNet.PirInputSignals(5);
    iterdone=cNet.PirInputSignals(6);

    dataout=cNet.PirOutputSignals(1);
    validout=cNet.PirOutputSignals(2);


    datareg=cNet.addSignal(data.Type,'dataReg');
    zreg=cNet.addSignal(liftsize.Type,'ZReg');
    vreg=cNet.addSignal(shift.Type,'shiftReg');
    validreg=cNet.addSignal(valid.Type,'validReg');
    countreg=cNet.addSignal(count.Type,'countReg');
    iterreg=cNet.addSignal(iterdone.Type,'iterReg');

    pirelab.getUnitDelayComp(cNet,data,datareg,'',0);
    pirelab.getUnitDelayComp(cNet,liftsize,zreg,'',2);
    pirelab.getUnitDelayComp(cNet,shift,vreg,'',0);
    pirelab.getUnitDelayComp(cNet,valid,validreg,'',0);
    pirelab.getUnitDelayComp(cNet,iterdone,iterreg,'',0);
    pirelab.getUnitDelayComp(cNet,count,countreg,'',0);


    wrenb=cNet.addSignal(ufix1Type,'wrEnb');
    iterdone_neg=cNet.addSignal(ufix1Type,'iterDoneNeg');

    pirelab.getLogicComp(cNet,iterreg,iterdone_neg,'not');
    pirelab.getLogicComp(cNet,[validreg,iterdone_neg],wrenb,'and');



    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+nrhdlsupport','+internal','@LDPCDecoder','cgireml','serialAddressGeneration.m'),'r');
    serialAddressGeneration=fread(fid,Inf,'char=>char');
    fclose(fid);

    wraddr=cNet.addSignal(ufix5Type,'wrAddr');
    rdaddr=cNet.addSignal(ufix5Type,'rdAddr');
    rdenable=cNet.addSignal(ufix1Type,'rdEnb');
    rdenablereg=cNet.addSignal(ufix1Type,'rdEnbReg');

    cNet.addComponent2(...
    'kind','cgireml',...
    'Name','serialAddressGeneration',...
    'InputSignals',[wrenb,countreg],...
    'OutputSignals',[wraddr,rdaddr,rdenable],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','serialAddressGeneration',...
    'EMLFileBody',serialAddressGeneration,...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    pirelab.getUnitDelayComp(cNet,rdenable,rdenablereg,'',0);

    dataD=cNet.addSignal(data.Type,'dataD');
    shiftD1=cNet.addSignal(shift.Type,'shiftD1');

    dataDReg=cNet.addSignal(data.Type,'dataDReg');
    shiftDReg=cNet.addSignal(shift.Type,'shiftDReg');

    if blockInfo.ScalingFactor==1
        pirelab.getSimpleDualPortRamComp(cNet,[datareg,wraddr,wrenb,rdaddr],dataDReg,'VariableDelayData',384,-1,[],'','',blockInfo.ramAttr_dist);
        pirelab.getUnitDelayComp(cNet,dataDReg,dataD,'',0);

        pirelab.getSimpleDualPortRamComp(cNet,[vreg,wraddr,wrenb,rdaddr],shiftDReg,'VariableDelayShift',1,-1,[],'','',blockInfo.ramAttr_dist);
        pirelab.getUnitDelayComp(cNet,shiftDReg,shiftD1,'',0);

    else
        pirelab.getSimpleDualPortRamComp(cNet,[datareg,wraddr,wrenb,rdaddr],dataD,'VariableDelayData',384,-1,[],'','',blockInfo.ramAttr_dist);
        pirelab.getSimpleDualPortRamComp(cNet,[vreg,wraddr,wrenb,rdaddr],shiftD1,'VariableDelayShift',1,-1,[],'','',blockInfo.ramAttr_dist);
    end


    shiftD2=cNet.addSignal(vType,'shiftD2');
    shifttmp=cNet.addSignal(vType,'shiftTmp');

    const384=cNet.addSignal(vType,'const384');
    pirelab.getConstComp(cNet,const384,384);

    const1=cNet.addSignal(vType,'const1');
    pirelab.getConstComp(cNet,const1,0);

    Z_shift=cNet.addSignal(vType,'shift_Z');
    pirelab.getSubComp(cNet,[zreg,shiftD1],Z_shift,'Floor','Wrap','Sub_Comp');

    pirelab.getSubComp(cNet,[const384,Z_shift],shifttmp,'Floor','Wrap','Sub_Comp1');
    pirelab.getAddComp(cNet,[shifttmp,const1],shiftD2,'Floor','Wrap','Sub_Comp2');

    if blockInfo.ScalingFactor==1
        shiftout=cNet.addSignal(vType,'shiftOut');
        pirelab.getSwitchComp(cNet,[shiftD1,shiftD2],shiftout,rdenablereg,'sel','~=',0,'Floor','Wrap');
    else
        shiftout=cNet.addSignal(vType,'shiftOut');
        pirelab.getSwitchComp(cNet,[shiftD1,shiftD2],shiftout,rdenable,'sel','~=',0,'Floor','Wrap');
    end

    sel_lut=cNet.addSignal(selVType,'selLUT');
    valid_reg=cNet.addSignal(ufix1Type,'validReg');

    if blockInfo.ScalingFactor==1
        pirelab.getUnitDelayComp(cNet,rdenablereg,valid_reg,'valid',0);
    else
        pirelab.getUnitDelayComp(cNet,rdenable,valid_reg,'valid',0);
    end

    sel_rst=cNet.addSignal(ufix1Type,'selReset');
    pirelab.getCompareToValueComp(cNet,Z_shift,sel_rst,'>',384);

    seladdr=cNet.addSignal(vType,'selAddr');
    pirelab.getSwitchComp(cNet,[const384,Z_shift],seladdr,sel_rst,'sel','~=',0,'Floor','Wrap');


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


    sdata=cNet.addSignal(sVType,'sData');
    shiftdata1=cNet.addSignal(sVType,'shiftData1');
    shiftdata2=cNet.addSignal(sVType,'shiftData2');


    brNet=this.elabBarrelRotatorUnitNetwork(cNet,blockInfo,dataRate);
    brNet.addComment('Barrel Rotator Unit');
    pirelab.instantiateNetwork(cNet,brNet,[dataD,shiftout],...
    sdata,'Barrel Rotator Unit');

    pirelab.getUnitDelayComp(cNet,sdata,shiftdata1,'',0);
    pirelab.getUnitDelayComp(cNet,shiftdata1,shiftdata2,'',0);


    d1array=this.demuxSignal(cNet,shiftdata1,'sd1Array');
    d2array=this.demuxSignal(cNet,shiftdata2,'sd2Array');
    selarray=this.demuxSignal(cNet,sel_lut,'selArray');

    for index=1:384
        doutarray(index)=cNet.addSignal(sType,['dOutArray_',num2str(index)]);%#ok<*AGROW> 
        pirelab.getSwitchComp(cNet,[d2array(index),d1array(index)],doutarray(index),selarray(index),'sel','~=',0,'Floor','Wrap');
    end

    datao=cNet.addSignal(dataout.Type,'dataOutD');

    this.muxSignal(cNet,doutarray,datao);

    if blockInfo.ScalingFactor==1
        pirelab.getWireComp(cNet,datao,dataout,'');
        pirelab.getIntDelayComp(cNet,valid_reg,validout,1,'',0);
    else
        pirelab.getIntDelayComp(cNet,datao,dataout,1,'',0);
        pirelab.getIntDelayComp(cNet,valid_reg,validout,2,'',0);
    end
end





