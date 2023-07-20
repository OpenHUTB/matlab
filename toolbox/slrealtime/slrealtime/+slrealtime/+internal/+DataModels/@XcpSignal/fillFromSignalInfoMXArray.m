function fillFromSignalInfoMXArray(this,streamingSignal)





    this.blockPath=streamingSignal.blockPath;
    this.blockSID=streamingSignal.blockSID;
    this.portNumber=streamingSignal.portNumber;
    this.signalName=streamingSignal.signalName;
    this.loggedName=streamingSignal.loggedName;
    this.propagatedName=streamingSignal.propagatedName;
    this.signalSourceUUID=streamingSignal.signalSourceUUID;
    this.signalSourceUUIDasInteger=streamingSignal.signalSourceUUIDasInteger;
    this.discreteInterval=streamingSignal.discreteInterval;
    this.sampleTimeString=streamingSignal.sampleTimeString;
    if isfield(streamingSignal,'sampleTimeStringToDisplay')||isprop(streamingSignal,'sampleTimeStringToDisplay')
        this.sampleTimeStringToDisplay=streamingSignal.sampleTimeStringToDisplay;
    else
        this.sampleTimeStringToDisplay=streamingSignal.sampleTimeString;
    end

    this.tid=int32(streamingSignal.tid);

    this.isVarDims=streamingSignal.isVarDims;
    this.isMessageLine=streamingSignal.isMessageLine;
    this.isDiscrete=streamingSignal.isDiscrete;
    this.domainType=streamingSignal.domainType;
    this.maxPoints=streamingSignal.maxPoints;
    this.targetAddress=streamingSignal.targetAddress;

    this.dimensions=streamingSignal.dimensions;

    if any(this.dimensions>1)
        this.isArraySignal=true;
    end

    this.dataTypeID=int32(streamingSignal.dataTypeID);
    this.dataTypeSize=streamingSignal.dataTypeSize;

    this.isEnum=streamingSignal.isEnum;
    this.isFixedPoint=streamingSignal.isFixedPoint;
    this.isHalf=streamingSignal.isHalf;
    this.isString=streamingSignal.isString;
    this.isNVBus=streamingSignal.isNVBus;
    this.isComplex=streamingSignal.isComplex;
    this.isFrame=streamingSignal.isFrame;

    if isfield(streamingSignal,'matlabObsFcn')||isprop(streamingSignal,'matlabObsFcn')
        if~isempty(streamingSignal.matlabObsFcn)
            this.attachMatlabObs=true;
            this.matlabObsFcn=streamingSignal.matlabObsFcn;
            this.matlabObsParam=streamingSignal.matlabObsParam;
            this.matlabObsCallbackGroup=streamingSignal.matlabObsCallbackGroup;
            this.matlabObsFuncHandle=streamingSignal.matlabObsFuncHandle;
            this.matlabObsDropIfBusy=streamingSignal.matlabObsDropIfBusy;
        end
    end

    if this.isEnum

        this.enumClassification=streamingSignal.enumClassification;
        this.enumClassName=streamingSignal.enumClassName;
        this.enumLabels=streamingSignal.enumLabels;
        this.enumValues=int32(streamingSignal.enumValues);
    end

    if this.isFixedPoint
        this.fxpSlopeAdjFactor=double(streamingSignal.fxpSlopeAdjFactor);
        this.fxpNumericType=int32(streamingSignal.fxpNumericType);
        this.fxpFractionLength=int32(streamingSignal.fxpFractionLength);
        this.fxpBias=double(streamingSignal.fxpBias);
        this.fxpWordLength=int32(streamingSignal.fxpWordLength);
        this.fxpFixedExponent=int32(streamingSignal.fxpFixedExponent);
        this.fxpSignedness=int32(streamingSignal.fxpSignedness);
    end
    if~isempty(streamingSignal.structElements)
        this.structElementOffset=streamingSignal.structElementOffset;
        this.structElementName=streamingSignal.structElementName;
    end

    if isfield(streamingSignal,'instrumentUUID')||isprop(streamingSignal,'instrumentUUID')
        this.instrumentUUID=streamingSignal.instrumentUUID;
    else
        this.instrumentUUID=-1;
    end

    if isfield(streamingSignal,'displayInSDI')||isprop(streamingSignal,'displayInSDI')
        this.displayInSDI=streamingSignal.displayInSDI;
    else
        this.displayInSDI=true;
    end

end
