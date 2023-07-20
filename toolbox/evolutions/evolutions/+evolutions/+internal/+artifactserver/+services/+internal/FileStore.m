classdef(Abstract)FileStore<evolutions.internal.artifactserver.services.internal.Service




    properties(Access=protected)
DBPath
    end

    properties(Access=private)
Model
DataBase
    end

    methods
        function obj=FileStore(dbPath)
            obj.Model=mf.zero.Model;
            obj.DBPath=dbPath;
            obj.connect;
        end
    end

    methods





        function connect(obj)
            dbPath=obj.DBPath;
            if isfile(dbPath)
                parser=mf.zero.io.XmlParser;
                parser.RemapUuids=false;
                parser.Model=obj.Model;
                bd=obj.Model.topLevelElements;
                parser.parseFile(dbPath);

                bd.destroy;
                obj.DataBase=obj.Model.topLevelElements;
            else
                obj.Model.ModelURI=strcat("xml@file:",dbPath);
                obj.DataBase=evolutions.Artifacts.database.FileMetaDb(obj.Model);
                serializeDB(obj);
            end
        end

        function updateDb(obj,key,file)

            oldData=obj.getFromDb(key);
            refCount=oldData.ReferenceCount;

            obj.removeFromDb(key);


            obj.addToDb(key,file);

            newData=obj.getFromDb(key);
            newData.ReferenceCount=refCount;
            serializeDB(obj);
        end

        function addToDb(obj,key,file)

            if~isfile(obj.DBPath)
                exception=MException...
                ('evolutions:artifacts:FileStoreDBNotFound',getString(message...
                ('evolutions:artifacts:FileStoreDBNotFound')));
                throw(exception);
            end

            meta=evolutions.Artifacts.database.FileMeta(obj.Model);


            meta.MetaIdentifier=key;


            meta.FileURI=strrep(file,getDBPath(obj),"");
            meta.CheckSum=evolutions.internal.utils.getFileChecksumFromPath(file);
            meta.ReferenceCount=1;


            [~,name,ext]=fileparts(meta.FileURI);
            storedFileName=strrep([name,ext],key,"");

            meta.FileName=storedFileName;



            obj.DataBase.FileData.add(meta);

            serializeDB(obj);

        end

        function incrementReferenceCount(obj,fileId)

            fileData=obj.getFromDb(fileId);
            fileData.ReferenceCount=fileData.ReferenceCount+1;


            serializeDB(obj);
        end

        function markForDelete=decrementReferenceCount(obj,fileId)

            markForDelete=false;
            fileData=obj.getFromDb(fileId);
            fileData.ReferenceCount=fileData.ReferenceCount-1;


            serializeDB(obj);


            if fileData.ReferenceCount<1
                obj.removeFromDb(fileId);
                markForDelete=true;
            end
        end

        function fileId=isFileInStorage(obj,file)
            fileId=char.empty;


            allFileData=obj.getFromDb;


            if isempty(allFileData)
                return;
            end

            fileChecksum=evolutions.internal.utils.getFileChecksumFromPath(file);


            checkSums={allFileData.CheckSum};
            fileDataIdx=find(strcmp(checkSums,fileChecksum));

            if~isempty(fileDataIdx)
                fileId=allFileData(fileDataIdx).MetaIdentifier;
            end
        end

        function fileData=getFromDb(obj,key)
            if nargin<2

                fileKeys=obj.DataBase.FileData.keys;

                fileData=evolutions.Artifacts.database.FileMeta.empty(1,0);

                for idx=1:numel(fileKeys)
                    key=fileKeys{idx};
                    fileData(end+1)=obj.DataBase.FileData.getByKey(key);%#ok<AGROW>
                end
                return;
            end

            fileData=obj.DataBase.FileData.getByKey(key);
            if isempty(fileData)
                exception=MException...
                ('evolutions:artifacts:StorageFileNotFound',getString(message...
                ('evolutions:artifacts:StorageFileNotFound')));
                throw(exception);
            end
        end

        function removeFromDb(obj,key)

            if~isfile(obj.DBPath)
                exception=MException...
                ('evolutions:artifacts:FileStoreDBNotFound',getString(message...
                ('evolutions:artifacts:FileStoreDBNotFound')));
                exception=exception.addCause(ME);
                throw(exception);
            end
            entry=obj.DataBase.FileData.getByKey(key);
            obj.DataBase.FileData.remove(entry);

            entry.destroy;

            serializeDB(obj);
        end

        function serializeDB(obj)



            serializer=mf.zero.io.XmlSerializer;
            serializer.serializeToFile(obj.Model,obj.DBPath);
        end

        function path=getDBPath(obj)

            dbPath=fileparts(obj.DBPath);

            path=strcat(dbPath,filesep);
        end

        function clearStorage(obj)

            obj.Model.destroy;
            obj.Model=mf.zero.Model;


            obj.DataBase=evolutions.Artifacts.database.FileMetaDb(obj.Model);
            obj.serializeDB;
        end
    end

    methods(Abstract)
        [tf,identifier]=create(obj,file);
        [file,fileData]=read(obj,identifier);
        tf=update(obj,identifier,file);
        tf=deleteFile(obj,identifier);
    end

end


