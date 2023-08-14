



classdef EmitterDb<sldv.code.internal.EmitterDb
    properties
CovStructs
    end

    methods
        function this=EmitterDb()
            this.CovStructs=containers.Map('KeyType','char','ValueType','any');
        end



        function addModuleInfo(this,moduleName,covStruct)
            this.CovStructs(moduleName)=covStruct;
        end




        function populateModuleInfo(this,modelInfo)
            tmpDir=tempname;
            polyspace.internal.makeParentDir(fullfile(tmpDir,'.'));
            if sldv.code.internal.feature('debug')
                fprintf(1,'### Debug: Keeping temporary directory %s\n',tmpDir);
            else
                cleanupDir=onCleanup(@()sldv.code.internal.removeDir(tmpDir));
            end

            for ii=1:numel(modelInfo)
                if modelInfo(ii).SupportSldv
                    settingsChecksum=modelInfo(ii).SettingsChecksum;
                    ccLib=modelInfo(ii).LibPath;
                    coverageDb=internal.slcc.cov.LibUtils.getTraceabilityDb(ccLib);
                    dbFile=sldv.code.internal.extractDb(tmpDir,coverageDb);

                    db=sldv.code.slcc.internal.TraceabilityDb(dbFile);
                    db.computeShortestUniquePaths();


                    this.addModuleInfo(settingsChecksum,struct('codeTr',db));
                    db.close();
                end
            end
        end
    end


    methods
        function covStruct=getCodeCoverageInfo(this,~,moduleName)
            covStruct=[];
            if this.CovStructs.isKey(moduleName)
                covStruct=this.CovStructs(moduleName);
            end
        end


        function moduleH=getModuleHandle(~,slHandle,moduleName)%#ok<INUSD>
            moduleH=slHandle;
        end




        function codeKind=getCodeKind(~)
            codeKind='slcc';
        end
    end

    methods(Access=protected)


        function[analysis,info]=getEntryInfoFromHandle(~,~)
            analysis=[];
            info=[];

            assert(false,'getEntryInfoFromHandle is not supposed to be called');
        end



        function extractAnalysisInfo(~)
            assert(false,'extractAnalysisInfo is not supposed to be called');
        end
    end
end


