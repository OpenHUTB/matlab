


classdef(Sealed)EmbeddedWebClient<codergui.WebClient

    properties(SetAccess=immutable)
        Async=true
        SupportsEvalReturn=false
        SupportsKeepAlive=false
        DebugPort=0
    end

    properties(Access=private)

    end

    methods
        function this=EmbeddedWebClient(varargin)
            this=this@codergui.WebClient(varargin{:},'WaitTimeout',90);
        end

        function bringToFront(~)
        end

        function minimize(~)
        end

        function restore(~)
        end
    end

    methods(Access=protected)
        function start(~)
        end

        function cleanup(~)
        end

        function setVisible(~,~)
        end

        function setWindowSize(~,~,~)
        end

        function setWindowTitle(~,~)
        end

        function result=doJsEval(~,~)%#ok<STOUT>
            error('EmbeddedWebClient does not support JS eval');
        end
    end

    methods(Hidden)
        function openDebugger(~)
        end
    end
end