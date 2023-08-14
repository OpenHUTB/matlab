classdef DragDropTransaction<handle

    methods
        function this=DragDropTransaction()
            Simulink.SystemArchitecture.internal.ApplicationManager.BeginDropEvent;
        end

        function delete(~)
            Simulink.SystemArchitecture.internal.ApplicationManager.SuccessfulDropEvent;
            Simulink.SystemArchitecture.internal.ApplicationManager.EndDropEvent;
        end

        function commit(this)
            delete(this);
        end
    end

end
