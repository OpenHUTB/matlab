classdef TableSpecificationAdapter<dltargets.internal.quantization.specificationadapter.SpecificationAdapter








    properties(Access=private)
OriginalContext
    end

    methods

        function obj=TableSpecificationAdapter(context)
            specification=createLayerNameMapping(context.instrumentationData,context.exponentScheme);
            obj=obj@dltargets.internal.quantization.specificationadapter.SpecificationAdapter(specification);
            obj.OriginalContext=context;
        end

        function exponent=getActivationsExponent(this,layerNames)
            activationLayerName=this.getLayerName(layerNames,'Activations');
            exponent=this.getExponent(activationLayerName,'Activations');
        end

        function exponent=getWeightsExponent(this,layerNames)
            weightLayerName=this.getLayerName(layerNames,'Weights');
            exponent=this.getExponent(weightLayerName,'Weights');
        end

        function exponent=getBiasExponent(this,layerNames)
            biasLayerName=this.getLayerName(layerNames,'Bias');
            exponent=this.getExponent(biasLayerName,'Bias');
        end

        function b=hasParameterValue(this,layerNames)
            activationLayerName=this.getLayerName(layerNames,'Activations');
            b=this.hasEntity(activationLayerName,'Parameter');
        end

        function b=hasActivationsValue(this,layerName)

            b=this.hasEntity(layerName,'Activations');
        end

        function exponent=getParameterExponent(this,layerNames)
            activationLayerName=this.getLayerName(layerNames,'Activations');
            exponent=this.getExponent(activationLayerName,'Parameter');
        end

        function this=setSkipLayer(this,~,~,~)


        end

        function skipLayers=getSkipLayers(this)
            skipLayers={this.OriginalContext.skipLayers};
        end
    end

    methods(Access=private)
        function exponent=getExponent(this,layerName,entityName)
            exponent=this.Specification(getMapKey(layerName,entityName));
        end

        function b=hasEntity(this,layerName,entityName)
            key=getMapKey(layerName,entityName);
            b=this.Specification.isKey(key);
        end

        function layerName=getLayerName(this,layerNames,entityName)
            for idx=numel(layerNames):-1:1
                layerName=layerNames{idx};
                if this.hasEntity(layerName,entityName)
                    return;
                end
            end
        end
    end
end

function layerNameToStatisticsMap=createLayerNameMapping(calibrationStats,exponentScheme)


    dataAdapter=dlinstrumentation.DataAdapter("ExponentScheme",exponentScheme);
    exponents=dataAdapter.computeExponents(calibrationStats,8).exponentsData;
    exponentTable=struct2table(exponents);

    layerNameToStatisticsMap=containers.Map(getMapKey(calibrationStats.DLTLayerName,calibrationStats.EntityName),exponentTable.Exponent);

end

function keyName=getMapKey(layerName,entityName)
    keyName=layerName+"_"+entityName;
end


