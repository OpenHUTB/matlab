function setBuildDir(h,buildDir,varargin)






    noload=false;
    h.CurrentModelReferenceTargetType='';
    if nargin>=3
        for k=1:length(varargin)
            switch varargin{k}
            case '-noload'
                noload=true;
            case '-mdlref'
                h.CurrentModelReferenceTargetType='mdlref';
            case '-standalone'
                h.CurrentModelReferenceTargetType='none';
            otherwise
                DAStudio.error('RTW:utility:invalidInputArgs',varargin{k});
            end
        end
    end

    if isempty(h.RelativeBuildDir)

        binfo=RTW.getBuildDir(h.Model);


        h.RelativeBuildDir=binfo.RelativeBuildDir;
        h.ModelRefRelativeBuildDir=binfo.ModelRefRelativeBuildDir;
    end

    if isempty(buildDir)
        if h.isModelReference
            buildDir=h.getModelRefBuildDir;
        else
            buildDir=h.getMostRecentBuildDir();
        end
        if isempty(buildDir)
            DAStudio.error('RTW:traceInfo:buildDirNotFound','',h.Model);
        end
    end

    buildDir=coder.internal.getAbsolutePath(buildDir);

    if buildDir(end)==filesep
        buildDir=buildDir(1:end-1);
    end
    if h.isModelReference
        buildDirRoot=buildDir(1:end-length(h.ModelRefRelativeBuildDir)-1);
    else
        buildDirRoot=fileparts(buildDir);
    end

    prevBuildDir=h.BuildDir;
    prevBuildDirRoot=h.BuildDirRoot;
    h.BuildDir=buildDir;
    h.BuildDirRoot=buildDirRoot;

    if~noload
        try
            h.loadTraceInfo;
        catch me

            h.BuildDir=prevBuildDir;
            h.BuildDirRoot=prevBuildDirRoot;
            rethrow(me);
        end

        [uptodate,reason,args]=h.isUpToDate;
        h.LastWarning=[reason,args];
        if~uptodate
            MSLDiagnostic(h.LastWarning{:}).reportAsWarning;
        end
    end


