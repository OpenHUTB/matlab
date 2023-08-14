classdef LocalStorage<evolutions.internal.artifactserver.services.internal.FileStore




    properties(Constant)
        FolderName='Files'
    end

    methods
        function obj=LocalStorage(dbPath)
            obj@evolutions.internal.artifactserver.services.internal.FileStore(dbPath);
        end

        function clearStorage(obj)

            clearStorage@evolutions.internal.artifactserver.services.internal.FileStore(obj);

            directory=fullfile(obj.getDBPath,obj.FolderName);
            if isfolder(directory)
                rmdir(directory,'s');
            end
        end

        [tf,identifier]=create(obj,file);
        [file,fileData]=read(obj,identifier);
        tf=update(obj,identifier,file);
        tf=deleteFile(obj,identifier);
        storeFile(obj,source,destination);

        function removeFile(~,file)
            delete(file);
        end
    end

    methods(Access=protected)
        function path=getFileInStorage(obj,id,file)

            [~,name,ext]=fileparts(file);
            fullfileName=sprintf('%s%s%s',id,name,ext);
            path=fullfile(getStorageDir(obj),fullfileName);
        end

        function directory=getStorageDir(obj)
            dbPath=fileparts(obj.DBPath);
            directory=fullfile(dbPath,obj.FolderName);
        end


    end
end

