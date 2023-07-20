function createProjectFolder(obj,folderPath)




    if nargin<2
        folderPath=obj.getProjectFolder;
    end

    downstream.tool.createDir(folderPath);

    if~isfolder(folderPath)
        error(message('hdlcommon:workflow:DownstreamInvalidDirectory',folderPath));
    end
end

