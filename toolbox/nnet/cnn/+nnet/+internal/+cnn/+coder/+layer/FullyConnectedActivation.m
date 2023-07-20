classdef FullyConnectedActivation<nnet.internal.cnn.layer.FusedLayer





    properties(Constant)

        DefaultName='fcWithActivation'
    end


    properties(SetAccess=private)


InputSize


OutputSize


ActivationFunctionType




ActivationParams
    end


    properties(Dependent,SetAccess=private)
Weights
Bias
    end


    properties(Dependent)
FullyConnectedLayer
ActivationLayer
    end


    methods
        function weights=get.Weights(this)
            weights=this.LearnableParameters(1).HostValue;
            if isa(weights,'dlarray')
                weights=extractdata(weights);
            end
            weights=nnet.internal.cnn.layer.util.FullyConnectedWeightsConverter.toExternal(...
            weights,this.OutputSize);
        end

        function bias=get.Bias(this)
            bias=this.LearnableParameters(2).HostValue;
            if(~isempty(bias))
                if isa(bias,'dlarray')
                    bias=extractdata(bias);
                end
                bias=nnet.internal.cnn.layer.util.FullyConnectedBiasConverter.toExternal(...
                bias,this.OutputSize);
            end
        end

        function layer=get.FullyConnectedLayer(this)
            layer=this.OriginalLayers{1};
        end

        function layer=get.ActivationLayer(this)
            layer=this.OriginalLayers{2};
        end

    end


    methods

        function obj=FullyConnectedActivation(name,layerGraph)

            obj=obj@nnet.internal.cnn.layer.FusedLayer(name,layerGraph);
            fcLayer=layerGraph.Layers{1};
            obj.InputSize=fcLayer.InputSize;
            obj.OutputSize=fcLayer.NumNeurons;

            activationLayer=layerGraph.Layers{2};


            [obj.ActivationFunctionType,obj.ActivationParams]=nnet.internal.cnn.util.getActivationFunctionTypeAndParams(activationLayer);
        end

        function this=setupForHostPrediction(this)


            this=setupForHostPrediction@nnet.internal.cnn.layer.FusedLayer(this);

            this.LearnableParameters(1).UseGPU=false;
            this.LearnableParameters(2).UseGPU=false;
        end

        function this=setupForGPUPrediction(this)


            this=setupForGPUPrediction@nnet.internal.cnn.layer.FusedLayer(this);

            this.LearnableParameters(1).UseGPU=true;
            this.LearnableParameters(2).UseGPU=true;
        end

    end

    methods(Static)

        function layerFuser=getLayerFuser(activationLayerClassName)

            layerFuser=nnet.internal.cnn.optimizer.SequenceLayerFuser(...
            nnet.internal.cnn.optimizer.FusedLayerFactory(...
            "nnet.internal.cnn.coder.layer.FullyConnectedActivation"),...
            ["nnet.internal.cnn.layer.FullyConnected";...
            activationLayerClassName]);
        end
    end

    methods(Access=protected)
        function bufferInfo=getBufferInfo(~,~)
            bufferInfo=nnet.internal.cnn.util.BufferInfo.generateSISOBufferInfo(2);
        end
    end
end