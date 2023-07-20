function createDirSafe(directory)




    if(~(isfolder(directory))&&~(isempty(directory)))
        mkdir(directory);
    end

