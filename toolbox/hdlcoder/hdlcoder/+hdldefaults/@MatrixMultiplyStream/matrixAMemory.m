function hARAMN=matrixAMemory(~,hAMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)




    hBoolT=pir_boolean_t;
    if(blockInfo.dotProductSize~=1)
        inputDataT=hInSigs(3).Type.BaseType;
    else
        inputDataT=hInSigs(3).Type;
    end
    hindexCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.aColumnSize/blockInfo.dotProductSize))+1,0);
    if(blockInfo.dotProductSize~=1)
        hdpSizeArrayT=hAMemCtlN.getType('Array','BaseType',inputDataT,'Dimensions',blockInfo.dotProductSize);
        hArrayBoolT=hAMemCtlN.getType('Array','BaseType',hBoolT,'Dimensions',blockInfo.dotProductSize);
        hArraySubColT=hAMemCtlN.getType('Array','BaseType',hindexCounterT,'Dimensions',blockInfo.dotProductSize);
    else
        hdpSizeArrayT=hInSigs(3).Type;
        hArrayBoolT=hInSigs(1).Type;
        hArraySubColT=hInSigs(2).Type;
    end

    hARAMN=pirelab.createNewNetwork(...
    'Name','matrixAMemory',...
    'InportNames',{'wrEn','wrAddr','wrData','rdAddr'},...
    'InportTypes',[hArrayBoolT,hArraySubColT,hdpSizeArrayT,hArraySubColT],...
    'InportRates',slRate*ones(1,4),...
    'OutportNames',{'aRAMDataOut'},...
    'OutportTypes',hdpSizeArrayT);
    for ii=1:numel(hARAMN.PirOutputSignals)
        hARAMN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    pirelab.instantiateNetwork(hAMemCtlN,hARAMN,hInSigs,hOutSigs,...
    [hARAMN.Name,'_inst']);
    wrEnS=hARAMN.PirInputSignals(1);
    wrAddrS=hARAMN.PirInputSignals(2);
    wrDataS=hARAMN.PirInputSignals(3);
    rdAddrS=hARAMN.PirInputSignals(4);
    aRAMDataOutTempS=l_addSignal(hARAMN,'rdData',hdpSizeArrayT,slRate);

    if(blockInfo.dotProductSize~=1)
        hwrEnC=wrEnS.split;
        hwrAddrC=wrAddrS.split;
        hwrDataC=wrDataS.split;
        hrdAddrC=rdAddrS.split;
        wrEnTempS=hwrEnC.PirOutputSignals;
        wrAddrTempS=hwrAddrC.PirOutputSignals;
        wrDataTempS=hwrDataC.PirOutputSignals;
        rdAddrTempS=hrdAddrC.PirOutputSignals;
    else
        wrEnTempS=wrEnS;
        wrAddrTempS=wrAddrS;
        wrDataTempS=wrDataS;
        rdAddrTempS=rdAddrS;
    end
    aRAMDataOutS=hARAMN.PirOutputSignals(1);

    if(blockInfo.dotProductSize==blockInfo.aColumnSize)
        aDataReg=hdlhandles(1,blockInfo.dotProductSize);
        aDataRegTemp=hdlhandles(1,blockInfo.dotProductSize);
        compareToConstantS=hdlhandles(1,blockInfo.dotProductSize);
        regWrEn=hdlhandles(1,blockInfo.dotProductSize);
        for i=1:blockInfo.dotProductSize
            suffix=['_',int2str(i-1)];
            aRAMDataOutTempS(i)=l_addSignal(hARAMN,['aRAMDataOutTemp',suffix],inputDataT,slRate);
            aDataReg(i)=l_addSignal(hARAMN,['aDataReg',suffix],inputDataT,slRate);
            aDataRegTemp(i)=l_addSignal(hARAMN,['aDataReg',suffix],inputDataT,slRate);
            regWrEn(i)=l_addSignal(hARAMN,['regWrEn',suffix],hBoolT,slRate);
            compareToConstantS(i)=l_addSignal(hARAMN,['compareToConstant',suffix],hBoolT,slRate);
            pirelab.getSwitchComp(hARAMN,...
            [wrDataTempS(i),aDataReg(i)],...
            aDataRegTemp(i),...
            compareToConstantS(i),'Switch',...
            '~=',0,'Floor','Wrap');
            pirelab.getCompareToValueComp(hARAMN,...
            wrEnTempS(i),...
            compareToConstantS(i),...
            '==',true,...
            ['compareToConstant',suffix],0);
            pirelab.getIntDelayComp(hARAMN,...
            aDataRegTemp(i),...
            aDataReg(i),...
            1,'aDataReg',...
            false,...
            0,0,[],0,0);

            pirelab.getWireComp(hARAMN,...
            aDataReg(i),...
            aRAMDataOutTempS(i),...
            'Data');

        end
        pirelab.getMuxComp(hARAMN,...
        aRAMDataOutTempS(1:end),...
        aRAMDataOutS,...
        'Data');

    elseif((blockInfo.dotProductSize~=1)&&(blockInfo.dotProductSize~=blockInfo.aColumnSize))
        for i=1:blockInfo.dotProductSize
            suffix=['_',int2str(i-1)];
            aRAMDataOutTempS(i)=l_addSignal(hARAMN,['aRAMDataOutTemp',suffix],inputDataT,slRate);
            pirelab.getSimpleDualPortRamComp(hARAMN,...
            [wrDataTempS(i),wrAddrTempS(i),wrEnTempS(i),rdAddrTempS(i)],...
            aRAMDataOutTempS(i),...
            ['SimpleDualPortRAM_generic',suffix],1,...
            -1,[],' ',...
            []);
        end

        pirelab.getMuxComp(hARAMN,...
        aRAMDataOutTempS(1:end),...
        aRAMDataOutS,...
        'Data');

    else
        aRAMDataOutTempS=l_addSignal(hARAMN,'aRAMDataOutTemp',inputDataT,slRate);
        pirelab.getSimpleDualPortRamComp(hARAMN,...
        [wrDataTempS,wrAddrTempS,wrEnTempS,rdAddrTempS],...
        aRAMDataOutTempS,...
        'SimpleDualPortRAM_generic',1,...
        -1,[],' ',...
        []);

        pirelab.getWireComp(hARAMN,...
        aRAMDataOutTempS,...
        aRAMDataOutS,...
        'Data');

    end
end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


