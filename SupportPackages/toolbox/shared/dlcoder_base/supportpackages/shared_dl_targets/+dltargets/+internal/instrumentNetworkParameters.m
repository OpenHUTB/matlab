function instrumentNetworkParameters(~)





    compsWithInputLayer=dltargets.internal.findPIRComponentsByCompKey({'gpucoder.input_layer_comp'});

    compsWithLearnableParameters=dltargets.internal.findPIRComponentsByCompKey({'gpucoder.conv_layer_comp','gpucoder.fused_conv_activation_layer_comp','gpucoder.fc_layer_comp','gpucoder.transposedconv_layer_comp'});
    numOfCompsWithLearnableParams=numel(compsWithLearnableParameters);



    compsWithRNNLearnableParameters=dltargets.internal.findPIRComponentsByCompKey({'gpucoder.rnn_layer_comp'});
    numOfCompsWithRNNLearnableParams=numel(compsWithRNNLearnableParameters);


    compsWithLeakyRelu=dltargets.internal.findPIRComponentsByCompKey({'gpucoder.leakyrelu_layer_comp'});
    numOfLeakyRelus=numel(compsWithLeakyRelu);


    compsWithClippedRelu=dltargets.internal.findPIRComponentsByCompKey({'gpucoder.clippedrelu_layer_comp'});
    numOfClippedRelus=numel(compsWithClippedRelu);


    compsWithAvgPool=dltargets.internal.findPIRComponentsByCompKey({'gpucoder.avg_pool_layer_comp'});
    numOfAvgPools=numel(compsWithAvgPool);

    numEntities=numOfCompsWithLearnableParams*2+numOfCompsWithRNNLearnableParams*2+numOfLeakyRelus+numOfClippedRelus+numOfAvgPools;



    if numEntities>0

        utils=dlinstrumentation.Utils;



        utils.startServiceForNetworkParameters(numEntities);


        registerLayers(compsWithLearnableParameters,{'Weights','Bias'});
        registerLayers(compsWithRNNLearnableParameters,{'Weights','Bias'});
        registerLayers(compsWithLeakyRelu,{'Parameter'});
        registerLayers(compsWithClippedRelu,{'Parameter'});
        registerLayers(compsWithAvgPool,{'Parameter'});


        logLearnableParameters(compsWithLearnableParameters,utils);
        logLearnableParameters(compsWithRNNLearnableParameters,utils);
        logLeakyReluParameters(compsWithLeakyRelu,utils);
        logClippedReluParameters(compsWithClippedRelu,utils);
        logAvgPoolParameters(compsWithAvgPool,compsWithInputLayer,utils);


        utils.endService();

    end

    p=dnn_pir;
    comps=p.getTopNetwork.Components();
    DLTLayerIdx=arrayfun(@(x)x.getDLTActivationLayerIndex,comps);
    PIRLayerName=arrayfun(@(x)x.getName,comps,'UniformOutput',false);






    isOutput=arrayfun(@(x)x.getIsOutputLayer,comps);
    existsInLayerGraph=arrayfun(@(x)x.getExistsInLayerGraph,comps);
    mismatchedCompIdx=find((DLTLayerIdx==-1)&isOutput);
    for idx=1:numel(mismatchedCompIdx)
        compIdx=mismatchedCompIdx(idx);
        drivingComps=comps(compIdx).DrivingComponents;

        DLTLayerIdx(compIdx)=drivingComps(1).getDLTActivationLayerIndex();
    end







    IsQuantizable=arrayfun(@(x)(strcmp(x.getCompKey,'gpucoder.conv_layer_comp')||...
    strcmp(x.getCompKey,'gpucoder.fused_conv_activation_layer_comp')),comps);




    IsOutputComp=~existsInLayerGraph&isOutput;
    dltMapTable=table(DLTLayerIdx,PIRLayerName,IsQuantizable,IsOutputComp);

    da=dlinstrumentation.DataAdapter;
    da.addDLTLayerNameMap(dltMapTable);
end
function registerLayers(comps,entityTypes)

    utils=dlinstrumentation.Utils;
    for idx=1:numel(comps)
        for idy=1:numel(entityTypes)
            utils.registerLayer(strcat(comps(idx).getName(),'_',entityTypes{idy}));
        end
    end
end
function logLearnableParameters(comps,utils)


    for idx=1:numel(comps)
        fd=fopen(comps(idx).getWeightsFile,'r');
        data=fread(fd,'single');
        fclose(fd);
        utils.logData(strcat(comps(idx).getName(),'_Weights'),single(data));

        fd=fopen(comps(idx).getBiasFile,'r');
        data=fread(fd,'single');
        fclose(fd);
        utils.logData(strcat(comps(idx).getName(),'_Bias'),single(data));
    end
end
function logLeakyReluParameters(comps,utils)

    for idx=1:numel(comps)
        data=single(comps(idx).getThreshold);
        utils.logData(strcat(comps(idx).getName(),'_Parameter'),single(data));
    end
end
function logClippedReluParameters(comps,utils)

    for idx=1:numel(comps)
        data=single(comps(idx).getCeiling);
        utils.logData(strcat(comps(idx).getName(),'_Parameter'),single(data));
    end
end
function logAvgPoolParameters(comps,inputLayerComp,utils)

    for idx=1:numel(comps)
        if(comps(idx).getPoolSizeW==-1&&comps(idx).getPoolSizeH==-1)

            data=single(inputLayerComp.getHeight*inputLayerComp.getWidth);
        else
            data=single(comps(idx).getPoolSizeW*comps(idx).getPoolSizeH);
        end

        utils.logData(strcat(comps(idx).getName(),'_Parameter'),single(1/data));
    end
end



