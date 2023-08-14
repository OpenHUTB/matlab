%#codegen




























function[opMiniBatchSizes,opBatchSizes,opPaddedBatchSizes]=getOutputSizeForPredict(snet,outputLayers,...
    inputSizes,miniBatchSize,batchSize,paddedBatchSize)



    coder.allowpcode('plain');
    opMiniBatchSizes=cell(numel(outputLayers),1);
    opBatchSizes=cell(numel(outputLayers),1);
    opPaddedBatchSizes=cell(numel(outputLayers),1);

    for i=1:numel(outputLayers)
        if(isprop(outputLayers{i},'OutputSize')&&isnumeric(outputLayers{i}.OutputSize))
            outputSize=outputLayers{i}.OutputSize;
        else
            portId=1;
            outputSize=coder.internal.iohandling.cnn.OutputDataPreparer.getOutputSizeForLayer(...
            snet,outputLayers{i},portId,inputSizes);
        end

        if isa(outputLayers{i},'nnet.cnn.layer.ClassificationOutputLayer')
            opMiniBatchSizes{i}=[miniBatchSize,outputSize];
            opBatchSizes{i}=[batchSize,outputSize];
            opPaddedBatchSizes{i}=[paddedBatchSize,outputSize];

        else


            opMiniBatchSizes{i}=...
            coder.internal.iohandling.cnn.OutputDataPreparer.getOutputSize(outputSize,miniBatchSize);
            opBatchSizes{i}=...
            coder.internal.iohandling.cnn.OutputDataPreparer.getOutputSize(outputSize,batchSize);
            opPaddedBatchSizes{i}=...
            coder.internal.iohandling.cnn.OutputDataPreparer.getOutputSize(outputSize,paddedBatchSize);
        end
    end
end
