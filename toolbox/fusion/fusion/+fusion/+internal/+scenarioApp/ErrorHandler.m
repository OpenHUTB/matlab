classdef ErrorHandler<handle
    properties
PreambleID
CleanupFcn
DialogTitle
Debug
    end

    methods
        function this=ErrorHandler
            this.CleanupFcn=@(x)this.noOp;
            this.DialogTitle=getString(message('fusion:trackingScenarioApp:Designer:AppName'));
            this.PreambleID='fusion:trackingScenarioApp:Designer:ErrorPreamble';
            this.Debug=false;
        end

        function handleException(this,ex)
            this.CleanupFcn(ex);
            errordlg(getString(message(this.PreambleID,ex.message)),this.DialogTitle);
        end

        function execute(this,cb,varargin)
            if this.Debug

                cb(varargin{:})
            else

                w=warning('off');
                restoreWarn=onCleanup(@()warning(w));

                try
                    cb(varargin{:});
                catch ex
                    handleException(this,ex);
                end
            end
        end

        function noOp(~)

        end
    end
end

