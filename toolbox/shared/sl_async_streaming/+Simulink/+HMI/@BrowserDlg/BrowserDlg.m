


classdef BrowserDlg<handle


    methods


        function obj=BrowserDlg(url_path,title,geometry,readyCB,useCEF,debugMode,closeCB,useReadyToShow,context,bIsOffscreen)
            obj.URL=connector.applyNonce(url_path);
            if nargin>1
                obj.DlgTitle=title;
            end
            if nargin>2
                obj.Geometry=geometry;
            end
            if nargin>3&&~isempty(readyCB)
                obj.Subscription=message.subscribe('/hmi/browserReady',readyCB);
            end
            if nargin>4
                obj.UsingCEF=useCEF;
            end
            if nargin>5
                obj.DebugMode=debugMode;
            end
            if nargin>6
                obj.CustomCloseCB=closeCB;
            end
            if nargin>7
                obj.UsingReadyToShow=useReadyToShow;
            end
            if nargin>8
                obj.Context=context;
            end
            obj.IsOffscreen=false;
            if nargin>9
                obj.IsOffscreen=bIsOffscreen;
            end

            obj.openGUI();
        end


        function delete(this)

            if~isempty(this.Dialog)&&ishandle(this.Dialog)
                delete(this.Dialog);
            end
            if~isempty(this.CEFWindow)&&isvalid(this.CEFWindow)
                delete(this.CEFWindow);
            end
            if~isempty(this.Subscription)
                message.unsubscribe(this.Subscription);
            end
        end


        function dlg=getDialogSchema(this)

            webbrowser.Type='webbrowser';
            webbrowser.Tag='sl_hmi_webbrowser';
            webbrowser.Url=this.URL;
            webbrowser.WebKit=true;
            webbrowser.DisableContextMenu=~this.DebugMode;
            if this.DebugMode
                webbrowser.EnableInspectorOnLoad=true;
                webbrowser.EnableInspectorInContextMenu=true;
            end

            dlg.DialogTitle=this.DlgTitle;
            dlg.Items={webbrowser};
            dlg.StandaloneButtonSet={''};
            dlg.IsScrollable=false;
            dlg.DispatcherEvents={};
            dlg.ExplicitShow=true;
            dlg.IgnoreESCClose=true;



            if ispc||ismac
                dlg.MinMaxButtons=true;
            end

            if~isempty(this.Geometry)
                dlg.Geometry=this.Geometry;
            end
        end


        function ret=isOpen(this)

            if this.UsingCEF
                if isempty(this.CEFWindow)||~isvalid(this.CEFWindow)
                    ret=false;
                else
                    ret=this.CEFWindow.isWindowValid;
                end
            else
                ret=~isempty(this.Dialog)&&ishandle(this.Dialog);
            end
        end


        function show(this)
            if this.UsingCEF&&~this.isOpen()
                this.openGUI();
            elseif this.UsingCEF
                this.CEFWindow.show();
                this.CEFWindow.bringToFront();
            elseif~ishandle(this.Dialog)
                this.Dialog=eval('DAStudio.Dialog(this)');
            else
                this.Dialog.show();
            end
        end


        function hide(this)
            if~isempty(this.Dialog)&&ishandle(this.Dialog)
                this.Dialog.hide();
            elseif~isempty(this.CEFWindow)||isvalid(this.CEFWindow)
                this.CEFWindow.hide();
            end
        end


        function bringToFront(this)
            this.show();
        end


        function setTitle(this,str)
            if~isempty(this.Dialog)&&ishandle(this.Dialog)
                this.Dialog.setTitle(str);
            elseif~isempty(this.CEFWindow)||isvalid(this.CEFWindow)
                this.CEFWindow.Title=str;
            end
        end
    end


    methods(Hidden)


        function onDialogClose(this)
            flag=true;
            if~isempty(this.CustomPreCloseCB)
                flag=this.CustomPreCloseCB();
            end
            if flag
                completeCloseOperation(this);
            end
        end


        function completeCloseOperation(this)
            this.WindowPosOnClose=this.CEFWindow.Position;
            delete(this.CEFWindow);
            this.CEFWindow=[];
            if~isempty(this.CustomCloseCB)
                this.CustomCloseCB();
            end
        end
    end


    methods(Access=private)


        function openGUI(this)
            if this.UsingCEF
                args={this.URL,matlab.internal.getDebugPort};
                if~isempty(this.Geometry)
                    args=[args,{'Position',this.Geometry}];
                end
                if(this.IsOffscreen)
                    this.CEFWindow=matlab.internal.cef.webwindow(args{:});
                else
                    this.CEFWindow=matlab.internal.webwindow(args{:});
                end
                this.CEFWindow.enableDragAndDrop();
                this.CEFWindow.CustomWindowClosingCallback=@(e,s)onDialogClose(this);
                if~isempty(this.DlgTitle)
                    this.CEFWindow.Title=this.DlgTitle;
                end
                if~this.UsingReadyToShow
                    this.CEFWindow.show();
                    this.CEFWindow.bringToFront();
                end
            else
                this.Dialog=eval('DAStudio.Dialog(this)');
                this.Dialog.show();
            end
        end

    end


    properties(Hidden)
        URL;
        DlgTitle='';
        Geometry;
        WindowPosOnClose;
        UsingCEF=false;
        DebugMode=false;
        Dialog;
        Subscription;
        CEFWindow;
        DebuggingPort;
        CustomCloseCB;
        CustomPreCloseCB;
        UsingReadyToShow=false;
        Context={};
        IsOffscreen=false;
    end
end
