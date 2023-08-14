classdef DebugSessionAccessor<handle






    properties(Constant,Access=private)

        instance_=SimulinkDebugger.DebugSessionAccessor();
    end

    properties


        session_=SimulinkDebugger.DebugSession.empty();

        modelCloseListener_;
    end

    methods(Access=private)
        function session=getSession(this,modelHandle)

            if isempty(this.session_)
                this.session_=SimulinkDebugger.DebugSession();
            end
            session=this.session_;

            if~isempty(modelHandle)
                this.modelCloseListener_=...
                Simulink.listener(modelHandle,'CloseEvent',@(~,~)this.clearDebugSessions);
            end
        end

        function clearDebugSessions(this)
            this.session_=[];
        end
    end

    methods(Access=public,Static)
        function session=getDebugSession(modelHandle)
            instance=SimulinkDebugger.DebugSessionAccessor.instance_;
            session=instance.getSession(modelHandle);
        end

        function clearAllDebugSessions()
            instance=SimulinkDebugger.DebugSessionAccessor.instance_;
            instance.clearDebugSessions();
        end
    end
end
