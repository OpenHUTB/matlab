function info=computeInferenceInfo(net,inputSizes,inputTypes,inputFormats,predictEnabled,activationLayers)









    if predictEnabled
        numPredictOutputs=numel(net.OutputNames);
    else
        numPredictOutputs=0;
    end

    args={'Acceleration','none'};

    predictOutputs=cell(numPredictOutputs,1);
    activationOutputs=cell(length(activationLayers),1);

    if isa(net,'dlnetwork')

        inputs=cell(size(inputSizes));
        for i=1:numel(inputSizes)
            inputs{i}=dlarray(ones(inputSizes{i},inputTypes{i}),inputFormats{i});
        end


        outputLayerNames=activationLayers;
        if predictEnabled
            outputLayerNames=[net.OutputNames,outputLayerNames];
        end

        [predictOutputs{:},activationOutputs{:}]=...
        net.predict(inputs{:},'Outputs',outputLayerNames,args{:});

    else

        inputs=cell(size(inputSizes));
        for i=1:numel(inputSizes)
            inputs{i}=ones(inputSizes{i},inputTypes{i});
        end

        if predictEnabled
            [predictOutputs{:}]=net.predict(inputs{:},args{:});
        end


        for i=1:numel(activationLayers)
            activationsOutput=net.activations(inputs{:},activationLayers{i},args{:});
            if iscell(activationsOutput)
                activationOutputs(i)=activationsOutput;
            else
                activationOutputs{i}=activationsOutput;
            end

        end
    end

    info=struct;

    info.PredictSizes=cellfun(@size,predictOutputs,'UniformOutput',false);
    info.ActivationSizes=cellfun(@size,activationOutputs,'UniformOutput',false);

    info.PredictTypes=cellfun(@underlyingType,predictOutputs,'UniformOutput',false);
    info.ActivationTypes=cellfun(@underlyingType,activationOutputs,'UniformOutput',false);

end