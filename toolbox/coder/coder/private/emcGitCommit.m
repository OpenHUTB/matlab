function emcGitCommit(dir)




    oldDir=pwd;
    restore=onCleanup(@()cd(oldDir));
    cd(dir);


    [s,~]=system('git status');
    if s==0
        [~,~]=system(['git add -- ',dir]);
        commitStr=coder.internal.getGitCommitString;
        [~,~]=system(['git commit -m "',commitStr,'" --author="MATLAB Coder<NULL>" -- ',dir]);
    end
