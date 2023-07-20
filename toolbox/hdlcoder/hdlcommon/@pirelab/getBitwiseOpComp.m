function bitOpComp=getBitwiseOpComp(hN,hSignalsIn,hSignalsOut,opName,compName,useBitMask,bitMask,isBitMaskZero)




    if(nargin<8)
        isBitMaskZero=false;
    end

    if(nargin<7)
        bitMask=0;
    end

    if(nargin<6)
        useBitMask=false;
    end

    if(nargin<5)
        compName=opName;
    end

    opName=upper(opName);

    if all(bitMask(:)==bitMask(1))

        bitMask=bitMask(1);
    end


    inSigs=pirelab.convertRowVecsToUnorderedVecs(hN,hSignalsIn);
    bitOpComp=pircore.getBitwiseOpComp(hN,inSigs,hSignalsOut,opName,compName,useBitMask,bitMask,isBitMaskZero);

end


