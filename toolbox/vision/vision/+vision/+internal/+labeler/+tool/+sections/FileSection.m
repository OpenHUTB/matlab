






classdef FileSection<vision.internal.uitools.NewToolStripSection

    properties
NewSessionButton
LoadSessionButton

SaveButton
SaveSession
SaveAsSession

ImportAnnotationsButton

LoadDefinitions

ImportAnnotationsFromFile
ImportAnnotationsFromWS
    end

    properties
AddSignalsItem
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons');
    end

    methods
        function this=FileSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)
        function createSection(this)

            fileSectionTitle=getString(message('vision:labeler:FileSectionTitle'));
            fileSectionTag='sectionFile';

            this.Section=matlab.ui.internal.toolstrip.Section(fileSectionTitle);
            this.Section.Tag=fileSectionTag;
        end

        function layoutSection(this)

            this.addNewSessionButton();
            this.addOpenSessionButton();
            this.addSaveSessionButton();
            this.addImportButton();

            colAddSession=this.addColumn();
            colAddSession.add(this.NewSessionButton);
            colAddSession.add(this.LoadSessionButton);
            colAddSession.add(this.SaveButton);

            colAnnotations=this.addColumn();
            colAnnotations.add(this.ImportAnnotationsButton);

        end

        function addNewSessionButton(this)
            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.toolstrip.Icon.*;


            newSessionTitleId='vision:labeler:NewSessionButton';
            newSessionIcon=NEW_16;
            newSessionTag='btnNewSession';
            this.NewSessionButton=this.createButton(newSessionIcon,...
            newSessionTitleId,newSessionTag);
            toolTipID='vision:imageLabeler:NewSessionButtonTooltip';
            this.setToolTipText(this.NewSessionButton,toolTipID);
        end

        function addOpenSessionButton(this)
            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.toolstrip.Icon.*;


            newSessionTitleId='vision:labeler:OpenSessionButton';
            newSessionIcon=OPEN_16;
            newSessionTag='btnOpenSession';
            this.LoadSessionButton=this.createButton(newSessionIcon,...
            newSessionTitleId,newSessionTag);
            toolTipID='vision:labeler:OpenSessionButtonTooltip';
            this.setToolTipText(this.LoadSessionButton,toolTipID);
        end

        function addSaveSessionButton(this)
            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.toolstrip.Icon.*;


            saveTitleID='vision:labeler:SaveSessionButton';
            saveIcon=SAVE_16;
            saveTag='btnSave';
            this.SaveButton=this.createDropDownButton(saveIcon,saveTitleID,saveTag);
            toolTipID='vision:labeler:SaveButtonTooltip';
            this.setToolTipText(this.SaveButton,toolTipID);


            saveSessionTitleID=vision.getMessage('vision:uitools:Save');
            saveSessionIcon=SAVE_16;
            this.SaveSession=ListItem(saveSessionTitleID,saveSessionIcon);
            this.SaveSession.Tag='itemSaveSession';
            this.SaveSession.ShowDescription=false;


            saveAsSessionTitleID=vision.getMessage('vision:labeler:SaveAs');
            saveAsSessionIcon=SAVE_AS_16;
            this.SaveAsSession=ListItem(saveAsSessionTitleID,saveAsSessionIcon);
            this.SaveAsSession.Tag='itemSaveAsSession';
            this.SaveAsSession.ShowDescription=false;


            savePopup=PopupList();

            savePopup.add(this.SaveSession);
            savePopup.add(this.SaveAsSession);

            this.SaveButton.Popup=savePopup;
        end

        function addImportButton(this)
            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.toolstrip.Icon.*;


            importIcon=IMPORT_24;
            importTitleID='vision:labeler:Import';
            importTag='btnImportAnnotations';
            this.ImportAnnotationsButton=this.createDropDownButton(importIcon,importTitleID,importTag);
            toolTipID='vision:labeler:ImportAnnotationsButtonTooltip';
            this.setToolTipText(this.ImportAnnotationsButton,toolTipID);


            loadLabelTitleID=vision.getMessage('vision:labeler:LabelDefinitions');
            loadLabelIcon=PROPERTIES_16;
            this.LoadDefinitions=ListItem(loadLabelTitleID,loadLabelIcon);
            this.LoadDefinitions.Tag='itemLoadLabelDefinition';
            this.LoadDefinitions.ShowDescription=false;


            text=vision.getMessage('vision:labeler:FromFile');

            this.ImportAnnotationsFromFile=ListItem(text);
            this.ImportAnnotationsFromFile.ShowDescription=false;
            this.ImportAnnotationsFromFile.Tag='itemImportFromFile';


            text=vision.getMessage('vision:labeler:FromWS');

            this.ImportAnnotationsFromWS=ListItem(text);
            this.ImportAnnotationsFromWS.ShowDescription=false;
            this.ImportAnnotationsFromWS.Tag='itemImportFromWS';


            detasHeader=PopupListHeader(vision.getMessage('vision:labeler:DataSource'));
            labelHeader=PopupListHeader(vision.getMessage('vision:labeler:HeaderLabels'));


            importPopup=PopupList();

            importPopup.add(detasHeader);
            this.addImportDataSourceList(importPopup);

            importPopup.add(labelHeader);

            importAnnotationPopup=PopupList();

            importAnnotationPopup.add(this.ImportAnnotationsFromFile);
            if~isdeployed()
                importAnnotationPopup.add(this.ImportAnnotationsFromWS);
            end


            text=vision.getMessage('vision:labeler:HeaderLabels');
            icon=IMPORT_16;
            labelPopup=ListItemWithPopup(text,icon);
            labelPopup.Tag='itemImportLabelPopup';
            labelPopup.ShowDescription=false;

            importPopup.add(labelPopup);
            labelPopup.Popup=importAnnotationPopup;

            importPopup.add(this.LoadDefinitions);
            this.ImportAnnotationsButton.Popup=importPopup;
        end
    end

    methods(Access=protected)
        function addImportDataSourceList(this,importPopup)
            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.toolstrip.Icon.*;


            addSignalsIcon=ADD_16;
            addSignalsTitleID=getSignalItem(this);
            this.AddSignalsItem=ListItem(addSignalsTitleID,addSignalsIcon);
            this.AddSignalsItem.Tag='itemAddSignals';
            this.AddSignalsItem.ShowDescription=false;

            importPopup.add(this.AddSignalsItem);
        end

        function addSignalsTitleID=getSignalItem(~)
            addSignalsTitleID=vision.getMessage('vision:labeler:AddRemoveSignals');
        end
    end
end
