





















%#codegen



function outputs=callPredict(obj,inputsT,...
    ~,~,~,~,...
    sortedOutputLayerIndices,sortedOutputPortIndices)

    coder.allowpcode('plain');
    coder.inline('always');

    if coder.const(isa(sortedOutputLayerIndices,'cell'))
        sortedOutputLayerIndicesVec=coder.nullcopy(zeros(1,coder.const(length(sortedOutputLayerIndices))));
        sortedOutputPortIndicesVec=coder.nullcopy(zeros(1,coder.const(length(sortedOutputLayerIndices))));
        coder.unroll
        for idx=1:coder.const(length(sortedOutputLayerIndices))

            sortedOutputPortIndicesVec(idx)=sortedOutputPortIndices{idx}+1;
            sortedOutputLayerIndicesVec(idx)=sortedOutputLayerIndices{idx};
        end
    else
        sortedOutputLayerIndicesVec=sortedOutputLayerIndices;
    end


    obj.checkNetworkIsSetUpForPredictCall();

    outputs=obj.callActivation(inputsT,coder.const(sortedOutputLayerIndicesVec),...
    coder.const(sortedOutputPortIndicesVec),obj.DLTNetwork,obj.NetworkInfo,obj.NetworkName,...
    obj.CodegenInputSizes,obj.InputLayerIndices);

end
