function hMuxData=matrixBMemoryReadDataDecoder(~,hMemCtlN,hInSigs,hOutSigs,slRate,blockInfo)



    hBoolT=pir_boolean_t;
    if(blockInfo.dotProductSize~=1)
        inputDataT=hInSigs(1).Type.BaseType;
    else
        inputDataT=hInSigs(1).Type;
    end
    bRow=blockInfo.aColumnSize;
    iter=ceil(blockInfo.aColumnSize/blockInfo.dotProductSize);
    hindexCounterT=pir_fixpt_t(false,ceil(log2(blockInfo.aColumnSize/blockInfo.dotProductSize))+1,0);
    if(blockInfo.dotProductSize~=1)
        hdpSizeArrayT=hMemCtlN.getType('Array','BaseType',inputDataT,'Dimensions',blockInfo.dotProductSize);
    else
        hdpSizeArrayT=hInSigs(1).Type;
    end
    if(blockInfo.aColumnSize~=1)
        hbRowSizeArrayT=hMemCtlN.getType('Array','BaseType',inputDataT,'Dimensions',bRow);
    else
        hbRowSizeArrayT=hInSigs(4).Type;
    end
    modulus=mod(blockInfo.aColumnSize,blockInfo.dotProductSize);
    indexMaxValue=ceil(blockInfo.aColumnSize/blockInfo.dotProductSize);

    hMuxData=pirelab.createNewNetwork(...
    'Name','matrixBMemoryReadDataDecoder',...
    'InportNames',{'aMemoryReadData','rdAddrValid','aRdAddr','bMemoryReadData'},...
    'InportTypes',[hdpSizeArrayT,hBoolT,hindexCounterT,hbRowSizeArrayT],...
    'InportRates',slRate*ones(1,4),...
    'OutportNames',{'aRdData','dataValid','bRdData'},...
    'OutportTypes',[hdpSizeArrayT,hBoolT,hdpSizeArrayT]);

    hMuxData.setTargetCompReplacementCandidate(true);
    for ii=1:numel(hMuxData.PirOutputSignals)
        hMuxData.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    pirelab.instantiateNetwork(hMemCtlN,hMuxData,hInSigs,hOutSigs,...
    [hMuxData.Name,'_inst']);

    aMemoryReadDataS=hMuxData.PirInputSignals(1);
    rdAddrValidS=hMuxData.PirInputSignals(2);
    aRdAddrS=hMuxData.PirInputSignals(3);
    bMemoryReadDataS=hMuxData.PirInputSignals(4);
    aRdDataS=hMuxData.PirOutputSignals(1);
    dataValidS=hMuxData.PirOutputSignals(2);
    bRdDataS=hMuxData.PirOutputSignals(3);

    aRdAddrDelay=l_addSignal(hMuxData,'aRdAddrDelay',hindexCounterT,slRate);
    bMemoryReadDataDelayS=l_addSignal(hMuxData,'bMemoryReadDataDelay',hbRowSizeArrayT,slRate);
    bMemoryReadDataTemp=l_addSignal(hMuxData,'bMemoryReadDataTemp',hbRowSizeArrayT,slRate);
    aMemoryReadDataTemp=l_addSignal(hMuxData,'aMemoryReadDataTemp',hdpSizeArrayT,slRate);

    pirelab.getIntDelayComp(hMuxData,...
    aRdAddrS,...
    aRdAddrDelay,...
    1,'Delay',...
    0,...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hMuxData,...
    bMemoryReadDataTemp,...
    bMemoryReadDataDelayS,...
    1,'Delay1',...
    single(0),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hMuxData,...
    aMemoryReadDataTemp,...
    aRdDataS,...
    1,'Delay2',...
    single(0),...
    0,0,[],0,0);

    pirelab.getIntDelayComp(hMuxData,...
    rdAddrValidS,...
    dataValidS,...
    1,'Delay4',...
    false,...
    0,0,[],0,0);

    pirelab.getSwitchComp(hMuxData,...
    [bMemoryReadDataS,bMemoryReadDataDelayS],...
    bMemoryReadDataTemp,...
    rdAddrValidS,'Switch5',...
    '~=',0,'Floor','Wrap');

    pirelab.getSwitchComp(hMuxData,...
    [aMemoryReadDataS,aRdDataS],...
    aMemoryReadDataTemp,...
    rdAddrValidS,'Switch6',...
    '~=',0,'Floor','Wrap');

    if(blockInfo.dotProductSize==bRow)
        pirelab.getWireComp(hMuxData,...
        bMemoryReadDataDelayS,...
        bRdDataS,...
        'DataWire');
    else
        if(modulus==0)
            hSplitC=bMemoryReadDataDelayS.split;

            hSplitSigs=hSplitC.PirOutputSignals;
        else

            NumberofZeroPaddingElements=((blockInfo.dotProductSize*indexMaxValue)-blockInfo.aColumnSize);
            hbRowSizeArrayT2=hMemCtlN.getType('Array','BaseType',inputDataT,'Dimensions',bRow+NumberofZeroPaddingElements);
            bMemoryReadDataDelayTempS=l_addSignal(hMuxData,'bMemoryReadDataDelayTempS',hbRowSizeArrayT2,slRate);
            bDataExtraelements=hdlhandles(1,NumberofZeroPaddingElements);

            constantZeroS=l_addSignal(hMuxData,'constant',inputDataT,slRate);
            pirelab.getConstComp(hMuxData,...
            constantZeroS,...
            0,...
            'dotProductSize');
            for i=1:NumberofZeroPaddingElements
                suffix=['_',int2str(i-1)];
                bDataExtraelements(i)=l_addSignal(hMuxData,['bDataExtra',suffix],inputDataT,slRate);
                pirelab.getWireComp(hMuxData,...
                constantZeroS,...
                bDataExtraelements(i),...
                'bDataExtra');
            end
            pirelab.getMuxComp(hMuxData,...
            [bMemoryReadDataDelayS,bDataExtraelements],...
            bMemoryReadDataDelayTempS);

            hSplitC=bMemoryReadDataDelayTempS.split;

            hSplitSigs=hSplitC.PirOutputSignals;
        end
        bmux=hdlhandles(1,iter);
        for i=1:iter
            suffix=['_',int2str(i-1)];
            bmux(i)=l_addSignal(hMuxData,['bmux',suffix],hdpSizeArrayT,slRate);
            if(blockInfo.dotProductSize~=1)
                if(modulus==0)
                    bRowLimit=bRow;
                else
                    bRowLimit=bRow+NumberofZeroPaddingElements;
                end
                pirelab.getMuxComp(hMuxData,...
                hSplitSigs(i:iter:bRowLimit),...
                bmux(i));
            else
                pirelab.getWireComp(hMuxData,...
                hSplitSigs(i),...
                bmux(i),...
                'DataWire');
            end
        end
        pirelab.getMultiPortSwitchComp(hMuxData,...
        [aRdAddrDelay,bmux],...
        bRdDataS,...
        1,'Zero-based contiguous','Floor','Wrap',sprintf('Multiport\nSwitch'),[]);
    end

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


