function result=getAccelBuildDir(model,isVMBased,varargin)




    result.BuildDir=accelBuildDir(model,false);
    cfg=Simulink.fileGenControl('getConfig');
    result.CacheFolder=cfg.CacheFolder;
    result.RelativeRootSimDir=fullfile('slprj','sim');
    if isVMBased
        result.ExeFile=fullfile(result.BuildDir,[model,'_top_vm.bc']);
    else
        platform=varargin{1};
        allext=mexext('all');
        anExt=allext(strcmp({allext.arch},platform)).ext;
        result.ExeFile=fullfile(cfg.CacheFolder,[model,'_acc.',anExt]);
    end
end


