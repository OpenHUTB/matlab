classdef MexNetworkOptimizer<nnet.internal.cnn.optimizer.NetworkOptimizable





    properties(Access=private)

UnderlyingMexNetwork


NumberOfLayers
    end

    methods
        function obj=MexNetworkOptimizer(network,mexNetworkConfig,useGPU,mexCache)


            import nnet.internal.cnn.coder.*

            obj.SupportsTraining=false;
            obj.SupportsUpdate=false;


            nnet.internal.cnn.coder.mustBeSupportedPlatformForMex(useGPU);


            [obj.UnderlyingMexNetwork,mexNetworkKey]=...
            mexCache.getMexNetwork(network,mexNetworkConfig);


            obj.Identifier=[mexNetworkKey,'_',obj.UnderlyingMexNetwork.MexFunctionName];
        end

        function optimizedLayerGraph=optimize(this,internalLayerGraph)





            this.NumberOfLayers=numel(internalLayerGraph.Layers);

            fusedLayerFcn=this.UnderlyingMexNetwork.Config.getFusedLayerFcn();
            defaultName=nnet.internal.cnn.coder.MexNetworkLayer.DefaultName;
            layer=fusedLayerFcn(defaultName,internalLayerGraph,this.UnderlyingMexNetwork);


            optimizedLayerGraph=nnet.internal.cnn.LayerGraph({layer});

            this.GraphChanged=true;
        end

        function[layerIndex,layerOffset]=mapFromOriginal(this,layerIndex)
            layerOffset=1;
            if~isempty(this.NumberOfLayers)
                layerOffset=layerIndex;
                layerIndex=1;
            end
        end

        function layerIndices=mapToOriginal(this,layerIndex)
            layerIndices=layerIndex;
            if~isempty(this.NumberOfLayers)
                layerIndices=(1:this.NumberOfLayers)';
            end
        end

        function internalLayerGraph=optimizeForTraining(~,~)%#ok<STOUT>






            error(message('nnet_cnn:dlAccel:TracingUnsupported'))
        end
    end
end


