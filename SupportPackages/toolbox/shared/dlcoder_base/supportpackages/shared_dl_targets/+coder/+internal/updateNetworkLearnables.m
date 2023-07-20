function net=updateNetworkLearnables(net,learnables)












%#codegen



    coder.allowpcode('plain');

    if coder.target('MATLAB')

        assert(isa(net,'dlnetwork'),...
        "Expected a dlnetwork object as the first input.")

        assert(isa(learnables,'struct'),"Expected the second input corresponding to network learnables to be a struct.");
        learnableLayerNames=fieldnames(learnables);
        numLayersWithLearnables=numel(learnableLayerNames);

        if isa(net,'dlnetwork')


            allValues=cell(1,numLayersWithLearnables);
            parameterNames=cell(1,numLayersWithLearnables);

            for iLayer=1:numLayersWithLearnables
                layerName=learnableLayerNames{iLayer};
                layerLearnables=learnables.(layerName);
                layerLearnableNames=fieldnames(layerLearnables);
                numLayerLearnables=length(layerLearnableNames);

                allValues{iLayer}=struct2cell(layerLearnables)';

                paramNames=strings(1,numLayerLearnables);
                paramNames(:)=string(layerLearnableNames);
                parameterNames{iLayer}=paramNames;
            end


            networkLearnablesValues=net.Learnables.Value;
            layerNames=net.Learnables.Layer;
            allValues=[allValues{:}]';

            numLearnables=size(networkLearnablesValues);
            for iLearnable=1:numLearnables
                allValues{iLearnable}=dlarray(allValues{iLearnable},dims(networkLearnablesValues{iLearnable}));
            end

            varNames={'Layer','Parameter','Value'};
            learnablesTable=table(layerNames,[parameterNames{:}]',allValues,'VariableNames',varNames);
            net.Learnables=learnablesTable;

        else
            if false

                snet=net.getInternalDAGNetwork();
                learnableValues={};
                iLearnable=1;

                numLayers=numel(snet.Layers);
                learnableLayerIdx=0;
                for layerIndex=1:numLayers
                    layer=snet.Layers{layerIndex};
                    if~isempty(layer.LearnableParameters)
                        learnableLayerIdx=learnableLayerIdx+1;
                        layerLearnables=learnables.(learnableLayerNames{learnableLayerIdx});
                        layerLearnableNames=fieldnames(layerLearnables);

                        if isa(layer,'nnet.internal.cnn.layer.FullyConnected')




                            learnableValues{iLearnable}=layer.ParConverter.toInternal(...
                            layerLearnables.(layerLearnableNames{1}),layer.InputSize,layer.NumNeurons,...
                            layer.ObservationDim,'Weights');
                            learnableValues{iLearnable+1}=layer.ParConverter.toInternal(...
                            layerLearnables.(layerLearnableNames{2}),layer.InputSize,layer.NumNeurons,...
                            layer.ObservationDim,'Bias');
                            iLearnable=iLearnable+2;
                        else
                            for layerParamIndex=1:numel(layer.LearnableParameters)
                                learnableValues{iLearnable}=...
                                layerLearnables.(layerLearnableNames{layerParamIndex});
                                iLearnable=iLearnable+1;
                            end
                        end
                    end
                end
                snet=setLearnableParameterValues(snet,learnableValues);
                net=net.setInternalDAGNetwork(snet);
            end
        end
    else

        coder.internal.reference_parameter(net);
        net.setLearnables(learnables);
    end

end
