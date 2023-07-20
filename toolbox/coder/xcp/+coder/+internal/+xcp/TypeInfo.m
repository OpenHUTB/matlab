classdef TypeInfo<matlab.mixin.Copyable






    methods(Access=public)
        function obj=TypeInfo()
        end

        function convertStructElementsFromTypeInfoToStructs(this)


            newStructElements=[];
            for i=1:length(this.structElements)
                if~isempty(this.structElements(i))
                    convertStructElementsFromTypeInfoToStructs(this.structElements(i))
                end

                s=struct(this.structElements(i));
                if isempty(newStructElements)
                    newStructElements=s;
                else
                    newStructElements(i)=s;%#ok
                end
            end
            this.structElements=newStructElements;
        end
    end

    properties(Access=public)
        dimensions=1;
        dataTypeID=0;
        dataTypeSize=0;

        isEnum=0;
        isFixedPoint=0;
        isHalf=0;
        isString=0;
        isNVBus=0;

        isComplex=0;
        isFrame=0;

        enumClassification='';
        enumClassName='';
        enumLabels=[];
        enumValues=[];

        fxpSlopeAdjFactor=0;
        fxpNumericType=0;
        fxpFractionLength=0;
        fxpBias=0;
        fxpWordLength=0;
        fxpFixedExponent=0;
        fxpSignedness=0;


        structElements=[];


        structElementOffset=-1;
        structElementName='';


    end
end
