function fillFromStructElementMXArray(this,structElement)





    this.dimensions=structElement.dimensions;
    this.dataTypeID=int32(structElement.dataTypeID);
    this.dataTypeSize=structElement.dataTypeSize;

    this.isEnum=structElement.isEnum;
    this.isFixedPoint=structElement.isFixedPoint;
    this.isHalf=structElement.isHalf;
    this.isString=structElement.isString;
    this.isNVBus=structElement.isNVBus;
    this.isComplex=structElement.isComplex;
    this.isFrame=structElement.isFrame;

    if this.isEnum

        this.enumClassification=structElement.enumClassification;
        this.enumClassName=structElement.enumClassName;
        this.enumLabels=structElement.enumLabels;
        this.enumValues=int32(structElement.enumValues);
    end


    if this.isFixedPoint
        this.fxpSlopeAdjFactor=double(structElement.fxpSlopeAdjFactor);
        this.fxpNumericType=int32(structElement.fxpNumericType);
        this.fxpFractionLength=int32(structElement.fxpFractionLength);
        this.fxpBias=double(structElement.fxpBias);
        this.fxpWordLength=int32(structElement.fxpWordLength);
        this.fxpFixedExponent=int32(structElement.fxpFixedExponent);
        this.fxpSignedness=int32(structElement.fxpSignedness);
    end

    this.structElementOffset=structElement.structElementOffset;
    this.structElementName=structElement.structElementName;

end
