




























classdef SampleRateInfo<handle
    properties
ModelName
Subsystem
        HasContinuousTime=[]
        HasAsyncRates=[]
        NumFiniteRate=[]
        SingleRate=[]
        SuggestToChangeFixedStepToAuto=[]
        FiniteRates=[]
    end
    methods
        function obj=SampleRateInfo(system)
            [mdl,sys]=strtok(system,'/');
            if~isempty(sys)
                obj.ModelName=mdl;
                obj.Subsystem=system;
            else
                obj.ModelName=mdl;
                obj.Subsystem='';
            end
            obj.checkRate;
        end
        function checkRate(obj)
            obj.HasContinuousTime=false;
            obj.HasAsyncRates=false;
            if~isempty(obj.Subsystem)
                obj.checkSubsystemRate;
            else
                obj.checkModelRate;
            end












            if obj.NumFiniteRate<=1
                obj.SingleRate=true;
            else
                obj.SingleRate=false;
            end
            fixedSizeSetting=get_param(obj.ModelName,'FixedStep');
            solverType=get_param(obj.ModelName,'SolverType');
            if strcmp(solverType,'Variable-step')&&obj.NumFiniteRate>=1&&~strcmp(fixedSizeSetting,'auto')
                obj.SuggestToChangeFixedStepToAuto=true;
            else
                obj.SuggestToChangeFixedStepToAuto=false;
            end

        end
    end
    methods(Hidden)
        function checkSubsystemRate(obj)
            system=obj.Subsystem;

            Simulink.BlockDiagram.getSampleTimes(obj.ModelName);
            rates=get_param(system,'CompiledSampleTime');
            if~iscell(rates)
                rates={rates};
            end
            nRates=0;
            for i=1:length(rates)
                switch rates{i}(1)
                case-1



                    if rates{i}(2)<-1
                        obj.HasAsyncRates=true;
                    end
                case Inf

                case 0
                    obj.HasContinuousTime=true;
                otherwise
                    if rates{i}(1)>0&&rates{i}(1)<Inf
                        nRates=nRates+1;
                        obj.FiniteRates(end+1)=rates{i}(1);
                    end
                end
            end
            obj.NumFiniteRate=nRates;
            if nRates<=1
                if nRates==0&&strcmp(get_param(obj.ModelName,'SolverType'),'Fixed-step')


                    if~strcmp(get_param(obj.ModelName,'FixedStep'),'auto')
                        obj.FiniteRates(end+1)=str2double(get_param(obj.ModelName,'FixedStep'));
                    end
                end
            end
        end
        function checkModelRate(obj)
            system=obj.ModelName;
            sample_time=loc_get_model_sample_time(system);
            obj.NumFiniteRate=sample_time.num_finite_rate;
            if sample_time.cont_time
                obj.HasContinuousTime=true;
            end
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);
            oc=onCleanup(@()Simulink.CMI.EIAdapter(sess.oldFeatureValue));
            try
                interface=get_param(system,'Object');
                if interface.outputFcnHasAsyncRates
                    obj.HasAsyncRates=true;
                else
                    obj.HasAsyncRates=false;
                end
            catch
            end

            function out=loc_get_model_sample_time(model)
                out=struct('multi_rate',false,'cont_time',false,'async_time',false,...
                'vari_time',false,'single_rate',false,'num_finite_rate',[]);
                times=Simulink.BlockDiagram.getSampleTimes(model);
                asyncSampleTimes=false;
                variableSampleTimes=false;
                continuousSampleTimes=false;
                finiteSampleTimes=0;
                for i=1:numel(times)
                    if strcmpi(times(i).Annotation(1),'H')

                    elseif strcmpi(times(i).Annotation(1),'T')

                    elseif~isempty(strfind(times(i).Annotation(1),'A'))
                        asyncSampleTimes=true;
                    elseif~isempty(strfind(times(i).Annotation(1),'V'))
                        variableSampleTimes=true;
                    elseif~isempty(strfind(times(i).Annotation,'Cont'))||...
                        ~isempty(strfind(times(i).Annotation(1),'F'))
                        continuousSampleTimes=true;
                    elseif~isempty(times(i).Value)&&isfinite(times(i).Value(1))
                        finiteSampleTimes=finiteSampleTimes+1;
                        obj.FiniteRates(end+1)=times(i).Value(1);
                    end
                end
                out.num_finite_rate=finiteSampleTimes;
                if finiteSampleTimes>=2
                    out.multi_rate=true;
                end
                if continuousSampleTimes
                    out.cont_time=true;
                end
                if asyncSampleTimes
                    out.async_time=true;
                end;
                if variableSampleTimes
                    out.vari_time=true;
                else
                    out.single_rate=true;
                end
            end
        end
    end
end

