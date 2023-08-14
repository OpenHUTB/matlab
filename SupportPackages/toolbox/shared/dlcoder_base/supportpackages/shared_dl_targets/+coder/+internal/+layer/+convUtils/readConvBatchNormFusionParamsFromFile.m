function[weightsFused,biasFused]=readConvBatchNormFusionParamsFromFile(layer,converter)





    layerName=dltargets.internal.utils.LayerToCompUtils.sanitizeName(layer.Name);
    weightsFileName=dir(fullfile(converter.BuildContext.BuildDir,['*',layerName,'_w*.bin'])).name;
    biasFileName=dir(fullfile(converter.BuildContext.BuildDir,['*',layerName,'_b*.bin'])).name;


    weightsFilePath=fullfile(converter.BuildContext.BuildDir,weightsFileName);
    biasFilePath=fullfile(converter.BuildContext.BuildDir,biasFileName);
    [heightSize,widthSize,channelSize,batchSize]=size(layer.Weights);
    heightTimesWidth=heightSize*widthSize;
    channelTimesBatch=channelSize*batchSize;

    dataType=class(layer.Weights);
    weightsFused=zeros([heightSize,widthSize,channelSize,batchSize],dataType);


    fileID=fopen(weightsFilePath,'r');

    assert(fileID~=-1,'Cannot open file containing fused weights for convolution+batchnorm')



    weightsLinear=cast(fread(fileID,[heightTimesWidth,channelTimesBatch],'single'),dataType);
    fclose(fileID);


    for batchIdx=1:batchSize
        offset=(batchIdx-1)*(channelSize);
        for channelIdx=1:channelSize
            idxWeightsLinear=channelIdx+offset;
            weightsFused(:,:,channelIdx,batchIdx)=reshape(weightsLinear(:,idxWeightsLinear),[widthSize,heightSize])';
        end
    end


    fileID=fopen(biasFilePath,'r');

    assert(fileID~=-1,'Cannot open file containing fused bias for convolution+batchnorm')

    biasFused=cast(reshape(fread(fileID,'single'),size(layer.Bias)),dataType);
    fclose(fileID);
end