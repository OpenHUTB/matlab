classdef GitStorage<evolutions.internal.artifactserver.services.internal.FileStore




    properties(Constant)
        FolderName='Files'
    end

    methods
        function obj=GitStorage(dbPath)
            obj@evolutions.internal.artifactserver.services.internal.FileStore(dbPath);


            currentPath=pwd;
            cleanup=onCleanup(@()cd(currentPath));
            cd(obj.getRepo);

            initString=sprintf('git init');
            [status,cmdout]=system(initString);
            if status
                throw(MException('evolution:manage:InitFail',cmdout));
            end
        end

        function clearStorage(obj)

            clearStorage@evolutions.internal.artifactserver.services.internal.FileStore(obj);


            gitDirectory=fullfile(obj.getDBPath,'.git');
            rmdir(gitDirectory,'s');


            directory=fullfile(obj.getDBPath,obj.FolderName);
            if isfolder(directory)
                rmdir(directory,'s');
            end
        end

        [tf,identifier]=create(obj,file);
        [file,fileData]=read(obj,identifier);
        tf=update(obj,identifier,file);
        tf=deleteFile(obj,identifier);
    end

    methods(Access=protected)
        function commitId=commit(obj)

            currentPath=pwd;
            cleanup=onCleanup(@()cd(currentPath));
            cd(obj.getRepo);

            commitString=sprintf('git commit -m "evolutions generated commit"');
            [status,cmdout]=system(commitString);
            if status
                throw(MException('evolution:manage:GitFail',cmdout));
            else
                str=sprintf('git --no-pager log %s -n 1','--format="%H"');
                [~,commitId]=system(str);
            end
        end

        function tf=checkout(obj,commitId,file)
            currentPath=pwd;
            cleanup=onCleanup(@()cd(currentPath));
            cd(obj.getRepo);

            checkoutString=sprintf('git checkout %s %s',commitId(1:6),...
            file);
            [status,cmdout]=system(checkoutString);
            if status
                throw(MException('evolution:manage:GitFail',cmdout));
            end

            tf=true;
        end

        function path=getFileInStorage(obj,file)


            pathparts=strsplit(file,filesep);
            if contains(pathparts{1},':')
                pathparts=fullfile(pathparts{2:end});
            else
                pathparts=fullfile(pathparts{:});
            end

            path=fullfile(obj.getRepo,'Files',pathparts);
        end

        function addFile(~,file)
            [path,name,ext]=fileparts(file);
            currentPath=pwd;
            cleanup=onCleanup(@()cd(currentPath));
            cd(path);
            commitString=sprintf('git add %s'...
            ,strcat(name,ext));
            [status,cmdout]=system(commitString);
            if status
                throw(MException('evolution:manage:GitFail',cmdout));
            end
        end

        function amendFile(obj,identifier,file)

            storageFile=obj.read(identifier);
            copyfile(file,storageFile);


            currentPath=pwd;
            cleanup=onCleanup(@()cd(currentPath));
            cd(obj.getRepo);

            commitString=sprintf('git commit --amend --no-edit');
            [status,cmdout]=system(commitString);
            if status
                throw(MException('evolution:manage:GitFail',cmdout));
            end

            obj.updateDb(identifier,storageFile);

        end

        function removeFile(obj,commitId,file)

            currentPath=pwd;
            cleanup=onCleanup(@()cd(currentPath));
            cd(obj.getRepo);













        end

        function repo=getRepo(obj)
            repo=fileparts(obj.DBPath);
        end

        function directory=getStorageDir(obj)
            dbPath=fileparts(obj.DBPath);
            directory=fullfile(dbPath,obj.FolderName);
        end


    end
end


