


classdef DataReader<slci.view.data.BaseReader

    methods


        function this=DataReader(aDD,aPathName)
            this=this@slci.view.data.BaseReader(aDD,aPathName);
        end


        function insertObject(this,aKey,aObject)
            this.insertData(this.fDataPath,aKey,aObject);
        end


        function replaceObject(this,aKey,aObject)
            this.replaceData(this.fDataPath,aKey,aObject);
        end


        function deleteObject(this,aKey)
            this.deleteData(this.fDataPath,aKey);
        end


        function aObj=getObject(this,aKey)
            aObj=this.getData(this.fDataPath,aKey);
        end


        function keyList=getObjectKeys(this)
            keyList=this.fDD.getChildNames(this.fDataPath);
        end


        function tf=hasObject(this,aKey)
            tf=this.hasData(this.fDataPath,aKey);
        end


        function objList=getObjects(this,aKeys)
            numKeys=numel(aKeys);
            objList=cell(numKeys,1);
            this.fDD.beginTransaction();
            try
                for k=1:numKeys
                    objList{k}=this.getObject(aKeys{k});
                end
            catch ex
                this.fDD.rollbackTransaction();
                throw(ex);
            end
            this.fDD.commitTransaction();
        end

    end


    methods(Access=private)


        function insertData(this,aPath,aKey,aObject)
            this.fDD.beginTransaction();
            try
                this.fDD.insertEntry(aPath,...
                aKey,aObject,'UserDataObject');
            catch ex
                this.fDD.rollbackTransaction();
                disp(['Error inserting ',aKey,' in ',aPath]);
                throw(ex);
            end
            this.fDD.commitTransaction();
        end


        function deleteData(this,aPath,aKey)
            this.fDD.beginTransaction();
            try
                this.fDD.deleteEntry([aPath,'.',aKey]);
            catch ex
                this.fDD.rollbackTransaction();
                disp(['Error deleting ',aKey,' in ',aPath]);
                throw(ex);
            end
            this.fDD.commitTransaction();
        end


        function dObject=getData(this,aPath,aKey)
            try
                dObject=this.fDD.getEntry([aPath,'.',aKey]);
            catch ex
                disp(['Error reading ',aKey,' in ',aPath]);
                throw(ex);
            end
        end


        function tf=hasData(this,aPath,aKey)
            try
                tf=this.fDD.entryExists([aPath,'.',aKey]);
            catch ex
                disp(['Error checking ',aKey,' in ',aPath]);
                throw(ex);
            end
        end


        function replaceData(this,aPath,aKey,aObject)
            try
                this.fDD.setEntry([aPath,'.',aKey],aObject);
            catch ex
                disp(['Error replacing ',aKey,' in ',aPath]);
                throw(ex);
            end
        end
    end

end
