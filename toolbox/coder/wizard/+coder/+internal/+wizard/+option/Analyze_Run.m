


classdef Analyze_Run<coder.internal.wizard.OptionBase
    methods
        function obj=Analyze_Run(env)
            id='Analyze_Run';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Scheduler';
            obj.Type='button';
            obj.Value='Analyze';
            if env.UseModelAdvisor
                obj.PostCompileActionCheck={'mathworks.codegen.quickstart.checkDeployment'};
            end
            obj.HasMessage=false;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end
        function onNext(obj)
            env=obj.Env;
            if env.isSubsystemBuild


                obj.NextQuestion_Id=coder.internal.wizard.question.Scheduler.getNextQuestionId(env);
            else
                sampleTime=env.ModelSampleTime;
                if sampleTime.SingleRate
                    obj.NextQuestion_Id=coder.internal.wizard.question.Scheduler.getNextQuestionId(env);

                    coder.internal.wizard.option.Scheduler_SingleTask.OnNext(env);
                end
            end
        end

        function onPostCompile(obj)


            env=obj.Env;

            env.ModelSampleTime=coder.internal.SampleRateInfo(env.ModelName);
            if env.isSubsystemBuild
                env.SubsystemSampleTime=coder.internal.SampleRateInfo(env.SourceSubsystem);
                env.HasContinuousTime=env.SubsystemSampleTime.HasContinuousTime;
            else
                env.HasContinuousTime=env.ModelSampleTime.HasContinuousTime;
            end

            if~env.isSubsystemBuild
                if strcmp(env.getParam('SolverType'),'Variable-step')
                    env.Solver='FixedStepAuto';
                    env.setParamRequired('Solver',env.Solver);
                else


                    env.Solver=env.getParam('Solver');
                end
            end
            compiledSolver=get_param(env.ModelHandle,'CompiledSolverName');
            if strcmp(compiledSolver,'FixedStepDiscrete')||strcmp(compiledSolver,'VariableStepDiscrete')
                env.UseContinuousSolver=false;
            else
                env.UseContinuousSolver=true;
            end
            if~env.isSubsystemBuild
                if env.ModelSampleTime.SuggestToChangeFixedStepToAuto
                    env.setParamRequired('FixedStep','auto');
                end
            end

            if env.isSubsystemBuild
                env.ExportedFunctionCalls=coder.internal.wizard.checkExportedFcnsCondition(env.SourceSubsystem);
            else
                env.ExportedFunctionCalls=coder.internal.wizard.checkExportedFcnsCondition(env.ModelName);
            end
        end
        function updateStateAfterAnalyze(obj)
            obj.Type='hidden';
            obj.Value=true;
            obj.Answer=true;
        end
        function reset(obj)


            obj.Type='button';
            obj.Value='Analyze';
            obj.Answer=-1;
        end
    end
end


