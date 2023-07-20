

classdef CEFBrowserDialog<constraint_manager.BrowserDialog

    properties(Constant)
        m_PrefferedDialogSize=[1000,700];
        m_MinimumDialogSize=[600,400];
    end

    properties(SetAccess=private,GetAccess=public)
        m_DebugPort;
        m_Dialog;
    end

    methods(Access=public)
        function obj=CEFBrowserDialog(aURL)
            obj.m_DebugPort=matlab.internal.getOpenPort();
            obj.m_Dialog=matlab.internal.webwindow(aURL,obj.m_DebugPort);


            if ispc
                obj.m_Dialog.Icon=fullfile(matlabroot,'toolbox','simulink','maskeditor','matlab','resources','sl_dialog_icon.ico');
            else
                obj.m_Dialog.Icon=fullfile(matlabroot,'toolbox','simulink','maskeditor','matlab','resources','sl_dialog_icon.png');
            end


            obj.m_Dialog.setMinSize(obj.m_MinimumDialogSize);

            aScreenSize=get(0,'screenSize');
            xStart=(aScreenSize(3)-obj.m_PrefferedDialogSize(1))/2;
            yStart=(aScreenSize(4)-obj.m_PrefferedDialogSize(2))/2;
            obj.m_Dialog.Position=[xStart,yStart,obj.m_PrefferedDialogSize(1),obj.m_PrefferedDialogSize(2)];
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


        function position(this,aModelName)
            aScreenSize=get(0,'screenSize');

            if isvarname(aModelName)&&bdIsLoaded(aModelName)


                aXPos=(aScreenSize(3)-this.m_PrefferedDialogSize(1))/2;
                aYPos=(aScreenSize(4)-this.m_PrefferedDialogSize(2))/2;
            else
                aXPos=(aScreenSize(3)-this.m_PrefferedDialogSize(1))/2;
                aYPos=(aScreenSize(4)-this.m_PrefferedDialogSize(2))/2;
            end

            this.m_Dialog.Position=[aXPos,aYPos,this.m_PrefferedDialogSize(1),this.m_PrefferedDialogSize(2)];
        end


        function reposition(this,aCenterXPos,aCenterYPos)
            aCurrentPosition=this.m_Dialog.Position;
            aXPos=aCenterXPos-(aCurrentPosition(3)/2);
            aYPos=aCenterYPos-(aCurrentPosition(4)/2);
            this.m_Dialog.Position=[aXPos,aYPos,aCurrentPosition(3),aCurrentPosition(4)];
        end
    end
end

