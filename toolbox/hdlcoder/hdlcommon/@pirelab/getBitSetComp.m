function cgirComp=getBitSetComp(hN,hInSignals,hOutSignals,isBitSet,bitIndex,compName,useBitMask)



    if nargin<7
        useBitMask=true;
    end


    if(nargin<6)
        if isBitSet
            compName='bitset';
        else
            compName='bitclear';
        end
    end

    cgirComp=pircore.getBitSetComp(hN,hInSignals,hOutSignals,isBitSet,bitIndex,compName,useBitMask);

end

