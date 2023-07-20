function hC=getAddrBlockDetectionComp(hN,hInSignals,hOutSignals,addrStart,addrBlockSize,regID)









    addr_in=hInSignals(1);
    addr_match=hOutSignals(1);


    blockBitWidth=log2(double(addrBlockSize));
    if blockBitWidth~=floor(log2(double(addrBlockSize)))
        error(message('hdlcommon:workflow:AddrBlockSize'));
    end


    maskValue=double(addrStart)/double(addrBlockSize);
    if maskValue~=floor(double(addrStart)/double(addrBlockSize))
        error(message('hdlcommon:workflow:AddrBlockStart'));
    end


    addrInType=addr_in.Type;
    addrInWordLength=addrInType.WordLength;
    addrMaskWordLength=addrInWordLength-blockBitWidth;
    addrMaskType=pir_ufixpt_t(addrMaskWordLength,0);


    addr_mask=hN.addSignal(addrMaskType,sprintf('addr_mask_%s',regID));
    pirelab.getBitSliceComp(hN,addr_in,addr_mask,addrInWordLength-1,blockBitWidth,sprintf('slice_%s',regID));


    hC=pirelab.getCompareToValueComp(hN,addr_mask,addr_match,'==',maskValue);

end


