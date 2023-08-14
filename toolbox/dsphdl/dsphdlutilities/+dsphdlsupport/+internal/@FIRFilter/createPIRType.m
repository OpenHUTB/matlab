function pirt=createPIRType(~,baseType,isComplex,numChannels)




    if isnumerictype(baseType)
        pirt=pir_fixpt_t(baseType.SignednessBool,baseType.WordLength,-baseType.FractionLength);
    else
        pirt=baseType;
    end

    if exist('isComplex','var')&&isComplex
        pirt=pir_complex_t(pirt);
    end

    if exist('numChannels','var')&&(numChannels>1)
        pirt=pirelab.getPirVectorType(pirt,numChannels,false);
    end

end
