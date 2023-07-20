classdef TETMonitor<slrealtime.internal.SLRTComponent




    properties(Access=protected)
        tgEventsTriggeringUpdateGUI={}
    end

    properties(Access={?slrealtime.internal.SLRTComponent},Transient,NonCopyable)
        HTML matlab.ui.control.HTML
        Grid matlab.ui.container.GridLayout
    end

    methods(Access=protected)
        function setup(this)


            htmlWidth=650;
            htmlHeight=160;



            this.Grid=uigridlayout(this,[1,1],...
            'Padding',0,'RowSpacing',0,'ColumnSpacing',0);
            this.Grid.ColumnWidth={'1x'};
            this.Grid.RowHeight={'1x'};



            this.HTML=uihtml(this.Grid);
            this.HTML.Layout.Row=1;
            this.HTML.Layout.Column=1;



            this.Position=[100,100,htmlWidth,htmlHeight];
        end

        function update(this)
            if this.isDesignTime()

                this.HTML.HTMLSource=fullfile(matlabroot,'toolbox','slrealtime','web','tet','TETMonitorAppComp.html');
            else

                this.HTML.HTMLSource=slrealtime.TETMonitor.getURL;
            end
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(this)%#ok
        end

        function updateGUI(this,~)%#ok
        end
    end
end