

















function batchDataFiles=batchCreate(dlcodeCfg,inputSize,calibrationBatchFilePath,isYoloV2Network)





    assert(numel(inputSize)>=2);
    if numel(inputSize)<3
        inputSize(end+1)=1;
    end


    assert(numel(inputSize)>=3);

    dataPath=dlcodeCfg.DeepLearningConfig.DataPath;
    numCalibrationBatches=dlcodeCfg.DeepLearningConfig.NumCalibrationBatches;
    batchsize=dlcodeCfg.BatchSize;

    calibrationBatchDir=calibrationBatchFilePath;


    createTensorRTBatchDir(calibrationBatchDir);


    dirinfo=dir(dataPath);


    dirinfo=dirinfo(cellfun(@isempty,regexp({dirinfo.name},'^(\.|\.\.)$')));






    calibData=prepareCalibrationTableEntries(dirinfo,dataPath);



    if(numCalibrationBatches*batchsize>height(calibData))
        error(message('dlcoder_spkg:cnncodegen:invalid_trainingbatches',...
        height(calibData),numCalibrationBatches*batchsize));
    end


    randarray=randi(height(calibData),height(calibData),1);




    batchDataFiles=cell(numCalibrationBatches,1);
    for i=1:numCalibrationBatches


        filename=fullfile(calibrationBatchDir,...
        strcat('batch',num2str(i-1)));
        fid1=fopen(filename,'wb');

        if(i==1)


            fwrite(fid1,[batchsize,inputSize(3),inputSize(2),inputSize(1)],'int');
        end


        for j=1:batchsize

            inputFile=fullfile(calibData.folder(randarray(j+i-1)),...
            calibData.name(randarray(j+i-1)));

            inputImage=imread(char(inputFile));
            resizeImage=imresize(inputImage,[inputSize(1),inputSize(2)]);
            resizeImageFloat=single(resizeImage);


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


function createTensorRTBatchDir(calibrationBatchDir)
    newdir=calibrationBatchDir;
    if exist(newdir,'dir')
        delete(fullfile(newdir,'*'));
        rmdir(newdir);
    end
    mkdir(newdir);
end


function calibData=prepareCalibrationTableEntries(dirinfo,dataPath)
    subfolderArray=arrayfun(@(x)x.isdir,dirinfo);
    subfolders=dirinfo(subfolderArray);
    nonSubfolders=dirinfo(~subfolderArray);


    calibData=struct2table(nonSubfolders,'AsArray',true);


    numSubfolders=size(subfolders,1);
    for i=1:numSubfolders
        thisdir=subfolders(i).name;
        thisdir=fullfile(dataPath,thisdir);


        subfolder=dir(thisdir);


        subfolder=subfolder(cellfun(@isempty,...
        regexp({subfolder.name},'^(\.|\.\.)$')));
        calibData=[calibData;struct2table(subfolder,'AsArray',true)];%#ok
    end


end
