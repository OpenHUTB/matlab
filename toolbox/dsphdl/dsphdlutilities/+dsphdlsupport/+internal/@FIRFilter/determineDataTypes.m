function pirTypes=determineDataTypes(this,dataInPIRType,blockInfo)




    pirTypes=struct();

    dataInBaseType=dataInPIRType.BaseType.BaseType;
    inputNT=numerictype(dataInBaseType.Signed,dataInBaseType.WordLength,-dataInBaseType.FractionLength);

    [accumulatorNT,outputNT]=dsphdl.FIRFilter.getPrecision(...
    blockInfo.NumeratorQuantized,inputNT,blockInfo.OutputDataType);


    numChannels=dataInPIRType.getDimensions;

    if numChannels==1
        isComplex=dataInPIRType.isComplexType;
    else
        isComplex=dataInPIRType.BaseType.isComplexType;
    end

    pirTypes.coefficientsType=this.createPIRType(blockInfo.NumeratorQuantized.numerictype);


    pirTypes.inputType=dataInPIRType;
    pirTypes.accumulatorType=this.createPIRType(accumulatorNT,isComplex,numChannels);
    pirTypes.outputType=this.createPIRType(outputNT,isComplex,numChannels);



...
...
...
...
...
...
...
...
...
...
...
...


    if isfield(pirTypes,'tapSumType')
        multDataInputType=pirTypes.tapSumType;
    else
        multDataInputType=dataInPIRType;
    end

    multDataInputBaseType=multDataInputType.BaseType.BaseType;
    coefficientsBaseType=pirTypes.coefficientsType.BaseType.BaseType;


    extraBit=(multDataInputBaseType.Signed~=coefficientsBaseType.Signed);

    productBaseType=pir_fixpt_t(...
    multDataInputBaseType.Signed||coefficientsBaseType.Signed,...
    multDataInputBaseType.WordLength+coefficientsBaseType.WordLength+extraBit,...
    multDataInputBaseType.FractionLength+coefficientsBaseType.FractionLength);

    pirTypes.productType=this.createPIRType(productBaseType,isComplex,numChannels);

end
