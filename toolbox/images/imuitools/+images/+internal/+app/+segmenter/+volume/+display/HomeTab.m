classdef HomeTab<handle




    events

AppCleared

VolumeLoadedFromWorkspace

VolumeLoadedFromFile

VolumeLoadedFromDICOM

VolumeLoadedFromBlockedImage

VolumeLoadedFromBlockedImageWorkspace

LabelsLoadedFromWorkspace

LabelsLoadedFromFile

VolumeLoadedFromBlockedImageFolder

LabelsSavedToWorkspace

LabelsSavedAsToWorkspace

LabelsSavedToFile

LabelsSavedAsToFile

LabelNamesImported

ColorOrderRestored

ThreeColumnLayoutRequested

TwoColumnLayoutRequested

ShowLabelsChanged

ShowVolumeChanged

LabelOpacityChanged

SliceDimensionChanged

RotateImage

ViewShortcuts

ViewDoc

ContrastChanged

ShowVoxelInfo

ShowOverviewChanged

RGBLimitsUpdated

    end


    properties(Dependent,SetAccess=protected)

ContrastLimits

    end


    properties

        SaveToMATFile(1,1)logical=true;

        SaveAsRequired(1,1)logical=true;

        SaveAsLogical logical=logical.empty;

        EligibleToSaveAsLogical logical=logical.empty;

        AutoSave(1,1)logical=false;

        SavedName char='';

    end


    properties(Access=protected)

        ContrastEnabled(1,1)logical=true;

        IsSaved(1,1)logical=true;

        LastSaveTimestamp(1,6)double

    end


    properties(Constant,Access=protected)

        AutoSaveDuration(1,1)double=300;

    end


    properties(SetAccess=protected,Hidden,Transient)

Tab

    end

    properties(Transient,SetAccess=protected,GetAccess={...
        ?images.uitest.factory.Tester,...
        ?uitest.factory.Tester,...
        ?medical.internal.app.home.labeler.display.toolstrip.HomeTab})

        New matlab.ui.internal.toolstrip.Button
        OpenVolume matlab.ui.internal.toolstrip.SplitButton
        OpenLabels matlab.ui.internal.toolstrip.SplitButton
        Save matlab.ui.internal.toolstrip.SplitButton
        Autosave matlab.ui.internal.toolstrip.ListItemWithCheckBox
        Layout matlab.ui.internal.toolstrip.DropDownButton
        ShowLabels matlab.ui.internal.toolstrip.ListItemWithCheckBox
        Show3DDisplay matlab.ui.internal.toolstrip.ListItemWithCheckBox
        ShowOverview matlab.ui.internal.toolstrip.ListItemWithCheckBox
        ColorOrder matlab.ui.internal.toolstrip.Button
        LabelNames matlab.ui.internal.toolstrip.Button
        Opacity matlab.ui.internal.toolstrip.Slider
        XYSlice matlab.ui.internal.toolstrip.ToggleButton
        YZSlice matlab.ui.internal.toolstrip.ToggleButton
        XZSlice matlab.ui.internal.toolstrip.ToggleButton
        Rotate matlab.ui.internal.toolstrip.DropDownButton
        Brightness matlab.ui.internal.toolstrip.Slider
        Contrast matlab.ui.internal.toolstrip.Slider
        Shortcuts matlab.ui.internal.toolstrip.Button
        OpenFileLabels matlab.ui.internal.toolstrip.ListItem
        SaveFile matlab.ui.internal.toolstrip.ListItem
        SaveWorkspace matlab.ui.internal.toolstrip.ListItem
        VoxelInfo matlab.ui.internal.toolstrip.ToggleButton
        RedMin matlab.ui.internal.toolstrip.EditField
        RedMax matlab.ui.internal.toolstrip.EditField
        GreenMin matlab.ui.internal.toolstrip.EditField
        GreenMax matlab.ui.internal.toolstrip.EditField
        BlueMin matlab.ui.internal.toolstrip.EditField
        BlueMax matlab.ui.internal.toolstrip.EditField

    end


    methods




        function self=HomeTab(show3DFlag)

            self.Tab=matlab.ui.internal.toolstrip.Tab(getString(message('images:segmenter:homeTab')));
            self.Tab.Tag="SegmenterTab";

            s=settings;
            self.AutoSave=s.images.VolumeSegmenter.AutoSave.ActiveValue;

            createTab(self,show3DFlag);

        end




        function enable(self)
            self.New.Enabled=true;
            self.OpenVolume.Enabled=true;
            self.OpenLabels.Enabled=true;
            self.Save.Enabled=true;
            self.Layout.Enabled=true;
            self.ColorOrder.Enabled=true;
            self.LabelNames.Enabled=true;
            self.Opacity.Enabled=true;
            self.XYSlice.Enabled=true;
            self.YZSlice.Enabled=true;
            self.XZSlice.Enabled=true;
            self.Rotate.Enabled=true;
            self.Shortcuts.Enabled=true;
            self.VoxelInfo.Enabled=true;

            if self.ContrastEnabled
                self.Brightness.Enabled=true;
                self.Contrast.Enabled=true;
                self.RedMin.Editable=false;
                self.RedMax.Editable=false;
                self.GreenMin.Editable=false;
                self.GreenMax.Editable=false;
                self.BlueMin.Editable=false;
                self.BlueMax.Editable=false;
                self.RedMin.Enabled=false;
                self.RedMax.Enabled=false;
                self.GreenMin.Enabled=false;
                self.GreenMax.Enabled=false;
                self.BlueMin.Enabled=false;
                self.BlueMax.Enabled=false;
            else
                self.Brightness.Enabled=false;
                self.Contrast.Enabled=false;
                self.RedMin.Editable=true;
                self.RedMax.Editable=true;
                self.GreenMin.Editable=true;
                self.GreenMax.Editable=true;
                self.BlueMin.Editable=true;
                self.BlueMax.Editable=true;
                self.RedMin.Enabled=true;
                self.RedMax.Enabled=true;
                self.GreenMin.Enabled=true;
                self.GreenMax.Enabled=true;
                self.BlueMin.Enabled=true;
                self.BlueMax.Enabled=true;
            end

            if self.SaveAsRequired
                self.Autosave.Enabled=false;
            else
                self.Autosave.Enabled=true;
            end

        end




        function disable(self)
            self.New.Enabled=false;
            self.OpenVolume.Enabled=false;
            self.OpenLabels.Enabled=false;
            self.Save.Enabled=false;
            self.Layout.Enabled=false;
            self.ColorOrder.Enabled=false;
            self.LabelNames.Enabled=false;
            self.Opacity.Enabled=false;
            self.XYSlice.Enabled=false;
            self.YZSlice.Enabled=false;
            self.XZSlice.Enabled=false;
            self.Rotate.Enabled=false;
            self.Brightness.Enabled=false;
            self.Contrast.Enabled=false;
            self.Shortcuts.Enabled=false;
            self.VoxelInfo.Enabled=false;
            self.RedMin.Editable=false;
            self.RedMax.Editable=false;
            self.GreenMin.Editable=false;
            self.GreenMax.Editable=false;
            self.BlueMin.Editable=false;
            self.BlueMax.Editable=false;
        end




        function enableLoadOnly(self)
            self.New.Enabled=true;
            self.OpenVolume.Enabled=true;
            self.OpenLabels.Enabled=false;
            self.Save.Enabled=false;
            self.Layout.Enabled=true;
            self.ColorOrder.Enabled=true;
            self.LabelNames.Enabled=true;
            self.Opacity.Enabled=false;
            self.XYSlice.Enabled=false;
            self.YZSlice.Enabled=false;
            self.XZSlice.Enabled=false;
            self.Rotate.Enabled=false;
            self.Brightness.Enabled=false;
            self.Contrast.Enabled=false;
            self.Shortcuts.Enabled=true;
            self.VoxelInfo.Enabled=false;
            self.RedMin.Editable=false;
            self.RedMax.Editable=false;
            self.GreenMin.Editable=false;
            self.GreenMax.Editable=false;
            self.BlueMin.Editable=false;
            self.BlueMax.Editable=false;
        end




        function markSaveAsDirty(self)

            if self.AutoSave&&~self.SaveAsRequired&&~isempty(self.LastSaveTimestamp)&&etime(clock,self.LastSaveTimestamp)>self.AutoSaveDuration
                save(self);
            else
                self.Save.Icon=matlab.ui.internal.toolstrip.Icon.SAVE_DIRTY_24;
                self.IsSaved=false;
            end

        end




        function markSaveAsClean(self)

            self.Save.Icon=matlab.ui.internal.toolstrip.Icon.SAVE_24;
            self.IsSaved=true;

        end




        function save(self)

            if self.SaveToMATFile
                if self.SaveAsRequired
                    saveAsFile(self);
                else

                    if self.EligibleToSaveAsLogical
                        isLogical=self.SaveAsLogical;
                    else
                        isLogical=false;
                    end

                    notify(self,'LabelsSavedToFile',images.internal.app.segmenter.volume.events.SaveEventData(self.SavedName,isLogical,true));
                    markSaveAsClean(self);
                end
            else
                if self.SaveAsRequired
                    saveAsWorkspace(self);
                else

                    if self.EligibleToSaveAsLogical
                        isLogical=self.SaveAsLogical;
                    else
                        isLogical=false;
                    end

                    notify(self,'LabelsSavedToWorkspace',images.internal.app.segmenter.volume.events.SaveEventData(self.SavedName,isLogical,false));
                    markSaveAsClean(self);
                end
            end

            self.LastSaveTimestamp=clock;

        end




        function showLabels(self,TF)

            self.ShowLabels.Value=TF;

        end




        function showVolume(self,TF)

            self.Show3DDisplay.Value=TF;

        end




        function showOverview(self,TF)

            self.ShowOverview.Value=TF;

        end




        function enableContrastControls(self,isRGB)

            self.ContrastEnabled=~isRGB;

            if~self.ContrastEnabled
                self.Brightness.Enabled=false;
                self.Contrast.Enabled=false;
            end

        end




        function TF=isDataSaved(self)

            TF=self.IsSaved;

        end




        function clear(self)

            markSaveAsClean(self);

            self.SaveAsRequired=true;
            self.SaveAsLogical=logical.empty;
            self.EligibleToSaveAsLogical=logical.empty;
            self.SavedName='';

        end




        function enableBlockedLabels(self,TF)

            if TF
                self.SaveFile.Text=getString(message('images:segmenter:saveBlockedImage'));
                self.OpenFileLabels.Text=getString(message('images:segmenter:loadLabelBlockedImage'));
            else
                self.SaveFile.Text=getString(message('images:segmenter:saveAsFile'));
                self.OpenFileLabels.Text=getString(message('images:segmenter:openFile'));
            end

            self.ShowOverview.Enabled=TF;
            self.SaveWorkspace.Enabled=~TF;

        end




        function deselectVoxelInfo(self)
            self.VoxelInfo.Value=false;
        end




        function updateRGBLimits(self,R,G,B)

            self.RedMin.Value=num2str(R(1));
            self.RedMax.Value=num2str(R(2));
            self.GreenMin.Value=num2str(G(1));
            self.GreenMax.Value=num2str(G(2));
            self.BlueMin.Value=num2str(B(1));
            self.BlueMax.Value=num2str(B(2));

        end




        function updateContrastLimits(self,contrastLimits)

            self.ContrastLimits=contrastLimits;

        end




        function updateSliceDimension(self,sliceDimension)

            switch sliceDimension

            case 'xy'
                self.XYSlice.Value=true;
                self.YZSlice.Value=false;
                self.XZSlice.Value=false;

            case 'yz'
                self.XYSlice.Value=false;
                self.YZSlice.Value=true;
                self.XZSlice.Value=false;

            case 'xz'
                self.XYSlice.Value=false;
                self.YZSlice.Value=false;
                self.XZSlice.Value=true;

            otherwise
                return

            end

            evt=images.internal.app.segmenter.volume.events.SliceDimensionChangedEventData(sliceDimension);
            notify(self,'SliceDimensionChanged',evt);

        end




        function sliceDimension=getSliceDimension(self)

            if self.XYSlice.Value
                sliceDimension="xy";
            elseif self.YZSlice.Value
                sliceDimension="yz";
            elseif self.XZSlice.Value
                sliceDimension="xz";
            end

        end

    end


    methods(Access=protected)


        function new(self)

            self.SaveAsRequired=true;
            self.SavedName='';

            notify(self,'AppCleared');
        end


        function openVolumeFromWorkspace(self)

            notify(self,'VolumeLoadedFromWorkspace');

        end


        function openVolumeFromFile(self)

            notify(self,'VolumeLoadedFromFile');

        end


        function openVolumeFromDICOM(self)

            notify(self,'VolumeLoadedFromDICOM');

        end


        function openLabelsFromWorkspace(self)

            notify(self,'LabelsLoadedFromWorkspace');

        end


        function openLabelsFromFile(self)

            notify(self,'LabelsLoadedFromFile');

        end


        function saveAsWorkspace(self)

            notify(self,'LabelsSavedAsToWorkspace');

        end


        function saveAsFile(self)

            notify(self,'LabelsSavedAsToFile');

        end


        function showLabelPanel(self,evt)

            notify(self,'ShowLabelsChanged',images.internal.app.segmenter.volume.events.ShowVolumeChangedEventData(...
            evt.EventData.NewValue));

        end


        function show3DDisplay(self,evt)

            notify(self,'ShowVolumeChanged',images.internal.app.segmenter.volume.events.ShowVolumeChangedEventData(...
            evt.EventData.NewValue));

        end


        function reactToShowOverview(self,evt)

            notify(self,'ShowOverviewChanged',images.internal.app.segmenter.volume.events.ShowVolumeChangedEventData(...
            evt.EventData.NewValue));

        end


        function restoreColorOrder(self)
            notify(self,'ColorOrderRestored');
        end


        function opacityChanged(self)

            notify(self,'LabelOpacityChanged',images.internal.app.segmenter.volume.events.LabelOpacityChangedEventData(...
            self.Opacity.Value/100));

        end


        function importLabelNames(self)
            notify(self,'LabelNamesImported');
        end


        function xySlice(self,evt)

            if evt.EventData.OldValue
                evt.Source.Value=true;
            else
                self.YZSlice.Value=false;
                self.XZSlice.Value=false;
                notify(self,'SliceDimensionChanged',...
                images.internal.app.segmenter.volume.events.SliceDimensionChangedEventData(...
                'xy'));
            end

        end


        function yzSlice(self,evt)

            if evt.EventData.OldValue
                evt.Source.Value=true;
            else
                self.XYSlice.Value=false;
                self.XZSlice.Value=false;
                notify(self,'SliceDimensionChanged',...
                images.internal.app.segmenter.volume.events.SliceDimensionChangedEventData(...
                'yz'));
            end

        end


        function xzSlice(self,evt)

            if evt.EventData.OldValue
                evt.Source.Value=true;
            else
                self.XYSlice.Value=false;
                self.YZSlice.Value=false;
                notify(self,'SliceDimensionChanged',...
                images.internal.app.segmenter.volume.events.SliceDimensionChangedEventData(...
                'xz'));
            end

        end


        function autosave(self)

            self.AutoSave=self.Autosave.Value;

            s=settings;
            s.images.VolumeSegmenter.AutoSave.PersonalValue=self.AutoSave;

        end


        function contrastChanged(self)
            notify(self,'ContrastChanged');
        end


        function rgbLimitsUpdated(self)

            notify(self,'RGBLimitsUpdated',images.internal.app.segmenter.volume.events.RGBLimitsEventData(...
            [str2double(self.RedMin.Value),str2double(self.RedMax.Value)],...
            [str2double(self.GreenMin.Value),str2double(self.GreenMax.Value)],...
            [str2double(self.BlueMin.Value),str2double(self.BlueMax.Value)]));

        end

    end


    methods(Access=protected)


        function createTab(self,show3DFlag)

            createFileSection(self);
            createLabelsSection(self);
            createOrientationSection(self);
            createLayoutSection(self,show3DFlag);
            createInspectSection(self);
            createShortcutsSection(self);

        end

        function createFileSection(self)

            section=addSection(self.Tab,getString(message('images:segmenter:file')));
            section.CollapsePriority=30;


            column=section.addColumn();
            self.New=matlab.ui.internal.toolstrip.Button(getString(message('images:segmenter:new')),matlab.ui.internal.toolstrip.Icon.NEW_24);
            self.New.Tag='New';
            self.New.Description=getString(message('images:segmenter:newTooltip'));
            addlistener(self.New,'ButtonPushed',@(~,~)new(self));
            column.add(self.New);


            column=section.addColumn();
            volumeHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('images:segmenter:memoryHeader')));
            blockedImageHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('images:segmenter:blockedImageHeader')));

            openWorkspace=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:openWorkspace')),matlab.ui.internal.toolstrip.Icon.IMPORT_24);
            openWorkspace.ShowDescription=false;
            openWorkspace.Tag='OpenFromWorkspace';
            addlistener(openWorkspace,'ItemPushed',@(~,~)openVolumeFromWorkspace(self));

            openFile=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:openFile')),matlab.ui.internal.toolstrip.Icon.OPEN_24);
            openFile.ShowDescription=false;
            openFile.Tag='OpenFile';
            addlistener(openFile,'ItemPushed',@(~,~)openVolumeFromFile(self));

            openDICOM=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:openDICOM')),matlab.ui.internal.toolstrip.Icon.OPEN_24);
            openDICOM.ShowDescription=false;
            openDICOM.Tag='OpenDICOMFile';
            addlistener(openDICOM,'ItemPushed',@(~,~)openVolumeFromDICOM(self));

            openBlocked=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:openBlockedImage')),matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','icons','mip_24.png')));
            openBlocked.ShowDescription=false;
            openBlocked.Tag='OpenBlockedFile';
            addlistener(openBlocked,'ItemPushed',@(~,~)notify(self,'VolumeLoadedFromBlockedImage'));

            openBlockedFolder=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:openBlockedImageFolder')),matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','icons','mip_24.png')));
            openBlockedFolder.ShowDescription=false;
            openBlockedFolder.Tag='OpenBlockedFolder';
            addlistener(openBlockedFolder,'ItemPushed',@(~,~)notify(self,'VolumeLoadedFromBlockedImageFolder'));

            openBlockedWorkspace=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:openBlockedImageFromWorkspace')),matlab.ui.internal.toolstrip.Icon.IMPORT_24);
            openBlockedWorkspace.ShowDescription=false;
            openBlockedWorkspace.Tag='OpenBlockedFromWorkspace';
            addlistener(openBlockedWorkspace,'ItemPushed',@(~,~)notify(self,'VolumeLoadedFromBlockedImageWorkspace'));

            popup=matlab.ui.internal.toolstrip.PopupList();
            add(popup,volumeHeader);
            add(popup,openFile);
            add(popup,openDICOM);
            add(popup,openWorkspace);
            add(popup,blockedImageHeader);
            add(popup,openBlocked);
            add(popup,openBlockedFolder);
            add(popup,openBlockedWorkspace);

            self.OpenVolume=matlab.ui.internal.toolstrip.SplitButton(getString(message('images:segmenter:openVolume')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','icons','volume_24.png')));
            self.OpenVolume.Tag='OpenVolume';
            self.OpenVolume.Description=getString(message('images:segmenter:openVolumeTooltip'));
            self.OpenVolume.Popup=popup;
            addlistener(self.OpenVolume,'ButtonPushed',@(~,~)openVolumeFromFile(self));
            column.add(self.OpenVolume);


            column=section.addColumn();

            openWSLabels=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:openWorkspace')),matlab.ui.internal.toolstrip.Icon.IMPORT_24);
            openWSLabels.ShowDescription=false;
            openWSLabels.Tag="OpenWorkspaceLabels";
            addlistener(openWSLabels,'ItemPushed',@(~,~)openLabelsFromWorkspace(self));

            self.OpenFileLabels=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:openFile')),matlab.ui.internal.toolstrip.Icon.OPEN_24);
            self.OpenFileLabels.ShowDescription=false;
            self.OpenFileLabels.Tag="OpenFileLabels";
            addlistener(self.OpenFileLabels,'ItemPushed',@(~,~)openLabelsFromFile(self));

            popup=matlab.ui.internal.toolstrip.PopupList();
            add(popup,self.OpenFileLabels);
            add(popup,openWSLabels);

            self.OpenLabels=matlab.ui.internal.toolstrip.SplitButton(getString(message('images:segmenter:openLabels')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','icons','LabelVolume_24.png')));
            self.OpenLabels.Tag='OpenLabels';
            self.OpenLabels.Description=getString(message('images:segmenter:openLabelsTooltip'));
            self.OpenLabels.Popup=popup;
            addlistener(self.OpenLabels,'ButtonPushed',@(~,~)openLabelsFromFile(self));
            column.add(self.OpenLabels);


            column=section.addColumn();

            saveHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('images:segmenter:saveHeader')));
            saveHeader.Tag="Save";

            saveButton=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:saveSegmentation')),matlab.ui.internal.toolstrip.Icon.SAVE_16);
            saveButton.ShowDescription=false;
            saveButton.Tag="SaveListItem";
            addlistener(saveButton,'ItemPushed',@(~,~)save(self));

            self.SaveWorkspace=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:saveAsWorkspace')),matlab.ui.internal.toolstrip.Icon.SAVE_AS_16);
            self.SaveWorkspace.ShowDescription=false;
            self.SaveWorkspace.Tag="SaveToWorkspace";
            addlistener(self.SaveWorkspace,'ItemPushed',@(~,~)saveAsWorkspace(self));

            self.SaveFile=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:saveAsFile')),matlab.ui.internal.toolstrip.Icon.SAVE_AS_16);
            self.SaveFile.ShowDescription=false;
            self.SaveFile.Tag="SaveToFile";
            addlistener(self.SaveFile,'ItemPushed',@(~,~)saveAsFile(self));

            autosaveHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('images:segmenter:autosaveHeader')));

            self.Autosave=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('images:segmenter:autosave')));
            self.Autosave.ShowDescription=false;
            self.Autosave.Tag="AutoSave";
            addlistener(self.Autosave,'ValueChanged',@(~,~)autosave(self));
            self.Autosave.Value=self.AutoSave;

            popup=matlab.ui.internal.toolstrip.PopupList();
            add(popup,saveHeader);
            add(popup,saveButton);
            add(popup,self.SaveFile);
            add(popup,self.SaveWorkspace);
            add(popup,autosaveHeader);
            add(popup,self.Autosave);

            self.Save=matlab.ui.internal.toolstrip.SplitButton(getString(message('images:segmenter:save')),matlab.ui.internal.toolstrip.Icon.SAVE_24);
            self.Save.Tag='Save';
            self.Save.Description=getString(message('images:segmenter:saveTooltip'));
            self.Save.Popup=popup;
            addlistener(self.Save,'ButtonPushed',@(~,~)save(self));
            column.add(self.Save);

        end

        function createLabelsSection(self)


            section=addSection(self.Tab,getString(message('images:segmenter:labelDefinitions')));
            section.CollapsePriority=0;


            column=section.addColumn();
            self.LabelNames=matlab.ui.internal.toolstrip.Button(getString(message('images:segmenter:importLabelNames')),matlab.ui.internal.toolstrip.Icon.IMPORT_16);
            self.LabelNames.Tag='LabelNames';
            self.LabelNames.Description=getString(message('images:segmenter:importLabelNamesToolltip'));
            addlistener(self.LabelNames,'ButtonPushed',@(~,~)importLabelNames(self));
            column.add(self.LabelNames);


            self.ColorOrder=matlab.ui.internal.toolstrip.Button(getString(message('images:segmenter:colorOrder')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_ColorOrder_16.png')));
            self.ColorOrder.Tag='ColorOrder';
            self.ColorOrder.Description=getString(message('images:segmenter:colorOrderTooltip'));
            addlistener(self.ColorOrder,'ButtonPushed',@(~,~)restoreColorOrder(self));
            column.add(self.ColorOrder);

        end

        function createOrientationSection(self)


            section=addSection(self.Tab,getString(message('images:segmenter:orientation')));
            section.CollapsePriority=20;
            column=section.addColumn();


            self.XYSlice=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:xySlice')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_XYSlice_16.png')));
            self.XYSlice.Tag='XYSlice';
            self.XYSlice.Description=getString(message('images:segmenter:xySliceTooltip'));
            self.XYSlice.Value=true;
            addlistener(self.XYSlice,'ValueChanged',@(src,evt)xySlice(self,evt));
            column.add(self.XYSlice);


            self.YZSlice=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:yzSlice')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_YZSlice_16.png')));
            self.YZSlice.Tag='YZSlice';
            self.YZSlice.Description=getString(message('images:segmenter:yzSliceTooltip'));
            addlistener(self.YZSlice,'ValueChanged',@(src,evt)yzSlice(self,evt));
            column.add(self.YZSlice);


            self.XZSlice=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:xzSlice')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_XZSlice_16.png')));
            self.XZSlice.Tag='XZSlice';
            self.XZSlice.Description=getString(message('images:segmenter:xzSliceTooltip'));
            addlistener(self.XZSlice,'ValueChanged',@(src,evt)xzSlice(self,evt));
            column.add(self.XZSlice);

        end

        function createLayoutSection(self,show3DFlag)


            section=addSection(self.Tab,getString(message('images:segmenter:view')));
            section.CollapsePriority=0;

            column=section.addColumn();

            layoutHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('images:segmenter:selectLayout')));

            if show3DFlag
                threeColumn=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:column3')),...
                fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_ThreeColumn_16.png'));
                threeColumn.ShowDescription=false;
                threeColumn.Tag="ThreeColumnLayout";
                addlistener(threeColumn,'ItemPushed',@(~,~)notify(self,'ThreeColumnLayoutRequested'));
            end

            twoColumn=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:column2')),...
            fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_TwoColumn_16.png'));
            twoColumn.ShowDescription=false;
            twoColumn.Tag="TwoColumnLayout";
            addlistener(twoColumn,'ItemPushed',@(~,~)notify(self,'TwoColumnLayoutRequested'));

            showHeader=matlab.ui.internal.toolstrip.PopupListHeader(getString(message('images:segmenter:show')));

            self.ShowLabels=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('images:segmenter:showLabelPanel')));
            self.ShowLabels.ShowDescription=false;
            self.ShowLabels.Tag="ShowLabels";
            addlistener(self.ShowLabels,'ValueChanged',@(src,evt)showLabelPanel(self,evt));

            self.Show3DDisplay=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('images:segmenter:show3dPanel')));
            self.Show3DDisplay.ShowDescription=false;
            self.Show3DDisplay.Tag="Show3DDisplay";

            self.ShowOverview=matlab.ui.internal.toolstrip.ListItemWithCheckBox(getString(message('images:segmenter:overview')));
            self.ShowOverview.ShowDescription=false;
            self.ShowOverview.Enabled=false;
            self.ShowOverview.Tag="ShowOverview";

            if show3DFlag
                addlistener(self.Show3DDisplay,'ValueChanged',@(src,evt)show3DDisplay(self,evt));
                addlistener(self.ShowOverview,'ValueChanged',@(src,evt)reactToShowOverview(self,evt));
            end

            popup=matlab.ui.internal.toolstrip.PopupList();
            add(popup,layoutHeader);

            if show3DFlag
                add(popup,threeColumn);
            end

            add(popup,twoColumn);
            add(popup,showHeader);
            add(popup,self.ShowLabels);

            if show3DFlag
                add(popup,self.Show3DDisplay);
                add(popup,self.ShowOverview);
            end

            self.Layout=matlab.ui.internal.toolstrip.DropDownButton(getString(message('images:segmenter:layout')),matlab.ui.internal.toolstrip.Icon.LAYOUT_24);
            self.Layout.Tag='Layout';
            self.Layout.Description=getString(message('images:segmenter:layoutTooltip'));
            self.Layout.Popup=popup;
            column.add(self.Layout);


            brightnessLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:brightness')));
            contrastLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:contrast')));
            opacityLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:labelOpacity')));

            brightnessLabel.Tag="BrightnessLabel";
            contrastLabel.Tag="ContrastLabel";
            opacityLabel.Tag="OpacityLabel";

            self.Brightness=matlab.ui.internal.toolstrip.Slider([0,100],50);
            self.Brightness.Compact=true;
            self.Brightness.Tag='Brightness';
            self.Brightness.Ticks=0;
            self.Brightness.Description=getString(message('images:segmenter:brightnessTooltip'));

            self.Contrast=matlab.ui.internal.toolstrip.Slider([0,100],0);
            self.Contrast.Compact=true;
            self.Contrast.Tag='Contrast';
            self.Contrast.Ticks=0;
            self.Contrast.Description=getString(message('images:segmenter:contrastTooltip'));

            self.Opacity=matlab.ui.internal.toolstrip.Slider([0,100],50);
            self.Opacity.Compact=true;
            self.Opacity.Tag='LabelOpacity';
            self.Opacity.Ticks=0;
            self.Opacity.Description=getString(message('images:segmenter:labelOpacityTooltip'));

            column=section.addColumn('HorizontalAlignment','right');
            column.add(brightnessLabel);
            column.add(contrastLabel);
            column.add(opacityLabel);

            column=section.addColumn('HorizontalAlignment','center','Width',120);
            column.add(self.Brightness);
            column.add(self.Contrast);
            column.add(self.Opacity);

            addlistener(self.Brightness,'ValueChanging',@(~,~)contrastChanged(self));
            addlistener(self.Contrast,'ValueChanging',@(~,~)contrastChanged(self));
            addlistener(self.Opacity,'ValueChanging',@(~,~)opacityChanged(self));

            column=section.addColumn('HorizontalAlignment','right');

            redLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:redLimit')));
            greenLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:greenLimit')));
            blueLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:blueLimit')));

            redLabel.Tag="RedLabel";
            greenLabel.Tag="GreenLabel";
            blueLabel.Tag="BlueLabel";

            column.add(redLabel);
            column.add(greenLabel);
            column.add(blueLabel);

            column=section.addColumn('Width',40);


            self.RedMin=matlab.ui.internal.toolstrip.EditField();
            self.RedMin.Description=getString(message('images:segmenter:redLimitTooltip'));
            self.RedMin.Tag='RedMin';
            column.add(self.RedMin);

            self.GreenMin=matlab.ui.internal.toolstrip.EditField();
            self.GreenMin.Description=getString(message('images:segmenter:greenLimitTooltip'));
            self.GreenMin.Tag='GreenMin';
            column.add(self.GreenMin);

            self.BlueMin=matlab.ui.internal.toolstrip.EditField();
            self.BlueMin.Description=getString(message('images:segmenter:blueLimitTooltip'));
            self.BlueMin.Tag='BlueMin';
            column.add(self.BlueMin);

            self.RedMin.Enabled=true;
            self.GreenMin.Enabled=true;
            self.BlueMin.Enabled=true;

            column=section.addColumn('Width',40);


            self.RedMax=matlab.ui.internal.toolstrip.EditField();
            self.RedMax.Description=getString(message('images:segmenter:redLimitTooltip'));
            self.RedMax.Tag='RedMax';
            column.add(self.RedMax);

            self.GreenMax=matlab.ui.internal.toolstrip.EditField();
            self.GreenMax.Description=getString(message('images:segmenter:greenLimitTooltip'));
            self.GreenMax.Tag='GreenMax';
            column.add(self.GreenMax);

            self.BlueMax=matlab.ui.internal.toolstrip.EditField();
            self.BlueMax.Description=getString(message('images:segmenter:blueLimitTooltip'));
            self.BlueMax.Tag='BlueMax';
            column.add(self.BlueMax);

            self.RedMax.Enabled=true;
            self.GreenMax.Enabled=true;
            self.BlueMax.Enabled=true;

            addlistener(self.RedMin,'ValueChanged',@(~,~)rgbLimitsUpdated(self));
            addlistener(self.GreenMin,'ValueChanged',@(~,~)rgbLimitsUpdated(self));
            addlistener(self.BlueMin,'ValueChanged',@(~,~)rgbLimitsUpdated(self));
            addlistener(self.RedMax,'ValueChanged',@(~,~)rgbLimitsUpdated(self));
            addlistener(self.GreenMax,'ValueChanged',@(~,~)rgbLimitsUpdated(self));
            addlistener(self.BlueMax,'ValueChanged',@(~,~)rgbLimitsUpdated(self));

            column=section.addColumn();


            rotateCounterclockwise=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:rotateCounterclockwise')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_RotateCCW_16.png')));
            rotateCounterclockwise.ShowDescription=false;
            rotateCounterclockwise.Tag="RotateCounterClockwise";
            addlistener(rotateCounterclockwise,'ItemPushed',@(~,~)notify(self,'RotateImage',images.internal.app.segmenter.volume.events.RotateImageEventData('ccw')));

            rotateClockwise=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:rotateClockwise')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_RotateCW_16.png')));
            rotateClockwise.ShowDescription=false;
            rotateClockwise.Tag="RotateClockwise";
            addlistener(rotateClockwise,'ItemPushed',@(~,~)notify(self,'RotateImage',images.internal.app.segmenter.volume.events.RotateImageEventData('cw')));

            flipHorizontal=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:flipHorizontal')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_FlipHorizontal_16.png')));
            flipHorizontal.ShowDescription=false;
            flipHorizontal.Tag="FlipHorizontal";
            addlistener(flipHorizontal,'ItemPushed',@(~,~)notify(self,'RotateImage',images.internal.app.segmenter.volume.events.RotateImageEventData('lr')));

            flipVertical=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:flipVertical')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_FlipVertical_16.png')));
            flipVertical.ShowDescription=false;
            flipVertical.Tag="FlipVertical";
            addlistener(flipVertical,'ItemPushed',@(~,~)notify(self,'RotateImage',images.internal.app.segmenter.volume.events.RotateImageEventData('ud')));

            resetRotate=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:reset')),matlab.ui.internal.toolstrip.Icon.RESTORE_16);
            resetRotate.ShowDescription=false;
            resetRotate.Tag="ResetRotate";
            addlistener(resetRotate,'ItemPushed',@(~,~)notify(self,'RotateImage',images.internal.app.segmenter.volume.events.RotateImageEventData('reset')));

            popup=matlab.ui.internal.toolstrip.PopupList();

            add(popup,rotateCounterclockwise);
            add(popup,rotateClockwise);
            add(popup,flipHorizontal);
            add(popup,flipVertical);
            add(popup,resetRotate);

            self.Rotate=matlab.ui.internal.toolstrip.DropDownButton(getString(message('images:segmenter:rotateSlice')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_RotateCCW_24.png')));
            self.Rotate.Tag='Rotate';
            self.Rotate.Description=getString(message('images:segmenter:rotateSliceTooltip'));
            self.Rotate.Popup=popup;
            column.add(self.Rotate);

        end

        function createInspectSection(self)

            section=addSection(self.Tab,getString(message('images:segmenter:inspect')));
            section.CollapsePriority=0;


            column=section.addColumn();
            self.VoxelInfo=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:showInfo')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_VoxelInfo_24.png')));
            self.VoxelInfo.Tag='VoxelInfo';
            self.VoxelInfo.Description=getString(message('images:segmenter:showInfoTooltip'));
            column.add(self.VoxelInfo);
            addlistener(self.VoxelInfo,'ValueChanged',@(src,evt)notify(self,'ShowVoxelInfo',evt));

        end

        function createShortcutsSection(self)


            section=addSection(self.Tab,getString(message('images:segmenter:shortcuts')));
            section.CollapsePriority=0;
            column=section.addColumn();

            self.Shortcuts=matlab.ui.internal.toolstrip.Button(getString(message('images:segmenter:viewShortcuts')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Shortcuts_24.png')));
            self.Shortcuts.Tag='Shortcuts';
            self.Shortcuts.Description=getString(message('images:segmenter:viewShortcutsTooltip'));
            addlistener(self.Shortcuts,'ButtonPushed',@(~,~)notify(self,'ViewShortcuts'));
            column.add(self.Shortcuts);

        end

    end


    methods




        function set.SaveAsRequired(self,TF)

            if isvalid(self.Autosave)%#ok<*MCSUP> 

                if TF
                    self.Autosave.Enabled=false;
                else
                    self.Autosave.Enabled=true;
                end

            end

            self.SaveAsRequired=TF;

        end




        function val=get.ContrastLimits(self)

            contrast=1-self.Contrast.Value/100;
            brightness=1-self.Brightness.Value/100;

            val=[brightness-(0.5*contrast),brightness+(0.5*contrast)];

            val(val<0)=0;
            val(val>1)=1;

            if val(1)==val(2)
                if val(1)==0
                    val(2)=val(1)+0.001;
                else
                    val(1)=val(2)-0.001;
                end
            end

        end

        function set.ContrastLimits(self,contrastLimits)

            contrast=1-diff(contrastLimits);
            brightness=1-mean(contrastLimits);

            self.Contrast.Value=contrast*100;
            self.Brightness.Value=brightness*100;

        end

    end


end