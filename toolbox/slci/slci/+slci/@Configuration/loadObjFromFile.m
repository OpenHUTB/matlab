function confObj=loadObjFromFile(mdlName)





    confObj=[];
    slciDir=slci.Configuration.getWorkDir(mdlName,'check');
    configObjFile=fullfile(slciDir,'config.mat');
    if exist(configObjFile,'file')
        try
            vars=load(configObjFile,'confObj');
            confObj=vars.confObj;
        catch ME
            DAStudio.error('Slci:ui:CannotLoadConfigFile',configObjFile);
        end
    end

end

