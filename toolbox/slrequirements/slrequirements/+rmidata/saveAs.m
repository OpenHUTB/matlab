function saveAs(modelH,targetReqFile)










    modelH=convertStringsToChars(modelH);
    targetReqFile=convertStringsToChars(targetReqFile);


    if ischar(modelH)
        modelH=get_param(modelH,'Handle');
    end


    modelPath=get_param(modelH,'FileName');
    reqFilePath=rmiut.absolute_path(targetReqFile,pwd);
    rmimap.StorageMapper.getInstance.set(modelPath,reqFilePath);




    rmidata.save(modelH,reqFilePath);

