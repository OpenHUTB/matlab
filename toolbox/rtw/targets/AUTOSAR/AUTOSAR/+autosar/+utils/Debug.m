classdef Debug<handle

    properties(Access=private)
        IsStackTrace;
    end


    methods(Access=private)
        function obj=Debug()

            obj.IsStackTrace=false;
        end
    end


    methods(Static,Hidden)
        function debugObj=getInstance()
            persistent debugInstance;
            if isempty(debugInstance)
                debugObj=autosar.utils.Debug();
                debugInstance=debugObj;
            else
                debugObj=debugInstance;
            end
        end
    end


    methods(Static,Access=public)

        function enable()            debugger=autosar.utils.Debug.getInstance();
            debugger.IsStackTrace=true;
        end


        function disable()            debugger=autosar.utils.Debug.getInstance();
            debugger.IsStackTrace=false;
        end


        function isStackTrace=showStackTrace()
            debugger=autosar.utils.Debug.getInstance();
            isStackTrace=debugger.IsStackTrace;
        end


        function validateXMLFiles=validateXMLFiles()
            debugger=autosar.utils.Debug.getInstance();
            validateXMLFiles=debugger.IsStackTrace;
        end
    end
end


