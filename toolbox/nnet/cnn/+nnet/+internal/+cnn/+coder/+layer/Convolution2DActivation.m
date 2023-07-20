classdef Convolution2DActivation<nnet.internal.cnn.layer.FusedLayer





    properties(Constant)

        DefaultName='convWithActivation'
    end


    properties(SetAccess=private)
EffectiveFilterSize
Stride
DilationFactor
PaddingMode
PaddingSize
PaddingValue
NumFilters


ActivationFunctionType




ActivationParams
    end


    properties(Dependent,SetAccess=private)
Weights
Bias
    end


    properties(Dependent,SetAccess=private)
ConvolutionLayer
ActivationLayer
    end

    properties(Access=private)

ExecutionStrategy
    end


    methods
        function weights=get.Weights(this)
            weights=this.LearnableParameters(1);
        end

        function bias=get.Bias(this)
            bias=this.LearnableParameters(2);
        end

        function layer=get.ConvolutionLayer(this)
            layer=this.OriginalLayers{1};
        end

        function layer=get.ActivationLayer(this)
            layer=this.OriginalLayers{2};
        end

    end


    methods

        function obj=Convolution2DActivation(name,layerGraph)

            obj=obj@nnet.internal.cnn.layer.FusedLayer(name,layerGraph);
            convLayer=layerGraph.Layers{1};
            obj.EffectiveFilterSize=convLayer.EffectiveFilterSize;
            obj.Stride=convLayer.Stride;
            obj.DilationFactor=convLayer.DilationFactor;
            obj.PaddingMode=convLayer.PaddingMode;
            obj.PaddingSize=convLayer.PaddingSize;
            obj.PaddingValue=convLayer.PaddingValue;
            obj.NumFilters=convLayer.NumFilters;

            activationLayer=layerGraph.Layers{2};


            [obj.ActivationFunctionType,obj.ActivationParams]=nnet.internal.cnn.util.getActivationFunctionTypeAndParams(activationLayer);
        end

        function this=prepareForTraining(this)
            this.LearnableParameters=nnet.internal.cnn.layer.learnable.convert2training(this.LearnableParameters);
            this=prepareForTraining@nnet.internal.cnn.layer.FusedLayer(this);
        end

        function this=prepareForPrediction(this)
            this.LearnableParameters=nnet.internal.cnn.layer.learnable.convert2prediction(this.LearnableParameters);
            this=prepareForPrediction@nnet.internal.cnn.layer.FusedLayer(this);
        end

        function this=setupForHostPrediction(this)
            this=setHostStrategy(this);


            this=setupForHostPrediction@nnet.internal.cnn.layer.FusedLayer(this);

            this.LearnableParameters(1).UseGPU=false;
            this.LearnableParameters(2).UseGPU=false;
        end

        function this=setupForGPUPrediction(this)
            this=setGPUStrategy(this);


            this=setupForGPUPrediction@nnet.internal.cnn.layer.FusedLayer(this);

            this.LearnableParameters(1).UseGPU=true;
            this.LearnableParameters(2).UseGPU=true;
        end

        function this=setupForHostTraining(this)
            this=setHostStrategy(this);


            if isempty(this.ExecutionStrategy)
                this=setupForHostTraining@nnet.internal.cnn.layer.FusedLayer(this);
            end
        end

        function this=setupForGPUTraining(this)
            this=setGPUStrategy(this);


            if isempty(this.ExecutionStrategy)
                this=setupForGPUTraining@nnet.internal.cnn.layer.FusedLayer(this);
            end
        end

    end


    methods


        function Z=predict(this,X)
            if~isempty(this.ExecutionStrategy)
                inputSize=[size(X,1),size(X,2)];
                paddingSize=iCalculatePaddingSizeFromInputSize(...
                this.PaddingMode,...
                this.PaddingSize,...
                this.EffectiveFilterSize,...
                this.Stride,inputSize);
                Z=this.ExecutionStrategy.forward(X,...
                this.LearnableParameters(1).Value,...
                this.LearnableParameters(2).Value,...
                paddingSize,...
                this.Stride,...
                this.DilationFactor);
            else
                Z=predict@nnet.internal.cnn.layer.FusedLayer(this,X);
            end
        end



        function[Z,memory]=forward(this,X)
            if~isempty(this.ExecutionStrategy)
                Z=predict(this,X);
                memory=[];
            else
                [Z,memory]=forward@nnet.internal.cnn.layer.FusedLayer(this,X);
            end
        end



        function varargout=backward(this,X,Z,dLossdZ,memory)
            if~isempty(this.ExecutionStrategy)
                inputSize=[size(X,1),size(X,2)];
                paddingSize=iCalculatePaddingSizeFromInputSize(...
                this.PaddingMode,...
                this.PaddingSize,...
                this.EffectiveFilterSize,...
                this.Stride,inputSize);
                [varargout{1:nargout}]=this.ExecutionStrategy.backward(...
                X,this.LearnableParameters(1).Value,Z,dLossdZ,...
                paddingSize,...
                this.Stride,...
                this.DilationFactor);
            else
                [varargout{1:nargout}]=...
                backward@nnet.internal.cnn.layer.FusedLayer(this,...
                X,Z,dLossdZ,memory);
            end
        end

    end


    methods(Access=private)

        function this=setHostStrategy(this)
            if(isscalar(this.NumFilters)&&strcmp(this.ActivationFunctionType,'ReLU'))
                this.ExecutionStrategy=nnet.internal.cnn.layer.util.ConvolutionReLUHostStrategy(this.PaddingValue);
            else
                this.ExecutionStrategy=[];
            end
        end

        function this=setGPUStrategy(this)
            if(isscalar(this.NumFilters)&&strcmp(this.ActivationFunctionType,'ReLU'))
                this.ExecutionStrategy=nnet.internal.cnn.layer.util.ConvolutionReLUGPUStrategy(this.PaddingValue);
            else
                this.ExecutionStrategy=[];
            end
        end
    end

    methods(Access=protected)
        function bufferInfo=getBufferInfo(~,~)
            bufferInfo=nnet.internal.cnn.util.BufferInfo.generateSISOBufferInfo(2);
        end
    end

    methods(Static)
        function layerFuser=getLayerFuser(activationLayerClassName)

            layerFuser=nnet.internal.cnn.optimizer.SequenceLayerFuser(...
            nnet.internal.cnn.optimizer.FusedLayerFactory(...
            "nnet.internal.cnn.coder.layer.Convolution2DActivation"),...
            ["nnet.internal.cnn.layer.Convolution2D";...
            activationLayerClassName]);
        end
    end

end

function paddingSize=iCalculatePaddingSizeFromInputSize(...
    paddingMode,paddingSize,filterOrPoolSize,stride,spatialInputSize)
    paddingSize=nnet.internal.cnn.layer.padding.calculatePaddingSizeFromInputSize(...
    paddingMode,paddingSize,filterOrPoolSize,stride,spatialInputSize);
end