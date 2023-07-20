classdef VVCAppStatusBar<handle




    properties(Access=private)
StatusBar
CurrentStatusItems
AppContainer
    end

    methods
        function obj=VVCAppStatusBar(AppContainer)



            obj.StatusBar=matlab.ui.internal.statusbar.StatusBar;
            obj.StatusBar.Tag='VVCStatusBar';


            add(AppContainer,obj.StatusBar)
            obj.AppContainer=AppContainer;
        end

        function setStatusItems(obj,Items)
            clearStatus(obj)
            for ct=1:numel(Items)
                add(obj.StatusBar,Items{ct});
            end
            obj.CurrentStatusItems=Items;
        end


        function clearStatus(obj)
            if~isempty(obj.CurrentStatusItems)
                for ct=1:numel(obj.CurrentStatusItems)
                    obj.StatusBar.remove(obj.CurrentStatusItems{ct})
                end
                obj.CurrentStatusItems=[];
            end
        end

        function setStatusText(obj,Text)

            Label=matlab.ui.internal.statusbar.StatusLabel();
            Label.Text=string(Text);
            Label.Tag="statusLabel";
            Label.Region="left";
            Label.Icon=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','Info_12px.png');


            setStatusItems(obj,{Label})

        end

        function setStatusProgress(obj,Text)
            StatusProgress=matlab.ui.internal.statusbar.StatusProgressBar();
            StatusProgress.Region="right";
            StatusProgress.Indeterminate=true;
            Label=matlab.ui.internal.statusbar.StatusLabel();
            Label.Text=string(Text);
            Label.Region="left";
            Label.Tag="statusLabel";
            Label.Icon=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','Info_12px.png');

            setStatusItems(obj,{Label;StatusProgress})
        end


    end


    methods(Hidden)
        function prop=qeGet(this,name)
            prop=this.(name);
        end
    end
end