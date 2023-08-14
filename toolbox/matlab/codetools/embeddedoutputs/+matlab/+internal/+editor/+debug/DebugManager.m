classdef DebugManager<handle

    events
DBStop
DBCont
    end

    methods(Access=private)
        function obj=DebugManager()
        end
    end


    methods(Static,Hidden)
        function doDBStop()
            import matlab.internal.editor.debug.DebugManager;
            debugManager=DebugManager.getInstance();
            debugManager.notify('DBStop');
        end

        function doDBCont()
            import matlab.internal.editor.debug.DebugManager;
            debugManager=DebugManager.getInstance();
            debugManager.notify('DBCont');
        end

        function obj=getInstance()
            import matlab.internal.editor.debug.DebugManager;
            persistent instance
            mlock;
            if isempty(instance)
                instance=DebugManager();
            end
            obj=instance;
        end
    end
end