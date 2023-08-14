

classdef CEFBrowserDialog<maskeditor.internal.BrowserDialog

    properties(SetAccess=private,GetAccess=public)
        m_DebugPort;
        m_Dialog;
    end

    methods(Access=public)
        function obj=CEFBrowserDialog(aURL)
            aScreenSize=get(0,'screenSize');
            aPrefferedXSize=min(1000,0.85*aScreenSize(3));
            aPrefferedYSize=min(800,0.85*aScreenSize(4));
            xStart=(aScreenSize(3)-aPrefferedXSize)/2;
            yStart=(aScreenSize(4)-aPrefferedYSize)/2;
            aPosition=[xStart,yStart,aPrefferedXSize,aPrefferedYSize];

            obj.m_DebugPort=matlab.internal.getDebugPort();
            obj.m_Dialog=matlab.internal.webwindow(aURL,obj.m_DebugPort,aPosition);


            if ispc
                obj.m_Dialog.Icon=fullfile(matlabroot,'toolbox','simulink','maskeditor','matlab','resources','sl_dialog_icon.ico');
            else
                obj.m_Dialog.Icon=fullfile(matlabroot,'toolbox','simulink','maskeditor','matlab','resources','sl_dialog_icon.png');
            end


            obj.m_Dialog.setMinSize([500,400]);
        end

        function delete(this)
            if this.isValid()
                this.m_Dialog.close();
            end
        end

        function addOnCloseFcn(this,onCloseFcn)
            this.m_Dialog.CustomWindowClosingCallback=onCloseFcn;
        end

        function show(this)
            this.m_Dialog.bringToFront();
        end

        function hide(this)
            this.m_Dialog.hide();
        end

        function bIsValid=isValid(this)
            bIsValid=this.m_Dialog.isvalid&&this.m_Dialog.isWindowValid;
        end

        function[bIsVisible]=isVisible(this)
            bIsVisible=this.m_Dialog.isVisible();
        end

        function[aTitle]=getTitle(this)
            aTitle=this.m_Dialog.Title;
        end

        function setTitle(this,aTitle)
            this.m_Dialog.Title=aTitle;
        end

        function[aWindowPosition,bIsMaximized]=getWindowState(this)
            aWindowPosition=this.m_Dialog.Position;
            bIsMaximized=this.m_Dialog.isMaximized;
        end

        function setWindowState(this,aWindowState)
            if~aWindowState.IsMaximized
                this.m_Dialog.Position=aWindowState.Position;
            end
        end
    end

end

