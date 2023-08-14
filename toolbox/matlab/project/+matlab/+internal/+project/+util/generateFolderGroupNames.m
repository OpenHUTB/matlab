function varargout=generateFolderGroupNames(rootFolders,folderName,varargin)




    MAX_NUMBER_INSTANCES=1000;
    if nargin>2
        maxNumberInstances=varargin{1};
    else
        maxNumberInstances=MAX_NUMBER_INSTANCES;
    end

    rootFolders=cellstr(rootFolders);

    varargout=...
    cellfun(@(x)fullfile(x,folderName),rootFolders,'UniformOutput',false);

    count=0;
    if anyFolderNamesExist(varargout)



        while anyFolderNamesExist(varargout)
            count=count+1;

            varargout=...
            cellfun(...
            @(x)fullfile(x,[folderName,num2str(count)]),...
            rootFolders,...
            'UniformOutput',false);

            if count>=maxNumberInstances
                rootFoldersString=string(rootFolders);
                rootFoldersCharArray=char(rootFoldersString.join(';'));
                error(message('SimulinkProject:Demo:CouldNotCreateTempDir',rootFoldersCharArray));
            end
        end

    end

end

function boolean=anyFolderNamesExist(folderGroupNames)
    boolean=any(cellfun(@(x)(exist(x,'dir')>0),folderGroupNames));
end