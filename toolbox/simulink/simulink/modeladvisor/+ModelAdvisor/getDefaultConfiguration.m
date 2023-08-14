function ConfigFilePath=getDefaultConfiguration()

    ConfigFilePath='';
    PrefFile=fullfile(prefdir,'mdladvprefs.mat');
    if exist(PrefFile,'file')
        mdladvprefs=load(PrefFile);
        if isfield(mdladvprefs,'ConfigPrefs')&&isfield(mdladvprefs.ConfigPrefs,'FilePath')
            ConfigFilePath=mdladvprefs.ConfigPrefs.FilePath;
        end
    end

end