classdef DCE<evolutions.internal.artifactserver.services.Service





    methods
        function obj=DCE(ServiceDBPath)

            obj@evolutions.internal.artifactserver.services.Service(ServiceDBPath);
        end

        function db=createDB(model)
            db=evolutions.Artifacts.database.DCEdata(model);
        end

        function addToDb(obj,key,value)


            costData=evolutions.Artifacts.database.CostData(obj.Model);
            costData.Identifier=key;
            costData.data=value;

            obj.DataBase.Data.add(costData);

            serializeDB(obj);

        end

        function cost=getFromDb(obj,key)
            fileData=obj.DataBase.Data.getByKey(key);
            cost=fileData.data;
        end

        function removeFromDb(obj,key)
            obj.DataBase.remove(key);
        end

        function tf=iskeyInDB(obj,key)
            costData=obj.DataBase.Data;
            data=costData.getByKey(key);
            if isempty(data)
                tf=false;
            else
                tf=true;
            end
        end

        function db=getDB(obj)
            db=evolutions.Artifacts.database.CostDataStorage(obj.Model);
        end

        tf=create(obj,data);

        tf=read(obj,data);
    end
end

