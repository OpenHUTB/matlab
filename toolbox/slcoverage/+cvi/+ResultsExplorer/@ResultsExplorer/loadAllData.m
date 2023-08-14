function loadAllData(obj)




    if obj.synced
        return;
    end

    if~exist(obj.getInputDir(),'dir')
        return;
    end
    try
        files=dir([obj.getInputDir(),filesep,'*.cvt']);
        if~isempty(files)
            fileNames={[files(1).folder,filesep,files(1).name]};
            for idx=2:numel(files)
                fileNames{end+1}=[files(idx).folder,filesep,files(idx).name];%#ok<AGROW>
            end
            if~isempty(fileNames)
                loadData(obj,fileNames,false);
            end
        end
        obj.synced=true;
    catch MEx
        rethrow(MEx);
    end
end