




classdef MatlabTaskDispatcherTask<Sldv.Tasking.Task
    properties(Access=private)
        mTestComp=[];
        mSldvAnalyzer Sldv.Analyzer


        mProximityDataFile='';
        mProximityDataReadyFile='';
        mCount=0;
        mProximityDataFileDirectory='';
        mProximityTaskFilename='proximityTask.mat';
        mProximityUndecidedObjs=[];
        mSelfTest_ProximityTaskCreation=false;


        mLoggerId='sldv::task_manager';
    end

    events
CheckForMatlabTask
    end


    methods(Access=public)
        function obj=MatlabTaskDispatcherTask(aTaskMgrH,aReady,aTestComp,aSldvAnalyzer)

            obj=obj@Sldv.Tasking.Task(aTaskMgrH,aReady);
            obj.mSldvAnalyzer=aSldvAnalyzer;
            obj.mTestComp=aTestComp;


            logStr=sprintf('MatlabTaskDispatcherTask: Task Created');
            sldvprivate('SLDV_LOG_DEBUG',obj.mLoggerId,logStr);

            obj.triggerOn(Sldv.Tasking.SldvEvents.AnalysisInit);
            obj.triggerOn(Sldv.Tasking.SldvEvents.AnalysisWrap);
            obj.triggerOn(Sldv.Tasking.SldvEvents.CheckForMatlabTask);
        end

        function delete(~)
        end
    end


    methods(Access=protected)
        function status=doTask(obj,aEvent)



            status=true;
            switch aEvent
            case Sldv.Tasking.SldvEvents.AnalysisInit
                try
                    obj.init();






                    if(strcmp('TestGeneration',obj.mSldvOpts.Mode))
                        obj.done();
                    end
                    val=obj.canRunProximity();
                    if~val
                        outputDir=sldvprivate('mdl_get_output_dir',obj.mTestComp);
                        [status,obj.mProximityDataFile,obj.mProximityDataReadyFile]=...
                        proximityDataGenerator.saveProximityData('proximitydata',outputDir);
                        return
                    end

                    obj.handleMatlabTasks();
                catch MEx
                    obj.done();
                end

            case Sldv.Tasking.SldvEvents.AnalysisWrap

                logStr=sprintf('MatlabTaskDispatcherTask: Task Done set by %s',aEvent);
                sldvprivate('SLDV_LOG_DEBUG',obj.mLoggerId,logStr);
                obj.done();
                return;

            case Sldv.Tasking.SldvEvents.CheckForMatlabTask

                logStr=sprintf('MatlabTaskDispatcherTask: handleMatlabTasks due to %s',aEvent);
                sldvprivate('SLDV_LOG_DEBUG',obj.mLoggerId,logStr);
                try
                    obj.handleMatlabTasks();
                catch MEx
                    obj.done();
                end

            otherwise
                assert(false,'MatlabTaskDispatcherTask received an invalid event');
            end
        end

        function status=canRunProximity(obj)
            obj.mTestComp.profileStage('QuickProximityCheck');
            status=false;
            try
                status=proximityDataGenerator.canRunProximity();
            catch

            end
            obj.mTestComp.profileStage('end');

            if~status
                obj.done();
            end
        end

        function doCleanup(obj,cause)
            if isfile(obj.mProximityDataReadyFile)
                delete(obj.mProximityDataReadyFile);
            end
            if isfile(obj.mProximityDataFile)
                delete(obj.mProximityDataFile);
            end
            return;
        end
    end

    methods(Access=private)

        function init(obj)

            logStr=sprintf('MatlabTaskDispatcherTask: init function called');
            sldvprivate('SLDV_LOG_DEBUG',obj.mLoggerId,logStr);

            if isempty(obj.mProximityDataFileDirectory)
                obj.mProximityDataFileDirectory=sldvprivate('mdl_get_output_dir',obj.mTestComp);
            end




        end

        function handleMatlabTasks(obj)
            try
                [tf,taskfile]=obj.isProximityTaskAvailable();
                if tf==false
                    logStr=sprintf('MatlabTaskDispatcherTask: Yielded by %s',Sldv.Tasking.SldvEvents.CheckForMatlabTask);
                    sldvprivate('SLDV_LOG_DEBUG',obj.mLoggerId,logStr);

                    obj.yield(Sldv.Tasking.SldvEvents.CheckForMatlabTask);
                    return;
                end

                obj.handleProximityTableCalcTask(taskfile);


                obj.done();
            catch MEx
                obj.done();
            end
        end


        function handleProximityTableCalcTask(obj,proximityTaskFile)
            try
                assert(isfile(proximityTaskFile));
                dataFromProximityTask=load(proximityTaskFile);
                obj.mProximityUndecidedObjs=dataFromProximityTask.inputObjs;

                delete(proximityTaskFile);



                obj.mTestComp.profileStage('TaskBasedProximityTableCalc');
                obj.calculateProximityData();
            catch MEx




            end
            obj.mTestComp.profileStage('end');
        end

        function[tf,proximityTaskFile]=isProximityTaskAvailable(obj)
            tf=false;

            obj.mCount=obj.mCount+1;

            logStr=sprintf('MatlabTaskDispatcherTask: Checking for ProximityTask %d time',obj.mCount);
            sldvprivate('SLDV_LOG_DEBUG',obj.mLoggerId,logStr);

            proximityTaskFile=fullfile(obj.mProximityDataFileDirectory,obj.mProximityTaskFilename);

            if obj.mSelfTest_ProximityTaskCreation

                [sldvData,~,~,~]=obj.mSldvAnalyzer.getStaticSldvData();
                inputObjs=1:length(sldvData.Objectives);
                save(proximityTaskFile,'inputObjs');
            end

            if isfile(proximityTaskFile)
                tf=true;
            end
        end

        function calculateProximityData(obj)
            logStr=sprintf('MatlabTaskDispatcherTask: Proximity Data is getting calculated');
            sldvprivate('SLDV_LOG_DEBUG',obj.mLoggerId,logStr);
            [sldvData,~,~,~,goalIdToDvIdMap]=obj.mSldvAnalyzer.getStaticSldvData();
            proximityDataGenerator=Sldv.Analysis.ProximityData.ProximityDataGenerator(sldvData,goalIdToDvIdMap);
            try
                proximityDataGenerator.run(obj.mProximityUndecidedObjs);
            catch MEx

            end
            outputDir=sldvprivate('mdl_get_output_dir',obj.mTestComp);
            [status,obj.mProximityDataFile,obj.mProximityDataReadyFile]=proximityDataGenerator.saveProximityData('proximitydata',outputDir);


            logStr=sprintf('MatlabTaskDispatcherTask: Proximity Data calculation is completed with status %d',status);

            sldvprivate('SLDV_LOG_DEBUG',obj.mLoggerId,logStr);
        end
    end

end
