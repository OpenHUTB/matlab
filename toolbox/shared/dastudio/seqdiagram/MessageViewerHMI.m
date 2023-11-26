classdef MessageViewerHMI<Simulink.HMI.BrowserDlg

    properties
        client=[];
    end

    methods

        function this=MessageViewerHMI(url_path,title,geometry,cb,useCEF,debugMode)
            this=this@Simulink.HMI.BrowserDlg(url_path,title,geometry,cb,useCEF,debugMode);
            this.CustomCloseCB=@()closeRequest(this);
            this.CEFWindow.setMinSize([350,350]);
        end

        function setCloseCallBack(this,client)
            this.client=client;
        end

        function closeRequest(this)
            if~isempty(this.client)&&isvalid(this.client)
                this.client.closeViewer();
            end
        end
    end

end

