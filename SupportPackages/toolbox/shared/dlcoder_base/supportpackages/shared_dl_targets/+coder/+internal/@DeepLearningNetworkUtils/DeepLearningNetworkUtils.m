%#codegen


classdef DeepLearningNetworkUtils




    methods(Hidden=true)
        function obj=DeepLearningNetworkUtils()
            coder.allowpcode('plain');
        end
    end

    methods(Static)



        layerArg=validateLayerArg(layerArg)

        validateStatefulCall(isRNN,functionName);



        maxSequenceLength=getSequenceLengthRNNCellInput(indata,miniBatchSize,miniBatchIdx,sequenceLengthMode,numMiniBatches,remainder,isImageInput);


        [miniBatchSize,numMiniBatches,remainder]=getMiniBatchInfo(miniBatchSize,batchSize,callerFunction)




        [opSize,sortedlayerIdx,portId,isSequenceOutput,isSequenceFolded]=getIOPropsForLayer(net,layerArg,inputSizes,targetlib)



        areLayersBetweenFoldAndUnfold=checkIfFolded(lgraph,sortedLayerIndices,isCustomCoderLayerGraph);


        out=permuteData(in,permutationDims);
    end
end
