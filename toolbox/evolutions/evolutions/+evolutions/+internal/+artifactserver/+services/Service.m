classdef(Abstract)Service<handle




    properties
DBPath
    end

    properties(Access=protected)
Model
DataBase
    end

    methods
        function obj=Service(path)
            obj.DBPath=path;
            obj.Model=mf.zero.Model;
            obj.connect;
        end

        output=create(obj,data);
        output=read(obj,data);
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
                obj.DataBase=getDB(obj);
                serializeDB(obj);
            end
        end

        function clearStorage(obj)

            obj.Model.destroy;
            obj.Model=mf.zero.Model;


            obj.DataBase=getDB(obj);
            obj.serializeDB;
        end

        function db=getDB(obj)
            db=evolutions.Artifacts.database.LocalToStorageId(obj.Model);
        end

        function addToDb(obj,key,value)



            obj.removeFromDb(key);
            obj.DataBase.FileIdData.add(key,value);

            serializeDB(obj);

        end

        function fileData=getFromDb(obj,key)
            fileData=obj.DataBase.FileIdData.at(key);
        end

        function fileData=getAllData(obj)

            fileKeys=obj.DataBase.FileIdData.keys;

            fileData={};

            for idx=1:numel(fileKeys)
                key=fileKeys{idx};
                fileData{end+1}=obj.DataBase.FileIdData.at(key);%#ok<AGROW>
            end
        end

        function removeFromDb(obj,key)
            obj.DataBase.FileIdData.remove(key);
            serializeDB(obj);
        end

        function tf=iskeyInDB(obj,key)
            if ismember(key,obj.DataBase.FileIdData.keys)
                tf=true;
            else
                tf=false;
            end
        end

        function serializeDB(obj)



            serializer=mf.zero.io.XmlSerializer;
            serializer.serializeToFile(obj.Model,obj.DBPath);
        end

        function dir=getServerDirectory(obj)

            dir=fileparts(obj.DBPath);
        end
    end
end


