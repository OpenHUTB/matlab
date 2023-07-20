



classdef ViewHMIBrowserDialog<simulinkcoder.internal.app.View
    properties
        ReadyToShowSubscription=[]
    end
    methods
        function obj=ViewHMIBrowserDialog(modelName)
            obj@simulinkcoder.internal.app.View(modelName);
        end

        function start(obj)
            start@simulinkcoder.internal.app.View(obj);
            if isempty(obj.Dlg)
                obj.createDlg();
            else
                obj.Dlg.show;
            end
        end

        function onBrowserClose(obj)
            onBrowserClose@simulinkcoder.internal.app.View(obj,obj.Dlg.WindowPosOnClose);
        end
    end

    methods(Access=private)
        function createDlg(obj)
            if obj.DEBUG
                url=obj.DebugURL;
            else
                url=obj.URL;
            end
            obj.ReadyToShowSubscription=message.subscribe('/coder/coderApp',@obj.onReadyToShow);
            obj.Dlg=Simulink.HMI.BrowserDlg(url,obj.Title,...
            obj.getGemoetry(),...
            [],obj.UseCEF,obj.DEBUG,...
            @()onBrowserClose(obj),true);
        end
    end
    methods(Hidden)

        function onReadyToShow(obj,msg)
            if strcmp(msg.messageID,'appReady')
                if isvalid(obj)&&~isempty(obj.Dlg)
                    obj.Dlg.show();
                    message.unsubscribe(obj.ReadyToShowSubscription);
                    obj.ReadyToShowSubscription=[];
                end
            end
        end
    end
end
