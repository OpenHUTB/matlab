function cgirComp=getBitSetByConcatComp(hN,hInSignals,hOutSignals,isBitSet,bitIndex,compName)







    if nargin<6
        if isBitSet
            compName='bitset';
        else
            compName='bitclear';
        end
    end

    [dimlen,outType]=pirelab.getVectorTypeInfo(hOutSignals(1));
    [indimlen,~]=pirelab.getVectorTypeInfo(hInSignals(1));

    if dimlen>1&&length(bitIndex)==1
        bitIndex=repmat(bitIndex,dimlen,1);
    end

    if indimlen~=dimlen
        hInSignals=pirelab.scalarExpand(hN,hInSignals(1),dimlen);
    end

    bitval=1;
    if~isBitSet
        bitval=0;
    end

    wordlen=outType.WordLength;

    cgirComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_bitset',...
    'EMLParams',{wordlen,bitval,bitIndex},...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_RunLoopUnrolling',false);
end

