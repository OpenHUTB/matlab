classdef SignalInfo<handle






    methods(Access=public)
        function obj=SignalInfo()
        end

        function sigStruct=convertToStruct(this)



            w=warning('off','MATLAB:structOnObject');
            c=onCleanup(@()warning(w));

            sigStruct=struct(this);

            t=this.type.copy();
            t.convertStructElementsFromTypeInfoToStructs();

            sigStruct.dimensions=t.dimensions;
            sigStruct.dataTypeID=t.dataTypeID;
            sigStruct.dataTypeName=t.dataTypeName;
            sigStruct.dataTypeSize=t.dataTypeSize;
            sigStruct.isEnum=t.isEnum;
            sigStruct.isFixedPoint=t.isFixedPoint;
            sigStruct.isHalf=t.isHalf;
            sigStruct.isString=t.isString;
            sigStruct.isNVBus=t.isNVBus;
            sigStruct.isComplex=t.isComplex;
            sigStruct.isFrame=t.isFrame;
            sigStruct.enumClassification=t.enumClassification;
            sigStruct.enumClassName=t.enumClassName;
            sigStruct.enumLabels=t.enumLabels;
            sigStruct.enumValues=t.enumValues;
            sigStruct.fxpSlopeAdjFactor=t.fxpSlopeAdjFactor;
            sigStruct.fxpNumericType=t.fxpNumericType;
            sigStruct.fxpFractionLength=t.fxpFractionLength;
            sigStruct.fxpBias=t.fxpBias;
            sigStruct.fxpWordLength=t.fxpWordLength;
            sigStruct.fxpFixedExponent=t.fxpFixedExponent;
            sigStruct.fxpSignedness=t.fxpSignedness;
            sigStruct.structElements=t.structElements;
            sigStruct.structElementOffset=t.structElementOffset;
            sigStruct.structElementName=t.structElementName;
        end
    end

    methods(Access=private)
    end

    properties(Access=public)
        blockPath='';
        blockSID='';
        portNumber=0;
        signalName='';
        loggedName='';
        propagatedName='';
        signalSourceUUID='';
        signalSourceUUIDasInteger=0;
        discreteInterval=0;
        sampleTimeString='';
        tid=0;
        leafElements=[];
        isVarDims=0;
        isMessageLine=0;
        isDiscrete=1;
        domainType='';
        maxPoints=0;
        targetAddress=-1;

        type=[];
    end
end
