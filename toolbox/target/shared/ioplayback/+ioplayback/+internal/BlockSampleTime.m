classdef BlockSampleTime<ioplayback.SourceSystem




%#codegen

    properties

        SampleTime=0.1;
    end

    methods
        function obj=BlockSampleTime
            coder.allowpcode('plain');
        end
    end

    methods
        function set.SampleTime(obj,newTime)
            coder.extrinsic('error');
            coder.extrinsic('message');
            if isLocked(obj)
                error(message('ioplayback:svd:SampleTimeNonTunable'))
            end
            newTime=ioplayback.internal.validateSampleTime(newTime);
            obj.SampleTime=newTime;
        end
    end

    methods(Access=protected)
        function st=getSampleTimeImpl(obj)
            if obj.SampleTime==-1
                st=createSampleTime(obj,'Type','Inherited');
            else
                st=createSampleTime(obj,'Type','Discrete','SampleTime',obj.SampleTime);
            end
        end
    end
end

