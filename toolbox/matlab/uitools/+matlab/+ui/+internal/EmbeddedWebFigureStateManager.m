classdef EmbeddedWebFigureStateManager<handle
    properties
        Enabled=false;
    end
    methods(Access=private)
        function obj=EmbeddedWebFigureStateManager()
        end
    end
    methods(Static)


        function obj=getInstance(peekflag)
            persistent objInstance;
            mlock;
            if isempty(objInstance)&&(nargin<=0||~peekflag)
                objInstance=matlab.ui.internal.EmbeddedWebFigureStateManager;
            end
            obj=objInstance;
        end
    end
    methods(Static)
        function previousState=setEnabled(state)


            if state
                obj=matlab.ui.internal.EmbeddedWebFigureStateManager.getInstance;
                previousState=obj.Enabled;
                obj.Enabled=true;
                LiveEditorFigure;
            else
                obj=matlab.ui.internal.EmbeddedWebFigureStateManager.getInstance(true);
                if isempty(obj)
                    previousState=false;
                    return
                else
                    previousState=obj.Enabled;
                    obj.Enabled=false;
                    LiveEditorFigureReset;
                end
            end
        end
    end
end