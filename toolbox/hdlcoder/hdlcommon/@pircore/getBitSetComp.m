function bitsetComp=getBitSetComp(hN,hInSignals,hOutSignals,isBitSet,bitIndex,compName,useBitMask)



    if nargin<7
        useBitMask=true;
    end


    if nargin<6
        if isBitSet
            compName='bitset';
        else
            compName='bitclear';
        end
    end

    bitsetComp=hN.addComponent2(...
    'kind','bitset_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'BitSet',isBitSet,...
    'BitPos',bitIndex,...
    'UsingBitMask',useBitMask...
    );


end

