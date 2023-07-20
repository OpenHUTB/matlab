
classdef SLCIDataManager_DMR<handle



    properties(Access=private)

        fRepo;


        fDataSrc;




    end

    properties(Access=private)
        fMetaDataEntries;
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

        function obj=SLCIDataManager_DMR(aModelName,aReportFolder)

            if(nargin<2)
                DAStudio.error('Slci:slci:InvalidNumberOfArguments');
            end


            obj.fDataSrc=fullfile(aReportFolder,[aModelName...
            ,'_verification_results']);

            obj.setConnectionObject();
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
            try
                obj.fRepo.delete;
                delete(obj.fDataSrc);
                obj.setConnectionObject();
            catch ex
                throw(ex);
            end
        end

        function beginTransaction(obj)
            obj.fRepo.beginTransaction();
        end

        function commitTransaction(obj)
            obj.fRepo.commitTransaction();
        end

        function rollbackTransaction(obj)
            obj.fRepo.rollBackTransaction();




            obj.setConnectionObject();
        end


        function out=hasMetaData(obj,aFieldName)
            try
                out=ismember(aFieldName,properties(obj.fMetaDataEntries));
            catch ex
                disp(['Error checking ',aFieldName]);
                throw(ex);
            end
        end


        function aData=getMetaData(obj,aFieldName)
            try
                aData=obj.fMetaDataEntries.(aFieldName);
            catch ex
                disp(['Error reading ',aFieldName]);
                throw(ex);
            end
        end



        function setMetaData(obj,aFieldName,aFieldValue)
            try
                obj.fMetaDataEntries.(aFieldName)=aFieldValue;
            catch ex
                disp(['Error setting ',aFieldName]);
                throw(ex);
            end
        end

    end

    methods(Access=private)







        function setConnectionObject(obj)


            obj.fRepo=slci.Repository(obj.fDataSrc);

            [isNewDB,dd]=isNewDatabaseFile(obj);

            if(isNewDB)
                obj.fRepo.beginTransaction();
                try
                    dd=obj.initTables();
                    obj.initReaders(dd.results,true);
                catch ex
                    obj.fRepo.rollBackTransaction();
                    throw(ex);
                end
                obj.fRepo.commitTransaction();
            else

                obj.fMetaDataEntries=dd.metaData;
                obj.initReaders(dd.results,false);
            end
        end







        function[isNewDB,dd]=isNewDatabaseFile(obj)

            ddConstraint=slci.resultsRepo.DDRootConstraint(obj.fRepo);


            ddIT=ddConstraint.Query.list(ddConstraint);

            if(ddIT.advance==1)
                isNewDB=false;
            else

                isNewDB=true;
            end
            dd=ddIT.getCurrent{1};
        end

        function dd=initTables(obj)


            dd=slci.resultsRepo.DDRoot(obj.fRepo);


            dd.metaData=slci.resultsRepo.MetaDataEntries(obj.fRepo);

            obj.fMetaDataEntries=dd.metaData;
        end

        function initReaders(obj,aResultsGroupCollection,aIsInitTables)
            obj.fBlockReader=slci.results.ReaderObject_DMR(...
            obj.fRepo,...
            aResultsGroupCollection,...
            'BLOCK',...
            aIsInitTables);
            obj.fCodeReader=slci.results.ReaderObject_DMR(...
            obj.fRepo,...
            aResultsGroupCollection,...
            'CODE',...
            aIsInitTables);
            obj.fBlockSliceReader=slci.results.ReaderObject_DMR(...
            obj.fRepo,...
            aResultsGroupCollection,...
            'BLOCKSLICE',...
            aIsInitTables);
            obj.fCodeSliceReader=slci.results.ReaderObject_DMR(...
            obj.fRepo,...
            aResultsGroupCollection,...
            'CODESLICE',...
            aIsInitTables);
            obj.fTempVarReader=slci.results.ReaderObject_DMR(...
            obj.fRepo,...
            aResultsGroupCollection,...
            'TEMPVAR',...
            aIsInitTables);
            obj.fTypeReplacementReader=slci.results.ReaderObject_DMR(...
            obj.fRepo,...
            aResultsGroupCollection,...
            'TYPEREPLACEMENT',...
            aIsInitTables);
            obj.fFunctionInterfaceReader=slci.results.ReaderObject_DMR(...
            obj.fRepo,...
            aResultsGroupCollection,...
            'FUNCTIONINTERFACE',...
            aIsInitTables);
            obj.fFunctionBodyReader=slci.results.ReaderObject_DMR(...
            obj.fRepo,...
            aResultsGroupCollection,...
            'FUNCTIONBODY',...
            aIsInitTables);
            obj.fErrorReader=slci.results.ReaderObject_DMR(...
            obj.fRepo,...
            aResultsGroupCollection,...
            'ERROR',...
            aIsInitTables);
            obj.fIncompatibilityReader=slci.results.ReaderObject_DMR(...
            obj.fRepo,...
            aResultsGroupCollection,...
            'INCOMPATIBILITY',...
            aIsInitTables);
            obj.fResultsTableReader=slci.results.ReaderObject_DMR(...
            obj.fRepo,...
            aResultsGroupCollection,...
            'RESULTS',...
            aIsInitTables);
            obj.fFunctionCallReader=slci.results.ReaderObject_DMR(...
            obj.fRepo,...
            aResultsGroupCollection,...
            'FUNCTIONCALL',...
            aIsInitTables);
            obj.fSubSystemReader=slci.results.ReaderObject_DMR(...
            obj.fRepo,...
            aResultsGroupCollection,...
            'SUBSYSTEM',...
            aIsInitTables);
        end

    end

    methods(Access=public,Hidden=true)

        function readerObj=getReader(obj,aObjectType)
            readerName=slci.results.SLCIDataManager.getReaderName(aObjectType);
            readerObj=obj.(readerName);
        end

    end

end
