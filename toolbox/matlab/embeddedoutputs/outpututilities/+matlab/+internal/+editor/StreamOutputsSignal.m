classdef StreamOutputsSignal<handle




    events
ShouldStream
ForceStream
    end

    methods(Access=private)
        function obj=StreamOutputsSignal()
        end
    end

    methods(Static)
        function stream()
            import matlab.internal.editor.StreamOutputsSignal;
            streamOutputSignal=StreamOutputsSignal.getInstance();
            streamOutputSignal.notify('ShouldStream');
        end

        function forceStream()
            import matlab.internal.editor.StreamOutputsSignal;
            streamOutputSignal=StreamOutputsSignal.getInstance();
            streamOutputSignal.notify('ForceStream');
        end

        function obj=getInstance()
            import matlab.internal.editor.StreamOutputsSignal;
            persistent instance
            mlock;
            if isempty(instance)
                instance=StreamOutputsSignal();
            end
            obj=instance;
        end
    end
end

