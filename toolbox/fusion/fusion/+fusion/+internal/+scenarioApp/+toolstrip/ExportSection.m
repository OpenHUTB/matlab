classdef ExportSection<fusion.internal.scenarioApp.toolstrip.Section
    properties
hExportDropDownButton
    end

    methods
        function this=ExportSection(hApplication,hToolstrip)
            this@fusion.internal.scenarioApp.toolstrip.Section(hApplication,hToolstrip);

            import matlab.ui.internal.toolstrip.*;

            hApp=this.Application;

            this.Title=msgString(this,'ExportSectionTitle');
            this.Tag='export';
            export=DropDownButton(msgString(this,'ExportButton'),Icon.CONFIRM_24);
            export.Description=msgString(this,'ExportDescription');
            export.Tag='exportDropdown';

            export.Popup=PopupList;
            export.Popup.Tag='exportPopup';

            exportMatlabCode=ListItem(msgString(this,'ExportMATLABCodeListItem'),...
            Icon(fullfile(this.IconDirectory,'ExportMatlabCode24.png')));
            exportMatlabCode.Tag='exportMatlabCodeItem';
            exportMatlabCode.ItemPushedFcn=hApp.initCallback(...
            @this.exportMatlabCodeCallback);
            exportMatlabCode.Description=msgString(this,'ExportMATLABCodeDescription');

            export.Popup.add(exportMatlabCode);
            export.Enabled=false;
            add(addColumn(this,'HorizontalAlignment','center'),export);
            this.CollapsePriority=20;
            this.hExportDropDownButton=export;
        end

        function update(this,enable)
            this.hExportDropDownButton.Enabled=enable;
        end
    end

    methods(Access=protected)
        function exportMatlabCodeCallback(this,~,~)
            exportMatlabCode(this.Application);
        end
    end
end