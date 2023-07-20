function mexOptsFile=emcLocateMexOptsFile(bStrict)



    directoryList={pwd,prefdir};
    if ispc
        fileName='mexopts.bat';
    end

    mexOptsFile='';
    for i=1:length(directoryList)
        tempOptsFile=fullfile(directoryList{i},fileName);
        if isfile(tempOptsFile)
            mexOptsFile=tempOptsFile;
            break;
        end
    end

    if bStrict&&isempty(mexOptsFile)
        error(message('Coder:reportGen:mexOptsFileNotFound'));
    end
