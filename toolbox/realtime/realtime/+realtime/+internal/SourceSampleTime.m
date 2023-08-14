classdef SourceSampleTime<matlab.System





%#codegen
%#ok<*EMCA>
%#ok<*EMCLS>

    properties

        SampleTime=0.1;
    end

    methods
        function obj=SourceSampleTime
            coder.allowpcode('plain');
        end
    end

    methods
        function set.SampleTime(obj,newTime)


            if numel(newTime)==1&&isreal(newTime)&&...
                (all(all(isfinite(newTime)))||all(all(isinf(newTime))))
                sampleTime=real(newTime);
            else
                error('SourceSampleTime:build:InvalidSampleTimeNeedScalar',...
                'Invalid sample time. Sample time must be a real scalar value.');
            end
            if sampleTime(1)<0.0&&sampleTime(1)~=-1.0
                error('SourceSampleTime:build:InvalidSampleTimeNeedPositive',...
                'Invalid sample time. Sample time must be non-negative or -1 (for inherited).');
            end




            if numel(sampleTime)==2
                if sampleTime(1)>0.0&&sampleTime(2)>=sampleTime(1)
                    error('SourceSampleTime:build:InvalidSampleTimeNeedSmallerOffset',...
                    'Invalid sample time. Offset must be smaller than period.');
                end
                if sampleTime(1)==-1.0&&sampleTime(2)~=0.0
                    error('SourceSampleTime:build:InvalidSampleTimeNeedZeroOffset',...
                    'Invalid sample time. When period is -1, offset must be 0.');
                end
                if sampleTime(1)==0.0&&sampleTime(2)~=1.0
                    error('SourceSampleTime:build:InvalidSampleTimeNeedOffsetOne',...
                    'Invalid sample time. When period is 0, offset must be 1.');
                end
            end
            obj.SampleTime=sampleTime;
        end
    end

    methods(Access=protected)
        function st=getSampleTimeImpl(obj)
            st=createSampleTime(obj,'Type','Discrete','SampleTime',obj.SampleTime);
        end
    end
end
