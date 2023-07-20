classdef PlatformPanelModel<handle



    properties
        Enabled logical=true;
    end


    events
PanelEnableChanged
SignatureDisplayChanged
    end

    methods
        function set.Enabled(this,newValue)
            oldValue=this.Enabled;
            this.Enabled=newValue;
            if oldValue~=newValue
                notify(this,'PanelEnableChanged');
            end
        end

        function enablePanel(this)
            this.Enabled=true;
        end

        function disablePanel(this)
            this.Enabled=false;
        end

    end
end

