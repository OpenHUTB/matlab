classdef BusyOverlay<handle




    properties(Access=private)
App
    end

    methods(Hidden)

        function this=BusyOverlay(app)
            this.App=app;
        end

        function show(this)
            this.App.Busy=true;
        end

        function hide(this)
            this.App.Busy=false;
        end
    end

    methods(Static,Hidden)
        function result=setGetBusyOverlay(value)
            mlock;
            persistent WaveletTFAnalyzerBusyOverlayInstance;
            if nargin
                WaveletTFAnalyzerBusyOverlayInstance=value;
            end
            result=WaveletTFAnalyzerBusyOverlayInstance;
        end
    end

end
