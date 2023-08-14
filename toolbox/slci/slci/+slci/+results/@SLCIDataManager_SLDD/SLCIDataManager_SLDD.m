
classdef SLCIDataManager_SLDD<handle



    properties(Access=private)

        fdd;
    end

    properties(Constant=true)
        fRootDataGroupName='Results';
        fRootMetaGroupName='MetaData';
    end

    properties(Access=private)
        fBlockReader;
        fCodeReader;
        fBlockSliceReader;
        fCodeSliceReader;
        fTempVarReader;
        fFunctionInterfaceReader;
        fFunctionBodyReader;
        fErrorReader;
        fIncompatibilityReader;
        fResultsTableReader;
        fTypeReplacementReader;

        fFunctionCallReader;

        fSubSystemReader;
    end

    methods(Access=public,Hidden=true)

        function obj=SLCIDataManager_SLDD(aModelName,aReportFolder)

            if(nargin<2)
                DAStudio.error('Slci:slci:InvalidNumberOfArguments');
            end






            aDataSrc=fullfile(aReportFolder,[aModelName...
            ,'_verification_results.sldd']);
            obj.setConnectionObject(aDataSrc);
            obj.initReaders();
        end


        function delete(obj)
            if obj.fdd.isOpen()
                obj.fdd.close;
            end
        end

    end

    methods(Access=public)

        function Op=getObject(obj,ObjectType,aKey)
            functionName='getObject';
            readerObj=obj.getReader(ObjectType);
            Op=feval(functionName,readerObj,aKey);
        end

        function hasObj=hasObject(obj,ObjectType,aKey)
            functionName='hasObject';
            readerObj=obj.getReader(ObjectType);
            hasObj=feval(functionName,readerObj,aKey);
        end

        function replaceObject(obj,ObjectType,aKey,aObject)
            functionName='replaceObject';
            readerObj=obj.getReader(ObjectType);
            feval(functionName,readerObj,aKey,aObject);
        end

    end

    methods(Access=public,Hidden=true)

        function keyList=getKeys(obj,aObjectType)
            functionName='getKeys';
            readerObj=obj.getReader(aObjectType);
            keyList=feval(functionName,readerObj);
        end

        function resetData(obj)
            obj.beginTransaction();
            try
                obj.deleteTable(obj.fRootDataGroupName);
                obj.deleteTable(obj.fRootMetaGroupName);
                obj.initTables();
                obj.initReaders();
            catch ex
                obj.rollbackTransaction();
                throw(ex);
            end
            obj.commitTransaction();
        end




        function saveData(obj)

            if exist(obj.fdd.filespec,'file')>0
                obj.fdd.saveChanges();
            end
        end



        function discardData(obj)
            obj.fdd.discardChanges();
        end

        function beginTransaction(obj)
            obj.fdd.beginTransaction();
        end

        function commitTransaction(obj)
            obj.fdd.commitTransaction();
        end

        function rollbackTransaction(obj)
            obj.fdd.rollbackTransaction();
        end


        function out=hasMetaData(obj,aFieldName)
            aPath=obj.fRootMetaGroupName;
            try
                out=obj.fdd.entryExists([aPath,'.',aFieldName]);
            catch ex
                disp(['Error checking ',aFieldName]);
                throw(ex);
            end
        end


        function aData=getMetaData(obj,aFieldName)
            aPath=obj.fRootMetaGroupName;
            try
                aData=obj.fdd.getEntry([aPath,'.',aFieldName]);
            catch ex
                disp(['Error reading ',aFieldName]);
                throw(ex);
            end
        end



        function setMetaData(obj,aFieldName,aFieldValue)
            aPath=obj.fRootMetaGroupName;
            try
                obj.fdd.setEntry([aPath,'.',aFieldName],aFieldValue);
            catch ex
                disp(['Error setting ',aFieldName]);
                throw(ex);
            end
        end

    end

    methods(Access=private)

        function setConnectionObject(obj,aDataSrc)
            if exist(aDataSrc,'file')
                obj.fdd=Simulink.dd.open(aDataSrc);
            else
                fileSchema=slci.results.SLCIDataManager_SLDD.getFileSchema();
                obj.fdd=Simulink.dd.create(aDataSrc,fileSchema);
                obj.initTables();
                obj.saveData();
            end
        end

        function initTables(obj)
            obj.fdd.insertEntry('',obj.fRootDataGroupName,'','ResultsGroup');
            obj.fdd.insertEntry('',obj.fRootMetaGroupName,'','MetaDataEntries');
        end

        function deleteTable(obj,aTableName)
            groupName=aTableName;
            if obj.fdd.entryExists(groupName,false)
                obj.fdd.deleteEntry(groupName);
            end
        end

        function initReaders(obj)
            obj.fBlockReader=slci.results.ReaderObject_SLDD(...
            obj.fdd,...
            [obj.fRootDataGroupName,'.blockTable']);
            obj.fCodeReader=slci.results.ReaderObject_SLDD(...
            obj.fdd,...
            [obj.fRootDataGroupName,'.codeTable']);
            obj.fBlockSliceReader=slci.results.ReaderObject_SLDD(...
            obj.fdd,...
            [obj.fRootDataGroupName,'.blockSliceTable']);
            obj.fCodeSliceReader=slci.results.ReaderObject_SLDD(...
            obj.fdd,...
            [obj.fRootDataGroupName,'.codeSliceTable']);
            obj.fTempVarReader=slci.results.ReaderObject_SLDD(...
            obj.fdd,...
            [obj.fRootDataGroupName,'.tempVarTable']);
            obj.fTypeReplacementReader=slci.results.ReaderObject_SLDD(...
            obj.fdd,...
            [obj.fRootDataGroupName,'.typeReplacementTable']);
            obj.fFunctionInterfaceReader=slci.results.ReaderObject_SLDD(...
            obj.fdd,...
            [obj.fRootDataGroupName,'.functionInterfaceTable']);
            obj.fFunctionBodyReader=slci.results.ReaderObject_SLDD(...
            obj.fdd,...
            [obj.fRootDataGroupName,'.functionBodyTable']);
            obj.fErrorReader=slci.results.ReaderObject_SLDD(...
            obj.fdd,...
            [obj.fRootDataGroupName,'.errorTable']);
            obj.fIncompatibilityReader=slci.results.ReaderObject_SLDD(...
            obj.fdd,...
            [obj.fRootDataGroupName,'.incompatibilityTable']);
            obj.fResultsTableReader=slci.results.ReaderObject_SLDD(...
            obj.fdd,...
            [obj.fRootDataGroupName,'.resultsTable']);
            obj.fFunctionCallReader=slci.results.ReaderObject_SLDD(...
            obj.fdd,...
            [obj.fRootDataGroupName,'.functionCallTable']);
            obj.fSubSystemReader=slci.results.ReaderObject_SLDD(...
            obj.fdd,...
            [obj.fRootDataGroupName,'.subsystemTable']);
        end


    end

    methods(Static=true)

        function afileschema=getFileSchema()
            fileName='slci_data_dictionary.xml';
            afileschema=fullfile(matlabroot,'toolbox','slci','slci',...
            fileName);
        end

    end

    methods(Access=public,Hidden=true)

        function readerObj=getReader(obj,aObjectType)
            readerName=slci.results.SLCIDataManager.getReaderName(aObjectType);
            readerObj=obj.(readerName);
        end

    end
end
