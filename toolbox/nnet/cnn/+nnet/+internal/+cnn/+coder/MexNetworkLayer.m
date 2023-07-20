classdef MexNetworkLayer<nnet.internal.cnn.layer.FusedLayer






    properties(Constant)

        DefaultName='mexNetwork'
    end

    properties(SetAccess=private)


        InputSize(1,:)cell



        InputData(1,:)cell
    end

    properties(Access=protected)

UnderlyingMexNetwork
    end


    methods

        function obj=MexNetworkLayer(mexNetwork,name,layerGraph,varargin)
            obj=obj@nnet.internal.cnn.layer.FusedLayer(name,layerGraph,varargin{:});


            obj.UnderlyingMexNetwork=mexNetwork;


            [obj.InputData,obj.InputSize]=iGetNetworkInputSizesInformation(...
            layerGraph.Layers,obj.InputLayerIdx);
        end

        function this=prepareForTraining(this)


            assert(false,"MexNetworkLayer cannot be used for training");
        end

        function this=setupForHostTraining(this)


            assert(false,"MexNetworkLayer cannot be used for training");
        end

        function this=setupForGPUTraining(this)


            assert(false,"MexNetworkLayer cannot be used for training");
        end

        function externalLabel=getExternalLabel(this)


            externalLabel=getOriginalLayerNames(this,this.InputLayerIdx);
        end
    end


    methods(Abstract)

        Z=predict(this,X)
    end


    methods(Access=protected)

        function this=cacheLearnables(this)



        end

        function layers=restoreLearnables(~,layers)


        end
    end

end

function[inputData,inputSize]=iGetNetworkInputSizesInformation(originalLayers,inputLayerIdx)




    uniqueInputLayerIdx=unique(inputLayerIdx,'stable');
    numLayersWithInputs=numel(uniqueInputLayerIdx);

    numInputs=numel(inputLayerIdx);
    inputData=cell(1,numInputs);
    inputSize=cell(1,numInputs);
    idx=1;
    for i=1:numLayersWithInputs
        currentLayerIdx=uniqueInputLayerIdx(i);
        currentLayer=originalLayers{currentLayerIdx};
        numInputsCurrentLayer=nnz(inputLayerIdx==currentLayerIdx);


        if numInputsCurrentLayer==1
            inputData{idx}=currentLayer.InputData;
            inputSize{idx}=currentLayer.InputSize;
        else
            k=1:numInputsCurrentLayer;
            inputData(idx+k)=currentLayer.InputData;
            inputSize(idx+k)=currentLayer.InputSize;
        end
        idx=idx+numInputsCurrentLayer;
    end
end
