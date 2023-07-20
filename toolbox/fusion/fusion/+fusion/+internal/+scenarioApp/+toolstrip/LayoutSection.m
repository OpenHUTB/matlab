classdef LayoutSection<fusion.internal.scenarioApp.toolstrip.Section
    methods
        function this=LayoutSection(hApplication,hToolstrip)
            this@fusion.internal.scenarioApp.toolstrip.Section(hApplication,hToolstrip);

            import matlab.ui.internal.toolstrip.*;
            hApp=this.Application;

            this.Title=msgString(this,'LayoutSectionTitle');
            this.Tag='layout';

            defaultLayout=Button(msgString(this,'DefaultLayoutButton'),Icon.LAYOUT_24);
            defaultLayout.Description=msgString(this,'DefaultLayoutDescription');
            defaultLayout.Tag='defaultlayout';
            defaultLayout.ButtonPushedFcn=hApp.initCallback(...
            @this.restoreDefaultLayoutCallback);
            add(addColumn(this,'HorizontalAlignment','center'),defaultLayout);
        end
    end

    methods(Hidden)
        function restoreDefaultLayoutCallback(this,~,~)
            restoreDefaultLayout(this.Application);
        end
    end
end