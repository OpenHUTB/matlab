


classdef SampleTime<handle


    properties(Access=private)
        period=[];
        offset=[];
        kind=[];
    end

    methods


        function obj=SampleTime(compiledSampleTime)
            assert(~iscell(compiledSampleTime),'SampleTime input cannot be cell');
            assert(numel(compiledSampleTime)==2);
            obj.period=compiledSampleTime(1);
            obj.offset=compiledSampleTime(2);
            obj.setKind();
        end


        function out=getPeriod(obj)
            out=obj.period;
        end


        function out=getOffset(obj)
            out=obj.offset;
        end


        function out=isAsync(aObj)
            out=(aObj.getKind()==slci.internal.SampleTimeType.ASYNC);
        end


        function out=isConstant(aObj)
            out=(aObj.getKind()==slci.internal.SampleTimeType.CONSTANT);
        end


        function out=isContinuous(aObj)
            out=(aObj.getKind()==slci.internal.SampleTimeType.CONTINUOUS);
        end


        function out=isDiscrete(aObj)
            out=(aObj.getKind()~=slci.internal.SampleTimeType.UNKNOWN&&...
            aObj.getKind()==slci.internal.SampleTimeType.DISCRETE);
        end


        function out=isParameter(aObj)
            out=(aObj.getKind()==slci.internal.SampleTimeType.PARAMETER);
        end


        function out=isTriggered(aObj)
            out=(aObj.getKind()==slci.internal.SampleTimeType.TRIGGERED);
        end


        function out=isFixedInMinorStep(aObj)
            out=(aObj.getKind()==slci.internal.SampleTimeType.FIXED_IN_MINOR_STEP);
        end

    end

    methods(Access=private)


        function out=getKind(obj)
            out=obj.kind;
        end


        function setKind(obj)
            if obj.isAsyncSampleTime()
                obj.kind=slci.internal.SampleTimeType.ASYNC;
            elseif obj.isConstantSampleTime()
                obj.kind=slci.internal.SampleTimeType.CONSTANT;
            elseif obj.isContinuousSampleTime()
                obj.kind=slci.internal.SampleTimeType.CONTINUOUS;
            elseif obj.isParameterSampleTime()
                obj.kind=slci.internal.SampleTimeType.PARAMETER;
            elseif obj.isTriggeredSampleTime()
                obj.kind=slci.internal.SampleTimeType.TRIGGERED;
            elseif obj.isFixedInMinorStepSampleTime()
                obj.kind=slci.internal.SampleTimeType.FIXED_IN_MINOR_STEP;
            elseif obj.isDiscreteSampleTime()
                obj.kind=slci.internal.SampleTimeType.DISCRETE;
            else
                obj.kind=slci.internal.SampleTimeType.UNKNOWN;
            end
        end


        function out=isDiscreteSampleTime(obj)
            out=(~obj.isAsyncSampleTime()&&...
            ~obj.isConstantSampleTime()&&...
            ~obj.isContinuousSampleTime()&&...
            ~obj.isTriggeredSampleTime()&&...
            ~obj.isParameterSampleTime()&&...
            ~obj.isFixedInMinorStepSampleTime());
        end


        function out=isTriggeredSampleTime(obj)
            out=(obj.period==-1.0)&&(obj.offset==-1.0);
        end


        function out=isAsyncSampleTime(obj)
            out=(obj.period==-1.0)&&(obj.offset<-1.0);
        end


        function out=isConstantSampleTime(obj)


            out=isinf(obj.period)&&isinf(obj.offset);
        end


        function out=isParameterSampleTime(obj)


            out=isinf(obj.period)&&(obj.offset==0.0);
        end


        function out=isContinuousSampleTime(obj)
            out=(obj.period==0.0)&&(obj.offset==0.0);
        end


        function out=isFixedInMinorStepSampleTime(obj)
            out=(obj.period==0.0)&&(obj.offset==1.0);
        end
    end
end
