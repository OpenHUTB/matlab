classdef CompositeSpecificationAdapter<dltargets.internal.quantization.specificationadapter.SpecificationAdapter








    properties(Access=private)
        SkipLayers={};
    end

    methods
        function exponent=getActivationsExponent(this,layerNames)

            activationLayerName=this.getActivationLayerName(layerNames);
            exponent=this.getExponent(activationLayerName,'Activations');
        end

        function exponent=getWeightsExponent(this,layerNames)



            layerName=layerNames{1};
            exponent=this.getExponent(layerName,'Weights');
        end

        function exponent=getBiasExponent(this,layerNames)



            layerName=layerNames{1};
            exponent=this.getExponent(layerName,'Bias');
        end

        function b=hasParameterValue(this,layerNames)


            activationLayerName=this.getActivationLayerName(layerNames);
            b=this.hasConfig(activationLayerName,'Parameter');
        end

        function b=hasActivationsValue(this,layerName)

            b=this.hasConfig(layerName,'Activations');
        end

        function exponent=getParameterExponent(this,layerNames)

            activationLayerName=this.getActivationLayerName(layerNames);
            exponent=this.getExponent(activationLayerName,'Parameter');
        end

        function this=setSkipLayer(this,layerNames,compKey,compName)
            skippableComps={'gpucoder.conv_layer_comp',...
            'gpucoder.fused_conv_activation_layer_comp',...
            'gpucoder.fc_layer_comp',...
            'gpucoder.max_pool_layer_comp'};


            if ismember(compKey,skippableComps)



                activationLayerName=this.getActivationLayerName(layerNames);
                activationConfig=this.getEntityConfig(activationLayerName,'Activations');
                if activationConfig.Codegen.DataTypeStr=="single"
                    this.SkipLayers{end+1}=compName;
                end
            end
        end

        function skipLayers=getSkipLayers(this)
            if isempty(this.SkipLayers)
                skipLayers={''};
            else
                skipLayers=this.SkipLayers;
            end
            skipLayers={skipLayers};
        end
    end

    methods(Access=private)
        function exponent=getExponent(this,layerName,configName)
            entity=this.getEntityConfig(layerName,configName);
            exponent=entity.Codegen.ScalingExponent;
        end

        function entity=getEntityConfig(this,layerName,configName)
            layerNumericSpec=this.Specification(layerName);
            entity=layerNumericSpec.getValueConfig(configName);
        end

        function layerName=getActivationLayerName(this,layerNames)


            for idx=numel(layerNames):-1:1
                layerName=layerNames{idx};
                if this.hasConfig(layerName,'Activations')
                    return;
                end
            end
        end

        function b=hasConfig(this,layerName,entityName)
            b=false;
            if this.Specification.isKey(layerName)
                layerNumericSpec=this.Specification(layerName);
                b=layerNumericSpec.hasValueConfig(entityName);
            end
        end
    end
end


