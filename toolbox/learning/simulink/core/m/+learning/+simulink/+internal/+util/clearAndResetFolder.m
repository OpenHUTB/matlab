function clearAndResetFolder(folderPath)
    paramType=class(folderPath);


    w(1)=warning('off','MATLAB:RMDIR:RemovedFromPath');
    c=onCleanup(@()warning(w));

    switch paramType
    case 'char'
        resetPath(folderPath)
    case 'cell'
        for k=1:length(folderPath)
            dirPath=folderPath{k};
            resetPath(dirPath);
        end
    end

    function resetPath(dirPath)
        if exist(dirPath,'dir')==7
            rmdir(dirPath,'s');
            mkdir(dirPath);
        end
    end
end