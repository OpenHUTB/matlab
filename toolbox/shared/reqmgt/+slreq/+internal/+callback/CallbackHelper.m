classdef CallbackHelper<handle



    properties(Access=protected)
Object
Text
Type


        Workspace='base'

        ErrorAction='Warning'
Error
CallStack
    end

    methods

        function this=CallbackHelper(obj)
            this.Object=obj;
        end
    end

    methods(Access=?slreq.internal.callback.Utils)

        function run(this)
            this.setup();
            this.execute();
            this.cleanup();
            this.handleCallbackErrorIfAny();
        end
    end
    methods

        function setupCallback(this,type,fcnText)
            this.Text=fcnText;
            this.Type=slreq.internal.callback.Types.([upper(type(1)),type(2:end)]);
        end
    end

    methods(Access=protected)


        function setup(this)
            this.Error=[];
            slreq.internal.callback.CurrentInformation.setRunningFlag(true);
            slreq.internal.callback.CurrentInformation.setCurrentObject(this.Object);
            slreq.internal.callback.CurrentInformation.setCallbackType(this.Type);

        end


        function cleanup(this)%#ok<MANU> 
            slreq.internal.callback.CurrentInformation.cleanup();
        end


        function execute(this)
            try
                slreq.cpputils.executeCallback(this.Text);
            catch ex
                this.Error=ex;
            end
        end


        function handleCallbackErrorIfAny(this)
            if~isempty(this.Error)
                switch lower(this.ErrorAction)
                case 'warning'
                    status=warning('off','backtrace');
                    w=onCleanup(@()warning(status));
                    warning(message('Slvnv:slreq:CallbacksWarningErrorsInFunction',char(this.Type),this.Error.message));
                case 'error'
                    error(message('Slvnv:slreq:CallbacksWarningErrorsInFunction',char(this.Type),this.Error.message));
                otherwise

                end
            end
        end

    end
end

