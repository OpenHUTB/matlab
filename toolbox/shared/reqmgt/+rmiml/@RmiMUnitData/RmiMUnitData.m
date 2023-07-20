classdef(Sealed=true)RmiMUnitData<handle




    properties





        munitCache;

        bookmarkToTestCache;
    end

    properties(Constant)
        NO_CREATE_BOOKMARK=false;
        FETCH_FUNCTION_NAME_POS_ONLY=false;

        IS_MUNIT="isMUnit";
        IS_STM_MUNIT="isSTMMUnit";

        FIELD_NAMES="names";
        FIELD_ISFILELEVEL="isFileLevel";


    end

    methods(Access=private)
        function this=RmiMUnitData()
            this.init();
        end

        function init(this)
            this.munitCache=containers.Map('KeyType','char','ValueType','any');
            this.bookmarkToTestCache=containers.Map('KeyType','char','ValueType','any');
        end

        function clear(this)
            this.munitCache.remove(this.munitCache.keys);
            this.bookmarkToTestCache.remove(this.bookmarkToTestCache.keys);
        end
    end

    methods(Static)

        [isMUnit,isSTMMUnit]=isMUnitFile(filepath);






        testClassName=getTestClassName(fileName);

        [testProcedureNames,isFileLevel]=getTestNamesFromEditorSelection(fileName);

        [testProcedureNames,isFileLevel]=getTestNamesUnderRange(fileName,positions);

        [testPositions,fileLevelPositions]=getLocationDataForTest(fileName,testName);

        [testNames,startPositions,endPositions]=getTestNamesAndPositions(parseTree);

        [testFileName,startPosition,endPosition]=getTestFileNameAndPosition(parseTree);

        bookmark=getBookmarkForTest(fileName,testName);

        success=navigateToSTMMunitTestCase(artifact,id);


        tf=isSLTestMUnitFile(filepath);

        tf=isGenericMUnitFile(filepath);

        [parseTree,code]=getParsedMTree(fileName);

        absPositions=convertToAbsolutePositions(parseTree,rowColPositions);
    end

    methods(Static)

        function singleObj=getInstance(varargin)
            mlock;
            persistent localRMIData;
            if isempty(localRMIData)||~isvalid(localRMIData)
                if nargin==0
                    localRMIData=rmiml.RmiMUnitData();
                    reqmgt('init');
                end
            end
            singleObj=localRMIData;
        end


        function result=isInitialized()
            result=~isempty(rmiml.RmiMUnitData.getInstance('dontInit'));
        end

        function reset()
            if rmiml.RmiMUnitData.isInitialized()
                data=rmiml.RmiMUnitData.getInstance;
                data.clear();
                delete(data);
            end
        end
    end

    methods
        [testProcedureNames,isFileLevel]=getTestNamesUnderRangeRaw(this,filepath,positions);

        function clearCacheEntry(this,filepath)


            this.clearIsMunitCache(filepath);
            this.clearBookmarkToTestCache(filepath);
        end
    end

    methods(Hidden)

        readAllBookmarksForTestNames(this,filepath)

        function clearIsMunitCache(this,filepath)

            if isKey(this.munitCache,filepath)
                this.munitCache.remove(filepath);
            end
        end

        function clearBookmarkToTestCache(this,filepath)
            bookmarkKeys=this.bookmarkToTestCache.keys();
            fileKey=filepath+"::";
            hasThisFile=startsWith(bookmarkKeys,fileKey);
            entriesToRemove=bookmarkKeys(hasThisFile);
            this.bookmarkToTestCache.remove(entriesToRemove);
        end
    end
end


