function cleanup=safecd(newDir)

















    oldDir=pwd;
    oldPath=path;


    cleanup=onCleanup(@()restore(oldDir,oldPath));


    addpath(oldDir);


    cd(newDir);
end

function restore(oldDir,oldPath)
    cd(oldDir);
    path(oldPath);
end