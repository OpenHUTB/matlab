function cleanPrefdir(configname)
    configPath=fullfile(prefdir,configname);
    if exist(configPath,'dir')==7
        rmdir(configPath,'s');
    end
end