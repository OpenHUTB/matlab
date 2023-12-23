function[fullPath,fullFilePath,slmcrtFilePath]=getMappingCacheFilePath(model,target,useAnchorDir)
    folders=Simulink.filegen.internal.FolderConfiguration(model);

    if strcmpi(target,'rtw')
        cacheRoot=folders.CodeGeneration.Root;
    else
        cacheRoot=folders.Simulation.Root;
    end

    if useAnchorDir&&Simulink.fileGenControl('GetParallelBuildInProgress')
        if strcmpi(target,'rtw')
            cacheRoot=coder.internal.infoMATFileMgr('getParallelAnchorDir','RTW');
        else
            cacheRoot=coder.internal.infoMATFileMgr('getParallelAnchorDir','SIM');
        end
    end

    filename=[model,'_DFCache.mat'];
    relativePath=fullfile('slprj','_cprj');

    if strcmpi(target,'simtarget')
        relativePath=fullfile(folders.Simulation.ModelReferenceCode,'tmwinternal');
    end
    if strcmpi(target,'accel')
        relativePath=fullfile(folders.Accelerator.ModelCode,'tmwinternal');
    end
    if strcmpi(target,'raccel')
        relativePath=fullfile(folders.RapidAccelerator.ModelCode,'tmwinternal');
    end
    if strcmpi(target,'rtw')


        relativePath=fullfile(folders.CodeGeneration.ModelReferenceCode,'tmwinternal');
    end
    fullPath=fullfile(cacheRoot,relativePath);
    fullFilePath=fullfile(fullPath,filename);

    if isempty(Simulink.fileGenControl('getinternalvalue','CacheFolder'))
        slmcrtFilePath=fullfile(relativePath,filename);
    else
        slmcrtFilePath=fullFilePath;
    end
end
