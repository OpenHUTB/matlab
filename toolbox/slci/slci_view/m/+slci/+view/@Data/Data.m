




classdef Data<handle
    properties(Access=protected)

        fDataSource;

        fDDConnection;


        fUserReader;
        fBlockReader;
        fCodeReader;


        fBlockToCodeTraceCache;
        fCodeToBlockTraceCache;


        fModelHandle;

    end


    properties(Constant=true)
        fRootDataGroupName='Results';
    end

    methods(Access=?slci.view.Manager)

        function obj=Data(modelHandle)
            obj.fModelHandle=modelHandle;
            obj.init();



        end
    end

    methods


        function delete(obj)
            obj.closeDDConnection();



        end


        function aReader=getReader(obj,aObjectType)
            readerName=obj.getReaderName(aObjectType);
            aReader=obj.(readerName);
            if isempty(aReader)
                obj.initializeReader();
                aReader=obj.(readerName);
            end
        end


        function out=getCodeTrace(obj,aBlockSID)
            out=[];
            if obj.fBlockToCodeTraceCache.isKey(aBlockSID)
                out=obj.fBlockToCodeTraceCache(aBlockSID);
            end
        end

        populateTraceCaches(obj,blockSID,codeTrace)
    end


    methods(Access=private)

        init(obj)
        initializeReader(obj)


        function closeDDConnection(obj)
            if isempty(obj.fDDConnection)
                return
            end
            if obj.fDDConnection.isOpen()
                if exist(obj.fDDConnection.filespec,'file')>0
                    obj.fDDConnection.discardChanges;
                end
                obj.fDDConnection.close;
            end
        end


        function deleteTable(obj,aTableName)
            groupName=aTableName;
            if obj.fDDConnection.entryExists(groupName)
                obj.fDDConnection.deleteEntry(groupName);
            end
        end
    end


    methods(Static=true,Access=public,Hidden=true)


        function readerName=getReaderName(aObjectType)
            mlock;
            persistent readerLookup;
            if isempty(readerLookup)

                keyToReaders={'BLOCK','fBlockReader';...
                'CODE','fCodeReader';...
                'USER','fUserReader'...
                };
                readerLookup=containers.Map(keyToReaders(:,1),...
                keyToReaders(:,2));
            end

            if isKey(readerLookup,aObjectType)
                readerName=readerLookup(aObjectType);
            else
                error(['Invalid type for ObjectType ',aObjectType]);
            end
        end
    end

end
