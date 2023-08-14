
















function batchDataFiles=batchCreateWithImageDatastore(inputSize,...
    calibrationBatchFilePath,...
    isYoloV2Network,...
    dlCodegenOptionsCallback,...
    networkInfo)




    if~isempty(char(dlCodegenOptionsCallback))

        dlCodegenOptionsCallbackClass=feval(dlCodegenOptionsCallback);
        if strcmpi(dlCodegenOptionsCallbackClass.getDataType(networkInfo.NetworkIdentifier),'int8')
            codegenOptionsObj=dlCodegenOptionsCallbackClass.getCodegenOptions(networkInfo.NetworkIdentifier);
        else

            batchDataFiles={};
            return;
        end
    else
        batchDataFiles={};
        return;
    end

    calibrationBatchDir=calibrationBatchFilePath;


    if exist(calibrationBatchDir,'dir')
        try
            delete(fullfile(calibrationBatchDir,'*'));
            rmdir(calibrationBatchDir);
        catch ME
            throw(ME);
        end
    end

    mkdir(calibrationBatchDir);

    batchsize=codegenOptionsObj.CalibrationDataStore.ReadSize;

    if(batchsize==1)
        warning(message('dlcoder_spkg:TensorRTReducedPrecision:IncreaseReadSizeofImageDataStore'));
    end



    totalnumImages=numel(codegenOptionsObj.CalibrationDataStore.Files);
    numCalibrationBatches=fix(totalnumImages/batchsize);


    inputSize=prepareInputSize(inputSize);





    batchDataFiles=cell(numCalibrationBatches,1);

    for i=1:numCalibrationBatches


        filename=fullfile(calibrationBatchDir,...
        strcat('batch',num2str(i-1)));
        fid1=fopen(filename,'wb');

        if(i==1)


            fwrite(fid1,[batchsize,inputSize(3),inputSize(2),inputSize(1)],'int');
        end


        imageBatch=codegenOptionsObj.CalibrationDataStore.read;


        for j=1:batchsize

            inputImage=imageBatch(:,:,:,j);


            if~isequal(size(inputImage,[1,2]),size(inputSize,[1,2]))
                resizeImageFloat=single(imresize(inputImage,[inputSize(1),inputSize(2)]));
            else
                resizeImageFloat=single(inputImage);
            end


            reorderedImageFloat=permute(resizeImageFloat,[2,1,3]);





            if isYoloV2Network

                reorderedImageFloat=rescale(reorderedImageFloat);
            end

            fwrite(fid1,reorderedImageFloat,'single');
        end

        fclose(fid1);
        batchDataFiles{i}=filename;

    end
end

function inputSize=prepareInputSize(inputSize)

    assert(numel(inputSize)>=2);

    if numel(inputSize)<3
        inputSize(end+1)=1;
    end


    assert(numel(inputSize)>=3);
end




