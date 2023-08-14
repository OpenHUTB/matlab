



classdef DockedDialog<handle

    properties(SetAccess=private,GetAccess=public)
        m_ComponentId;
    end

    methods(Static=true,Hidden=true,Access='public')
        function debug_address=getDebugAddress(aComponentId)
            aURL=connector.getUrl('/toolbox/simulink/simulink/slmsgviewer/slmsgviewer-debug.html');
            aURL=[aURL,'&componentId=',aComponentId];
            cef_debug_win=matlab.internal.webwindow(aURL,matlab.internal.getDebugPort());
            cef_debug_win.show();
            debug_address=['http://localhost:',num2str(cef_debug_win.RemoteDebuggingPort)];
        end
    end

    methods(Access=public)

        function obj=DockedDialog(aComponentId)
            obj.m_ComponentId=aComponentId;
        end

        function delete(~)

        end

        function title=getTitle(this)
            title=GLUE2.DiagnosticViewerComponent.getDockedDVTitle(this.m_ComponentId);
        end

        function status=isAlive(this)
            status=GLUE2.DiagnosticViewerComponent.isClientAlive(this.m_ComponentId);
        end

        function show(this)

            GLUE2.DiagnosticViewerComponent.show(this.m_ComponentId);
        end

        function hide(this)
            GLUE2.DiagnosticViewerComponent.hide(this.m_ComponentId);
        end

        function bIsValid=isValid(this)

            bIsValid=true;
        end

        function[bIsVisible]=isVisible(this)
            bIsVisible=GLUE2.DiagnosticViewerComponent.isVisible(this.m_ComponentId);
        end

        function toggleDock(this)
            GLUE2.DiagnosticViewerComponent.toggleDock(this.m_ComponentId);
        end

        function position(this,aModelName)

        end

        function reposition(this,aCenterXPos,aCenterYPos)

        end
    end

end


