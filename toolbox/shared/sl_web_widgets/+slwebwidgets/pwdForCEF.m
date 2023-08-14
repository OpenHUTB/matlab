function currentPath=pwdForCEF()





    currentPath=pwd();



    if currentPath(end)~=filesep

        currentPath=[currentPath,filesep];
    end