classdef WebFigureModeInteractionData<handle





    properties
Cached_WindowButtonDownFcn
Cached_WindowButtonUpFcn
Cached_WindowScrollWheelFcn
Cached_WindowKeyPressFcn
Cached_WindowKeyReleaseFcn
Cached_KeyPressFcn
Cached_KeyReleaseFcn

WindowMousePressListener

PreviousWindowState
WindowListenerHandles

PropertyRestoreMap
    end

    methods
        function this=WebFigureModeInteractionData(hFig)
            this.cacheFigure(hFig);
            this.PropertyRestoreMap=containers.Map();
        end
        function setWindowCallbackSetListeners(this,value)
            matlab.graphics.internal.setListenerState(this.WindowListenerHandles,value);
        end
        function restoreFigure(this,hFig)
            this.setWindowCallbackSetListeners('off');
            hFig.WindowButtonDownFcn=this.Cached_WindowButtonDownFcn;
            hFig.WindowButtonUpFcn=this.Cached_WindowButtonUpFcn;
            hFig.WindowScrollWheelFcn=this.Cached_WindowScrollWheelFcn;
            hFig.WindowKeyPressFcn=this.Cached_WindowKeyPressFcn;
            hFig.WindowKeyReleaseFcn=this.Cached_WindowKeyReleaseFcn;
            hFig.KeyPressFcn=this.Cached_KeyPressFcn;
            hFig.KeyReleaseFcn=this.Cached_KeyReleaseFcn;

            delete(this.WindowMousePressListener);
        end

        function setPropertyToRestore(this,name,value)
            this.PropertyRestoreMap(name)=value;
        end

        function clearProperties(this)
            this.PropertyRestoreMap=containers.Map;
        end
    end

    methods(Access=private)
        function cacheFigure(this,hFig)
            this.Cached_WindowButtonDownFcn=hFig.WindowButtonDownFcn;
            this.Cached_WindowButtonUpFcn=hFig.WindowButtonUpFcn;
            this.Cached_WindowScrollWheelFcn=hFig.WindowScrollWheelFcn;
            this.Cached_WindowKeyPressFcn=hFig.WindowKeyPressFcn;
            this.Cached_WindowKeyReleaseFcn=hFig.WindowKeyReleaseFcn;
            this.Cached_KeyPressFcn=hFig.KeyPressFcn;
            this.Cached_KeyReleaseFcn=hFig.KeyReleaseFcn;

            window_prop=[findprop(hFig,'WindowButtonDownFcn'),...
            findprop(hFig,'WindowButtonUpFcn'),...
            findprop(hFig,'WindowScrollWheelFcn'),...
            findprop(hFig,'WindowKeyPressFcn'),...
            findprop(hFig,'WindowKeyReleaseFcn'),...
            findprop(hFig,'KeyPressFcn'),...
            findprop(hFig,'KeyReleaseFcn')];

            l=event.proplistener(hFig,window_prop,'PreSet',@(obj,evd)(localModeWarn(this,obj,evd)));
            l(end+1)=event.proplistener(hFig,window_prop,'PostSet',@(obj,evd)(localModeRestore(this,obj,evd,l(end))));

            matlab.graphics.internal.setListenerState(l,'off');
            this.WindowListenerHandles=l;
        end

        function localModeWarn(hThis,hProp,evd)
            hThis.PreviousWindowState=get(evd.AffectedObject,hProp.Name);
            warning(message('MATLAB:modes:mode:InvalidPropertySet',hProp.Name));
        end

        function localModeRestore(hThis,hProp,evd,listener)
            matlab.graphics.internal.setListenerState(listener,'off');
            set(evd.AffectedObject,hProp.Name,hThis.PreviousWindowState);
            matlab.graphics.internal.setListenerState(listener,'on');
        end
    end
end
