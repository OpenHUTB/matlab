function[learnablesOut,learnablesSizes,learnableLayerIndices]=networkLearnables(net)

















    assert(isa(net,'dlnetwork'),...
    "Expected network to be a dlnetwork.")


    learnablesOut=struct();

    if isa(net,'dlnetwork')
        learnables=net.Learnables;
        numLearnables=size(learnables,1);

        if nargout>1
            learnableLayerIndices=zeros(numLearnables,1);
            layers=net.Layers;
            layerIndices=1:numel(layers);
            learnablesSizes=cell(numLearnables,1);
        end

        for iLearnable=1:numLearnables
            layerName=learnables.Layer(iLearnable);
            paramName=iReplaceNonAlphaNumericUnderscore(learnables.Parameter(iLearnable));
            extractedData=extractdata(learnables.Value{iLearnable});

            if nargout>1
                layerIndex=layerIndices(arrayfun(@(x)strcmp(x.Name,layerName),layers));
                learnableLayerIndices(iLearnable)=layerIndex;
                learnablesSizes{iLearnable}=size(extractedData);
            end

            layerName=iReplaceNonAlphaNumericUnderscore(layerName);
            learnablesOut.(layerName).(paramName)=extractedData;

        end
    else
        if false

            snet=net.getInternalDAGNetwork();
            layers=snet.Layers;
            numLayers=numel(layers);
            learnableCount=0;

            for iLayer=1:numLayers
                layerLearnables=layers{iLayer}.LearnableParameters;
                if~isempty(layerLearnables)
                    layer=layers{iLayer};
                    layerName=iReplaceNonAlphaNumericUnderscore(layer.Name);
                    numLearnables=numel(layerLearnables);





                    if isa(layer,'nnet.internal.cnn.layer.FullyConnected')




                        learnablesOut.(layerName).('learnable1')=nnet.internal.cnn.layer.util.FullyConnectedWeightsConverter.toExternal(...
                        layer.Weights.Value,layer.NumNeurons);
                        learnablesOut.(layerName).('learnable2')=nnet.internal.cnn.layer.util.FullyConnectedBiasConverter.toExternal(...
                        layer.Bias.Value,layer.NumNeurons);

                        if nargout>1
                            learnableLayerIndices(learnableCount+1:learnableCount+2)=iLayer;
                            learnablesSizes{learnablesCount+1}=size(learnablesOut.(layerName).('learnable1'));
                            learnablesSizes{learnablesCount+2}=size(learnablesOut.(layerName).('learnable2'));
                            learnableCount=learnableCount+2;
                        end

                    else
                        for iLearnable=1:numLearnables
                            learnablesOut.(layerName).(['learnable',num2str(iLearnable)])=layerLearnables(iLearnable).Value;


                            if nargout>1
                                learnablesCount=learnablesCount+1;
                                learnablesSizes{learnablesCount}=size(layerLearnables(iLearnable).Value);
                                learnableLayerIndices(learnableCount)=iLayer;
                            end
                        end
                    end
                end
            end
        end
    end

end

function newStr=iReplaceNonAlphaNumericUnderscore(oldStr)


    newStr=regexprep(oldStr,'\W','_');
end
