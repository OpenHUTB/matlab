function gfTabValNet=elabGfTabVal(this,topNet,blockInfo,rate)




    inportNames=cell(1);
    outportNames=cell(1,2);

    inportNames{1}='inp1';
    inDataRate=[rate];
    outportNames{1}='gfTabOut';
    outportNames{2}='inpModOut';
    if strcmp(blockInfo.FECFrameType,'Normal')
        inpType=pir_fixpt_t(0,16,0);
        shiftLen=16;
    else
        inpType=pir_fixpt_t(0,16,0);
        shiftLen=14;
    end

    inTypes(1)=pir_fixpt_t(0,17,0);
    outTypes(1)=inpType;
    outTypes(2)=inpType;
    gfTabValNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','gfTabValNet',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',inDataRate,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    inp1=gfTabValNet.PirInputSignals(1);
    gfTabOut=gfTabValNet.PirOutputSignals(1);
    inpAfterMod=gfTabValNet.PirOutputSignals(2);
    falseconst=newControlSignal(gfTabValNet,'falseConstant',rate);
    pirelab.getConstComp(gfTabValNet,falseconst,0);
    onesconst=newDataSignal(gfTabValNet,'onesconst',pir_ufixpt_t(1,0),rate);
    pirelab.getConstComp(gfTabValNet,onesconst,1);
    gfTables=coder.load(fullfile(matlabroot,'toolbox','whdl','whdl','+satcomhdl','+internal','dvbs2BCH_GFTables.mat'),'GFTable');

    if strcmp(blockInfo.FECFrameType,'Normal')

        gfTable1_16=ufi(gfTables.GFTable(1).table1,16,0);
        gfTable2_16=ufi(gfTables.GFTable(1).table2,16,0);
        gfTable2_16(1)=ufi(2^16-1,16,0);
    else

        gfTable1_14=ufi(gfTables.GFTable(2).table1,16,0);
        gfTable2_14=ufi(gfTables.GFTable(2).table2,16,0);
        gfTable2_14(1)=ufi(2^14-1,16,0);
    end
    N_long=newDataSignal(gfTabValNet,'N_long',inpType,rate);
    pirelab.getConstComp(gfTabValNet,N_long,2^shiftLen-1);

    zeroconst=newDataSignal(gfTabValNet,'zeroconst',inpType,rate);
    pirelab.getConstComp(gfTabValNet,zeroconst,0);


    inp1MinusOne=newDataSignal(gfTabValNet,'inp1MinusOne',inpType,rate);
    inp1TempLog=newDataSignal(gfTabValNet,'inp1TempLog',inpType,rate);
    inp1GreaterThanN=newControlSignal(gfTabValNet,'inp1GreaterThanN',rate);
    inp1AfterMod=newDataSignal(gfTabValNet,'inp1AfterMod',inpType,rate);

    inp1IsZero=newControlSignal(gfTabValNet,'inp1IsZero',rate);
    inp1IsZeroD1=newControlSignal(gfTabValNet,'inp1IsZero',rate);
    pirelab.getUnitDelayComp(gfTabValNet,inp1IsZero,inp1IsZeroD1);
    inp1AfterModTemp=newDataSignal(gfTabValNet,'inp1AfterModTemp',inpType,rate);

    pirelab.getCompareToValueComp(gfTabValNet,inp1,inp1GreaterThanN,'>',2^shiftLen-1);

    if shiftLen==16

        inp1ModuloNet=this.elabModulo(gfTabValNet,blockInfo,inp1,inp1AfterModTemp,rate);
        inp1ModuloNet.addComment('inp1ModuloNet');
        pirelab.instantiateNetwork(gfTabValNet,inp1ModuloNet,inp1,inp1AfterModTemp,'inp1ModNet');
        pirelab.getDTCComp(gfTabValNet,inp1AfterModTemp,inp1AfterMod);
        ramInputSigs=[zeroconst,zeroconst,falseconst,inp1MinusOne];
        pirelab.getSimpleDualPortRamComp(gfTabValNet,ramInputSigs,inp1TempLog,['RamForLUT'],1,-1,[],'',gfTable1_16);
    else

        inp1ModuloNet=this.elabModulo(gfTabValNet,blockInfo,inp1,inp1AfterModTemp,rate);
        inp1ModuloNet.addComment('inp1ModuloNet');
        inp1AfterMod14Bit=newDataSignal(gfTabValNet,'inp1AfterMod14Bit',pir_fixpt_t(0,16,0),rate);

        pirelab.instantiateNetwork(gfTabValNet,inp1ModuloNet,inp1,inp1AfterMod14Bit,'inp1ModNet');
        pirelab.getDTCComp(gfTabValNet,inp1AfterMod14Bit,inp1AfterMod);
        ramInputSigs=[zeroconst,zeroconst,falseconst,inp1MinusOne];
        pirelab.getSimpleDualPortRamComp(gfTabValNet,ramInputSigs,inp1TempLog,['RamForLUT'],1,-1,[],'',gfTable1_14);
    end
    pirelab.getSubComp(gfTabValNet,[inp1AfterMod,onesconst],inp1MinusOne);
    pirelab.getCompareToValueComp(gfTabValNet,inp1AfterMod,inp1IsZero,'==',0);

    pirelab.getSwitchComp(gfTabValNet,[inp1TempLog,zeroconst],gfTabOut,inp1IsZeroD1);

    pirelab.getWireComp(gfTabValNet,inp1AfterMod,inpAfterMod);
end

function signal=newControlSignal(topNet,name,rate)
    controlType=pir_ufixpt_t(1,0);
    signal=topNet.addSignal(controlType,name);
    signal.SimulinkRate=rate;
end

function signal=newDataSignal(topNet,name,inType,rate)
    signal=topNet.addSignal(inType,name);
    signal.SimulinkRate=rate;
end