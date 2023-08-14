function activationsNeedReshapeBool=checkIfActivationsNeedReshape(obj,layerIndices)







    optimizedLayerGraph=obj.getOptimizedLayerGraph();


    isCustomCoderLayerGraph=true;
    activationsNeedReshapeBool=coder.internal.DeepLearningNetworkUtils.checkIfFolded(...
    optimizedLayerGraph,layerIndices,isCustomCoderLayerGraph);

end
