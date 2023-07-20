
classdef SLCIDataManager<handle




    properties(Access=private)
        fDmgr;
    end

    methods(Access=public,Hidden=true)

        function obj=SLCIDataManager(aModelName,aReportFolder)

            if(nargin<2)
                DAStudio.error('Slci:slci:InvalidNumberOfArguments');
            end

            if(slcifeature('SlciDMR')==1)
                obj.fDmgr=slci.results.SLCIDataManager_DMR(aModelName,...
                aReportFolder);
            else
                obj.fDmgr=slci.results.SLCIDataManager_SLDD(aModelName,...
                aReportFolder);
            end

        end

    end

    methods(Access=public)

        function Op=getObject(obj,ObjectType,aKey)
            Op=obj.fDmgr.getObject(ObjectType,aKey);
        end

        function hasObj=hasObject(obj,ObjectType,aKey)
            hasObj=obj.fDmgr.hasObject(ObjectType,aKey);
        end

        function replaceObject(obj,ObjectType,aKey,aObject)
            obj.fDmgr.replaceObject(ObjectType,aKey,aObject)
        end

    end

    methods(Access=public,Hidden=true)

        function keyList=getKeys(obj,aObjectType)
            keyList=obj.fDmgr.getKeys(aObjectType);
        end

        function resetData(obj)
            obj.fDmgr.resetData();
        end




        function saveData(obj)

            if(slcifeature('SlciDMR')==0)
                obj.fDmgr.saveData();
            end
        end

        function discardData(obj)
            if(slcifeature('SlciDMR')==0)
                obj.fDmgr.discardData();
            end
        end

        function beginTransaction(obj)
            obj.fDmgr.beginTransaction();
        end

        function commitTransaction(obj)
            obj.fDmgr.commitTransaction();
        end

        function rollbackTransaction(obj)
            obj.fDmgr.rollbackTransaction();
        end


        function aData=hasMetaData(obj,aFieldName)
            aData=obj.fDmgr.hasMetaData(aFieldName);
        end


        function aData=getMetaData(obj,aFieldName)
            aData=obj.fDmgr.getMetaData(aFieldName);
        end


        function setMetaData(obj,aFieldName,aFieldValue)
            obj.fDmgr.setMetaData(aFieldName,aFieldValue);
        end
    end

    methods(Static=true,Access=public,Hidden=true)

        function readerName=getReaderName(aObjectType)
            mlock;
            persistent readerLookup;
            if isempty(readerLookup)

                keyToReaders={'BLOCK','fBlockReader';...
                'CODE','fCodeReader';
                'BLOCKSLICE','fBlockSliceReader';
                'CODESLICE','fCodeSliceReader';
                'FUNCTIONINTERFACE','fFunctionInterfaceReader';
                'FUNCTIONBODY','fFunctionBodyReader';
                'TEMPVAR','fTempVarReader';
                'TYPEREPLACEMENT','fTypeReplacementReader';
                'INCOMPATIBILITY','fIncompatibilityReader';
                'ERROR','fErrorReader';
                'RESULTS','fResultsTableReader';
                'FUNCTIONCALL','fFunctionCallReader';
                'SUBSYSTEM','fSubSystemReader';
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

    methods(Access=public,Hidden=true)

        function readerObj=getReader(obj,aObjectType)
            readerObj=obj.fDmgr.getReader(aObjectType);
        end


        function readerObj=getBlockReader(obj)
            readerObj=obj.getReader('BLOCK');
        end

        function readerObj=getCodeReader(obj)
            readerObj=obj.getReader('CODE');
        end

        function readerObj=getBlockSliceReader(obj)
            readerObj=obj.getReader('BLOCKSLICE');
        end

        function readerObj=getCodeSliceReader(obj)
            readerObj=obj.getReader('CODESLICE');
        end

        function readerObj=getTempVarReader(obj)
            readerObj=obj.getReader('TEMPVAR');
        end

        function readerObj=getTypeReplacementReader(obj)
            readerObj=obj.getReader('TYPEREPLACEMENT');
        end

        function readerObj=getFunctionInterfaceReader(obj)
            readerObj=obj.getReader('FUNCTIONINTERFACE');
        end

        function readerObj=getFunctionBodyReader(obj)
            readerObj=obj.getReader('FUNCTIONBODY');
        end

        function readerObj=getErrorReader(obj)
            readerObj=obj.getReader('ERROR');
        end

        function readerObj=getIncompatibilityReader(obj)
            readerObj=obj.getReader('INCOMPATIBILITY');
        end

        function readerObj=getResultsTableReader(obj)
            readerObj=obj.getReader('RESULTS');
        end


        function readerObj=getFunctionCallReader(obj)
            readerObj=obj.getReader('FUNCTIONCALL');
        end


        function readerObj=getSubSystemReader(obj)
            readerObj=obj.getReader('SUBSYSTEM');
        end

    end
end
