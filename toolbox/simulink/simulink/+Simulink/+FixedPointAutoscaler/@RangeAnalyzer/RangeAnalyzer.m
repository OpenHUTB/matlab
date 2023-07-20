


classdef RangeAnalyzer<handle



    properties(GetAccess='private',SetAccess='private')
        model;
        subsystem;
        rangeData;
        rangeFileLoc;
        status;
        debugFileHandle;
        oldCGIRSetting;
        oldSLDVDebugSetting;
        runName;
        target;
        compatCheckOnly;
    end

    methods(Access='protected')

        loadRangeData(obj)



        reportRanges(obj)


        removeTempFiles(obj)


        range_record=objectiveToRangeRecord(obj,objective,emlInfo)


        [url,isSFRecord,instanceHdl]=objectiveToURL(obj,objective,emlInfo)



        analyzeRanges(obj)

        cleanupModels(obj)
    end

    methods(Access='public')

        function obj=RangeAnalyzer(curSystem,compatCheckOnly)

            if nargin==1
                compatCheckOnly=false;
            end

            obj.compatCheckOnly=compatCheckOnly;

            obj.model=bdroot(curSystem);
            mdlRefTargetType=get_param(obj.model,'ModelReferenceTargetType');
            obj.target=slprivate('perf_logger_target_resolution',mdlRefTargetType,obj.model,false,false);

            cleanupObj=obj.enterTracePoint('Range Analyzer Constructor');%#ok<NASGU>

            if strcmp(obj.model,curSystem)

                obj.subsystem='';
            else

                obj.subsystem=curSystem;
            end
            obj.rangeData=[];
            obj.rangeFileLoc=[];


            load_system(obj.model);
            try
                obj.model=get_param(obj.model,'Name');
            catch model_load_exception
                rethrow(model_load_exception);
            end

            obj.runName=get_param(obj.model,'FPTRunName');

            if(slsvTestingHook('RAviaRTWtesting')>1)
                obj.debugFileHandle=fopen('fptDebugOutput.txt','w');
            end
            if(slsvTestingHook('RAviaRTWtesting')>2)
                obj.oldCGIRSetting=slsvTestingHook('EnableCGIRPrettyPrinting',1);
                obj.oldSLDVDebugSetting=slavteng('feature','debugLevel');
                slavteng('feature','debugLevel',10);
            end




            fxptds.MATLABIdentifier.holdMasterInferenceReport;

        end

        function analyze(obj)



            datasets=fxptds.getAllDatasetsForModel(obj.model);
            for i=1:numel(datasets)
                runObj=datasets{i}.getRun(obj.runName);
                runObj.cleanupOnDerivation;
            end
            analyzeRanges=Simulink.FixedPointAutoscaler.RangeAnalyzerInner(...
            obj.model,obj.subsystem,obj.target,obj.compatCheckOnly);
            obj.rangeFileLoc=analyzeRanges.analyze;
            delete(analyzeRanges);
            if~obj.compatCheckOnly
                obj.reportRanges;
            end
        end

        function delete(obj)
            cleanupObj=obj.enterTracePoint('Range Analyzer Destructor');%#ok<NASGU>

            if slsvTestingHook('RAviaRTWtesting')>1
                fclose(obj.debugFileHandle);
                if slsvTestingHook('RAviaRTWtesting')>2
                    slsvTestingHook('EnableCGIRPrettyPrinting',obj.oldCGIRSetting);
                    slavteng('feature','debugLevel',obj.oldSLDVDebugSetting);
                end
            else
                obj.removeTempFiles;
            end



            fxptds.MATLABIdentifier.releaseMasterInferenceReport;
        end


        function setRunName(obj,runName)
            obj.runName=runName;
        end

    end

    methods(Access='private')
        function cleanupObj=enterTracePoint(obj,point)

            PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
            obj.model,...
            obj.target,...
            point,...
            true);


            cleanupObj=onCleanup(@()PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
            obj.model,...
            obj.target,...
            point,...
            false));
        end
    end

end



