classdef HomeTab<handle




    properties(SetAccess=protected,Hidden)

        Tab matlab.ui.internal.toolstrip.Tab

    end

    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)

New
Open
Save
ImportData
ImportFromDICOMFolder

VolumeSection
ShowVolumeBtn

WindowLevel
WindowLimitsLabels
WindowMin
WindowMax

LabelOpacity
Contrast

DisplaySection
DisplayMarkers
ShowScaleBar
OrientationMarkers2D
OrientationAxes3D

DisplayConvention
Neurological
Radiological

VoxelInfo

LayoutSection
Layout
FocusTransverse
FocusCoronal
FocusSagittal

Shortcuts

Snapshot
Screenshot
Animation
Publish

Export
ExportLabels
ExportLabelDefinitions

    end

    properties

        AutoSave(1,1)logical=true;

        IsVolumeDisplaySupported(1,1)logical=true;

    end

    properties(Dependent)
ShowOrientationMarkers
WindowLevelEnabled
    end

    properties(Access=protected)

        ContrastEnabled(1,1)logical=true;

        LastSaveTimestamp(1,6)double;
        IsSaved(1,1)logical=true;

    end

    properties(Access=protected,Constant)

        VolumeSectionIdx=2;
        DisplaySectionIdx=4;
        LayoutSectionIdx=7;

        AutoSaveDuration(1,1)double=300;

    end

    events

NewVolumeSessionRequested
NewImageSessionRequested
OpenSessionRequested
OpenRecentSessionRequested
SaveSessionRequested

ImportDataFromFile
ImportVolumeFromFolder
ImportGroundTruthFromFile
ImportGroundTruthFromWksp
ImportLabelDefsFromFile

ShowVolume
ContrastChanged
LabelOpacityChanged
EnableWindowLevel
ResetWindowLevel

ShowScaleBars
Show2DOrientationMarkers
Show3DOrientationAxes
ShowVoxelInfo

DisplayConventionChanged

LayoutChangeRequested
ViewShortcuts

SnapshotRequested
AnimationRequested
ShowPublishPanel
ExportGroundTruthToFile
ExportLabelDefsToFile

    end

    methods


        function self=HomeTab()

            self.Tab=matlab.ui.internal.toolstrip.Tab(getString(message('medical:medicalLabeler:homeTab')));
            self.Tab.Tag="HomeTab";

            self.createTab();

            self.LastSaveTimestamp=clock;

        end


        function setup(self,dataFormat)

            switch dataFormat

            case medical.internal.app.labeler.enums.DataFormat.Volume


                importPopup=self.ImportData.Popup;
                if isempty(importPopup.find(self.ImportFromDICOMFolder.Tag))
                    index=3;
                    importPopup.add(self.ImportFromDICOMFolder,index);
                    self.ImportData.Popup=importPopup;
                end


                if isempty(self.Tab.find(self.VolumeSection.Tag))
                    self.Tab.add(self.VolumeSection,self.VolumeSectionIdx);
                end
                if self.IsVolumeDisplaySupported
                    self.ShowVolumeBtn.Enabled=true;
                else
                    self.ShowVolumeBtn.Enabled=false;
                end


                self.VoxelInfo.Text=getString(message('medical:medicalLabeler:voxelInfo'));


                if isempty(self.Tab.find(self.DisplaySection.Tag))
                    self.Tab.add(self.DisplaySection,self.DisplaySectionIdx);
                end


                if isempty(self.Tab.find(self.LayoutSection.Tag))
                    self.Tab.add(self.LayoutSection,self.LayoutSectionIdx);
                end

                self.Layout.Enabled=true;

            case medical.internal.app.labeler.enums.DataFormat.Image


                importPopup=self.ImportData.Popup;
                if~isempty(importPopup.find(self.ImportFromDICOMFolder.Tag))
                    importPopup.remove(self.ImportFromDICOMFolder);
                    self.ImportData.Popup=importPopup;
                end


                if~isempty(self.Tab.find(self.VolumeSection.Tag))
                    self.Tab.remove(self.VolumeSection);
                end


                self.VoxelInfo.Text=getString(message('medical:medicalLabeler:pixelInfo'));


                if~isempty(self.Tab.find(self.DisplaySection.Tag))
                    self.Tab.remove(self.DisplaySection);
                end


                if~isempty(self.Tab.find(self.LayoutSection.Tag))
                    self.Tab.remove(self.LayoutSection);
                end

            otherwise
                error('Invalid mode, should never reach here')

            end


            self.ImportData.Enabled=true;


            self.Publish.Value=false;


            self.WindowLevel.Value=false;

        end


        function enableLoadOnly(self)


            self.New.Enabled=true;
            self.Open.Enabled=true;
            self.Save.Enabled=false;
            self.ImportData.Enabled=false;
            self.ShowVolumeBtn.Enabled=false;
            self.Contrast.Enabled=false;
            self.WindowLevel.Enabled=false;
            self.WindowLimitsLabels.Enabled=false;
            self.WindowMin.Enabled=false;
            self.WindowMax.Enabled=false;
            self.LabelOpacity.Enabled=false;
            self.DisplayMarkers.Enabled=false;
            self.DisplayConvention.Enabled=false;
            self.VoxelInfo.Enabled=false;
            self.Shortcuts.Enabled=false;
            self.Layout.Enabled=false;
            self.Snapshot.Enabled=false;
            self.Publish.Enabled=false;
            self.Export.Enabled=false;
            self.ExportLabels.Enabled=false;
            self.ExportLabelDefinitions.Enabled=false;

        end


        function enable(self)


            self.New.Enabled=true;
            self.Open.Enabled=true;
            self.Save.Enabled=true;
            self.ImportData.Enabled=true;

            if self.IsVolumeDisplaySupported
                self.ShowVolumeBtn.Enabled=true;
            end

            if self.ContrastEnabled
                self.WindowLevel.Enabled=true;
                self.WindowLimitsLabels.Enabled=true;
                self.WindowMin.Enabled=true;
                self.WindowMax.Enabled=true;
            else
                self.WindowLevel.Enabled=false;
                self.WindowLimitsLabels.Enabled=false;
                self.WindowMin.Enabled=false;
                self.WindowMax.Enabled=false;
            end

            self.LabelOpacity.Enabled=true;

            self.DisplayMarkers.Enabled=true;
            self.DisplayConvention.Enabled=true;
            self.VoxelInfo.Enabled=true;
            self.Shortcuts.Enabled=true;
            self.Layout.Enabled=true;
            self.Publish.Enabled=true;
            self.Snapshot.Enabled=true;
            self.Export.Enabled=true;
            self.ExportLabels.Enabled=true;
            self.ExportLabelDefinitions.Enabled=true;

        end


        function disable(self)


            self.New.Enabled=false;
            self.Open.Enabled=false;
            self.Save.Enabled=false;
            self.ImportData.Enabled=false;
            self.ShowVolumeBtn.Enabled=false;
            self.Contrast.Enabled=false;
            self.WindowLevel.Enabled=false;
            self.WindowLimitsLabels.Enabled=false;
            self.WindowMin.Enabled=false;
            self.WindowMax.Enabled=false;
            self.LabelOpacity.Enabled=false;
            self.DisplayMarkers.Enabled=false;
            self.DisplayConvention.Enabled=false;
            self.VoxelInfo.Enabled=false;
            self.Layout.Enabled=false;
            self.Shortcuts.Enabled=false;
            self.Publish.Enabled=false;
            self.Snapshot.Enabled=false;
            self.Export.Enabled=false;
            self.ExportLabels.Enabled=false;
            self.ExportLabelDefinitions.Enabled=false;

        end


        function enableSaveSession(self,TF)
            self.Save.Enabled=TF;
        end


        function enableLabelOpacity(self)
            self.LabelOpacity.Enabled=true;
        end


        function disableLabelOpacity(self)
            self.LabelOpacity.Enabled=false;
        end


        function enableExport(self)
            self.Export.Enabled=true;
            self.ExportLabels.Enabled=true;
            self.ExportLabelDefinitions.Enabled=true;
        end


        function disableExport(self)
            self.Export.Enabled=false;
            self.ExportLabels.Enabled=false;
            self.ExportLabelDefinitions.Enabled=false;
        end


        function enableExportLabelDefs(self)
            self.Export.Enabled=true;
            self.ExportLabelDefinitions.Enabled=true;
        end


        function disableExportLabelDefs(self)


            self.Export.Enabled=false;

        end


        function TF=getShowVolume(self)
            TF=self.ShowVolumeBtn.Value;
        end


        function setLabelOpacity(self,opacity)

            if isempty(opacity)
                return
            end

            if opacity>1
                opacity=1;
            elseif opacity<0
                opacity=0;
            end

            self.LabelOpacity.Value=opacity*100;

        end


        function opacity=getLabelOpacity(self)
            opacity=self.LabelOpacity.Value/100;
        end


        function setWindowBounds(self,bounds)
            self.WindowMin.Value=num2str(bounds(1));
            self.WindowMax.Value=num2str(bounds(2));
        end


        function enableContrastControls(self,TF)

            self.ContrastEnabled=TF;

            self.WindowLevel.Enabled=TF;
            self.WindowLimitsLabels.Enabled=TF;
            self.WindowMin.Enabled=TF;
            self.WindowMax.Enabled=TF;

        end


        function setIsCurrentDataOblique(self,TF)

            if TF

                self.FocusTransverse.Text=medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Transverse);
                self.FocusCoronal.Text=medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Coronal);
                self.FocusSagittal.Text=medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Sagittal);

                self.OrientationMarkers2D.Enabled=false;

            else

                self.FocusTransverse.Text=getString(message('medical:medicalLabeler:transverse'));
                self.FocusCoronal.Text=getString(message('medical:medicalLabeler:coronal'));
                self.FocusSagittal.Text=getString(message('medical:medicalLabeler:sagittal'));

                self.OrientationMarkers2D.Enabled=true;

            end

        end


        function markSaveAsDirty(self)

            if self.AutoSave&&~isempty(self.LastSaveTimestamp)&&etime(clock,self.LastSaveTimestamp)>self.AutoSaveDuration
                saveSession(self);
            else
                self.Save.Icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','AutosaveDirty_24.png');
                self.IsSaved=false;
            end

        end


        function markSaveAsClean(self)

            self.Save.Icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','Autosave_24.png');
            self.IsSaved=true;

        end


        function TF=isDataSaved(self)

            TF=self.IsSaved;

        end


        function refreshRecentSessions(self,recentSessions,dataFormat)

            self.Open.Popup=[];

            icon=matlab.ui.internal.toolstrip.Icon.OPEN_16;
            openListItem=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:openSession')),icon);
            openListItem.ShowDescription=false;
            openListItem.Tag=string(medical.internal.app.labeler.enums.Tag.OpenSessionFile);
            addlistener(openListItem,'ItemPushed',@(~,~)self.notify('OpenSessionRequested'));

            openPopup=matlab.ui.internal.toolstrip.PopupList();
            openPopup.add(openListItem);

            if~isempty(recentSessions)

                recentHeader=getString(message('medical:medicalLabeler:recentSessions'));
                recentSessionsHeader=matlab.ui.internal.toolstrip.PopupListHeader(recentHeader);
                openPopup.add(recentSessionsHeader);

                for i=1:length(recentSessions)

                    [~,folderName,~]=fileparts(recentSessions(i));

                    switch dataFormat(i)
                    case medical.internal.app.labeler.enums.DataFormat.Volume
                        icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','VolumeSession_24.png');
                    case medical.internal.app.labeler.enums.DataFormat.Image
                        icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','ImageSequenceSession_24.png');
                    end

                    h=matlab.ui.internal.toolstrip.ListItem(folderName,icon);
                    h.Description=recentSessions(i);
                    openPopup.add(h);

                    evtData=medical.internal.app.labeler.events.ValueEventData(recentSessions(i));
                    addlistener(h,'ItemPushed',@(~,~)notify(self,'OpenRecentSessionRequested',evtData));

                    openPopup.addSeparator();

                end

            end


            self.Open.Popup=openPopup;

        end

    end


    methods(Access=private)


        function createTab(self)






            self.createFileSection();
            self.createVolumeSection();
            self.createViewSection();
            self.createDisplaySection();
            self.createInspectSection();
            self.createShortcutsSection();
            self.createLayoutSection();
            self.createPublishSection();
            self.createExportSection();

        end


        function createFileSection(self)

            section=self.Tab.addSection(upper(getString(message('medical:medicalLabeler:file'))));



            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','NewVolumeSession_24.png');
            newVolumeSession=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:newVolumeSession')),icon);
            newVolumeSession.Tag=string(medical.internal.app.labeler.enums.Tag.NewVolumeSession);
            newVolumeSession.ShowDescription=true;
            newVolumeSession.Description=getString(message('medical:medicalLabeler:newVolumeSessionDescription'));
            addlistener(newVolumeSession,'ItemPushed',@(~,~)notify(self,'NewVolumeSessionRequested'));

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','NewImageSequenceSession_24.png');
            newUltrasoundSession=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:newImageSession')),icon);
            newUltrasoundSession.Tag=string(medical.internal.app.labeler.enums.Tag.NewUltrasoundSession);
            newUltrasoundSession.ShowDescription=true;
            newUltrasoundSession.Description=getString(message('medical:medicalLabeler:newImageSessionDescription'));
            addlistener(newUltrasoundSession,'ItemPushed',@(~,~)notify(self,'NewImageSessionRequested'));

            newSessionPopup=matlab.ui.internal.toolstrip.PopupList();
            newSessionPopup.add(newVolumeSession);
            newSessionPopup.addSeparator();
            newSessionPopup.add(newUltrasoundSession);

            icon=matlab.ui.internal.toolstrip.Icon.NEW_24;
            self.New=matlab.ui.internal.toolstrip.DropDownButton(getString(message('medical:medicalLabeler:newSession')),icon);
            self.New.Enabled=false;
            self.New.Description=getString(message('medical:medicalLabeler:newDescription'));
            self.New.Popup=newSessionPopup;
            self.New.Tag=string(medical.internal.app.labeler.enums.Tag.NewSession);




            icon=matlab.ui.internal.toolstrip.Icon.OPEN_24;
            self.Open=matlab.ui.internal.toolstrip.SplitButton(getString(message('medical:medicalLabeler:openSession')),icon);
            self.Open.Enabled=false;
            self.Open.Popup=[];
            self.Open.Description=getString(message('medical:medicalLabeler:openDescription'));
            self.Open.Tag=string(medical.internal.app.labeler.enums.Tag.OpenSession);
            addlistener(self.Open,'ButtonPushed',@(~,~)self.notify('OpenSessionRequested'));


            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','Autosave_24.png');
            self.Save=matlab.ui.internal.toolstrip.Button(getString(message('medical:medicalLabeler:saveSession')),icon);
            self.Save.Enabled=false;
            self.Save.Description=getString(message('medical:medicalLabeler:saveDescription'));
            self.Save.Tag=string(medical.internal.app.labeler.enums.Tag.SaveSession);
            addlistener(self.Save,'ButtonPushed',@(~,~)self.saveSession());

            column=section.addColumn();
            column.add(self.New);
            column=section.addColumn();
            column.add(self.Open);
            column=section.addColumn();
            column.add(self.Save);



            dataHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('medical:medicalLabeler:data')));
            labelsHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('medical:medicalLabeler:groundTruth')));
            labelDefinitionsHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('medical:medicalLabeler:importLabelDefinitions')));


            importFromFile=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:importFromFile')),...
            matlab.ui.internal.toolstrip.Icon.OPEN_16);
            importFromFile.ShowDescription=false;
            importFromFile.Tag=string(medical.internal.app.labeler.enums.Tag.ImportFromFile);
            addlistener(importFromFile,'ItemPushed',@(~,~)notify(self,'ImportDataFromFile'));


            self.ImportFromDICOMFolder=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:importFromDICOMFolder')),...
            matlab.ui.internal.toolstrip.Icon.OPEN_16);
            self.ImportFromDICOMFolder.ShowDescription=false;
            self.ImportFromDICOMFolder.Tag=string(medical.internal.app.labeler.enums.Tag.ImportFromDICOMFolder);
            addlistener(self.ImportFromDICOMFolder,'ItemPushed',@(~,~)notify(self,'ImportVolumeFromFolder'));



            importGTruthFromFile=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:fromFile')),...
            matlab.ui.internal.toolstrip.Icon.OPEN_16);
            importGTruthFromFile.ShowDescription=false;
            importGTruthFromFile.Tag=string(medical.internal.app.labeler.enums.Tag.ImportGTFromFile);
            addlistener(importGTruthFromFile,'ItemPushed',@(~,~)notify(self,'ImportGroundTruthFromFile'));


            importGTruthFromWksp=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:fromWorkspace')),...
            matlab.ui.internal.toolstrip.Icon.IMPORT_16);
            importGTruthFromWksp.ShowDescription=false;
            importGTruthFromWksp.Tag=string(medical.internal.app.labeler.enums.Tag.ImportGTFromWorkspace);
            addlistener(importGTruthFromWksp,'ItemPushed',@(~,~)notify(self,'ImportGroundTruthFromWksp'));


            icon=matlab.ui.internal.toolstrip.Icon.OPEN_16;
            importLabelDefinition=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:fromFile')),icon);
            importLabelDefinition.Description=getString(message('medical:medicalLabeler:importLabelDefinitionsDescription'));
            importLabelDefinition.ShowDescription=false;
            importLabelDefinition.Tag=string(medical.internal.app.labeler.enums.Tag.ImportLabelDefinition);
            addlistener(importLabelDefinition,'ItemPushed',@(~,~)self.notify('ImportLabelDefsFromFile'));

            importPopup=matlab.ui.internal.toolstrip.PopupList();
            importPopup.add(dataHeader);
            importPopup.add(importFromFile);
            importPopup.add(self.ImportFromDICOMFolder);
            importPopup.add(labelsHeader);
            importPopup.add(importGTruthFromFile);
            importPopup.add(importGTruthFromWksp);
            importPopup.add(labelDefinitionsHeader);
            importPopup.add(importLabelDefinition);

            self.ImportData=matlab.ui.internal.toolstrip.DropDownButton(getString(message('medical:medicalLabeler:importData')),...
            matlab.ui.internal.toolstrip.Icon.IMPORT_24);
            self.ImportData.Tag='ImportVolume';
            self.ImportData.Description=getString(message('medical:medicalLabeler:importDataDescription'));
            self.ImportData.Popup=importPopup;
            self.ImportData.Enabled=false;
            self.ImportData.Tag=string(medical.internal.app.labeler.enums.Tag.Import);

            column=section.addColumn();
            column.add(self.ImportData);

        end


        function createVolumeSection(self)

            section=self.Tab.addSection(getString(message('medical:medicalLabeler:volume3D')));
            section.Tag="VolumeSection";
            section.CollapsePriority=0;


            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','ShowVolume_24.png');
            self.ShowVolumeBtn=matlab.ui.internal.toolstrip.ToggleButton(getString(message('medical:medicalLabeler:visualizeVolume')),icon);
            self.ShowVolumeBtn.Value=true;
            self.ShowVolumeBtn.Tag=string(medical.internal.app.labeler.enums.Tag.ShowVolume);
            self.ShowVolumeBtn.Description=getString(message('medical:medicalLabeler:visualizeVolumeDescription'));
            addlistener(self.ShowVolumeBtn,'ValueChanged',@(src,evt)self.volumeVisibilityToggled());

            column=section.addColumn();
            column.add(self.ShowVolumeBtn);

            self.VolumeSection=section;

        end


        function createViewSection(self)

            section=self.Tab.addSection(getString(message('medical:medicalLabeler:view')));



            reset=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:reset')));
            reset.ShowDescription=false;
            reset.Tag=string(medical.internal.app.labeler.enums.Tag.WindowLevelReset);
            addlistener(reset,'ItemPushed',@(~,~)self.notify('ResetWindowLevel'));

            wlPopup=matlab.ui.internal.toolstrip.PopupList();
            add(wlPopup,reset);


            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','WindowLevel_24.png');
            self.WindowLevel=matlab.ui.internal.toolstrip.ToggleSplitButton(getString(message('medical:medicalLabeler:windowLevel')),...
            icon);
            self.WindowLevel.Enabled=true;
            self.WindowLevel.Value=false;
            self.WindowLevel.Popup=wlPopup;
            self.WindowLevel.Tag=string(medical.internal.app.labeler.enums.Tag.WindowLevel);
            self.WindowLevel.Description=getString(message('medical:medicalLabeler:windowLevelDescription'));
            addlistener(self.WindowLevel,'ValueChanged',@(~,evt)windowLevelToggled(self,evt));

            column=section.addColumn();
            column.add(self.WindowLevel);


            section.addColumn('Width',5);


            self.WindowLimitsLabels=matlab.ui.internal.toolstrip.Label(getString(message('medical:medicalLabeler:windowLimits')));
            self.WindowLimitsLabels.Enabled=false;
            self.WindowLimitsLabels.Tag=string(medical.internal.app.labeler.enums.Tag.WindowLimits);
            self.WindowLimitsLabels.Description=getString(message('medical:medicalLabeler:windowLimitsDescription'));


            self.WindowMin=matlab.ui.internal.toolstrip.EditField();
            self.WindowMin.Enabled=false;
            self.WindowMin.Editable=false;
            self.WindowMin.Tag=string(medical.internal.app.labeler.enums.Tag.WindowMin);
            self.WindowMin.Description=getString(message('medical:medicalLabeler:windowLimitsDescription'));


            self.WindowMax=matlab.ui.internal.toolstrip.EditField();
            self.WindowMax.Enabled=false;
            self.WindowMax.Editable=false;
            self.WindowMax.Tag=string(medical.internal.app.labeler.enums.Tag.WindowMax);
            self.WindowMax.Description=getString(message('medical:medicalLabeler:windowLimitsDescription'));

            column=section.addColumn('Width',100);
            column.add(self.WindowLimitsLabels);
            column.add(self.WindowMin);
            column.add(self.WindowMax);


            section.addColumn('Width',10);

            opacityLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:labelOpacity')));
            opacityLabel.Tag=string(medical.internal.app.labeler.enums.Tag.OpacityLabel);

            self.LabelOpacity=matlab.ui.internal.toolstrip.Slider([0,100],50);
            self.LabelOpacity.Compact=true;
            self.LabelOpacity.Tag=string(medical.internal.app.labeler.enums.Tag.LabelOpacity);
            self.LabelOpacity.Ticks=0;
            self.LabelOpacity.Description=getString(message('images:segmenter:labelOpacityTooltip'));

            column=section.addColumn('HorizontalAlignment','center','Width',120);
            column.add(opacityLabel);
            column.add(self.LabelOpacity);
            addlistener(self.LabelOpacity,'ValueChanging',@(~,~)labelOpacityChanged(self));

        end


        function createDisplaySection(self)

            section=self.Tab.addSection(getString(message('medical:medicalLabeler:display')));
            section.Tag="DisplaySection";
            self.DisplaySection=section;


            s=settings;
            showScaleBar=s.medical.apps.labeler.ShowScaleBars.ActiveValue;
            showOrientationMarkers=s.medical.apps.labeler.ShowOrientationMarkers2D.ActiveValue;
            showOrientationAxes=s.medical.apps.volume.ShowOrientationAxes.ActiveValue;

            header2D=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('medical:medicalLabeler:slices2D')));
            header3D=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('medical:medicalLabeler:volume3D')));


            self.ShowScaleBar=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('medical:medicalLabeler:scaleBars')));
            self.ShowScaleBar.ShowDescription=false;
            self.ShowScaleBar.Value=showScaleBar;
            self.ShowScaleBar.Tag=string(medical.internal.app.labeler.enums.Tag.ShowScaleBars);
            addlistener(self.ShowScaleBar,'ValueChanged',@(~,~)self.scaleBarToggled());


            self.OrientationMarkers2D=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('medical:medicalLabeler:orientationMarkers')));
            self.OrientationMarkers2D.ShowDescription=false;
            self.OrientationMarkers2D.Value=showOrientationMarkers;
            self.OrientationMarkers2D.Tag=string(medical.internal.app.labeler.enums.Tag.ShowOrientationMarkers);
            addlistener(self.OrientationMarkers2D,'ValueChanged',@(~,~)self.orientationMarkers2DToggled());

            self.OrientationAxes3D=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('medical:medicalLabeler:orientationAxes')));
            self.OrientationAxes3D.ShowDescription=false;
            self.OrientationAxes3D.Value=showOrientationAxes;
            self.OrientationAxes3D.Tag=string(medical.internal.app.labeler.enums.Tag.ShowOrientationAxes);
            addlistener(self.OrientationAxes3D,'ValueChanged',@(~,~)self.orientationAxes3DToggled());


            displayPopup=matlab.ui.internal.toolstrip.PopupList();
            add(displayPopup,header2D);
            add(displayPopup,self.OrientationMarkers2D);
            add(displayPopup,header3D);
            add(displayPopup,self.ShowScaleBar);
            add(displayPopup,self.OrientationAxes3D);

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','DisplayMarker_24.png');
            self.DisplayMarkers=matlab.ui.internal.toolstrip.DropDownButton(getString(message('medical:medicalLabeler:displayMarkers')),icon);
            self.DisplayMarkers.Enabled=false;
            self.DisplayMarkers.Description=getString(message('medical:medicalLabeler:displayMarkersDescription'));
            self.DisplayMarkers.Popup=displayPopup;
            self.DisplayMarkers.Tag=string(medical.internal.app.labeler.enums.Tag.DisplayMarkers);

            column=section.addColumn();
            column.add(self.DisplayMarkers);


            group=matlab.ui.internal.toolstrip.ButtonGroup;

            self.Radiological=matlab.ui.internal.toolstrip.ListItemWithRadioButton(group,getString(message('medical:medicalLabeler:radiological')));
            self.Radiological.ShowDescription=true;
            self.Radiological.Tag=string(medical.internal.app.labeler.enums.Tag.Radiological);
            self.Radiological.Description=getString(message('medical:medicalLabeler:radiologicalDescription'));
            addlistener(self.Radiological,'ValueChanged',@(src,evt)displayConventionChanged(self,src,evt));

            self.Neurological=matlab.ui.internal.toolstrip.ListItemWithRadioButton(group,getString(message('medical:medicalLabeler:neurological')));
            self.Neurological.ShowDescription=true;
            self.Neurological.Tag=string(medical.internal.app.labeler.enums.Tag.Neurological);
            self.Neurological.Description=getString(message('medical:medicalLabeler:neurologicalDescription'));
            addlistener(self.Neurological,'ValueChanged',@(src,evt)displayConventionChanged(self,src,evt));


            s=settings;
            displayConvention=s.medical.apps.labeler.DisplayConvention.ActiveValue;
            if displayConvention=="Radiological"
                self.Radiological.Value=true;
            elseif displayConvention=="Neurological"
                self.Neurological.Value=true;
            end

            popup=matlab.ui.internal.toolstrip.PopupList();
            popup.add(self.Radiological);
            popup.add(self.Neurological);

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','DisplayConventionLR_24.png');
            self.DisplayConvention=matlab.ui.internal.toolstrip.DropDownButton(getString(message('medical:medicalLabeler:displayConvention')),icon);
            self.DisplayConvention.Enabled=false;
            self.DisplayConvention.Tag=string(medical.internal.app.labeler.enums.Tag.DisplayConvention);
            self.DisplayConvention.Description=getString(message('medical:medicalLabeler:displayConventionDescription'));
            self.DisplayConvention.Popup=popup;

            column=section.addColumn();
            column.add(self.DisplayConvention);

        end


        function createInspectSection(self)

            section=self.Tab.addSection(getString(message('medical:medicalLabeler:inspect')));
            section.CollapsePriority=0;


            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','VoxelInfo_24.png');
            self.VoxelInfo=matlab.ui.internal.toolstrip.ToggleButton(getString(message('medical:medicalLabeler:voxelInfo')),icon);
            self.VoxelInfo.Tag=string(medical.internal.app.labeler.enums.Tag.VoxelInfo);
            self.VoxelInfo.Description=getString(message('medical:medicalLabeler:voxelInfoDescription'));
            addlistener(self.VoxelInfo,'ValueChanged',@(~,~)self.voxelInfoToggled());

            column=section.addColumn();
            column.add(self.VoxelInfo)

        end


        function createShortcutsSection(self)


            section=addSection(self.Tab,getString(message('images:segmenter:shortcuts')));
            section.CollapsePriority=0;

            icon=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Shortcuts_24.png');
            self.Shortcuts=matlab.ui.internal.toolstrip.Button(getString(message('images:segmenter:viewShortcuts')),icon);
            self.Shortcuts.Tag='Shortcuts';
            self.Shortcuts.Description=getString(message('images:segmenter:viewShortcutsTooltip'));
            addlistener(self.Shortcuts,'ButtonPushed',@(~,~)notify(self,'ViewShortcuts'));

            column=section.addColumn();
            column.add(self.Shortcuts);

        end


        function createLayoutSection(self)

            section=self.Tab.addSection(upper(getString(message('medical:medicalLabeler:layout'))));
            section.Tag="LayoutSection";
            self.LayoutSection=section;

            defaultHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('medical:medicalLabeler:default')));
            focusHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('medical:medicalLabeler:focus')));


            icon=matlab.ui.internal.toolstrip.Icon.LAYOUT_16;
            grid2x2Layout=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:grid2by2')),icon);
            grid2x2Layout.ShowDescription=false;
            grid2x2Layout.Tag=string(medical.internal.app.labeler.view.Layout.Grid2x2);

            layoutType=medical.internal.app.labeler.view.Layout.Grid2x2;
            evtData=medical.internal.app.labeler.events.ValueEventData(layoutType);
            addlistener(grid2x2Layout,'ItemPushed',@(~,~)self.notify('LayoutChangeRequested',evtData));


            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','LayoutFocus3D_16.png');
            focusVolume=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:volume3D')),icon);
            focusVolume.ShowDescription=false;
            focusVolume.Tag=string(medical.internal.app.labeler.view.Layout.FocusVolume);
            layoutType=medical.internal.app.labeler.view.Layout.FocusVolume;
            evtData=medical.internal.app.labeler.events.ValueEventData(layoutType);
            addlistener(focusVolume,'ItemPushed',@(~,~)self.notify('LayoutChangeRequested',evtData));


            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','LayoutFocusTransverse_16.png');
            self.FocusTransverse=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:axial')),icon);
            self.FocusTransverse.ShowDescription=false;
            self.FocusTransverse.Tag=string(medical.internal.app.labeler.view.Layout.FocusTransverse);

            layoutType=medical.internal.app.labeler.view.Layout.FocusTransverse;
            evtData=medical.internal.app.labeler.events.ValueEventData(layoutType);
            addlistener(self.FocusTransverse,'ItemPushed',@(~,~)self.notify('LayoutChangeRequested',evtData));


            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','LayoutFocusSagittal_16.png');
            self.FocusSagittal=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:sagittal')),icon);
            self.FocusSagittal.ShowDescription=false;
            self.FocusSagittal.Tag=string(medical.internal.app.labeler.view.Layout.FocusSagittal);

            layoutType=medical.internal.app.labeler.view.Layout.FocusSagittal;
            evtData=medical.internal.app.labeler.events.ValueEventData(layoutType);
            addlistener(self.FocusSagittal,'ItemPushed',@(~,~)self.notify('LayoutChangeRequested',evtData));


            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','LayoutFocusCoronal_16.png');
            self.FocusCoronal=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:coronal')),icon);
            self.FocusCoronal.ShowDescription=false;
            self.FocusCoronal.Tag=string(medical.internal.app.labeler.view.Layout.FocusCoronal);

            layoutType=medical.internal.app.labeler.view.Layout.FocusCoronal;
            evtData=medical.internal.app.labeler.events.ValueEventData(layoutType);
            addlistener(self.FocusCoronal,'ItemPushed',@(~,~)self.notify('LayoutChangeRequested',evtData));


            layoutPopup=matlab.ui.internal.toolstrip.PopupList();
            layoutPopup.add(defaultHeader);
            layoutPopup.add(grid2x2Layout);
            layoutPopup.add(focusHeader);
            layoutPopup.add(focusVolume);
            layoutPopup.add(self.FocusTransverse);
            layoutPopup.add(self.FocusSagittal);
            layoutPopup.add(self.FocusCoronal);


            icon=matlab.ui.internal.toolstrip.Icon.LAYOUT_24;
            button=matlab.ui.internal.toolstrip.SplitButton(getString(message('medical:medicalLabeler:layout')),icon);
            button.Tag=string(medical.internal.app.labeler.enums.Tag.Layout);
            button.Description=getString(message('medical:medicalLabeler:layoutButtonDescription'));
            button.Enabled=false;
            self.Layout=button;

            column=section.addColumn();
            column.add(self.Layout);

            layoutType=medical.internal.app.labeler.view.Layout.Default;
            evtData=medical.internal.app.labeler.events.ValueEventData(layoutType);
            addlistener(self.Layout,'ButtonPushed',@(~,~)self.notify('LayoutChangeRequested',evtData));

            self.Layout.Popup=layoutPopup;

        end


        function createPublishSection(self)

            section=self.Tab.addSection(getString(message('medical:medicalLabeler:publish')));
            section.CollapsePriority=0;

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','Camera_24.png');
            self.Snapshot=matlab.ui.internal.toolstrip.Button(getString(message('medical:medicalLabeler:saveSnapshot')),icon);
            self.Snapshot.Enabled=false;
            self.Snapshot.Tag=string(medical.internal.app.labeler.enums.Tag.Snapshot);
            self.Snapshot.Description=getString(message('medical:medicalLabeler:snapshotDescription'));
            addlistener(self.Snapshot,'ButtonPushed',@(~,~)self.notify('SnapshotRequested'));

            column=section.addColumn();
            column.add(self.Snapshot)


            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','PublishImages_24.png');
            self.Publish=matlab.ui.internal.toolstrip.ToggleButton(getString(message('medical:medicalLabeler:publish')),icon);
            self.Publish.Tag=string(medical.internal.app.labeler.enums.Tag.Publish);
            self.Publish.Description=getString(message('medical:medicalLabeler:publishDescription'));
            addlistener(self.Publish,'ValueChanged',@(~,~)self.publishToggled());

            column=section.addColumn();
            column.add(self.Publish)

        end


        function createExportSection(self)

            section=self.Tab.addSection(upper(getString(message('medical:medicalLabeler:export'))));


            groundTruthHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('medical:medicalLabeler:groundTruth')));
            labelDefsHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('medical:medicalLabeler:labelDefinitions')));

            self.ExportLabels=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:exportToFile')),...
            matlab.ui.internal.toolstrip.Icon.EXPORT_16);
            self.ExportLabels.Tag=string(medical.internal.app.labeler.enums.Tag.ExportGroundTruth);
            self.ExportLabels.ShowDescription=false;
            addlistener(self.ExportLabels,'ItemPushed',@(~,~)notify(self,'ExportGroundTruthToFile'));

            self.ExportLabelDefinitions=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:exportToFile')),...
            matlab.ui.internal.toolstrip.Icon.EXPORT_16);
            self.ExportLabelDefinitions.Tag=string(medical.internal.app.labeler.enums.Tag.ExportLabelDefinition);
            self.ExportLabelDefinitions.ShowDescription=false;
            addlistener(self.ExportLabelDefinitions,'ItemPushed',@(~,~)notify(self,'ExportLabelDefsToFile'));

            exportPopup=matlab.ui.internal.toolstrip.PopupList();
            exportPopup.add(groundTruthHeader);
            exportPopup.add(self.ExportLabels);
            exportPopup.add(labelDefsHeader);
            exportPopup.add(self.ExportLabelDefinitions);

            icon=matlab.ui.internal.toolstrip.Icon.EXPORT_24;
            self.Export=matlab.ui.internal.toolstrip.DropDownButton(getString(message('medical:medicalLabeler:export')),icon);
            self.Export.Enabled=false;
            self.Export.Tag=string(medical.internal.app.labeler.enums.Tag.Export);
            self.Export.Description=getString(message('medical:medicalLabeler:exportDescription'));
            self.Export.Popup=exportPopup;

            column=section.addColumn();
            column.add(self.Export);

        end

    end


    methods(Access=protected)


        function windowLevelToggled(self,evt)

            TF=evt.EventData.NewValue;
            evt=medical.internal.app.labeler.events.ValueEventData(TF);
            self.notify('EnableWindowLevel',evt);

        end


        function saveSession(self)
            notify(self,'SaveSessionRequested');
            self.LastSaveTimestamp=clock;
        end


        function volumeVisibilityToggled(self)

            TF=self.ShowVolumeBtn.Value;
            self.OrientationAxes3D.Enabled=TF;

            evt=medical.internal.app.labeler.events.ValueEventData(self.ShowVolumeBtn.Value);
            self.notify('ShowVolume',evt);

        end


        function contrastChanged(self)
            notify(self,'ContrastChanged');
        end


        function labelOpacityChanged(self)
            self.notify('LabelOpacityChanged');
        end


        function displayConventionChanged(self,src,evt)

            if~evt.EventData.NewValue
                return
            end

            s=settings;

            if isequal(src,self.Radiological)

                evt=medical.internal.app.labeler.events.ValueEventData("Radiological");
                s.medical.apps.labeler.DisplayConvention.PersonalValue="Radiological";

            elseif isequal(src,self.Neurological)

                evt=medical.internal.app.labeler.events.ValueEventData("Neurological");
                s.medical.apps.labeler.DisplayConvention.PersonalValue="Neurological";

            end

            self.notify('DisplayConventionChanged',evt);

        end


        function scaleBarToggled(self)

            s=settings;
            s.medical.apps.labeler.ShowScaleBars.PersonalValue=self.ShowScaleBar.Value;

            evt=medical.internal.app.labeler.events.ValueEventData(self.ShowScaleBar.Value);
            self.notify('ShowScaleBars',evt);

        end


        function orientationMarkers2DToggled(self)

            s=settings;
            s.medical.apps.labeler.ShowOrientationMarkers2D.PersonalValue=self.OrientationMarkers2D.Value;

            evt=medical.internal.app.labeler.events.ValueEventData(self.OrientationMarkers2D.Value);
            self.notify('Show2DOrientationMarkers',evt);

        end


        function orientationAxes3DToggled(self)

            s=settings;
            s.medical.apps.volume.ShowOrientationAxes.PersonalValue=self.OrientationAxes3D.Value;

            evt=medical.internal.app.labeler.events.ValueEventData(self.OrientationAxes3D.Value);
            self.notify('Show3DOrientationAxes',evt);

        end


        function voxelInfoToggled(self)
            evt=medical.internal.app.labeler.events.ValueEventData(self.VoxelInfo.Value);
            self.notify('ShowVoxelInfo',evt);
        end


        function publishToggled(self)
            evt=medical.internal.app.labeler.events.ValueEventData(self.Publish.Value);
            self.notify('ShowPublishPanel',evt);
        end

    end


    methods


        function TF=get.ShowOrientationMarkers(self)

            TF=false;
            if self.OrientationMarkers2D.Enabled
                TF=self.OrientationMarkers2D.Value;
            end

        end


        function TF=get.WindowLevelEnabled(self)
            TF=self.WindowLevel.Value;
        end

        function set.WindowLevelEnabled(self,TF)
            self.WindowLevel.Value=TF;
        end


        function set.IsVolumeDisplaySupported(self,TF)

            self.ShowVolumeBtn.Enabled=TF;%#ok<MCSUP> 
            self.IsVolumeDisplaySupported=TF;

        end

    end

end
