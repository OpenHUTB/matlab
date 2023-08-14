function cgirComp=getBitSetByBitMaskComp(hN,hInSignals,hOutSignals,isBitSet,bitIndex,compName)




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











    wordlen=outType.WordLength;
    isSigned=outType.Signed;

    isWire=true;
    bitMask=fi(zeros(dimlen,1),isSigned,wordlen,0,hdlfimath);
    for ii=1:dimlen
        iBit=bitIndex(ii)-1;
        if iBit<0
            iBit=0;
        elseif iBit>wordlen
            iBit=wordlen;
        else
            isWire=false;
        end

        bitMask(ii)=bitshift(1,iBit);
        if~isBitSet
            bitMask(ii)=bitcmp(bitMask(ii));
        end
    end

    if isWire
        cgirComp=pircore.getWireComp(hN,hInSignals,hOutSignals,compName);
    else
        cgirComp=hN.addComponent2(...
        'kind','cgireml',...
        'Name',compName,...
        'InputSignals',hInSignals,...
        'OutputSignals',hOutSignals,...
        'EMLFileName','hdleml_bitsetwithmask',...
        'EMLParams',{isBitSet,bitMask},...
        'EMLFlag_ParamsFollowInputs',false,...
        'EMLFlag_RunLoopUnrolling',false);
    end
end


