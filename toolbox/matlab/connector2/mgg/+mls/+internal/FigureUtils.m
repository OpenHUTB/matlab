classdef FigureUtils<handle

    properties(Access=private)
FigureCreatedListener
    end

    methods(Static)
        function enableCreatedListener()
            obj=localGetInstance();
            obj.FigureCreatedListener.Enabled=true;
        end

        function disableCreatedListener()
            obj=localGetInstance();
            obj.FigureCreatedListener.Enabled=false;
        end

        function state=isCreatedListenerEnabled()
            obj=localGetInstance();
            state=obj.FigureCreatedListener.Enabled;
        end
    end

    methods(Access=private)
        function obj=FigureUtils()
            classObj=?matlab.ui.Figure;
            callback=@(~,ev)mls.internal.figureCreated(ev.Instance);
            obj.FigureCreatedListener=event.listener(classObj,'InstanceCreated',callback);
            obj.FigureCreatedListener.Enabled=false;
        end
    end
end

function obj=localGetInstance()
mlock
    persistent instance
    if isempty(instance)
        instance=mls.internal.FigureUtils();
    end
    obj=instance;
end
