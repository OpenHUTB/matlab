function saveObjToFile(mdlName,confObj)





    try

        slci.Configuration.checkWorkDir;

        slciDir=slci.Configuration.getWorkDir(mdlName,'create');
        configObjFile=fullfile(slciDir,'config.mat');
    catch ME
        DAStudio.error('Slci:ui:CannotSaveUnnamedConfigFile',ME.message);
    end

    try
        save(configObjFile,'confObj');
    catch ME
        DAStudio.error('Slci:ui:CannotSaveNamedConfigFile',ME.message,configObjFile);
    end
end

