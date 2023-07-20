function result=getSimBuildDirs(model)



    fileGenCfg=Simulink.fileGenControl('getConfig');
    result.CacheFolder=fileGenCfg.CacheFolder;
    result.CodeGenFolder=fileGenCfg.CodeGenFolder;
    result.ModelRefRelativeRootSimDir=fullfile('slprj','sim');
    result.ModelRefRelativeSimDir=fullfile(result.ModelRefRelativeRootSimDir,model);
    result.SharedUtilsSimDir=fullfile(result.ModelRefRelativeRootSimDir,'_sharedutils');
    result.ModelRefFullSimDir=fullfile(result.CacheFolder,result.ModelRefRelativeSimDir);
end


