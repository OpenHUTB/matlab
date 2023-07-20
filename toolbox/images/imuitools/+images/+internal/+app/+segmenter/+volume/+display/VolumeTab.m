classdef VolumeTab<handle




    events


SpatialReferencingChanged


ColorChanged


GradientColorChanged


UseGradientChanged



RenderingChanged


OrientationAxesChanged



ShowLabelsInVolume



RegenerateOverview



OverviewSettingsChanged

    end


    properties(SetAccess=protected,Hidden,Transient)

Tab

    end


    properties(Transient,SetAccess=protected,GetAccess={...
        ?images.uitest.factory.Tester,...
        ?uitest.factory.Tester,...
        ?medical.internal.app.home.labeler.display.toolstrip.VolumeTab})

        X matlab.ui.internal.toolstrip.EditField
        Y matlab.ui.internal.toolstrip.EditField
        Z matlab.ui.internal.toolstrip.EditField
        Color matlab.ui.internal.toolstrip.Button
        GradientColor matlab.ui.internal.toolstrip.Button
        UseGradient matlab.ui.internal.toolstrip.CheckBox
        Threshold matlab.ui.internal.toolstrip.Slider
        Opacity matlab.ui.internal.toolstrip.Slider
        Restore matlab.ui.internal.toolstrip.Button
        Show matlab.ui.internal.toolstrip.DropDownButton
        OrientationAxes matlab.ui.internal.toolstrip.ToggleButton
        Wireframe matlab.ui.internal.toolstrip.ToggleButton

        GenerateOverview matlab.ui.internal.toolstrip.Button
        ShowHistory matlab.ui.internal.toolstrip.ToggleButton
        ShowCompleted matlab.ui.internal.toolstrip.ToggleButton
        ShowCurrent matlab.ui.internal.toolstrip.ToggleButton
        ShowHistoryLabel matlab.ui.internal.toolstrip.Label
        ShowCompletedLabel matlab.ui.internal.toolstrip.Label
        ShowCurrentLabel matlab.ui.internal.toolstrip.Label

LabelSection

IconSize
ShowGradientTools

    end


    properties(Access=protected,Transient)

        Visible(1,1)logical=true;

    end


    methods




        function self=VolumeTab(show3DDisplay,useWebVersion)

            if~show3DDisplay
                self.Visible=false;
                return;
            end

            if useWebVersion
                self.IconSize=16;
                self.ShowGradientTools=true;
            else
                self.IconSize=24;
                self.ShowGradientTools=false;
            end

            self.Tab=matlab.ui.internal.toolstrip.Tab(getString(message('images:segmenter:volumeTab')));
            self.Tab.Tag='VolumeTab';

            createTab(self,useWebVersion);

        end




        function enable(self,isBlockedImage)

            if self.Visible

                self.X.Editable=true;
                self.Y.Editable=true;
                self.Z.Editable=true;
                self.X.Enabled=true;
                self.Y.Enabled=true;
                self.Z.Enabled=true;
                self.Color.Enabled=true;
                self.UseGradient.Enabled=true;
                self.GradientColor.Enabled=self.UseGradient.Value;
                self.Threshold.Enabled=true;
                self.Opacity.Enabled=true;
                self.Restore.Enabled=true;
                self.Show.Enabled=true;
                self.OrientationAxes.Enabled=true;
                self.Wireframe.Enabled=true;

                self.ShowCompleted.Enabled=isBlockedImage;
                self.ShowHistory.Enabled=isBlockedImage;
                self.ShowCurrent.Enabled=isBlockedImage;
                self.ShowCompletedLabel.Enabled=isBlockedImage;
                self.ShowHistoryLabel.Enabled=isBlockedImage;
                self.ShowCurrentLabel.Enabled=isBlockedImage;
                self.GenerateOverview.Enabled=isBlockedImage;

            end

        end




        function disable(self)

            if self.Visible

                self.X.Editable=false;
                self.Y.Editable=false;
                self.Z.Editable=false;
                self.X.Enabled=false;
                self.Y.Enabled=false;
                self.Z.Enabled=false;
                self.Color.Enabled=false;
                self.UseGradient.Enabled=false;
                self.GradientColor.Enabled=false;
                self.Threshold.Enabled=false;
                self.Opacity.Enabled=false;
                self.Restore.Enabled=false;
                self.Show.Enabled=false;
                self.OrientationAxes.Enabled=false;
                self.Wireframe.Enabled=false;
                self.ShowCompleted.Enabled=false;
                self.ShowHistory.Enabled=false;
                self.ShowCurrent.Enabled=false;
                self.ShowCompletedLabel.Enabled=false;
                self.ShowHistoryLabel.Enabled=false;
                self.ShowCurrentLabel.Enabled=false;
                self.GenerateOverview.Enabled=false;

            end

        end




        function setColor(self,color)

            if self.Visible

                img=zeros(self.IconSize,self.IconSize,3);
                img(:,:,1)=color(1);
                img(:,:,2)=color(2);
                img(:,:,3)=color(3);

                self.Color.Icon=matlab.ui.internal.toolstrip.Icon(im2uint8(img));

            end

        end




        function setGradientColor(self,color)

            if self.Visible

                img=zeros(self.IconSize,self.IconSize,3);
                img(:,:,1)=color(1);
                img(:,:,2)=color(2);
                img(:,:,3)=color(3);

                self.GradientColor.Icon=matlab.ui.internal.toolstrip.Icon(im2uint8(img));

            end

        end




        function setUseGradient(self,val)

            if self.Visible

                self.UseGradient.Value=val;

            end

        end




        function setRendering(self,thresh,alpha)

            if self.Visible

                self.Threshold.Value=thresh;
                self.Opacity.Value=alpha;

            end

        end




        function setSpatialReferencing(self,x,y,z)

            if self.Visible

                self.X.Value=num2str(x);
                self.Y.Value=num2str(y);
                self.Z.Value=num2str(z);

            end

        end




        function setWireframe(self,TF)

            if self.Visible

                self.Wireframe.Value=TF;
                orientationAxesChanged(self);

            end

        end




        function enableBlockedLabels(self,TF)

            if self.Visible
                if TF
                    self.LabelSection.Title=getString(message('images:segmenter:display3DBlockTitle'));
                else
                    self.LabelSection.Title=getString(message('images:segmenter:labelsTitle'));
                end
            end

        end




        function overviewSettingsChanged(self)

            if self.Visible
                notify(self,'OverviewSettingsChanged',images.internal.app.segmenter.volume.events.BlockOverviewSettingsEventData(...
                self.ShowCurrent.Value,self.ShowHistory.Value,self.ShowCompleted.Value));
            end

        end

    end


    methods(Access=protected)


        function restoreDefaults(self)

            self.OrientationAxes.Value=true;
            self.Wireframe.Value=false;
            setColor(self,[0.0,0.329,0.529]);
            if self.ShowGradientTools
                setGradientColor(self,[0.0,0.561,1.0]);
                self.UseGradient.Value=true;
                self.GradientColor.Enabled=true;
            end
            setSpatialReferencing(self,1,1,1);
            setRendering(self,30,25);

            orientationAxesChanged(self);
            notify(self,'ColorChanged',images.internal.app.segmenter.volume.events.BackgroundColorChangedEventData([0.0,0.329,0.529]));
            spatialReferencingChanged(self);
            renderingChanged(self);
            notify(self,'ShowLabelsInVolume',images.internal.app.segmenter.volume.events.ShowVolumeChangedEventData(true));

            if self.ShowGradientTools
                notify(self,'GradientColorChanged',images.internal.app.segmenter.volume.events.BackgroundColorChangedEventData([0.0,0.561,1.0]));
                notify(self,'UseGradientChanged',images.internal.app.segmenter.volume.events.BackgroundColorChangedEventData(true));
            end

        end


        function spatialReferencingChanged(self)

            notify(self,'SpatialReferencingChanged',images.internal.app.segmenter.volume.events.SpatialReferencingChangedEventData(...
            str2double(self.X.Value),...
            str2double(self.Y.Value),...
            str2double(self.Z.Value)));

        end


        function backgroundColorPressed(self)

            notify(self,'ColorChanged',images.internal.app.segmenter.volume.events.BackgroundColorChangedEventData([]));

        end


        function gradientColorPressed(self)

            notify(self,'GradientColorChanged',images.internal.app.segmenter.volume.events.BackgroundColorChangedEventData([]));

        end

        function useGradientValueChanged(self,val)

            if val
                self.GradientColor.Enabled=true;
            else
                self.GradientColor.Enabled=false;
            end

            notify(self,'UseGradientChanged',images.internal.app.segmenter.volume.events.BackgroundColorChangedEventData(val));

        end


        function renderingChanged(self)

            notify(self,'RenderingChanged',images.internal.app.segmenter.volume.events.RenderingChangedEventData(...
            self.Threshold.Value/100,self.Opacity.Value/100));

        end


        function orientationAxesChanged(self)

            notify(self,'OrientationAxesChanged',images.internal.app.segmenter.volume.events.OrientationAxesChangedEventData(...
            self.OrientationAxes.Value,self.Wireframe.Value));

        end

    end


    methods(Access=protected)


        function createTab(self,useWebVersion)

            createSpatialRefSection(self);
            createRenderingSection(self);
            createColorSection(self,useWebVersion);
            createRestoreSection(self);
            createLabelsSection(self);
            createOverviewSection(self);

            disable(self);

        end

        function createSpatialRefSection(self)


            section=addSection(self.Tab,getString(message('images:segmenter:spatialRef')));
            column=section.addColumn();


            xLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:volumeViewer:xAxisLabel')));
            xLabel.Tag="XLabel";
            column.add(xLabel);

            yLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:volumeViewer:yAxisLabel')));
            yLabel.Tag="YLabel";
            column.add(yLabel);

            zLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:volumeViewer:zAxisLabel')));
            zLabel.Tag="ZLabel";
            column.add(zLabel);

            column=section.addColumn('Width',70);


            self.X=matlab.ui.internal.toolstrip.EditField();
            self.X.Description=getString(message('images:segmenter:xAxisTooltip'));
            self.X.Tag='XRef';
            column.add(self.X);

            self.Y=matlab.ui.internal.toolstrip.EditField();
            self.Y.Description=getString(message('images:segmenter:yAxisTooltip'));
            self.Y.Tag='YRef';
            column.add(self.Y);

            self.Z=matlab.ui.internal.toolstrip.EditField();
            self.Z.Description=getString(message('images:segmenter:zAxisTooltip'));
            self.Z.Tag='ZRef';
            column.add(self.Z);

            self.X.Enabled=true;
            self.Y.Enabled=true;
            self.Z.Enabled=true;


            column=section.addColumn();

            xLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:volumeViewer:unitsLabel')));
            xLabel.Tag="XUnits";
            column.add(xLabel);

            yLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:volumeViewer:unitsLabel')));
            yLabel.Tag="YUnits";
            column.add(yLabel);

            zLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:volumeViewer:unitsLabel')));
            zLabel.Tag="ZUnits";
            column.add(zLabel);

            column=section.addColumn();

            self.OrientationAxes=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:orientationAxes')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_OrientationAxes_24.png')));
            self.OrientationAxes.Tag='OrientationAxes';
            self.OrientationAxes.Description=getString(message('images:segmenter:orientationAxesTooltip'));
            self.OrientationAxes.Value=true;
            column.add(self.OrientationAxes);

            column=section.addColumn();

            self.Wireframe=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:wireframe')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Wireframe_24.png')));
            self.Wireframe.Tag='Wireframe';
            self.Wireframe.Description=getString(message('images:segmenter:wireframeTooltip'));
            column.add(self.Wireframe);


            addlistener(self.X,'ValueChanged',@(~,~)spatialReferencingChanged(self));
            addlistener(self.Y,'ValueChanged',@(~,~)spatialReferencingChanged(self));
            addlistener(self.Z,'ValueChanged',@(~,~)spatialReferencingChanged(self));
            addlistener(self.OrientationAxes,'ValueChanged',@(~,~)orientationAxesChanged(self));
            addlistener(self.Wireframe,'ValueChanged',@(~,~)orientationAxesChanged(self));

        end

        function createRenderingSection(self)


            section=addSection(self.Tab,getString(message('images:segmenter:viewSettings')));


            thresholdLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:threshold')));
            opacityLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:opacity')));
            thresholdLabel.Tag="ThresholdLabel";
            opacityLabel.Tag="OpacityLabel";

            self.Threshold=matlab.ui.internal.toolstrip.Slider([0,100],30);
            self.Threshold.Compact=true;
            self.Threshold.Tag='Threshold';
            self.Threshold.Ticks=0;
            self.Threshold.Description=getString(message('images:segmenter:thresholdTooltip'));

            self.Opacity=matlab.ui.internal.toolstrip.Slider([0,100],25);
            self.Opacity.Compact=true;
            self.Opacity.Tag='Opacity';
            self.Opacity.Ticks=0;
            self.Opacity.Description=getString(message('images:segmenter:opacityTooltip'));

            column=section.addColumn('HorizontalAlignment','right');
            column.add(thresholdLabel);
            column.add(opacityLabel);

            column=section.addColumn('Width',120);
            column.add(self.Threshold);
            column.add(self.Opacity);


            addlistener(self.Threshold,'ValueChanged',@(~,~)renderingChanged(self));
            addlistener(self.Opacity,'ValueChanged',@(~,~)renderingChanged(self));

        end

        function createColorSection(self,useWebVersion)


            section=addSection(self.Tab,getString(message('images:segmenter:color')));
            column=section.addColumn();


            self.Color=matlab.ui.internal.toolstrip.Button(getString(message('images:segmenter:backgroundColor')));
            self.Color.Tag='BackgroundColor';
            self.Color.Description=getString(message('images:segmenter:backgroundColorTooltip'));
            column.add(self.Color);

            self.UseGradient=matlab.ui.internal.toolstrip.CheckBox(getString(message('images:volumeViewer:useGradientButtonLabel')));
            self.UseGradient.Tag='Use Gradient';
            self.UseGradient.Description=getString(message('images:volumeViewer:useGradientButtonDescription'));

            self.GradientColor=matlab.ui.internal.toolstrip.Button(getString(message('images:volumeViewer:gradientColorButtonLabel')));
            self.GradientColor.Tag='Gradient Color';
            self.GradientColor.Description=getString(message('images:volumeViewer:gradientColorButtonDescription'));

            if useWebVersion
                column.add(self.UseGradient);
                column.add(self.GradientColor);
                addlistener(self.UseGradient,'ValueChanged',@(hobj,evt)useGradientValueChanged(self,evt.EventData.NewValue));
                addlistener(self.GradientColor,'ButtonPushed',@(hobj,evt)gradientColorPressed(self));
            end


            addlistener(self.Color,'ButtonPushed',@(~,~)backgroundColorPressed(self));

        end

        function createRestoreSection(self)


            section=addSection(self.Tab,getString(message('images:segmenter:restore')));
            column=section.addColumn();


            self.Restore=matlab.ui.internal.toolstrip.Button(getString(message('images:segmenter:restoreDefault')),matlab.ui.internal.toolstrip.Icon.RESTORE_24);
            self.Restore.Tag='Restore';
            self.Restore.Description=getString(message('images:segmenter:restoreDefaultTooltip'));
            column.add(self.Restore);


            addlistener(self.Restore,'ButtonPushed',@(~,~)restoreDefaults(self));

        end

        function createLabelsSection(self)

            self.LabelSection=addSection(self.Tab,getString(message('images:segmenter:labelsTitle')));
            column=self.LabelSection.addColumn();


            showAll=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:showAllLabels')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_ShowLabels_16.png')));
            showAll.ShowDescription=false;
            showAll.Tag='ShowAll';
            addlistener(showAll,'ItemPushed',@(~,~)notify(self,'ShowLabelsInVolume',images.internal.app.segmenter.volume.events.ShowVolumeChangedEventData(true)));

            hideAll=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:hideAllLabels')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_HideLabels_16.png')));
            hideAll.ShowDescription=false;
            hideAll.Tag='HideAll';
            addlistener(hideAll,'ItemPushed',@(~,~)notify(self,'ShowLabelsInVolume',images.internal.app.segmenter.volume.events.ShowVolumeChangedEventData(false)));

            customizeLabels=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:showCustomLabels')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Customize_16.png')));
            customizeLabels.ShowDescription=false;
            customizeLabels.Tag='CustomizeLabels';
            addlistener(customizeLabels,'ItemPushed',@(~,~)notify(self,'ShowLabelsInVolume',images.internal.app.segmenter.volume.events.ShowVolumeChangedEventData(logical.empty)));

            popup=matlab.ui.internal.toolstrip.PopupList();

            add(popup,showAll);
            add(popup,hideAll);
            add(popup,customizeLabels);

            self.Show=matlab.ui.internal.toolstrip.DropDownButton(getString(message('images:segmenter:showLabels')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_ShowLabels_24.png')));
            self.Show.Tag='Show';
            self.Show.Description=getString(message('images:segmenter:showLabelsTooltip'));
            self.Show.Popup=popup;
            column.add(self.Show);

        end

        function createOverviewSection(self)


            section=addSection(self.Tab,getString(message('images:segmenter:overview')));
            column=section.addColumn();

            self.GenerateOverview=matlab.ui.internal.toolstrip.Button(getString(message('images:segmenter:generateOverview')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_CreateOverview_24.png')));
            self.GenerateOverview.Tag='GenerateOverview';
            self.GenerateOverview.Description=getString(message('images:segmenter:generateOverviewTooltip'));
            column.add(self.GenerateOverview);
            column=section.addColumn();

            self.ShowCurrent=matlab.ui.internal.toolstrip.ToggleButton("",...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_CurrentBlock_16.png')));
            self.ShowCurrent.Value=true;
            self.ShowCurrent.Tag='ShowCurrent';
            self.ShowCurrent.Description=getString(message('images:segmenter:showCurrentTooltip'));
            column.add(self.ShowCurrent);

            self.ShowHistory=matlab.ui.internal.toolstrip.ToggleButton("",...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_HistorySeen_16.png')));
            self.ShowHistory.Value=true;
            self.ShowHistory.Tag='ShowHistory';
            self.ShowHistory.Description=getString(message('images:segmenter:showHistoryTooltip'));
            column.add(self.ShowHistory);

            self.ShowCompleted=matlab.ui.internal.toolstrip.ToggleButton("",...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_ShowCompleted_16.png')));
            self.ShowCompleted.Value=true;
            self.ShowCompleted.Tag='ShowCompleted';
            self.ShowCompleted.Description=getString(message('images:segmenter:showCompletedTooltip'));
            column.add(self.ShowCompleted);

            column=section.addColumn();

            self.ShowCurrentLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:showCurrent')));
            self.ShowCurrentLabel.Tag='CurrentLabel';
            self.ShowCurrentLabel.Description=getString(message('images:segmenter:showCurrentTooltip'));
            column.add(self.ShowCurrentLabel);

            self.ShowHistoryLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:showHistory')));
            self.ShowHistoryLabel.Tag='HistoryLabel';
            self.ShowHistoryLabel.Description=getString(message('images:segmenter:showHistoryTooltip'));
            column.add(self.ShowHistoryLabel);

            self.ShowCompletedLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:showCompleted')));
            self.ShowCompletedLabel.Tag='CompletedLabel';
            self.ShowCompletedLabel.Description=getString(message('images:segmenter:showCompletedTooltip'));
            column.add(self.ShowCompletedLabel);


            addlistener(self.ShowCompleted,'ValueChanged',@(~,~)overviewSettingsChanged(self));
            addlistener(self.ShowHistory,'ValueChanged',@(~,~)overviewSettingsChanged(self));
            addlistener(self.ShowCurrent,'ValueChanged',@(~,~)overviewSettingsChanged(self));
            addlistener(self.GenerateOverview,'ButtonPushed',@(~,~)notify(self,'RegenerateOverview',...
            images.internal.app.segmenter.volume.events.BlockOverviewRegeneratedEventData(...
            true,false,[])));

        end

    end

end