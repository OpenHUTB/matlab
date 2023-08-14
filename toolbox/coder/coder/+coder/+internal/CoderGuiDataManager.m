classdef(Sealed)CoderGuiDataManager<handle









    properties(Constant)
        FIELD_REPORT='report';
        FIELD_TEST_OUTPUT='testOutput';
        FIELD_COVERAGE='coverageInfo';
        SERIAL_VERSION_UID=2;
    end

    properties(Access=private)
registry
cacheMap
restoredBuildTypes
    end


    methods(Access=private)
        function this=CoderGuiDataManager()
            this.registry=com.mathworks.toolbox.coder.app.CoderRegistry.getInstance();
            this.reset();
        end
    end


    methods(Static)
        function v=VERSION()
            v=coder.internal.CoderGuiDataManager.createVersionStruct();
        end

        function instance=getInstance()
            mlock;
            persistent singleton;

            if isempty(singleton)
                singleton=coder.internal.CoderGuiDataManager();
            end

            instance=singleton;
        end

        function vars=getCoderTargetDisabled(varargin)
            persistent CoderTargetApiDisabled;
            if isempty(CoderTargetApiDisabled)
                CoderTargetApiDisabled=false;
            end
            if nargin>0
                CoderTargetApiDisabled=varargin{1};
            end
            vars=CoderTargetApiDisabled;
        end

        function equal=isCurrentVersion(versionStruct)
            thisVersion=coder.internal.CoderGuiDataManager.VERSION;
            equal=all(isfield(versionStruct,{'matlabVersion','serialVersion','toolboxChecksum'}))&&...
            strcmp(versionStruct.matlabVersion,thisVersion.matlabVersion)&&...
            versionStruct.serialVersion==thisVersion.serialVersion&&...
            strcmp(versionStruct.toolboxChecksum,thisVersion.toolboxChecksum);
        end
    end

    methods(Static,Access=private)
        function versionStruct=createVersionStruct()
            import('com.mathworks.toolbox.coder.model.CoderFileSupport');
            versionStruct=struct('matlabVersion',version(),...
            'serialVersion',coder.internal.CoderGuiDataManager.SERIAL_VERSION_UID,...
            'toolboxChecksum','');
        end
    end

    methods(Static,Hidden)
        function setCoderTargetsDisabled(disabled)


            coder.internal.CoderGuiDataManager.getCoderTargetDisabled(disabled);
        end
    end

    methods
        function isgui=isGuiProject(this,javaConfig)
            isgui=this.registry.isGui(javaConfig);
        end

        function cacheReportPostCodegen(this,javaConfig,report)


            if this.isGuiProject(javaConfig)
                return;
            end

            buildType=com.mathworks.toolbox.coder.app.CoderBuildType.PRIMARY;
            this.updateCache(buildType,'report',report);



            com.mathworks.toolbox.coder.plugin.Utilities.updatePrebuildChecksum(javaConfig,buildType);
            this.storeLastOutputRoot(javaConfig,report,buildType);
            this.saveGuiData(javaConfig);
        end

        function setGuiCodegenReport(this,javaConfig,buildType,report,log)
            this.assertGuiProject(javaConfig);

            if isfield(report,'summary')
                report.summary.buildResults{end+1}=log;
            end

            this.updateCache(buildType,'report',report);
            this.storeLastOutputRoot(javaConfig,report,buildType);
        end

        function setCoverageInfo(this,javaConfig,buildType,coverageInfo)
            this.assertGuiProject(javaConfig);
            this.updateCache(buildType,this.FIELD_COVERAGE,coverageInfo);
        end

        function setGuiTestOutput(this,javaConfig,buildType,testOutput)
            this.assertGuiProject(javaConfig);
            this.updateCache(buildType,'testOutput',testOutput);
        end

        function cacheDataForGui(this,javaConfig)
            this.assertGuiProject(javaConfig);
            this.saveGuiData(javaConfig);
        end

        function[report,errorCode]=restore(this,javaConfig,restorationFile,buildType)
            this.assertGuiProject(javaConfig);
            report=[];
            errorCode=[];

            matfile=char(restorationFile.getAbsolutePath());

            try
                data=load(matfile);
                [valid,reason]=this.validateCache(javaConfig,data,buildType);

                if valid
                    this.updateCache(buildType,data);
                    report=data.report;
                else
                    errorCode=reason;
                end
            catch
                errorCode=com.mathworks.toolbox.coder.mi.RestorationFailureCode.GENERIC;
            end
        end

        function data=retrieveFromCache(this,buildType,field)
            data=[];
            key=char(buildType.toString());

            if this.cacheMap.isKey(key)
                cache=this.cacheMap(key);
                if isfield(cache,field)
                    data=cache.(field);
                end
            end
        end

        function reset(this)
            this.cacheMap=containers.Map();
            this.restoredBuildTypes={};
        end
    end

    methods(Access=private)
        function updateCache(this,buildType,varargin)
            key=char(buildType.toString());

            if this.cacheMap.isKey(key)
                cache=this.cacheMap(key);
            else
                cache=struct(this.FIELD_REPORT,[],this.FIELD_TEST_OUTPUT,[],this.FIELD_COVERAGE,[]);
            end

            if~isstruct(varargin{1})
                for i=1:2:(nargin-2)
                    field=varargin{i};
                    if ismember(field,{'version','checksum'})
                        continue;
                    end
                    cache.(field)=varargin{i+1};
                end
            else
                fields=fieldnames(varargin{1});
                for i=1:numel(fields)
                    if ismember(fields{i},{'version','checksum'})
                        continue;
                    end
                    cache.(fields{i})=varargin{1}.(fields{i});
                end
            end

            this.cacheMap(key)=cache;
        end

        function saveGuiData(this,javaConfig)
            keys=this.cacheMap.keys();
            for i=1:length(keys)
                this.saveDataParcel(javaConfig,keys{i});
            end
        end

        function saveDataParcel(this,javaConfig,cacheKey)
            cache=this.cacheMap(cacheKey);

            if isempty(cache.report)||~all(isfield(cache.report,{'inference','summary'}))
                return;
            end

            buildType=com.mathworks.toolbox.coder.app.CoderBuildType.valueOf(cacheKey);
            assert(~isempty(buildType));

            import('com.mathworks.toolbox.coder.plugin.Utilities');

            checksum=char(Utilities.getPreBuildChecksum(javaConfig,buildType));
            data=struct(...
            'version',this.VERSION,...
            'checksum',checksum,...
            this.FIELD_REPORT,cache.(this.FIELD_REPORT),...
            this.FIELD_TEST_OUTPUT,cache.(this.FIELD_TEST_OUTPUT),...
            this.FIELD_COVERAGE,cache.(this.FIELD_COVERAGE));
            matFile=Utilities.resolveGuiReportFile(javaConfig,buildType);

            save(char(matFile.getAbsolutePath()),'-struct','data');
        end

        function assertGuiProject(this,javaConfig)
            assert(this.isGuiProject(javaConfig));
        end

        function storeLastOutputRoot(this,javaConfig,report,buildType)%#ok<INUSL>
            outputRoot='';
            if isfield(report,'summary')&&isfield(report.summary,'directory')
                outputRoot=report.summary.buildDirectory;
            end

            com.mathworks.toolbox.coder.plugin.Utilities.storeLastOutputRoot(...
            javaConfig,java.io.File(outputRoot),buildType);
        end

        function[valid,reason]=validateCache(this,javaConfig,data,buildType)
            import('com.mathworks.toolbox.coder.mi.RestorationFailureCode');
            checksum=com.mathworks.toolbox.coder.plugin.Utilities.getPreBuildChecksum(javaConfig,buildType);
            valid=false;

            if~all(isfield(data,{'version','checksum'}))
                reason=RestorationFailureCode.MALFORMED_DATA_CACHE;
            elseif~this.isCurrentVersion(data.version)
                reason=RestorationFailureCode.MATLAB_VERSION_MISMATCH;
            elseif~strcmp(data.checksum,char(checksum))
                reason=RestorationFailureCode.PROJECT_CACHE_OUT_OF_SYNC;
            else
                reason=[];
                valid=true;
            end
        end
    end
end