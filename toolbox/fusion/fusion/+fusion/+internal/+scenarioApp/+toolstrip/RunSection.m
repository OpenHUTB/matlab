classdef RunSection<fusion.internal.scenarioApp.toolstrip.Section
    properties(SetAccess=private)
RunButton
    end

    methods
        function this=RunSection(hApplication,hToolstrip)
            this@fusion.internal.scenarioApp.toolstrip.Section(hApplication,hToolstrip);

            import matlab.ui.internal.toolstrip.*;
            hApp=this.Application;

            this.Title=msgString(this,'RunSectionTitle');
            this.Tag='run';

            run=SplitButton(msgString(this,'RunButtonText'),Icon.RUN_24);
            run.Description=msgString(this,'RunButtonDescription');
            run.Tag='runbutton';
            run.Enabled=false;
            run.ButtonPushedFcn=hApp.initCallback(@this.runSceneCallback);

            popup=PopupList;
            popup.Tag='runscenelist';
            runListItem=ListItem('Run');
            runListItem.Description=msgString(this,'RunListItemDescription');
            runListItem.ItemPushedFcn=hApp.initCallback(@this.runSceneCallback);
            popup.add(runListItem);
            runwoListItem=ListItem(msgString(this,'RunwoListItemText'));
            runwoListItem.Description=msgString(this,'RunwoListItemDescription');
            runwoListItem.ItemPushedFcn=hApp.initCallback(@this.previewSceneCallback);
            popup.add(runwoListItem);
            run.Popup=popup;
            this.RunButton=run;
            add(addColumn(this,'HorizontalAlignment','center'),run);
        end

        function update(this)
            isPlayable=~isempty(this.Application.DataModel.CurrentPlatform);
            this.RunButton.Enabled=isPlayable;
        end
    end

    methods(Access=protected)

        function runSceneCallback(this,~,~)
            run(this.Application);
        end

        function previewSceneCallback(this,~,~)
            runTrajOnly(this.Application);
        end

    end
end