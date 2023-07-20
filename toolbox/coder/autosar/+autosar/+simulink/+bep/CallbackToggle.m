classdef CallbackToggle<handle







    properties(Access=private)
        AreCallbacksEnabled{islogical}=true;
    end

    methods
        function value=areCallbacksEnabled(this)
            value=this.AreCallbacksEnabled;
        end

        function enableCallbacks(this)
            this.AreCallbacksEnabled=true;
        end

        function cleanup=disableCallbacks(this)
            this.AreCallbacksEnabled=false;

            cleanup=onCleanup(@()this.enableCallbacks());
        end
    end
end
