classdef WindowManager<handle




    properties(Constant)
        Instance=dependencies.internal.widget.WindowManager();
    end

    properties(GetAccess=private,SetAccess=immutable)
        Handles containers.Map;
    end

    methods
        function this=WindowManager()
            this.Handles=containers.Map("KeyType","double","ValueType","any");


            mlock;
        end

        function launchAndRegister(this,handle)
            this.register(handle);
            handle.launch();
        end
    end

    methods(Hidden)
        function handles=getHandles(this)
            handles=this.Handles.values;
            handles=cellfun(@(s)s.Handle,handles);
        end
    end

    methods(Access=private)
        function register(this,handle)
            id=handle.ID;

            closeListener=handle.Window.listener(...
            "Closed",@(~,~)this.Handles.remove(id));

            this.Handles(id)=struct(...
            "Handle",handle,...
            "Listener",closeListener);
        end
    end

end
