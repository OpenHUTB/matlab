function error=decryptSPFiles(srcLoc,desLoc)





    [srcLoc,desLoc]=convertStringsToChars(srcLoc,desLoc);
    error=false;


    if slrealtime.internal.postprocesssupportpackage(fullfile(srcLoc,'slrtssd.sec')...
        ,fullfile(desLoc,'slrtssd.raw'),'decrypt')
        error=true;
    end
    if~error&&slrealtime.internal.postprocesssupportpackage(fullfile(srcLoc,'qnxtools.sec')...
        ,fullfile(desLoc,'qnxtools.tar'),'decrypt')
        error=true;
    end

    if strcmpi(computer('arch'),'win64')
        if~error&&slrealtime.internal.postprocesssupportpackage(fullfile(srcLoc,'slrt_qnxwin64.sec')...
            ,fullfile(desLoc,'slrt_qnxwin64.tar.gz'),'decrypt')
            error=true;
        end
    elseif strcmpi(computer('arch'),'glnxa64')
        if~error&&slrealtime.internal.postprocesssupportpackage(fullfile(srcLoc,'slrt_qnxglnxa64.sec')...
            ,fullfile(desLoc,'slrt_qnxglnxa64.tar.gz'),'decrypt')
            error=true;
        end
    end
end

