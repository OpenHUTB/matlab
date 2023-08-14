classdef ErrorHandler<handle



    properties
        DebugMode=false
    end

    properties(Hidden)

WarningListener
NonCriticalErrorListener
CriticalErrorListener
    end

    methods(Access=?evolutions.internal.session.SessionManager)
        function obj=ErrorHandler
        end

        function setup(this)
            installListeners(this);
        end

        function installListeners(this)
            this.WarningListener=evolutions.internal.session...
            .EventHandler.subscribe('Warning',@this.warningAction);
            this.NonCriticalErrorListener=evolutions.internal.session...
            .EventHandler.subscribe('NonCriticalError',@this.nonCriticalErrorAction);
            this.CriticalErrorListener=evolutions.internal.session...
            .EventHandler.subscribe('CriticalError',@this.criticalErrorAction);
        end

        function delete(this)
            deleteListeners(this);
            this.delete;
        end

        function deleteListeners(this)
            listeners=["WarningListener",...
            "NonCriticalErrorListener",...
            "CriticalErrorListener"];
            evolutions.internal.ui.deleteListeners(this,listeners);
        end
    end

    methods(Hidden)
        warningAction(this,src,data);
        nonCriticalErrorAction(this,src,data);
        criticalErrorAction(this,src,data);
    end
end
