function emcSetupGitRepo(dir,forceCreate)




    if isunix
        [~,gitPath]=system('which git');
    else
        [~,gitPath]=system('where git');
    end

    if isempty(gitPath)
        warning(message('Coder:FE:CannotFindGit'));
        return;
    end

    oldPath=pwd;
    restorePath=onCleanup(@()cd(oldPath));
    cd(dir);



    if forceCreate&&isfolder(fullfile(pwd,'.git'))
        error(message('Coder:FE:CannotReinitGit'));
    end


    [status,~]=system('git status');
    if status==0

        return;
    else
        [~,~]=system('git init');
    end
