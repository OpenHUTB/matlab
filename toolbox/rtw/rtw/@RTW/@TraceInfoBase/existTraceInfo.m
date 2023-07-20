function out=existTraceInfo(h)










    out=false;


    dirs=RTW.getBuildDir(h.Model);
    workDir=dirs.CodeGenFolder;
    tInfoMat=fullfile(workDir,h.getTraceInfoFileName);

    if exist(tInfoMat,'file')
        out=true;
        return
    elseif h.isModelReference
        out=false;
        return
    end


    sInfoMat=fullfile(workDir,h.getSInfoFileName);

    if exist(sInfoMat,'file')
        sinfo=load(sInfoMat);
        if~isempty(sinfo)&&isfield(sinfo,'infoStruct')...
            &&isfield(sinfo.infoStruct,'Subsystems')...
            &&~isempty(sinfo.infoStruct.Subsystems)
            buildDirs={sinfo.infoStruct.Subsystems.buildDir};
            matExist=cellfun(@(x)exist(fullfile(x,'html','traceInfo.mat'),'file'),...
            buildDirs);
            if any(matExist)
                out=true;
            end
        end
    end


