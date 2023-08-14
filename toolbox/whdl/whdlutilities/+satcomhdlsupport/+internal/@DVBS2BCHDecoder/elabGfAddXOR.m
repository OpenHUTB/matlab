function gfAddXORNet=elabGfAddXOR(this,topNet,blockInfo,rate)




    inportNames=cell(1,4);
    outportNames=cell(1);

    inportNames{1}='inp1';
    inportNames{2}='inp2';
    inportNames{3}='inp1Log';
    inportNames{4}='inp2Log';
    inDataRate=[rate,rate,rate,rate];
    outportNames{1}='gfAddOut';
    inpType=pir_fixpt_t(0,16,0);
    if strcmp(blockInfo.FECFrameType,'Normal')

        shiftLen=16;
    else

        shiftLen=14;
    end

    inTypes(1)=inpType;
    inTypes(2)=inpType;
    inTypes(3)=inpType;
    inTypes(4)=inpType;
    outTypes(1)=inpType;

    gfAddXORNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','gfAddXORNet',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',inDataRate,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );
    inp1=gfAddXORNet.PirInputSignals(1);
    inp2=gfAddXORNet.PirInputSignals(2);
    inp1Log=gfAddXORNet.PirInputSignals(3);
    inp2Log=gfAddXORNet.PirInputSignals(4);
    gfAddOut=gfAddXORNet.PirOutputSignals(1);
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
    onesconst=newDataSignal(gfAddXORNet,'onesconst',inpType,rate);
    pirelab.getConstComp(gfAddXORNet,onesconst,1);
    falseconst=newControlSignal(gfAddXORNet,'falseConstant',rate);
    pirelab.getConstComp(gfAddXORNet,falseconst,0);
    N_long=newDataSignal(gfAddXORNet,'N_long',inpType,rate);
    pirelab.getConstComp(gfAddXORNet,N_long,2^shiftLen-1);

    zeroconst=newDataSignal(gfAddXORNet,'zeroconst',inpType,rate);
    pirelab.getConstComp(gfAddXORNet,zeroconst,0);

    inp1D1=newDataSignal(gfAddXORNet,'inp1D1',inpType,rate);
    pirelab.getUnitDelayComp(gfAddXORNet,inp1,inp1D1);
    inp1IsZero=newControlSignal(gfAddXORNet,'inp1IsZero',rate);
    pirelab.getCompareToValueComp(gfAddXORNet,inp1D1,inp1IsZero,'==',0);

    inp2D1=newDataSignal(gfAddXORNet,'inp2D2',inpType,rate);
    pirelab.getUnitDelayComp(gfAddXORNet,inp2,inp2D1);
    inp2IsZero=newControlSignal(gfAddXORNet,'inp2IsZero',rate);

    pirelab.getCompareToValueComp(gfAddXORNet,inp2D1,inp2IsZero,'==',0);


    xorOut=newDataSignal(gfAddXORNet,'xorOut',inpType,rate);
    xorOutD1=newDataSignal(gfAddXORNet,'xorOutD1',inpType,rate);
    pirelab.getUnitDelayComp(gfAddXORNet,xorOut,xorOutD1);
    xorFinalOut=newDataSignal(gfAddXORNet,'xorFinalOut',inpType,rate);
    xorOutIsZero=newControlSignal(gfAddXORNet,'xorOutIsZero',rate);
    xorOutIsOne=newControlSignal(gfAddXORNet,'xorOutIsOne',rate);
    xorOutMinusOne=newDataSignal(gfAddXORNet,'xorOutMinusOne',inpType,rate);
    xorOutTempLog=newDataSignal(gfAddXORNet,'xorOutTempLog',inpType,rate);
    xorOutLog=newDataSignal(gfAddXORNet,'xorOutLog',inpType,rate);

    pirelab.getBitwiseOpComp(gfAddXORNet,[inp1Log,inp2Log],xorOut,'XOR');
    pirelab.getCompareToValueComp(gfAddXORNet,xorOutD1,xorOutIsZero,'==',0);
    pirelab.getCompareToValueComp(gfAddXORNet,xorOutD1,xorOutIsOne,'==',1);

    if shiftLen==16


        ramInputSigs=[zeroconst,zeroconst,falseconst,xorOutMinusOne];
        pirelab.getSimpleDualPortRamComp(gfAddXORNet,ramInputSigs,xorOutTempLog,['RamForLUT'],1,-1,[],'',gfTable2_16);
    else


        ramInputSigs=[zeroconst,zeroconst,falseconst,xorOutMinusOne];
        pirelab.getSimpleDualPortRamComp(gfAddXORNet,ramInputSigs,xorOutTempLog,['RamForLUT'],1,-1,[],'',gfTable2_14);
    end
    pirelab.getSubComp(gfAddXORNet,[xorOut,onesconst],xorOutMinusOne);




    pirelab.getSwitchComp(gfAddXORNet,[xorOutTempLog,zeroconst],xorOutLog,xorOutIsZero);
    pirelab.getSwitchComp(gfAddXORNet,[xorOutLog,N_long],xorFinalOut,xorOutIsOne);

    gfAddOutTemp=newDataSignal(gfAddXORNet,'xorOut',inpType,rate);
    pirelab.getSwitchComp(gfAddXORNet,[xorFinalOut,inp2D1],gfAddOutTemp,inp1IsZero);
    pirelab.getSwitchComp(gfAddXORNet,[gfAddOutTemp,inp1D1],gfAddOut,inp2IsZero);

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