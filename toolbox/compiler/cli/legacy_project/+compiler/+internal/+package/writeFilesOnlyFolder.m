

function writeFilesOnlyFolder(theFiles,forTestingFolder,filesOnlyFolder)


    if~exist(filesOnlyFolder,'dir')
        mkdir(filesOnlyFolder);
    end

    fixedTestingFolder=strrep(forTestingFolder,".",pwd);
    for i=1:length(theFiles)
        if isfolder(theFiles{i})
            [~,folderName,folderExt]=fileparts(theFiles{i});

            copyfile(theFiles{i},fullfile(filesOnlyFolder,strcat(folderName,folderExt)),'f');
        else

            parentFolder=fileparts(theFiles{i});
            if contains(parentFolder,fixedTestingFolder)&&...
                ~strcmp(fixedTestingFolder,parentFolder)




                folderToCopyTo=fileparts(filesOnlyFolder+strrep(theFiles{i},fixedTestingFolder,""));
                if~exist(folderToCopyTo,"dir")
                    mkdir(folderToCopyTo);
                end
            else
                folderToCopyTo=filesOnlyFolder;
            end

            copyfile(theFiles{i},folderToCopyTo,'f');
        end
    end
end