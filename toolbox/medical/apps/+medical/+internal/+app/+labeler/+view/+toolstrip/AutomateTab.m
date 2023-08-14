classdef AutomateTab<images.internal.app.segmenter.volume.display.AutomateTab




    properties(Access=protected)

SliceDirectionLabel
SliceDirection

DirectionSection
SliceDirectionColumn

Help

    end

    properties(Access=protected,Dependent)
SliceDirectionNeeded
    end

    events
AutomationDirectionUpdated
ViewAutomationHelp
    end

    methods

        function self=AutomateTab()

            showMetrics=false;
            self@images.internal.app.segmenter.volume.display.AutomateTab(showMetrics);

        end


        function setup(self,dataFormat)

            switch dataFormat

            case medical.internal.app.labeler.enums.DataFormat.Volume


                if isempty(self.DirectionSection.find(self.SliceDirectionColumn.Tag))
                    self.DirectionSection.add(self.SliceDirectionColumn,1);
                end


                if isempty(self.Gallery.Popup.find(self.VolumeCategory.Tag))
                    self.Gallery.Popup.add(self.VolumeCategory);
                end


                self.NewVolume.Enabled=true;
                self.VolumeFromFile.Enabled=true;

            case medical.internal.app.labeler.enums.DataFormat.Image


                if~isempty(self.DirectionSection.find(self.SliceDirectionColumn.Tag))
                    self.DirectionSection.remove(self.SliceDirectionColumn);
                end


                if~isempty(self.Gallery.Popup.find(self.VolumeCategory.Tag))
                    self.Gallery.Popup.remove(self.VolumeCategory);
                end


                self.NewVolume.Enabled=false;
                self.VolumeFromFile.Enabled=false;

            otherwise
                error('Invalid mode, should never reach here')

            end

        end


        function setIsCurrentDataOblique(self,TF)

            if TF
                directions={...
                medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Coronal);...
                medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Sagittal);...
                medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Transverse)};
            else

                directions={...
                getString(message('medical:medicalLabeler:coronal'));...
                getString(message('medical:medicalLabeler:sagittal'));...
                getString(message('medical:medicalLabeler:transverse'))};

            end

            self.SliceDirection.replaceAllItems(directions);

        end


        function enable(self)

            self.Add.Enabled=true;
            self.Gallery.Enabled=true;

            if isempty(self.SelectedAlgorithm)

                self.Run.Enabled=false;
                self.SliceDirection.Enabled=false;
                self.SliceDirectionLabel.Enabled=false;
                disableRange(self);

            elseif self.IsAlgorithmVolumeBased

                self.Run.Enabled=true;
                self.SliceDirection.Enabled=false;
                self.SliceDirectionLabel.Enabled=false;
                enableRange(self);

            else

                if self.SliceDirectionNeeded

                    self.SliceDirection.Enabled=true;
                    self.SliceDirectionLabel.Enabled=true;

                    if self.SliceDirection.SelectedIndex==-1
                        disableRange(self);
                        self.Run.Enabled=false;
                    else
                        enableRange(self);
                        self.Run.Enabled=true;
                    end

                else
                    enableRange(self);
                    self.Run.Enabled=true;
                end

            end

            self.Stop.Enabled=false;
            self.Help.Enabled=true;

            enableSettings(self);

        end


        function disable(self)

            self.Add.Enabled=false;
            self.Gallery.Enabled=false;
            self.Run.Enabled=false;
            self.Stop.Enabled=false;
            self.Settings.Enabled=false;

            self.Help.Enabled=false;

            self.SliceDirection.Enabled=false;
            self.SliceDirectionLabel.Enabled=false;

            disableRange(self);

        end


        function disableDuringAutomation(self)

            self.Add.Enabled=false;
            self.Gallery.Enabled=false;
            self.Run.Enabled=false;
            self.Stop.Enabled=true;
            self.Settings.Enabled=false;

            self.Help.Enabled=false;

            self.SliceDirection.Enabled=false;
            self.SliceDirectionLabel.Enabled=false;

            disableRange(self);

        end


        function displayAutomationRangeMedicalApp(self,currentSlice,maxSlice,sliceDir)

            if self.SliceDirectionNeeded

                if~self.SliceDirection.Enabled||~strcmpi(self.SliceDirection.Value,string(sliceDir))
                    return
                end

            end

            switch self.Window.SelectedIndex

            case 1
                self.Start.Value=num2str(currentSlice);
                self.End.Value=num2str(currentSlice);
            case 2
                self.Start.Value=num2str(currentSlice);
                self.End.Value=num2str(1);
            case 3
                self.Start.Value=num2str(currentSlice);
                self.End.Value=num2str(maxSlice);
            end

            self.WindowCurrent=currentSlice;
            self.WindowMax=maxSlice;

            notify(self,'AutomationRangeUpdated',images.internal.app.segmenter.volume.events.AutomationRangeEventData(str2double(self.Start.Value),str2double(self.End.Value)));

        end

    end

    methods(Access=protected)


        function createTab(self)

            self.createAddAlgorithmSection();
            self.createDirectionSection();
            self.createRunSection();
            self.createHelpSection();

        end


        function setSettingsSource(self)

            self.SliceAlgoSettingsSource=@()settings().medical.apps.labeler.SliceAlgorithmList;
            self.VolumeAlgoSettingsSource=@()settings().medical.apps.labeler.VolumeAlgorithmList;
            self.GalleryFavoriteSettingsSource=@()settings().medical.apps.labeler.AutomationGalleryFavorites;

        end


        function newSliceClassTemplate(self)

            templateFile=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+automation','+template','sliceClass.template');
            codeString=fileread(templateFile);
            codeString=strrep(codeString,'Volume Segmenter','Medical Image Labeler');
            codeString=strrep(codeString,'Image Processing','Medical Image Processing');

            self.UnsavedTemplates(end+1)=matlab.desktop.editor.newDocument(codeString);
            self.IsUnsavedTemplateVolume(end+1)=false;

            startTimer(self);

        end


        function newSliceFunctionTemplate(self)

            templateFile=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+automation','+template','sliceFunction.template');
            codeString=fileread(templateFile);
            codeString=strrep(codeString,'Volume Segmenter','Medical Image Labeler');
            codeString=strrep(codeString,'Image Processing','Medical Image Processing');

            self.UnsavedTemplates(end+1)=matlab.desktop.editor.newDocument(codeString);
            self.IsUnsavedTemplateVolume(end+1)=false;

            startTimer(self);

        end


        function newVolumeClassTemplate(self)

            templateFile=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+automation','+template','volumeClass.template');
            codeString=fileread(templateFile);
            codeString=strrep(codeString,'Volume Segmenter','Medical Image Labeler');
            codeString=strrep(codeString,'Image Processing','Medical Image Processing');

            self.UnsavedTemplates(end+1)=matlab.desktop.editor.newDocument(codeString);
            self.IsUnsavedTemplateVolume(end+1)=true;

            startTimer(self);

        end


        function newVolumeFunctionTemplate(self)

            templateFile=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+automation','+template','volumeFunction.template');
            codeString=fileread(templateFile);
            codeString=strrep(codeString,'Volume Segmenter','Medical Image Labeler');
            codeString=strrep(codeString,'Image Processing','Medical Image Processing');

            self.UnsavedTemplates(end+1)=matlab.desktop.editor.newDocument(codeString);
            self.IsUnsavedTemplateVolume(end+1)=true;

            startTimer(self);

        end


        function runAutomation(self,evt)

            if isfile(evt.Source.Tag)
                [~,name]=images.internal.app.segmenter.volume.automation.getFileParts(evt.Source.Tag);
                self.SelectedAlgorithm=name;
            else
                self.SelectedAlgorithm=evt.Source.Tag;
            end

            self.IsAlgorithmVolumeBased=evt.Source.Parent==self.VolumeCategory;

            evt.Source.Value=true;

            deselectAllOtherGalleryItems(self,evt.Source);

            enable(self);

        end


        function createDirectionSection(self)

            import medical.internal.app.labeler.enums.Tag;

            section=addSection(self.Tab,getString(message('images:segmenter:direction')));
            self.DirectionSection=section;
            self.DirectionSection.Tag='DirectionSection';


            self.SliceDirectionLabel=matlab.ui.internal.toolstrip.Label(getString(message('medical:medicalLabeler:sliceDirection')));
            self.SliceDirectionLabel.Tag=string(Tag.SliceDirectionLabel);

            directions={...
            getString(message('medical:medicalLabeler:coronal'));...
            getString(message('medical:medicalLabeler:sagittal'));...
            getString(message('medical:medicalLabeler:transverse'))};
            self.SliceDirection=matlab.ui.internal.toolstrip.DropDown(directions);
            self.SliceDirection.Description=getString(message('medical:medicalLabeler:sliceDirection'));
            self.SliceDirection.Tag=string(Tag.SliceDirection);
            self.SliceDirection.SelectedIndex=-1;
            self.SliceDirection.PlaceholderText=strcat(getString(message('medical:medicalLabeler:select')),'...');

            column=self.DirectionSection.addColumn('Width',120);
            column.add(self.SliceDirectionLabel);
            column.add(self.SliceDirection);
            self.SliceDirectionColumn=column;
            self.SliceDirectionColumn.Tag='SliceDirectionColumn';


            self.DirectionSection.addColumn('Width',10);


            spaceLabel=matlab.ui.internal.toolstrip.Label(' ');

            self.StartLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:startSlice')));
            self.StartLabel.Tag=string(Tag.StartLabel);

            self.EndLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:endSlice')));
            self.EndLabel.Tag=string(Tag.EndLabel);

            column=section.addColumn();
            column.add(spaceLabel);
            column.add(self.StartLabel);
            column.add(self.EndLabel)


            self.Window=matlab.ui.internal.toolstrip.DropDown({getString(message('images:segmenter:currentSlice'));getString(message('images:segmenter:beginningToCurrent'));getString(message('images:segmenter:currentToEnd'))});
            self.Window.Description=getString(message('images:segmenter:windowPresetsTooltip'));
            self.Window.Tag=string(Tag.Window);
            self.Window.SelectedIndex=1;
            self.Window.PlaceholderText=getString(message('medical:medicalLabeler:customRange'));

            self.Start=matlab.ui.internal.toolstrip.EditField();
            self.Start.Description=getString(message('images:segmenter:windowStartTooltip'));
            self.Start.Tag=string(Tag.Start);

            self.End=matlab.ui.internal.toolstrip.EditField();
            self.End.Description=getString(message('images:segmenter:windowEndTooltip'));
            self.End.Tag=string(Tag.End);

            column=section.addColumn('Width',150);
            column.add(self.Window);
            column.add(self.Start);
            column.add(self.End);

            addlistener(self.SliceDirection,'ValueChanged',@(~,~)sliceDirectionUpdated(self));
            addlistener(self.Window,'ValueChanged',@(~,~)dropDownUpdated(self));
            addlistener(self.Start,'ValueChanged',@(~,~)rangeUpdated(self));
            addlistener(self.End,'ValueChanged',@(~,~)rangeUpdated(self));

        end


        function createHelpSection(self)

            section=addSection(self.Tab,getString(message('medical:medicalLabeler:help')));

            icon=matlab.ui.internal.toolstrip.Icon.HELP_24;
            self.Help=matlab.ui.internal.toolstrip.Button(getString(message('medical:medicalLabeler:howToAutomate')),icon);
            self.Help.Tag=string(medical.internal.app.labeler.enums.Tag.HowToAutomate);
            self.Help.Description=getString(message('medical:medicalLabeler:howToAutomateDescription'));

            column=section.addColumn();
            column.add(self.Help);

            addlistener(self.Help,'ButtonPushed',@(src,evt)self.notify('ViewAutomationHelp'));

        end

    end


    methods(Access=protected)


        function sliceDirectionUpdated(self)

            if self.SliceDirection.SelectedIndex~=-1

                switch self.SliceDirection.Value

                case{getString(message('medical:medicalLabeler:transverse')),...
                    medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Transverse)}
                    sliceDirection=medical.internal.app.labeler.enums.SliceDirection.Transverse;

                case{getString(message('medical:medicalLabeler:sagittal')),...
                    medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Sagittal)}
                    sliceDirection=medical.internal.app.labeler.enums.SliceDirection.Sagittal;

                case{getString(message('medical:medicalLabeler:coronal')),...
                    medical.internal.app.labeler.utils.ras2Direction(medical.internal.app.labeler.enums.SliceDirection.Coronal)}
                    sliceDirection=medical.internal.app.labeler.enums.SliceDirection.Coronal;

                end

                self.enableRange();
                self.Run.Enabled=true;

                evt=medical.internal.app.labeler.events.ValueEventData(sliceDirection);
                self.notify('AutomationDirectionUpdated',evt);



                self.dropDownUpdated();

            else
                self.disableRange();
                self.Run.Enabled=false;
            end

        end

    end


    methods


        function TF=get.SliceDirectionNeeded(self)
            TF=~isempty(self.DirectionSection.find(self.SliceDirectionColumn.Tag));
        end

    end

end
