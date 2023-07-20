function bitOpComp=getBitwiseOpComp(hN,hSignalsIn,hSignalsOut,opName,compName,useBitMask,bitMask,isBitMaskZero)



    if(nargin<8)
        isBitMaskZero=0;
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

    bitOpComp=hN.addComponent2(...
    'kind','bitwiseop_comp',...
    'name',compName,...
    'InputSignals',hSignalsIn,...
    'OutputSignals',hSignalsOut,...
    'OpName',opName,...
    'UseBitMask',useBitMask,...
    'BitMask',bitMask,...
    'IsBitMaskZero',isBitMaskZero);

end



