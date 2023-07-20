classdef SignalTypes






    enumeration
        Badged,Line,Scalar,ForCallback
    end
    methods
        function tf=isInstrumentSignal(obj)
            tf=(obj==slrealtime.internal.instrument.SignalTypes.Line||...
            obj==slrealtime.internal.instrument.SignalTypes.Scalar||...
            obj==slrealtime.internal.instrument.SignalTypes.ForCallback);
        end

        function tf=isScalarSignal(obj)
            tf=(obj==slrealtime.internal.instrument.SignalTypes.Scalar);
        end

        function tf=isForCallback(obj)
            tf=(obj==slrealtime.internal.instrument.SignalTypes.ForCallback);
        end
    end
end
