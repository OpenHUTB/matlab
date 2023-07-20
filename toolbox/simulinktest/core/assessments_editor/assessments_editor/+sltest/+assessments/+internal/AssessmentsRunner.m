




classdef AssessmentsRunner<handle

    properties

Model
Harness
Parameters
Signals


AssessmentInfo


StartupCode
WorkspaceVars
IsExplore
IsParallel
IsQuantitative


Iteration
Tic
StopCondition
SimulationInput
IterationParameters


SimOut
Result
GlobalResult


RevertStruct
    end

    methods

        function obj=AssessmentsRunner(config)
            if isfield(config,'parameters')
                obj.Parameters=config.parameters;
            else
                obj.Parameters=[];
            end
            if isfield(config,'stopCondition')
                obj.StopCondition=str2func(config.stopCondition);
            else
                obj.StopCondition=@(x)(x.Iteration>1);
            end
            if isfield(config,'assessmentInfo')
                obj.AssessmentInfo=config.assessmentInfo;
            end
            if isfield(config,'startupCode')
                obj.StartupCode=config.startupCode;
            end
            if isfield(config,'model')
                obj.Model=config.model;
            end
            if isfield(config,'harness')
                obj.Harness=config.harness;
            end
            if isfield(config,'signals')
                obj.Signals=config.signals;
            end
            if isfield(config,'isExplore')
                obj.IsExplore=config.isExplore;
            else
                obj.IsExplore=false;
            end
            if isfield(config,'quantitative')
                obj.IsQuantitative=config.quantitative;
            else
                obj.IsQuantitative=false;
            end
            if isfield(config,'isParallel')
                obj.IsParallel=config.isParallel;
            else
                obj.IsParallel=false;
            end
            obj.GlobalResult=containers.Map;
            obj.IterationParameters={};
            if obj.IsParallel
                obj.SimOut=parallel.FevalFuture.empty(0,0);
            else
                obj.SimOut=Simulink.SimulationOutput.empty(0,0);
            end
            obj.WorkspaceVars={};
        end


        function explore(obj)
            obj.Tic=tic;
            obj.Iteration=1;
            numWorkers=1;
            poolobj=[];


            if(obj.IsParallel)
                poolobj=gcp('nocreate');
                if isempty(poolobj)

                    poolobj=parpool;
                end
                numWorkers=poolobj.NumWorkers;
            end


            if~isempty(obj.StartupCode)
                if obj.IsParallel
                    pctRunOnAll(obj.StartupCode);
                end
                evalin('base',obj.StartupCode);
                obj.WorkspaceVars=sltest.assessments.internal.AssessmentsRunner.evalCallback(obj.StartupCode);
            end


            obj.loadModel();


            obj.markSignalForLogging();


            while~obj.StopCondition(obj)&&obj.Iteration<=numWorkers

                obj.setParameters(obj.Iteration);
                obj.overrideParameters();


                obj.preExec(obj.Iteration);


                obj.SimOut(obj.Iteration)=obj.simulate(poolobj);
                obj.Iteration=obj.Iteration+1;
            end


            processedId=1;
            if obj.IsParallel
                [completedIdx,res]=fetchNext(obj.SimOut);
            else
                res=obj.SimOut(processedId);
                completedIdx=processedId;
            end


            obj.evaluateAssessments(res);


            obj.postExec(completedIdx);
            processedId=processedId+1;


            while~obj.StopCondition(obj)&&~sltest.assessments.internal.AssessmentsRunner.stop()

                obj.setParameters(obj.Iteration);
                obj.overrideParameters();

                obj.preExec(obj.Iteration);

                fprintf('Simulate [%d]',obj.Iteration);
                obj.SimOut(obj.Iteration)=obj.simulate(poolobj);
                obj.Iteration=obj.Iteration+1;

                if obj.IsParallel
                    [completedIdx,res]=fetchNext(obj.SimOut);
                else
                    res=obj.SimOut(processedId);
                    completedIdx=processedId;
                end

                obj.evaluateAssessments(res);

                obj.postExec(completedIdx);
                processedId=processedId+1;

                drawnow();
            end



            while processedId<obj.Iteration
                [completedIdx,res]=fetchNext(obj.SimOut);
                obj.evaluateAssessments(res);
                obj.postExec(completedIdx);
                processedId=processedId+1;
            end


            obj.revertSignalForLogging();

            obj.closeModel();
        end


        function res=simulate(obj,poolobj)
            if(~isempty(obj.Model))
                if isempty(poolobj)
                    res=sim(obj.SimulationInput{obj.Iteration});
                else
                    res=parfeval(poolobj,@sim,1,obj.SimulationInput{obj.Iteration});
                end
            else
                res=Simulink.SimulationOutput;
            end
        end


        function evaluateAssessments(obj,sltest_simout)

            ccInput={};
            if~isempty(obj.Model)
                ccInput.sltest_simout={sltest_simout};
                if~isempty(obj.Harness)
                    ccInput.sltest_sut={obj.Harness};
                    ccInput.sltest_bdroot={obj.Harness};
                    ccInput.sltest_isharness=true;
                else
                    ccInput.sltest_sut={obj.Model};
                    ccInput.sltest_bdroot={obj.Model};
                    ccInput.sltest_isharness=true;
                end
            end
            ccInput.quantitative=obj.IsQuantitative;




            if(~isempty(obj.WorkspaceVars))
                ccInput.WorkspaceVars=obj.WorkspaceVars;
            end
            results=sltest.internal.evaluateAssessments(obj.AssessmentInfo,ccInput);

            obj.Result=results{1};
            obj.updateGlobalResult();
        end

        function preExec(obj,k)

        end


        function overrideParameters(obj)
            if(~isempty(obj.Model))
                obj.SimulationInput{obj.Iteration}=obj.SimulationInput{1};
            end
            params=obj.IterationParameters{obj.Iteration};
            for i=1:numel(params)
                if(~isempty(obj.Model))
                    obj.SimulationInput{obj.Iteration}=obj.SimulationInput{obj.Iteration}.setVariable(params(i).name,params(i).value);
                end
                fprintf('%s:%g\n',params(i).name,params(i).value);
            end
        end


        function setParameters(obj,iteration)
            params=obj.Parameters;
            for i=1:numel(params)
                if(iteration>1||isempty(params(i).value))
                    params(i).value=params(i).minValue+rand*(params(i).maxValue-params(i).minValue);
                end
            end
            obj.IterationParameters{obj.Iteration}=params;
        end


        function loadModel(obj)
            if(~isempty(obj.Model))
                if(~isempty(obj.Harness))
                    load_system(obj.Model);
                    sltest.harness.load(obj.Model,obj.Harness);
                    if obj.IsParallel
                        pctRunOnAll(sprintf('cd ''%s''',pwd));
                        pctRunOnAll(sprintf('load_system(''%s'')',obj.Model));
                        pctRunOnAll(sprintf('sltest.harness.load(''%s'',''%s'')',obj.Model,obj.Harness));
                    end

                    obj.SimulationInput{obj.Iteration}=Simulink.SimulationInput(obj.Harness);
                else
                    load_system(obj.Model);
                    obj.SimulationInput{obj.Iteration}=Simulink.SimulationInput(obj.Model);
                end
            end
        end


        function closeModel(obj)
            if(~isempty(obj.Model))
                close_system(obj.Model,0);
            end
        end


        function markSignalForLogging(obj)
            isemptySig=isempty(obj.Signals);
            if~isemptySig&&isa(obj.Signals,'cell')
                for i=1:numel(obj.Signals)
                    if(isempty(obj.Signals{i}))
                        isemptySig=true;
                        break;
                    end
                end
            end
            if(~isempty(obj.Model)&&~isemptySig)
                sut=obj.Model;
                if(~isempty(obj.Harness))
                    sut=obj.Harness;
                end
                if obj.IsParallel
                    parfevalOnAll(@stm.internal.util.markOutputSignalsForStreaming,2,sut,obj.Signals);
                end
                [~,obj.RevertStruct.InstrumentedSignals,~]=stm.internal.util.markOutputSignalsForStreaming(sut,obj.Signals);
            end
        end


        function revertSignalForLogging(obj)
            if(isempty(obj.RevertStruct))
                return;
            end
            models=obj.RevertStruct.InstrumentedSignals.keys;
            for i=1:length(models)
                mdl=models{i};
                instrumentedSignalsForMdl=obj.RevertStruct.InstrumentedSignals(mdl);
                currLoggedSignals=stm.internal.MRT.share.getInstrumentedSignals(mdl);
                bHasHMIInstrumentedSignals=isa(currLoggedSignals,'Simulink.HMI.InstrumentedSignals')||...
                isa(instrumentedSignalsForMdl,'Simulink.HMI.InstrumentedSignals');

                if(bHasHMIInstrumentedSignals)
                    set_param(mdl,'InstrumentedSignals',instrumentedSignalsForMdl);
                else

                    for k=1:length(currLoggedSignals)
                        phs=get_param(currLoggedSignals(k).BlockPath,'PortHandles');
                        set_param(phs.Outport,'DataLogging','off');
                    end

                    for k=1:length(instrumentedSignalsForMdl)
                        phs=get_param(instrumentedSignalsForMdl(k).BlockPath,'PortHandles');
                        set_param(phs.Outport,'DataLogging','on');
                    end
                end
            end
        end


        function postExec(obj,k)
            if(obj.IsExplore)

                params=[];
                iterationParams=obj.IterationParameters{k};
                for i=1:numel(iterationParams)
                    params.(iterationParams(i).name)=iterationParams(i).value;
                end
                res.params=params;
                res.result=obj.Result;
                for idx=1:numel(res)
                    res.result(idx).Result=sltest.assessments.internal.AssessmentResultDB.saveResult(res.result(idx).Result);
                end
                message.publish('/Assessments/parametersEvaluationResult',res);
            end
        end


        function updateGlobalResult(obj)
            for i=1:numel(obj.Result)
                label=obj.Result(i).Name;
                pass=(obj.Result(i).Outcome==0);
                if(obj.GlobalResult.isKey(label))
                    if~pass
                        obj.GlobalResult(label)=pass;
                    end
                else
                    obj.GlobalResult(label)=pass;
                end
            end
        end


        function res=allFailed(obj)
            v=obj.GlobalResult.values;
            res=~isempty(v)&&all(~[v{:}]);
        end


        function res=anyFailed(obj)
            v=obj.GlobalResult.values;
            res=any(~[v{:}]);
        end
    end

    methods(Static)

        function vars=evalCallback(callbackString)
            eval(callbackString);
            tmp=whos;
            vars={};
            for i=1:numel(tmp)
                if~strcmp(tmp(i).name,'callbackString')
                    vars.(tmp(i).name)=eval(tmp(i).name);
                end
            end
        end


        function res=stop(val)
            persistent stop;
            if(nargin==1)
                stop=val;
            end
            res=stop;
        end
    end

end

