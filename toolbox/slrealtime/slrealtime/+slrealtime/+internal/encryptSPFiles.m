function encryptSPFiles(srcLoc,desLoc)






    [srcLoc,desLoc]=convertStringsToChars(srcLoc,desLoc);


    slrealtime.internal.postprocesssupportpackage(fullfile(srcLoc,'slrtssd.raw')...
    ,fullfile(desLoc,'slrtssd.sec'),'encrypt');
    slrealtime.internal.postprocesssupportpackage(fullfile(srcLoc,'qnxtools.tar')...
    ,fullfile(desLoc,'qnxtools.sec'),'encrypt');

    if strcmpi(computer('arch'),'win64')
        slrealtime.internal.postprocesssupportpackage(fullfile(srcLoc,'slrt_qnxwin64.tar.gz')...
        ,fullfile(desLoc,'slrt_qnxwin64.sec'),'encrypt');
    elseif strcmpi(computer('arch'),'glnxa64')
        slrealtime.internal.postprocesssupportpackage(fullfile(srcLoc,'slrt_qnxglnxa64.tar.gz')...
        ,fullfile(desLoc,'slrt_qnxglnxa64.sec'),'encrypt');
    end

end
