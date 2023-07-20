
classdef ReaderObject_DMR<slci.results.BaseReader_DMR




    methods(Access=public)


        function obj=ReaderObject_DMR(aRepo,add,aType,aIsInitTables)
            if(nargin<4)
                DAStudio.error('Slci:slci:InvalidNumberOfArguments');
            end

            obj=obj@slci.results.BaseReader_DMR(aRepo,add,aType,aIsInitTables);
        end


        function dObject=getObject(obj,aKey)
            parsedKey=obj.parseKey(aKey);
            try

                dObject=obj.fData.getByKey(parsedKey).userDataObject;
            catch ex
                disp(['Error reading ',aKey,'in Data']);
                throw(ex);
            end
        end


        function hasObj=hasObject(obj,aKey)
            hasObj=obj.hasData(obj.fData,aKey,'Data');
        end


        function dObject=getDescription(obj,aKey)
            parsedKey=obj.parseKey(aKey);
            try
                dObject=obj.fDesc.getByKey(parsedKey).descriptionObject;
            catch ex
                disp(['Error reading ',aKey,'in Desc']);
                throw(ex);
            end
        end


        function hasObj=hasDescription(obj,aKey)
            hasObj=obj.hasData(obj.fDesc,aKey,'Desc');
        end


        function objList=getObjects(obj,aKeys)
            numKeys=numel(aKeys);
            objList=cell(numKeys,1);

            obj.fRepo.beginTransaction();
            try
                for k=1:numKeys
                    objList{k}=obj.getObject(aKeys{k});
                end
            catch ex
                obj.fRepo.rollBackTransaction();
                throw(ex);
            end
            obj.fRepo.commitTransaction();
        end

    end

    methods(Access=public,Hidden=true)




        function insertObject(obj,aKey,aObject)
            parsedKey=obj.parseKey(aKey);
            try
                dataGroupObj=slci.resultsRepo.DataGroup(obj.fRepo);
                dataGroupObj.userDataKey=parsedKey;
                dataGroupObj.userDataObject=aObject;
                obj.fData.insert(dataGroupObj);
            catch ex
                disp(['Error inserting ',aKey,' in Data']);
                throw(ex);
            end
        end


        function replaceObject(obj,aKey,aObject)
            parsedKey=obj.parseKey(aKey);
            try

                obj.fData.getByKey(parsedKey).userDataObject=aObject;
            catch ex
                disp(['Error replacing ',parsedKey,'in Data']);
                throw(ex);
            end
        end




        function insertDescription(obj,aKey,aObject)
            parsedKey=obj.parseKey(aKey);
            try
                descGroupObj=slci.resultsRepo.DescriptionGroup(obj.fRepo);
                descGroupObj.descriptionKey=parsedKey;
                descGroupObj.descriptionObject=aObject;
                obj.fDesc.insert(descGroupObj);
            catch ex
                disp(['Error inserting ',aKey,' in Desc']);
                throw(ex);
            end
        end


        function replaceDescription(obj,aKey,aObject)
            parsedKey=obj.parseKey(aKey);
            try
                obj.fDesc.getByKey(parsedKey).descriptionObject=aObject;
            catch ex
                disp(['Error replacing ',parsedKey,'in Desc']);
                throw(ex);
            end
        end


        function keyList=getKeys(obj)
            dataGroupObjs=obj.fData.toArray;
            keyList=cell(1,numel(dataGroupObjs));
            for k=1:numel(dataGroupObjs)
                aKey=char(dataGroupObjs(k).userDataKey);
                aKey=obj.unParseKey(aKey);
                keyList{k}=aKey;
            end
        end

    end

    methods(Access=protected)




        function hasObj=hasData(obj,aTableGroupField,aKey,aType)
            parsedKey=obj.parseKey(aKey);
            try
                if(aTableGroupField.getByKey(parsedKey).isvalid==1)
                    hasObj=true;
                else
                    hasObj=false;
                end
            catch ex
                disp(['Error checking ',aKey,' in ',aType]);
                throw(ex);
            end
        end

    end

end
