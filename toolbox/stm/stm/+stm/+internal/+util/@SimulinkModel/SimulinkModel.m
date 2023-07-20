classdef SimulinkModel<handle





    properties
        Model;
        ConfigParameters;
        ModelLoadedOrOpened;
        AutoSaveOptions;
        VarsLoaded;
        HarnessMode;
        InputMode;
        SelectedHarness;
        System;
        HarnessName;
        ModelName;
        StopTimer;
        stmBeenStopped=false;
    end

    events
        ModelStopped;
    end

    methods
        [currenState1,currenState2,sigB,ind,varsLoaded,...
        currStopTime,paramValues,warnMessage,...
        logOrError,externalInputRunData,sigBuilderInfo]...
        =loadInputs(obj,simInputs,inputDataSetsRunFile,inputSignalGroupRunFile);

        function obj=SimulinkModel(model,system)
            obj.System=system;



            obj.Model=model;
            obj.ModelName=model;
            obj.loadModel();
            obj.AutoSaveOptions=get_param(0,'AutoSaveOptions');

            callback=@(varargin)cb_Stop(obj);
            obj.StopTimer=timer('Name','sltestmgrstop');
            obj.StopTimer.ObjectVisibility='off';
            obj.StopTimer.TimerFcn=callback;
            obj.StopTimer.Period=0.5;
            obj.StopTimer.ExecutionMode='fixedRate';
        end

        function startTimer(obj)
            if~isempty(obj.StopTimer)
                start(obj.StopTimer);
            end
        end

        function stopTimer(obj)
            if~isempty(obj.StopTimer)
                if isvalid(obj.StopTimer)
                    stop(obj.StopTimer);
                end
                obj.StopTimer.TimerFcn='';
                delete(obj.StopTimer);
                obj.StopTimer=[];
            end
        end

        function cb_Stop(obj)

            bStop=obj.readStopTestBit();
            if(bStop==1)
                obj.stmBeenStopped=true;
            end

            if(bStop==1&&...
                strcmp(get_param(obj.Model,'SimulationStatus'),'running'))
                set_param(obj.Model,'SimulationCommand','stop');
                evt=event.EventData;
                notify(obj,'ModelStopped',evt);
            end
        end

        function delete(obj)
            try
                if~isempty(obj.StopTimer)
                    if isvalid(obj.StopTimer)
                        stop(obj.StopTimer);
                    end
                    obj.StopTimer.TimerFcn='';
                    delete(obj.StopTimer);
                    obj.StopTimer=[];
                end
                timers=timerfindall('Name','sltestmgrstop');
                if~isempty(timers)
                    stop(timers);
                    delete(timers);
                    obj.StopTimer=[];
                end
            catch
            end

            obj.restore();
        end

        function out=get.Model(obj)
            if isempty(obj.HarnessName)
                out=obj.Model;
            else
                out=obj.HarnessName;
            end
        end

        function restore(obj)
            import stm.internal.SlicerDebuggingStatus;
            if~obj.ModelLoadedOrOpened&&(stm.internal.slicerDebugStatus~=SlicerDebuggingStatus.DebugModeTestRun)
                bdclose(obj.ModelName);
            end
            obj.ModelLoadedOrOpened='';
        end

        function flag=readStopTestBit(~)
            flag=stm.internal.readStopTest();
        end
    end

    methods(Hidden)
        function loadModel(obj)
            obj.ModelLoadedOrOpened=true;
            if~stm.internal.util.SimulinkModel.isModelOpenOrLoaded(obj.Model)
                obj.ModelLoadedOrOpened=false;
                load_system(obj.Model);
            end
            type=get_param(obj.Model,'Type');
            if~strcmp(type,'block_diagram')
                error(message('stm:general:InvalidModelNameInNewTestFileFromModelDialog'));
            end
        end
    end

    methods(Static)
        function[dataSets,validIdx]=getInputDataHelper(externalInput)
            dataSets={};
            validIdx=[];
            if~isempty(externalInput)
                try
                    inputStrings=strsplit(externalInput,',');
                catch

                    inps=textscan(externalInput,'%s',',');
                    inputStrings=inps{1};
                end

                validIdx=true(1,length(inputStrings));
                for k=1:length(inputStrings)
                    try
                        dataSets{end+1}=evalin('base',inputStrings{k});%#ok<AGROW>
                    catch


                        validIdx(k)=false;
                    end
                end
            end
        end

        function tMax=getLastTimePoint(inputRunData)
            tMax=[];
            numRuns=length(inputRunData);
            if(numRuns>0)
                tFinal=-realmax;
                runID=[inputRunData.runID];
                for i=1:numRuns
                    tFinal=max(stm.internal.getRunMaxTime(runID(i)),tFinal);
                end
                tMax=tFinal;
            end
        end


        function result=isModelOpenOrLoaded(model)
            result=bdIsLoaded(model);
        end

        function text=formatSimTime(time)

            text=sprintf('%.17g',time);
        end
    end
end
