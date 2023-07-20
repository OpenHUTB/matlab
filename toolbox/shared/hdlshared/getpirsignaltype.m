function pirType=getpirsignaltype(slSignalType,isComplex,portDims)









    narginchk(1,3);

    if nargin<3
        portDims=1;
    end

    if nargin<2
        isComplex=0;
    end

    pirType=pirelab.convertSLType2PirType(slSignalType);

    if isComplex
        pirType=pir_complex_t(pirType);
    end

    if iscolumn(portDims)
        portDims=portDims';
    end

    if~isascalartype(portDims)
        pirType=pirelab.createPirArrayType(pirType,portDims);
    end
end
