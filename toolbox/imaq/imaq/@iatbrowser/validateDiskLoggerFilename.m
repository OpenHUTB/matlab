function[newFilename,fileExists]=validateDiskLoggerFilename(filename,profileName)
    [filePath,fileBase,fileExt]=fileparts(filename);

    profiles=VideoWriter.getProfiles();
    curProfile=profiles(strcmp(profileName,{profiles.Name}));

    if isempty(fileExt)
        fileExt=curProfile.FileExtensions{1};
    elseif~ismember(fileExt,curProfile.FileExtensions)
        fileExt=curProfile.FileExtensions{1};
    end

    if isempty(filePath)
        newFilename=fullfile(pwd,[fileBase,fileExt]);
    else
        [success,info]=fileattrib(filePath);

        if success
            newFilename=fullfile(info.Name,[fileBase,fileExt]);
        else


            newFilename=filename;
        end
    end

    fileExists=~isempty(dir(newFilename));