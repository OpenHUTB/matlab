function result=shorterPath(filePath)

    result=filePath;

    maxLength=50;
    rootDir=matlabroot;

    if strncmp(filePath,rootDir,length(rootDir))
        result=fullfile('[MATLAB]',filePath(length(rootDir)+1:end));

    elseif length(filePath)>maxLength
        seps=strfind(filePath,filesep);
        cuts=find(seps>maxLength);
        if~isempty(cuts)
            result=['...',filePath(seps(cuts(1)):end)];
        end
    end
end
