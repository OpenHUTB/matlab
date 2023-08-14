function bd=getBuildDir(h)



    bd=[];


    dirs=RTW.getBuildDir(h.Model);
    sInfoMat=fullfile(dirs.CodeGenFolder,h.getSInfoFileName);

    if exist(sInfoMat,'file')
        sinfo=load(sInfoMat);
        if~isempty(sinfo)&&isfield(sinfo,'infoStruct')...
            &&isfield(sinfo.infoStruct,'Subsystems')
            buildDir=sinfo.infoStruct.Subsystems.BuildDir;
            h.BuildDirRoot=buildDir{1};
            h.RelativeBuildDir=buildDir{2};
            h.BuildDir=fullfile(h.BuildDirRoot,h.RelativeBuildDir);
            bd=h.BuildDir;
        end
    end
