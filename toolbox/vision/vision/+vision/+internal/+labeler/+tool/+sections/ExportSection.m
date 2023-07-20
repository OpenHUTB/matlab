





classdef ExportSection<vision.internal.uitools.NewToolStripSection

    properties
ExportButton
SaveDefinitions
ExportAnnotationsToFile
ExportAnnotationsToWS
    end

    methods
        function this=ExportSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=protected)
        function toolTipID=getExportButtonToolTip(~)


            toolTipID='vision:labeler:ExportAnnotationsToolTip';
        end
    end

    methods(Access=private)
        function createSection(this)

            exportSectionTitle=getString(message('vision:uitools:ExportSection'));
            exportSectionTag='sectionExport';

            this.Section=matlab.ui.internal.toolstrip.Section(exportSectionTitle);
            this.Section.Tag=exportSectionTag;
        end

        function layoutSection(this)

            this.addExportButton();

            col=this.addColumn();
            col.add(this.ExportButton);
        end

        function addExportButton(this)

            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.toolstrip.Icon.*;

            icon=CONFIRM_24;
            titleID='vision:labeler:ExportButton';
            tag='btnExport';
            this.ExportButton=this.createDropDownButton(icon,titleID,tag);
            toolTipID=this.getExportButtonToolTip();
            this.setToolTipText(this.ExportButton,toolTipID);


            saveLabelTitleID=vision.getMessage('vision:labeler:ToFile');
            saveLabelIcon=PROPERTIES_16;
            this.SaveDefinitions=ListItem(saveLabelTitleID,saveLabelIcon);
            this.SaveDefinitions.Tag='itemSaveLabelDefinition';
            this.SaveDefinitions.ShowDescription=false;


            text=vision.getMessage('vision:labeler:ToFile');
            icon=SAVE_16;
            this.ExportAnnotationsToFile=ListItem(text,icon);
            this.ExportAnnotationsToFile.ShowDescription=false;
            this.ExportAnnotationsToFile.Tag='itemExportToFile';


            text=vision.getMessage('vision:labeler:ToWS');
            icon=EXPORT_16;
            this.ExportAnnotationsToWS=ListItem(text,icon);
            this.ExportAnnotationsToWS.ShowDescription=false;
            this.ExportAnnotationsToWS.Tag='itemExportToWS';


            defsPopup=PopupList();

            labelHeader=PopupListHeader(vision.getMessage('vision:labeler:HeaderLabels'));
            defsPopup.add(labelHeader);
            defsPopup.add(this.ExportAnnotationsToFile);
            if~isdeployed()
                defsPopup.add(this.ExportAnnotationsToWS);
            end

            defsHeader=PopupListHeader(vision.getMessage('vision:labeler:LabelDefinitions'));
            defsPopup.add(defsHeader);
            defsPopup.add(this.SaveDefinitions);

            this.ExportButton.Popup=defsPopup;
        end
    end
end
