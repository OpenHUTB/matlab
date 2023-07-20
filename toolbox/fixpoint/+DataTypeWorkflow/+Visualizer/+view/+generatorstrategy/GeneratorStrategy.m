classdef(Abstract)GeneratorStrategy<handle




    properties
        ShiftFactor=129
        MinOpacityValue=0.25
        MaxOpacityValue=1
        MinBinLimit=-128
        MaxBinLimit=127
    end

    methods
        function setLimits(this,limits)
            this.MinBinLimit=limits(1);
            this.MaxBinLimit=limits(2);
        end
    end

    methods(Hidden)
        function addGroup(this,viewData,bins,opacity,color)

            indices=this.translate(bins);
            viewData.RGBColorVector(indices)=color;
            viewData.RGBValueVector(indices)=opacity;

        end

        function addLimits(this,viewData,limits)
            shiftedLimits=this.translate(limits);
            viewData.YLimits=shiftedLimits;
        end

        function vector=generateUniformVector(~,bins,value)
            vector(1:numel(bins))=value;
        end

        function vector=generateLinearInterpolatedVector(~,values,minValue,maxValue)
            vector=[];
            if~isempty(values)
                normalizedValues=normalize(double(values),'norm',inf);
                minNormalizedValue=min(normalizedValues);
                vector=rescale(normalizedValues,max(minNormalizedValue,minValue),maxValue)';
            end
        end
    end

    methods(Abstract)
        generate(this,viewData,histogramVisualizationInfo);
        limits=extractLimits(histogramVisualizationInfo);
        translatedVector=translate(this,vector);
    end


end

