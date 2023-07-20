



classdef CEFBrowserDialog<Simulink.messageviewer.internal.BrowserDialog

    properties(SetAccess=private,GetAccess=public)
        m_Dialog;
    end

    methods(Static=true,Hidden=true,Access='public')
        function debug_address=getDebugAddress()

            aURL=connector.getUrl('/toolbox/simulink/simulink/slmsgviewer/slmsgviewer-debug.html');
            aURL=[aURL,'&componentId=0'];
            cef_debug_win=matlab.internal.webwindow(aURL,matlab.internal.getDebugPort(),'EnableZoom',true);
            cef_debug_win.show();
            debug_address=['http://localhost:',num2str(cef_debug_win.RemoteDebuggingPort)];
        end
    end

    methods(Access=public)
        function obj=CEFBrowserDialog()


            if slf_feature('get','DockedDiagnosticViewer')==2
                aURL=connector.getUrl('/toolbox/simulink/simulink/dockeddiagnosticviewer/slmsgviewer.html');
            else
                aURL=connector.getUrl('/toolbox/simulink/simulink/slmsgviewer/slmsgviewer.html');
            end

            aURL=[aURL,'&componentId=0'];
            aDebugPort=matlab.internal.getDebugPort();

            obj.m_Dialog=matlab.internal.webwindow(aURL,aDebugPort,'EnableZoom',true);



            if ispc
                obj.m_Dialog.Icon=fullfile(matlabroot,'toolbox','simulink','core','general','+Simulink','+messageviewer','resources','sl_dialog_icon.ico');
            else
                obj.m_Dialog.Icon=fullfile(matlabroot,'toolbox','simulink','core','general','+Simulink','+messageviewer','resources','sl_dialog_icon.png');
            end


            obj.m_Dialog.CustomWindowClosingCallback=@(varargin)obj.hide;@(x)isa(x,'function_handle');


            obj.m_Dialog.setMinSize(slmsgviewer.m_MinimumDialogSize);

            aScreenSize=get(0,'screenSize');
            xStart=(aScreenSize(3)-slmsgviewer.m_PrefferedDialogSize(1))/2;
            yStart=(aScreenSize(4)-slmsgviewer.m_PrefferedDialogSize(2))/2;
            obj.m_Dialog.Position=[xStart,yStart,slmsgviewer.m_PrefferedDialogSize(1),slmsgviewer.m_PrefferedDialogSize(2)];
        end

        function delete(this)
            if this.isValid()
                this.m_Dialog.close();
            end
        end

        function show(this)
            this.m_Dialog.bringToFront();
        end

        function hide(this)
            this.m_Dialog.hide();
        end

        function bIsValid=isValid(this)
            bIsValid=~isempty(this.m_Dialog)&&this.m_Dialog.isvalid&&this.m_Dialog.isWindowValid;
        end

        function[bIsVisible]=isVisible(this)
            bIsVisible=this.m_Dialog.isVisible();
        end

        function status=isAlive(this)
            status=GLUE2.DiagnosticViewerComponent.isClientAlive("0");
            if(status==false)
                this.m_Dialog.executeJS('location.reload(true)');
                status=GLUE2.DiagnosticViewerComponent.isClientAlive("0");
            end
        end


        function position(this,aModelName)
            aScreenSize=get(0,'screenSize');

            if isvarname(aModelName)&&bdIsLoaded(aModelName)
                aActiveModelLocation=get_param(aModelName,'Location');

                aXPos=min(aActiveModelLocation(3),aScreenSize(3)-slmsgviewer.m_PrefferedDialogSize(1)-25);
                aYPos=aActiveModelLocation(4)+aActiveModelLocation(2);
                aYPos=max(0,aYPos);
                aYPos=min(aYPos,aScreenSize(4)-slmsgviewer.m_PrefferedDialogSize(2)-30);
            else
                aXPos=(aScreenSize(3)-slmsgviewer.m_PrefferedDialogSize(1))/2;
                aYPos=(aScreenSize(4)-slmsgviewer.m_PrefferedDialogSize(2))/2;
            end

            this.m_Dialog.Position=[aXPos,aYPos,slmsgviewer.m_PrefferedDialogSize(1),slmsgviewer.m_PrefferedDialogSize(2)];
        end


        function reposition(this,aCenterXPos,aCenterYPos)
            aCurrentPosition=this.m_Dialog.Position;
            aXPos=aCenterXPos-(aCurrentPosition(3)/2);
            aYPos=aCenterYPos-(aCurrentPosition(4)/2);
            this.m_Dialog.Position=[aXPos,aYPos,aCurrentPosition(3),aCurrentPosition(4)];
        end
    end

end


