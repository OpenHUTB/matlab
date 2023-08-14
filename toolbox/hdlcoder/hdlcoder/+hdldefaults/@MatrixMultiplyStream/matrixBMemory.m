function hBArrN=matrixBMemory(~,hBMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)




    hBoolT=pir_boolean_t;
    inputDataT=hInSigs(3).Type.BaseType;
    bRow=blockInfo.aColumnSize;
    hbColCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.bColumnSize))+1,0);
    if(blockInfo.aColumnSize~=1)
        hbRowSizeArrayT=hBMemCtlN.getType('Array','BaseType',inputDataT,'Dimensions',bRow);
        hbRowSizeBoolT=hBMemCtlN.getType('Array','BaseType',hBoolT,'Dimensions',bRow);
        hbRowSizeArrayColCounT=hBMemCtlN.getType('Array','BaseType',hbColCounterT,'Dimensions',bRow);
    else
        hbRowSizeArrayT=hInSigs(3).Type;
        hbRowSizeBoolT=hInSigs(1).Type;
        hbRowSizeArrayColCounT=hbColCounterT;
    end

    hBArrN=pirelab.createNewNetwork(...
    'Name','matrixBMemory',...
    'InportNames',{'wrEn','wrAddr','wrData','rdAddr'},...
    'InportTypes',[hbRowSizeBoolT,hbRowSizeArrayColCounT,hbRowSizeArrayT,hbRowSizeArrayColCounT],...
    'InportRates',slRate*ones(1,4),...
    'OutportNames',{'bRAMDataOut'},...
    'OutportTypes',hbRowSizeArrayT);
    for ii=1:numel(hBArrN.PirOutputSignals)
        hBArrN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    pirelab.instantiateNetwork(hBMemCtlN,hBArrN,hInSigs,hOutSigs,...
    [hBArrN.Name,'_inst']);

    wrEnS=hBArrN.PirInputSignals(1);
    wrAddrS=hBArrN.PirInputSignals(2);
    wrDataS=hBArrN.PirInputSignals(3);
    rdAddrS=hBArrN.PirInputSignals(4);
    bRAMDataOutS=hBArrN.PirOutputSignals(1);


    if(blockInfo.aColumnSize~=1)
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


    if(blockInfo.bColumnSize~=1)
        if(blockInfo.aColumnSize~=1)
            bRAMDataOutTempS=l_addSignal(hBArrN,'rdData',hbRowSizeArrayT,slRate);
            for i=1:bRow
                suffix=['_',int2str(i-1)];
                bRAMDataOutTempS(i)=l_addSignal(hBArrN,['bRAMDataOutTemp',suffix],inputDataT,slRate);
                pirelab.getSimpleDualPortRamComp(hBArrN,...
                [wrDataTempS(i),wrAddrTempS(i),wrEnTempS(i),rdAddrTempS(i)],...
                bRAMDataOutTempS(i),...
                ['SimpleDualPortRAM_generic',suffix],1,...
                -1,[],' ',...
                []);
            end

            pirelab.getMuxComp(hBArrN,...
            bRAMDataOutTempS(1:end),...
            bRAMDataOutS,...
            'Data');
        else
            bRAMDataOutTempS=l_addSignal(hBArrN,'rdData',hbRowSizeArrayT,slRate);
            pirelab.getSimpleDualPortRamComp(hBArrN,...
            [wrDataTempS,wrAddrTempS,wrEnTempS,rdAddrTempS],...
            bRAMDataOutTempS,...
            'SimpleDualPortRAM_generic',1,...
            -1,[],' ',...
            []);

            pirelab.getWireComp(hBArrN,...
            bRAMDataOutTempS,...
            bRAMDataOutS,...
            'Data');

        end

    else
        bDataReg=hdlhandles(1,blockInfo.aColumnSize);
        bDataRegTemp=hdlhandles(1,blockInfo.aColumnSize);
        compareToConstantS=hdlhandles(1,blockInfo.aColumnSize);
        regWrEn=hdlhandles(1,blockInfo.aColumnSize);
        bRAMDataOutTempS=l_addSignal(hBArrN,'rdData',hbRowSizeArrayT,slRate);
        for i=1:blockInfo.aColumnSize
            suffix=['_',int2str(i-1)];
            bRAMDataOutTempS(i)=l_addSignal(hBArrN,['bRAMDataOutTempS',suffix],inputDataT,slRate);
            bDataReg(i)=l_addSignal(hBArrN,['bDataReg',suffix],inputDataT,slRate);
            bDataRegTemp(i)=l_addSignal(hBArrN,['bDataRegTemp',suffix],inputDataT,slRate);
            regWrEn(i)=l_addSignal(hBArrN,['regWrEn',suffix],hBoolT,slRate);
            compareToConstantS(i)=l_addSignal(hBArrN,['compareToConstant',suffix],hBoolT,slRate);
            pirelab.getSwitchComp(hBArrN,...
            [wrDataTempS(i),bDataReg(i)],...
            bDataRegTemp(i),...
            compareToConstantS(i),'Switch',...
            '~=',0,'Floor','Wrap');
            pirelab.getCompareToValueComp(hBArrN,...
            wrEnTempS(i),...
            compareToConstantS(i),...
            '==',true,...
            ['compareToConstant',suffix],0);
            pirelab.getIntDelayComp(hBArrN,...
            bDataRegTemp(i),...
            bDataReg(i),...
            1,'bDataReg',...
            false,...
            0,0,[],0,0);

            pirelab.getWireComp(hBArrN,...
            bDataReg(i),...
            bRAMDataOutTempS(i),...
            'Data');
        end
        pirelab.getMuxComp(hBArrN,...
        bRAMDataOutTempS(1:end),...
        bRAMDataOutS,...
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


