

classdef F2FGuiCallbackManager<handle
    properties(Constant,Access=private)
        F2F_GUI_REPORT_FILENAME=char(com.mathworks.toolbox.coder.plugin.Utilities.GUI_REPORT_F2F_MAT_FILENAME);
        RESTORATION_PATH_KEY=char(com.mathworks.toolbox.coder.plugin.Utilities.PARAM_F2F_DATA_CACHE_PATH);
        VERSION_FIELD='Version';
        MANAGED_PROPERTIES={'MexBuildOutput','DerivedRangeAnalysisOutput','SimulationOutput','ConversionOutput',...
        'VerificationOutput','CheckForIssuesOutput','Logs','Checksum'};
    end

    properties(AbortSet)
MexBuildOutput
SimulationOutput
DerivedRangeAnalysisOutput
ConversionOutput
VerificationOutput
CheckForIssuesOutput
Checksum
    end

    properties(Dependent,SetAccess=private)
ConversionSummary
    end

    properties(Hidden)
Logs
    end

    properties(Access=private)
javaConfig
restoring
restored
invalid
    end

    methods(Access=private)
        function this=F2FGuiCallbackManager()
            this.restoring=false;
            this.reset();
        end
    end

    methods(Static)
        function instance=getInstance()
            mlock;
            persistent singleton;

            if isempty(singleton)
                singleton=coder.internal.F2FGuiCallbackManager();
            end

            instance=singleton;
        end

        function result=restoreSingleton()
            instance=coder.internal.F2FGuiCallbackManager.getInstance();
            result=instance.restore();
        end

        function result=initAndRestore(javaConfig)
            instance=coder.internal.F2FGuiCallbackManager.getInstance();
            instance.init(javaConfig);
            result=instance.restore();
        end

        function saveAndCleanup(fixedPointState)
            instance=coder.internal.F2FGuiCallbackManager.getInstance();
            instance.cleanup(fixedPointState,true);
        end

        function saveWithLogs(logs)
            instance=coder.internal.F2FGuiCallbackManager.getInstance();
            instance.updateLogField(logs);
            instance.saveData();
        end

        function resetAndClear()
            instance=coder.internal.F2FGuiCallbackManager.getInstance();
            instance.cleanup([],false);
        end
    end

    methods
        function success=init(this,javaConfig)
            if isempty(this.javaConfig)
                this.javaConfig=javaConfig;
                this.reset();
                success=true;
            else
                success=false;
            end
        end

        function cleanup(this,fixedPointState,commit)
            if isempty(this.javaConfig)
                return;
            end

            saveError=[];
            try
                if commit
                    if~isempty(fixedPointState)
                        this.updateLogField(fixedPointState);
                    end
                    this.saveData();
                end
            catch saveError
            end

            this.reset();
            this.javaConfig=[];

            if~isempty(saveError)
                saveError.throwAsCaller();
            end
        end

        function reset(this)
            for i=1:length(this.MANAGED_PROPERTIES)
                this.(this.MANAGED_PROPERTIES{i})=[];
            end

            this.invalid=false;
            this.restored=false;
        end

        function data=restore(this)
            function setValueFromStruct(fieldName)
                if~strcmp(fieldName,this.VERSION_FIELD)
                    this.(fieldName)=raw.(fieldName);
                end
            end

            this.assertInitialized();

            data=[];
            dataPath=char(this.javaConfig.getParamAsString(this.RESTORATION_PATH_KEY));

            if~isempty(dataPath)&&isfile(dataPath)
                this.restoring=true;

                try
                    raw=load(dataPath);

                    if this.validateDataStruct(raw)
                        cellfun(@(fieldName)setValueFromStruct(fieldName),this.MANAGED_PROPERTIES);
                        data=raw;

                        manager=coderprivate.Float2FixedManager.instance();
                        manager.deferredBackendLoad=true;
                    end
                catch
                    data=[];
                end

                this.restoring=false;
            end
        end

        function saveData(this)
            this.assertInitialized();

            if~this.invalid
                return;
            end

            this.updateCachePathParam();
            data=struct(this.VERSION_FIELD,coder.internal.CoderGuiDataManager.VERSION);

            for i=1:length(this.MANAGED_PROPERTIES)
                property=this.MANAGED_PROPERTIES{i};
                data.(property)=this.(property);
            end

            try
                save(this.getSavePath(),'-struct','data');
                this.getConverter.saveConverterState();
            catch
            end
        end

        function updateCachePathParam(this)
            this.assertInitialized();
            try



                currentSavePath=this.getSavePath();
            catch


                currentSavePath='';
            end
            this.javaConfig.setParamAsString(this.RESTORATION_PATH_KEY,currentSavePath);
        end
    end

    methods
        function set.MexBuildOutput(this,value)
            this.MexBuildOutput=this.invalidateAndReturn('MexBuildOutput',value);
        end

        function set.SimulationOutput(this,value)
            this.SimulationOutput=this.invalidateAndReturn('SimulationOutput',value);
        end

        function set.DerivedRangeAnalysisOutput(this,value)
            this.DerivedRangeAnalysisOutput=this.invalidateAndReturn('DerivedRangeAnalysisOutput',value);
        end

        function set.ConversionOutput(this,value)
            this.ConversionOutput=this.invalidateAndReturn('ConversionOutput',value);
        end

        function set.VerificationOutput(this,value)
            this.VerificationOutput=this.invalidateAndReturn('VerificationOutput',value);
        end

        function set.CheckForIssuesOutput(this,value)
            this.CheckForIssuesOutput=this.invalidateAndReturn('CheckForIssuesOutput',value);
        end

        function set.Checksum(this,value)
            if~isempty(value)
                this.Checksum=this.invalidateAndReturn('Checksum',char(value));
            end
        end

        function summary=get.ConversionSummary(this)
            if~isempty(this.ConversionOutput)&&numel(this.ConversionOutput)>=5
                summary=this.ConversionOutput{5};
            else
                summary=[];
            end
        end
    end

    methods(Access=private)
        function valid=validateDataStruct(this,raw)
            valid=isfield(raw,this.VERSION_FIELD)&&all(isfield(raw,this.MANAGED_PROPERTIES));



            valid=valid&&coder.internal.CoderGuiDataManager.isCurrentVersion(raw.(this.VERSION_FIELD));



            import com.mathworks.toolbox.coder.mi.ConversionUtils;
            valid=valid&&strcmp(char(ConversionUtils.getProjectChecksum(this.javaConfig)),raw.Checksum);
        end

        function updateLogField(this,fixedPointState)
            function updateLogElement(pos,predicate,extractor)
                if predicate()
                    this.Logs{pos}=char(extractor());
                else
                    this.Logs{pos}='';
                end
            end

            assert(isa(fixedPointState,...
            'com.mathworks.toolbox.coder.fixedpoint.FixedPointRestorationHelper$FpStateSaveContext'));

            if numel(this.Logs)~=5
                this.Logs=cell(5,1);
            end

            updateLogElement(1,@fixedPointState.isSimulationLogOutdated,@fixedPointState.getSimulationLog);
            updateLogElement(2,@fixedPointState.isDerivedRangesLogOutdated,@fixedPointState.getDerivedRangeLog);
            updateLogElement(3,@fixedPointState.isConversionLogOutdated,@fixedPointState.getConversionLog);
            updateLogElement(4,@fixedPointState.isVerificationLogOutdated,@fixedPointState.getVerificationLog);
            updateLogElement(5,@fixedPointState.isCheckForIssuesLogOutdated,@fixedPointState.getCheckForIssuesLog);
        end

        function newValue=invalidateAndReturn(this,field,newValue)
            if isempty(this.javaConfig)||this.restoring||this.invalid
                return;
            elseif~isempty(newValue)||(isempty(this.(field))~=isempty(newValue))
                this.invalid=true;
            end
        end

        function converter=getConverter(this)%#ok<MANU>
            converter=coderprivate.Float2FixedManager.instance().fpc;
        end

        function fixptConfig=getFixptConfig(this)
            fixptConfig=this.getConverter().fxpCfg;
            assert(~isempty(fixptConfig));
        end

        function saveDirectory=getSaveDirectory(this)
            saveDirectory=this.getFixptConfig().OutputFilesDirectory;
            assert(~isempty(saveDirectory));
        end

        function savePath=getSavePath(this)
            savePath=[this.getSaveDirectory(),'/',this.F2F_GUI_REPORT_FILENAME];
        end

        function assertInitialized(this)
            assert(~isempty(this.javaConfig));
        end
    end
end
