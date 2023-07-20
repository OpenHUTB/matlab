function hC=getMemoryComp(hN,hInSignals,hOutSignals,size,directFeedthrough,compName)








    if nargin<6||isempty(compName)
        compName='ramblock';
    end

    if nargin<5||isempty(directFeedthrough)
        directFeedthrough=0;
    end

    if nargin<4||isempty(size)
        addrType=hInSignals(2).Type;
        size=2^(addrType.getLeafType.WordLength);
    end


    hWrDataSignal=hInSignals(1);
    hWrAddrSignal=hInSignals(2);
    hRdAddrSignal=hInSignals(3);

    hRdDataSignal=hOutSignals(1);


    [numWriteData,hWriteDataType]=pirelab.getVectorTypeInfo(hWrDataSignal);
    [numWriteAddr,hWriteAddrType]=pirelab.getVectorTypeInfo(hWrAddrSignal);
    [numReadAddr,hReadAddrType]=pirelab.getVectorTypeInfo(hRdAddrSignal);
    [numReadData,hReadDataType]=pirelab.getVectorTypeInfo(hRdDataSignal);

    if numWriteData~=numWriteAddr
        error(message('hdlcommon:hdlcommon:WriteAddressDataMismatch'));
    end

    if numReadData~=numReadAddr
        error(message('hdlcommon:hdlcommon:ReadAddressDataMismatch'));
    end



    dataTypeSame=hWriteDataType.isNumericType&&hWriteDataType.isBitCompatible(hReadDataType);

    if~dataTypeSame&&~hWriteDataType.isEqual(hReadDataType)
        error(message('hdlcommon:hdlcommon:WriteDataTypeMismatch'));
    end



    addrTypeSame=hWriteAddrType.isNumericType&&hWriteAddrType.isBitCompatible(hReadAddrType);

    if~addrTypeSame&&~hWriteAddrType.isEqual(hReadAddrType)
        error(message('hdlcommon:hdlcommon:ReadDataTypeMismatch'));
    end

    if numReadData>1
        error(message('hdlcommon:hdlcommon:SingletonReader',numReadData));
    end

    if numWriteData>1
        error(message('hdlcommon:hdlcommon:SingletonWriter',numWriteData));
    end


    signalSize=2^(hWriteAddrType.getLeafType.WordLength);
    if signalSize<size
        error(message('hdlcommon:hdlcommon:AddressTypeError',size,signalSize));
    end

    hWrAddrSignal=createAddressSignal(hN,hWrAddrSignal,signalSize,size,sprintf('%s_wraddr',compName));
    hRdAddrSignal=createAddressSignal(hN,hRdAddrSignal,signalSize,size,sprintf('%s_rdaddr',compName));

    if length(hInSignals)==4
        hWrEnSignal=hInSignals(4);
    else
        ufix1Type=pir_ufixpt_t(1,0);
        hWrEnSignal=hN.addSignal(ufix1Type,sprintf('%s_wrenb',compName));
        hWrEnSignal.SimulinkRate=hWrAddrSignal.SimulinkRate;
        pireml.getConstComp(hN,hWrEnSignal,1,sprintf('%s_wrenbc',compName));
    end

    if directFeedthrough
        ufix1Type=pir_ufixpt_t(1,0);
        hCompareOut=hN.addSignal(ufix1Type,sprintf('%s_readequalswrite',compName));
        hCompareOut.SimulinkRate=hWrAddrSignal.SimulinkRate;
        pireml.getRelOpComp(hN,[hWrAddrSignal,hRdAddrSignal],hCompareOut,'==',sprintf('%s_readEqualsWrite',compName));



        hCDelayed=insertDelay(hN,hCompareOut,1,compName);
        hWDelayed=insertDelay(hN,hWrDataSignal,1,compName);

        hActualRead=hN.addSignal(hRdDataSignal);
        hActualRead.Name=sprintf('%s_readData',compName);
        hActualRead.SimulinkRate=hRdDataSignal.SimulinkRate;
        pireml.getSwitchComp(hN,[hCDelayed,hActualRead,hWDelayed],hRdDataSignal,1,'floor','wrap',sprintf('%s_actualData',compName));
    else
        hActualRead=hRdDataSignal;
    end

    hRamInSignals=[hWrDataSignal,hWrAddrSignal,hWrEnSignal,hRdAddrSignal];


    [~,hC]=pirelab.getSimpleDualPortRamComp(hN,hRamInSignals,hActualRead,compName,length(hWrDataSignal),-1,[]);

end

function hOutSig=insertDelay(hN,hInSig,numDelays,name)
    hOutSig=hN.addSignal(hInSig);
    hOutSig.Name=sprintf('%s_delayed',name);
    hOutSig.SimulinkRate=hInSig.SimulinkRate;

    pireml.getIntDelayComp(hN,hInSig,hOutSig,numDelays,sprintf('%s_delay',name));

end


function hAddrSignal=createAddressSignal(hN,hCurrSignal,signalSize,ramSize,name)

    hAddrSignal=hCurrSignal;
    if ramSize~=signalSize
        if signalSize<ramSize
            error(message('hdlcommon:hdlcommon:AddressTypeError',ramSize,signalSize));
        end

        addrWidth=ceil(log2(ramSize));
        addrType=pir_ufixpt_t(addrWidth,0);
        hAddrSignal=hN.addSignal(addrType,name);
        hAddrSignal.SimulinkRate=hCurrSignal.SimulinkRate;
        pireml.getDTCComp(hN,hCurrSignal,hAddrSignal,'Floor','Wrap','SI',name);
    end
end


