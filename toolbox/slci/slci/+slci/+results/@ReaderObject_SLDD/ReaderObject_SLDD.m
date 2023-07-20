
classdef ReaderObject_SLDD<slci.results.BaseReader_SLDD



    properties(Access=protected)


        fDataOrder=0;
    end

    methods(Access=public)


        function obj=ReaderObject_SLDD(add,aPathName)
            if(nargin<1)
                DAStudio.error('Slci:slci:InvalidNumberOfArguments');
            end
            obj=obj@slci.results.BaseReader_SLDD(add,aPathName);
        end



        function dObject=getObject(obj,aKey)
            dObject=obj.getData(obj.fDataPath,aKey);
        end

        function hasObj=hasObject(obj,aKey)
            hasObj=obj.hasData(obj.fDataPath,aKey);
        end


        function dObject=getDescription(obj,aKey)
            dObject=obj.getData(obj.fDescriptionPath,aKey);
        end

        function hasObj=hasDescription(obj,aKey)
            hasObj=obj.hasData(obj.fDescriptionPath,aKey);
        end


        function objList=getObjects(obj,aKeys)
            numKeys=numel(aKeys);
            objList=cell(numKeys,1);
            obj.fdd.beginTransaction();
            try
                for k=1:numKeys
                    objList{k}=obj.getObject(aKeys{k});
                end
            catch ex
                obj.fdd.rollbackTransaction();
                throw(ex);
            end
            obj.fdd.commitTransaction();
        end

    end

    methods(Access=public,Hidden=true)


        function insertObject(obj,aKey,aObject)
            obj.insertData(obj.fDataPath,aKey,aObject);
        end

        function replaceObject(obj,aKey,aObject)
            obj.replaceData(obj.fDataPath,aKey,aObject);
        end


        function insertDescription(obj,aKey,aObject)
            obj.insertData(obj.fDescriptionPath,aKey,aObject);
        end

        function replaceDescription(obj,aKey,aObject)
            obj.replaceData(obj.fDescriptionPath,aKey,aObject);
        end


        function keyList=getKeys(obj)
            keyList=obj.getObjectKeys(obj.fDataPath);
        end


        function keyList=getDescriptionKeys(obj)
            keyList=obj.getDescriptionKeys(obj.fDataPath);
        end

    end

    methods(Access=protected)

        function dObject=getData(obj,aPath,aKey)
            parsedKey=obj.parseKey(aKey);
            try
                dObject=obj.fdd.getEntry([aPath,'.',parsedKey]);
            catch ex
                disp(['Error reading ',aKey,' in ',aPath]);
                throw(ex);
            end
        end

        function hasObj=hasData(obj,aPath,aKey)
            parsedKey=obj.parseKey(aKey);
            try
                hasObj=obj.fdd.entryExists([aPath,'.',parsedKey],false);
            catch ex
                disp(['Error checking ',aKey,' in ',aPath]);
                throw(ex);
            end
        end

        function replaceData(obj,aPath,aKey,aObject)
            parsedKey=obj.parseKey(aKey);
            try
                obj.fdd.setEntry([aPath,'.',parsedKey],aObject);
            catch ex
                disp(['Error replacing ',parsedKey,' in ',aPath]);
                throw(ex);
            end
        end

        function insertData(obj,aPath,aKey,aObject)
            parsedKey=obj.parseKey(aKey);
            try
                obj.fdd.insertEntry(aPath,...
                parsedKey,aObject,'UserDataObject');
            catch ex
                disp(['Error inserting ',aKey,' in ',aPath]);
                throw(ex);
            end
        end

        function keyList=getObjectKeys(obj,aPath)
            keyList={};
            if(obj.fdd.entryExists(aPath))
                keyList=obj.fdd.getChildNames(aPath);
                for k=1:numel(keyList)
                    aKey=keyList{k};
                    aKey=obj.unParseKey(aKey);
                    keyList{k}=aKey;
                end
            end
        end

    end


end
