classdef(Hidden)AbstractSampleRateEngine<phased.internal.AbstractVarSizeEngine

%#ok<*EMCLS>
%#ok<*EMCA>
%#codegen

    methods(Access=protected)
        function obj=AbstractSampleRateEngine
            obj@phased.internal.AbstractVarSizeEngine;
            coder.allowpcode('plain');
        end

        function Fs=getSampleRate(obj,N,K,fallbackFs)


            if obj.getExecPlatformIndex()
                sts=getSampleTime(obj);
                if strcmp(sts.Type,'Discrete')||strcmp(sts.Type,'Inherited')
                    ts=sts.SampleTime;
                    cond=~isscalar(ts)||(ts<=0);
                    if cond
                        coder.internal.errorIf(cond,...
                        'phased:phased:invalidSampleTime');
                    end
                    Fs=phased.internal.samptime2rate(ts,N/K);
                elseif strcmp(sts.Type,'Controllable')
                    ts=sts.TickTime;
                    N=1;
                    Fs=phased.internal.samptime2rate(ts,N);
                else
                    coder.internal.errorIf(true,...
                    'phased:phased:invalidSampleTimeType',sts.Type);
                end
            else
                Fs=fallbackFs/K;
            end
        end
    end


    methods(Access={?phased.internal.AbstractSampleRateEngine,?matlab.system.internal.PropertyOrMethod})
        function Fs=getSampleRateInSimulation(obj)

            sts=getSampleTime(obj);
            if strcmp(sts.Type,'Discrete')||strcmp(sts.Type,'Inherited')
                st=sts.SampleTime;
                thisSize=propagatedInputSize(obj,1);
                if isempty(thisSize)
                    N=1;
                else
                    N=thisSize(1);
                end
            elseif strcmp(sts.Type,'Controllable')
                st=sts.TickTime;
                N=1;
            else
                coder.internal.errorIf(true,...
                'phased:phased:invalidSampleTimeType',sts.Type);
            end
            Fs=phased.internal.samptime2rate(st,N);
        end
    end

    methods(Access=protected)
        function flag=isSourceBlock(obj)
            flag=obj.getExecPlatformIndex();
        end

        function flag=isComplexityPropagated(obj)
            flag=obj.getExecPlatformIndex();
        end

        function validateSampleRate(obj,N,desiredFs)
            if obj.getExecPlatformIndex()
                sts=getSampleTime(obj);
                if strcmp(sts.Type,'Discrete')||strcmp(sts.Type,'Inherited')
                    ts=sts.SampleTime;
                    Fs=phased.internal.samptime2rate(ts,N);
                elseif strcmp(sts.Type,'Controllable')
                    Fs=1/sts.TickTime;
                else
                    coder.internal.errorIf(true,...
                    'phased:phased:invalidSampleTimeType',sts.Type);
                end
                cond=abs(desiredFs-Fs)>eps(desiredFs);
                if cond
                    coder.internal.errorIf(cond,...
                    'phased:phased:MatchedFilter:SampleRateMismatch',...
                    'SampleRate',sprintf('%f',Fs));
                end
            end
        end

        function group=flattenGroupsAndMoveSensorToTop(~,propName,groups)


            propertyList=[groups.PropertyList];
            propNameIdx=strcmp(propName,propertyList);
            group=matlab.mixin.util.PropertyGroup([propName,propertyList(~propNameIdx)]);
        end
    end
end
