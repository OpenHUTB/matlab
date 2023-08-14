%#codegen



function paddedData=batchPadInputData(in,batchSize,paddedBatchSize,isPadded,isImageInput)


    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;

    if isPadded
        if isImageInput

            paddedData=coder.nullcopy(zeros(size(in,1),...
            size(in,2),...
            size(in,3),...
            paddedBatchSize,...
            'single'));

            paddedData(:,:,:,1:batchSize)=in;

            paddedData(:,:,:,batchSize+1:paddedBatchSize)=zeros(size(in,1),...
            size(in,2),...
            size(in,3),...
            paddedBatchSize-batchSize,...
            'single');
        else

            assert(numel(size(in))==2);
            paddedData=coder.nullcopy(zeros(paddedBatchSize,size(in,2),'single'));

            paddedData(1:batchSize,:)=in;

            paddedData(batchSize+1:paddedBatchSize,:)=zeros(paddedBatchSize-batchSize,size(in,2),'single');
        end
    else

        paddedData=in;
    end
end