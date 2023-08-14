classdef VolumeRenderingTab<handle




    properties(SetAccess=protected,Hidden)

Tab

    end

    properties(Access=protected)

RenderingEditor

PresetsGallery
        PresetsRenderings matlab.ui.internal.toolstrip.ToggleGalleryItem
        UserDefinedRenderings matlab.ui.internal.toolstrip.ToggleGalleryItem
CustomPresetButton
PresetsCategory
UserDefinedCategory

SaveRendering
ManageCustomRendering

ApplyToAll

ShowLabels

BackgroundGradient
BackgroundColor
GradientColor
RestoreBackground

    end

    properties(Access=protected,Constant)

        ColorIconSize=[16,16,3];

    end

    events

RenderingEditorToggled

PresetRenderingRequested
UserDefinedRenderingRequested

SaveRenderingRequested
ManageRenderingRequested
ApplyRenderingToAllVolumes

BackgroundGradientToggled
BackgroundColorChangeRequested
GradientColorChangeRequested
RestoreBackgroundRequested

    end

    methods

        function self=VolumeRenderingTab()

            self.Tab=matlab.ui.internal.toolstrip.Tab(getString(message('medical:medicalLabeler:volumeRenderingTab')));
            self.Tab.Tag=string(medical.internal.app.labeler.enums.Tag.VolumeRenderingTab);

            self.createTab();

        end


        function enable(self)

            self.RenderingEditor.Enabled=true;

            self.PresetsGallery.Enabled=true;

            self.SaveRendering.Enabled=true;
            if isempty(self.UserDefinedRenderings)
                self.ManageCustomRendering.Enabled=false;
            else
                self.ManageCustomRendering.Enabled=true;
            end

            self.ApplyToAll.Enabled=true;
            self.ShowLabels.Enabled=true;
            self.ShowLabels.Enabled=true;

            self.BackgroundGradient.Enabled=true;
            self.BackgroundColor.Enabled=true;
            if self.BackgroundGradient.Value
                self.GradientColor.Enabled=true;
            else
                self.GradientColor.Enabled=false;
            end
            self.RestoreBackground.Enabled=true;


        end


        function disable(self)

            self.RenderingEditor.Enabled=false;

            self.PresetsGallery.Enabled=false;

            self.SaveRendering.Enabled=false;
            self.ManageCustomRendering.Enabled=false;

            self.ApplyToAll.Enabled=false;

            self.ShowLabels.Enabled=false;

            self.BackgroundGradient.Enabled=false;
            self.BackgroundColor.Enabled=false;
            self.GradientColor.Enabled=false;
            self.RestoreBackground.Enabled=false;

        end


        function disableSaveCustomRenderings(self)
            self.SaveRendering.Enabled=false;
        end


        function setBackgroundColor(self,color)

            if isempty(color)
                return
            end

            img=zeros(self.ColorIconSize);
            img(:,:,1)=color(1);
            img(:,:,2)=color(2);
            img(:,:,3)=color(3);

            self.BackgroundColor.Icon=matlab.ui.internal.toolstrip.Icon(im2uint8(img));

            s=settings;
            s.medical.apps.volume.BackgroundColor.PersonalValue=color;

        end


        function setGradientColor(self,color)

            if isempty(color)
                return
            end

            img=zeros(self.ColorIconSize);
            img(:,:,1)=color(1);
            img(:,:,2)=color(2);
            img(:,:,3)=color(3);

            self.GradientColor.Icon=matlab.ui.internal.toolstrip.Icon(im2uint8(img));

            s=settings;
            s.medical.apps.volume.GradientColor.PersonalValue=color;

        end


        function setBackgroundGradient(self,useGradient)

            self.BackgroundGradient.Value=useGradient;

            s=settings;
            s.medical.apps.volume.BackgroundColor.PersonalValue=useGradient;

        end


        function setVolumeBackgroundSettings(self,useGradient,backgroundColor,gradientColor)

            self.setBackgroundColor(backgroundColor);
            self.setGradientColor(gradientColor);
            self.setBackgroundGradient(useGradient);

            if self.BackgroundGradient.Value
                self.GradientColor.Enabled=true;
            else
                self.GradientColor.Enabled=false;
            end

        end


        function TF=getShowRenderingEditor(self)
            TF=self.RenderingEditor.Value;
        end


        function setRenderingPreset(self,renderingPrest)

            galleryBtnTag=string(renderingPrest);
            btn=findobj([self.PresetsRenderings,self.UserDefinedRenderings],'Tag',galleryBtnTag);
            btn.Value=true;

            if renderingPrest==medical.internal.app.labeler.model.PresetRenderingOptions.CustomPreset
                self.CustomPresetButton.Enabled=true;
            else
                self.CustomPresetButton.Enabled=false;
            end

        end


        function addUserDefinedRendering(self,tag,renderingName)

            category=self.UserDefinedCategory;
            btnGroup=self.PresetsCategory.Children(1).ButtonGroup;

            for i=1:length(tag)

                icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','CustomPreset_24.png');
                newItem=matlab.ui.internal.toolstrip.ToggleGalleryItem(renderingName(i),icon,btnGroup);
                newItem.Tag=tag(i);

                category.add(newItem);
                self.UserDefinedRenderings(end+1)=newItem;

                addlistener(newItem,'ValueChanged',@(src,~)self.userDefinedRenderingSettingChanged(src));

                self.ManageCustomRendering.Enabled=true;

            end

        end


        function refreshUserDefinedRenderings(self,tag,renderingName)

            if~isempty(self.UserDefinedRenderings)
                delete(self.UserDefinedRenderings)
            end

            self.addUserDefinedRendering(tag,renderingName)

        end


        function removeUserDefinedRendering(self,tag)

            currentButtonBeingDeleted=false;


            btn=findobj(self.UserDefinedRenderings,'Tag',tag);
            btnIdx=find(self.UserDefinedRenderings==btn);



            if btn.Value
                currentButtonBeingDeleted=true;
            end


            self.UserDefinedCategory.remove(self.UserDefinedRenderings(btnIdx));
            self.UserDefinedRenderings(btnIdx)=[];

            if isempty(self.UserDefinedRenderings)
                self.ManageCustomRendering.Enabled=false;
            end


            if currentButtonBeingDeleted


                self.CustomPresetButton.Enabled=true;
                self.CustomPresetButton.Value=true;
            end

        end


        function enableShowLabels(self)
            self.ShowLabels.Enabled=true;
        end


        function disableShowLabels(self)
            self.ShowLabels.Enabled=false;
        end


        function setRenderingEditor(self,TF)
            self.RenderingEditor.Value=TF;
        end

    end


    methods(Access=protected)


        function createTab(self)

            self.createShowSection();
            self.createRenderingPresetsSection();
            self.createColorSection();

        end


        function createShowSection(self)

            section=self.Tab.addSection(getString(message('medical:medicalLabeler:show')));


            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','ShowRenderingEditor_24.png');
            self.RenderingEditor=matlab.ui.internal.toolstrip.ToggleButton(getString(message('medical:medicalLabeler:renderingEditor')),icon);
            self.RenderingEditor.Value=false;
            self.RenderingEditor.Tag=string(medical.internal.app.labeler.enums.Tag.RenderingEditor);
            self.RenderingEditor.Description=getString(message('medical:medicalLabeler:renderingEditorDescription'));
            self.RenderingEditor.Enabled=false;
            addlistener(self.RenderingEditor,'ValueChanged',@(~,~)self.renderingEditorToggled());

            column=section.addColumn();
            column.add(self.RenderingEditor);

        end


        function createRenderingPresetsSection(self)

            section=self.Tab.addSection(getString(message('medical:medicalLabeler:renderingPresets')));


            self.createPresetsGallary();
            column=section.addColumn();
            column.add(self.PresetsGallery);



            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','SaveRendering_16.png');
            saveRendering=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:saveRendering')),icon);
            saveRendering.Tag=string(medical.internal.app.labeler.enums.Tag.SaveRenderingItem);
            saveRendering.ShowDescription=false;
            addlistener(saveRendering,'ItemPushed',@(~,~)self.notify('SaveRenderingRequested'));


            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','Settings_16.png');
            self.ManageCustomRendering=matlab.ui.internal.toolstrip.ListItem(getString(message('medical:medicalLabeler:manageCustomRendering')),icon);
            self.ManageCustomRendering.Tag=string(medical.internal.app.labeler.enums.Tag.ManageRendering);
            self.ManageCustomRendering.Enabled=false;
            addlistener(self.ManageCustomRendering,'ItemPushed',@(~,~)self.manageCustomRenderingPressed());

            saveRenderingPopup=matlab.ui.internal.toolstrip.PopupList();
            saveRenderingPopup.add(saveRendering);
            saveRenderingPopup.addSeparator();
            saveRenderingPopup.add(self.ManageCustomRendering);

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','SaveRendering_24.png');
            self.SaveRendering=matlab.ui.internal.toolstrip.SplitButton(getString(message('medical:medicalLabeler:saveRendering')),icon);
            self.SaveRendering.Tag=string(medical.internal.app.labeler.enums.Tag.SaveRendering);
            self.SaveRendering.Popup=saveRenderingPopup;
            self.SaveRendering.Description=getString(message('medical:medicalLabeler:saveRenderingDescription'));
            self.SaveRendering.Enabled=false;
            addlistener(self.SaveRendering,'ButtonPushed',@(~,~)self.notify('SaveRenderingRequested'));

            column=section.addColumn();
            column.add(self.SaveRendering);


            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','ApplyRendering_24.png');
            self.ApplyToAll=matlab.ui.internal.toolstrip.Button(getString(message('medical:medicalLabeler:applyToAllVolumes')),icon);
            self.ApplyToAll.Tag=string(medical.internal.app.labeler.enums.Tag.ApplyToAllVolumes);
            self.ApplyToAll.Description=getString(message('medical:medicalLabeler:applyToAllVolumesDescription'));
            self.ApplyToAll.Enabled=false;
            addlistener(self.ApplyToAll,'ButtonPushed',@(~,~)self.notify('ApplyRenderingToAllVolumes'));

            column=section.addColumn();
            column.add(self.ApplyToAll);

        end


        function createColorSection(self)

            section=self.Tab.addSection(getString(message('medical:medicalLabeler:color')));

            s=settings;
            backgroundGradient=s.medical.apps.volume.BackgroundGradient.ActiveValue;


            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','UseGradient_24.png');
            self.BackgroundGradient=matlab.ui.internal.toolstrip.ToggleButton(getString(message('medical:medicalLabeler:backgroundGradient')),icon);
            self.BackgroundGradient.Tag=string(medical.internal.app.labeler.enums.Tag.BackgroundGradient);
            self.BackgroundGradient.Description=getString(message('medical:medicalLabeler:backgroundGradientDescription'));
            self.BackgroundGradient.Value=backgroundGradient;
            self.BackgroundGradient.Enabled=false;

            column=section.addColumn();
            column.add(self.BackgroundGradient);


            self.BackgroundColor=matlab.ui.internal.toolstrip.Button(getString(message('medical:medicalLabeler:backgroundColor')));
            self.BackgroundColor.Tag=string(medical.internal.app.labeler.enums.Tag.BackgroundColor);
            self.BackgroundColor.Description=getString(message('medical:medicalLabeler:backgroundColorDescription'));
            self.BackgroundColor.Enabled=false;


            self.GradientColor=matlab.ui.internal.toolstrip.Button(getString(message('medical:medicalLabeler:gradientColor')));
            self.GradientColor.Tag=string(medical.internal.app.labeler.enums.Tag.GradientColor);
            self.GradientColor.Description=getString(message('medical:medicalLabeler:gradientColorDescription'));
            self.GradientColor.Enabled=false;

            column=section.addColumn();
            column.add(self.BackgroundColor);
            column.add(self.GradientColor);


            icon=matlab.ui.internal.toolstrip.Icon.RESTORE_24;
            self.RestoreBackground=matlab.ui.internal.toolstrip.Button(getString(message('medical:medicalLabeler:restoreBackground')),icon);
            self.RestoreBackground.Tag=string(medical.internal.app.labeler.enums.Tag.RestoreBackground);
            self.RestoreBackground.Description=getString(message('medical:medicalLabeler:restoreBackgroundDescription'));
            self.RestoreBackground.Enabled=false;

            column=section.addColumn();
            column.add(self.RestoreBackground);

            addlistener(self.BackgroundGradient,'ValueChanged',@(~,~)self.backgroundGradientToggled());
            addlistener(self.BackgroundColor,'ButtonPushed',@(~,~)self.notify('BackgroundColorChangeRequested'));
            addlistener(self.GradientColor,'ButtonPushed',@(~,~)self.notify('GradientColorChangeRequested'));
            addlistener(self.RestoreBackground,'ButtonPushed',@(~,~)self.notify('RestoreBackgroundRequested'));

        end


        function createPresetsGallary(self)


            group=matlab.ui.internal.toolstrip.ButtonGroup();


            self.PresetsCategory=matlab.ui.internal.toolstrip.GalleryCategory(getString(message('medical:medicalLabeler:renderingPresets')));

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','LinearGrayscale_24.png');
            linearGrayscale=matlab.ui.internal.toolstrip.ToggleGalleryItem(getString(message('medical:medicalLabeler:linearGrayscale')),icon,group);
            linearGrayscale.Value=true;
            linearGrayscale.Tag=string(medical.internal.app.labeler.model.PresetRenderingOptions.LinearGrayscale);
            self.PresetsRenderings(end+1)=linearGrayscale;

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','MRI_24.png');
            mri=matlab.ui.internal.toolstrip.ToggleGalleryItem(getString(message('medical:medicalLabeler:mri')),icon,group);
            mri.Value=false;
            mri.Tag=string(medical.internal.app.labeler.model.PresetRenderingOptions.MRI);
            self.PresetsRenderings(end+1)=mri;

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','CTBone_24.png');
            ctBone=matlab.ui.internal.toolstrip.ToggleGalleryItem(getString(message('medical:medicalLabeler:ctBone')),icon,group);
            ctBone.Value=false;
            ctBone.Tag=string(medical.internal.app.labeler.model.PresetRenderingOptions.CT_Bone);
            self.PresetsRenderings(end+1)=ctBone;

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','CTLung_24.png');
            ctLung=matlab.ui.internal.toolstrip.ToggleGalleryItem(getString(message('medical:medicalLabeler:ctLung')),icon,group);
            ctLung.Value=false;
            ctLung.Tag=string(medical.internal.app.labeler.model.PresetRenderingOptions.CT_Lung);
            self.PresetsRenderings(end+1)=ctLung;

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','CTSoftTissue_24.png');
            ctSoftTissue=matlab.ui.internal.toolstrip.ToggleGalleryItem(getString(message('medical:medicalLabeler:ctSoftTissue')),icon,group);
            ctSoftTissue.Value=false;
            ctSoftTissue.Tag=string(medical.internal.app.labeler.model.PresetRenderingOptions.CT_SoftTissue);
            self.PresetsRenderings(end+1)=ctSoftTissue;

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','CTCoronary_24.png');
            ctCoronary=matlab.ui.internal.toolstrip.ToggleGalleryItem(getString(message('medical:medicalLabeler:ctCoronary')),icon,group);
            ctCoronary.Value=false;
            ctCoronary.Tag=string(medical.internal.app.labeler.model.PresetRenderingOptions.CT_Coronary);
            self.PresetsRenderings(end+1)=ctCoronary;

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','MRI_MIP_24.png');
            mriMIP=matlab.ui.internal.toolstrip.ToggleGalleryItem(getString(message('medical:medicalLabeler:mriMIP')),icon,group);
            mriMIP.Value=false;
            mriMIP.Tag=string(medical.internal.app.labeler.model.PresetRenderingOptions.MRI_MIP);
            self.PresetsRenderings(end+1)=mriMIP;

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','CT_MIP_24.png');
            ctMIP=matlab.ui.internal.toolstrip.ToggleGalleryItem(getString(message('medical:medicalLabeler:ctMIP')),icon,group);
            ctMIP.Value=false;
            ctMIP.Tag=string(medical.internal.app.labeler.model.PresetRenderingOptions.CT_MIP);
            self.PresetsRenderings(end+1)=ctMIP;

            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','CustomPreset_24.png');
            custom=matlab.ui.internal.toolstrip.ToggleGalleryItem(getString(message('medical:medicalLabeler:custom')),icon,group);
            custom.Value=false;
            custom.Tag=string(medical.internal.app.labeler.model.PresetRenderingOptions.CustomPreset);
            custom.Enabled=false;
            self.CustomPresetButton=custom;
            self.PresetsRenderings(end+1)=custom;


            self.PresetsCategory.add(linearGrayscale);
            self.PresetsCategory.add(mri);
            self.PresetsCategory.add(ctBone);
            self.PresetsCategory.add(ctLung);
            self.PresetsCategory.add(ctSoftTissue);
            self.PresetsCategory.add(ctCoronary);

            self.PresetsCategory.add(mriMIP);
            self.PresetsCategory.add(ctMIP);

            self.PresetsCategory.add(custom);



            self.UserDefinedCategory=matlab.ui.internal.toolstrip.GalleryCategory(getString(message('medical:medicalLabeler:userDefined')));


            popup=matlab.ui.internal.toolstrip.GalleryPopup('ShowSelection',true,'FavoritesEnabled',true);
            popup.add(self.PresetsCategory);
            popup.add(self.UserDefinedCategory);


            self.PresetsGallery=matlab.ui.internal.toolstrip.Gallery(popup,'MaxColumnCount',3,'MinColumnCount',3);
            self.PresetsGallery.Enabled=false;
            self.PresetsGallery.Tag=string(medical.internal.app.labeler.enums.Tag.Presets);

            addlistener(self.PresetsRenderings,'ValueChanged',@(src,~)self.presetRenderingSettingChanged(src));

        end

    end


    methods(Access=private)


        function renderingEditorToggled(self)

            evtData=medical.internal.app.labeler.events.ValueEventData(self.RenderingEditor.Value);
            self.notify('RenderingEditorToggled',evtData);

        end


        function manageCustomRenderingPressed(self)

            if isempty(self.UserDefinedCategory)
                return
            end

            numCustomRenderings=numel(self.UserDefinedRenderings);

            name=repmat("",[1,numCustomRenderings]);
            tag=repmat("",[1,numCustomRenderings]);

            for idx=1:numel(self.UserDefinedRenderings)
                name(idx)=self.UserDefinedRenderings(idx).Text;
                tag(idx)=self.UserDefinedRenderings(idx).Tag;
            end

            evt=medical.internal.app.labeler.events.ManageCustomRenderingEventData(name,tag);
            self.notify('ManageRenderingRequested',evt);

        end


        function backgroundGradientToggled(self)

            evtData=medical.internal.app.labeler.events.ValueEventData(self.BackgroundGradient.Value);
            self.notify('BackgroundGradientToggled',evtData);

            if self.BackgroundGradient.Value
                self.GradientColor.Enabled=true;
            else
                self.GradientColor.Enabled=false;
            end

        end


        function presetRenderingSettingChanged(self,src)


            if~src.Value
                return
            end

            self.CustomPresetButton.Enabled=false;

            preset=renderingPresetTagToEnum(src.Tag);

            evtData=medical.internal.app.labeler.events.ValueEventData(preset);
            self.notify('PresetRenderingRequested',evtData);

        end


        function userDefinedRenderingSettingChanged(self,src)


            if~src.Value
                return
            end

            self.CustomPresetButton.Enabled=false;

            evtData=medical.internal.app.labeler.events.ValueEventData(src.Tag);
            self.notify('UserDefinedRenderingRequested',evtData);

        end

    end

end

function preset=renderingPresetTagToEnum(tag)

    switch string(tag)

    case string(medical.internal.app.labeler.model.PresetRenderingOptions.LinearGrayscale)
        preset=medical.internal.app.labeler.model.PresetRenderingOptions.LinearGrayscale;

    case string(medical.internal.app.labeler.model.PresetRenderingOptions.MRI)
        preset=medical.internal.app.labeler.model.PresetRenderingOptions.MRI;

    case string(medical.internal.app.labeler.model.PresetRenderingOptions.CT_Bone)
        preset=medical.internal.app.labeler.model.PresetRenderingOptions.CT_Bone;

    case string(medical.internal.app.labeler.model.PresetRenderingOptions.CT_Lung)
        preset=medical.internal.app.labeler.model.PresetRenderingOptions.CT_Lung;

    case string(medical.internal.app.labeler.model.PresetRenderingOptions.CT_SoftTissue)
        preset=medical.internal.app.labeler.model.PresetRenderingOptions.CT_SoftTissue;

    case string(medical.internal.app.labeler.model.PresetRenderingOptions.CT_Coronary)
        preset=medical.internal.app.labeler.model.PresetRenderingOptions.CT_Coronary;

    case string(medical.internal.app.labeler.model.PresetRenderingOptions.MRI_MIP)
        preset=medical.internal.app.labeler.model.PresetRenderingOptions.MRI_MIP;

    case string(medical.internal.app.labeler.model.PresetRenderingOptions.CT_MIP)
        preset=medical.internal.app.labeler.model.PresetRenderingOptions.CT_MIP;

    case string(medical.internal.app.labeler.model.PresetRenderingOptions.CustomPreset)
        preset=medical.internal.app.labeler.model.PresetRenderingOptions.CustomPreset;

    otherwise
        preset=string(tag);

    end

end
