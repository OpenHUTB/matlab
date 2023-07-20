function out=getRelativeBuildDir(h)




    if h.isModelReference
        out=h.ModelRefRelativeBuildDir;
    elseif~isempty(h.BuildDir)

        if h.BuildDirRoot(end)==filesep
            idx=length(h.BuildDirRoot)+1;
        else
            idx=length(h.BuildDirRoot)+2;
        end
        out=h.BuildDir(idx:end);
    else

        out=h.RelativeBuildDir;
    end

