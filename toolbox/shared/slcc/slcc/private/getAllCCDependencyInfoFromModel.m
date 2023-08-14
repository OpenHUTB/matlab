function modelCCDepInfoStructs=getAllCCDependencyInfoFromModel(modelName)


    modelCCDepInfoStructs={};

    if(~ischar(modelName))
        modelName=get_param(modelName,'Name');
    end

    libraryCCDeps=slcc('getCachedCustomCodeDependencies',get_param(modelName,'Handle'));
    for i=1:numel(libraryCCDeps)
        checkSum=libraryCCDeps(i).SettingsChecksum;
        assert(~isempty(checkSum));
        fullCheckSum=libraryCCDeps(i).FullChecksum;
        ccInfo=slcc('getCachedCustomCodeInfo',checkSum);
        modelCCDepInfoStructs{end+1}=struct('fullCheckSum',fullCheckSum,...
        'ccInfo',ccInfo);%#ok<AGROW>
    end

end

