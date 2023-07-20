classdef LabelTab<handle




    events


BrushSelected


BrushSizeChanged


LabelToolSelected


InterpolateRequested



InterpolateManually



PaintBySuperpixels

FloodFillSensitivityChanged

    end


    properties(SetAccess=protected,Hidden,Transient)

Tab


        ActiveTool char='None';

        HideLabelsOnDraw(1,1)logical=false;

    end


    properties(Transient,SetAccess=protected,GetAccess={...
        ?images.uitest.factory.Tester,...
        ?uitest.factory.Tester,...
        ?medical.internal.app.labeler.view.toolstrip.LabelTab})

        Select matlab.ui.internal.toolstrip.ToggleButton
        Freehand matlab.ui.internal.toolstrip.ToggleButton
        AssistedFreehand matlab.ui.internal.toolstrip.ToggleButton
        Polygon matlab.ui.internal.toolstrip.ToggleButton
        PaintBrush matlab.ui.internal.toolstrip.ToggleButton
        Eraser matlab.ui.internal.toolstrip.ToggleButton
        BrushLabel matlab.ui.internal.toolstrip.Label
        BrushSize matlab.ui.internal.toolstrip.Slider
        Superpixels matlab.ui.internal.toolstrip.ToggleButton
        FillRegion matlab.ui.internal.toolstrip.ToggleButton
        Interpolate matlab.ui.internal.toolstrip.Button
        ManualInterpolate matlab.ui.internal.toolstrip.Button
        HideOnDraw matlab.ui.internal.toolstrip.ToggleButton

        FloodFill matlab.ui.internal.toolstrip.ToggleButton
        Sensitivity matlab.ui.internal.toolstrip.Slider
        RegionSize matlab.ui.internal.toolstrip.Slider

    end


    properties(Access=protected,Transient)

        Enabled(1,1)logical=false;
        InterpolationState(1,1)logical=false;

    end

    properties(Dependent)
IsSuperPixelsActive
    end

    methods




        function self=LabelTab()

            self.Tab=matlab.ui.internal.toolstrip.Tab(getString(message('images:segmenter:labelTab')));
            self.Tab.Tag="LabelTab";

            createTab(self);
            disable(self);

        end




        function enable(self)

            self.Enabled=true;

            buttons=getAllStateButtons(self);

            for idx=1:numel(buttons)
                buttons(idx).Enabled=true;
                if buttons(idx).Value
                    self.ActiveTool=buttons(idx).Tag;
                end
            end

            updateBrushSizeState(self);
            updateFloodFillState(self);

            updateInterpolationState(self);

            self.HideOnDraw.Enabled=true;

        end




        function disable(self)

            self.Enabled=false;

            buttons=getAllStateButtons(self);

            for idx=1:numel(buttons)
                buttons(idx).Enabled=false;
            end
            self.ActiveTool='None';

            self.BrushLabel.Enabled=false;
            self.BrushSize.Enabled=false;
            self.Superpixels.Enabled=false;
            self.Sensitivity.Enabled=false;
            self.RegionSize.Enabled=false;

            updateInterpolationState(self);

            self.HideOnDraw.Enabled=false;

        end




        function enableInterpolation(self,TF)

            self.InterpolationState=TF;
            updateInterpolationState(self);

        end




        function deselectPaintBySuperpixels(self)
            self.Superpixels.Value=false;
            self.BrushLabel.Text=getString(message('images:segmenter:brushSize'));
        end




        function deselectAll(self)

            self.ActiveTool='None';

            buttons=getAllStateButtons(self);

            for idx=1:numel(buttons)
                buttons(idx).Value=false;
            end

            updateBrushSizeState(self);
            updateFloodFillState(self);

        end




        function TF=get.IsSuperPixelsActive(self)

            TF=false;
            if any(strcmp(self.ActiveTool,{'PaintBrush','Eraser'}))
                TF=self.Superpixels.Value;
            end

        end




        function sz=getPaintBrushSize(self)
            sz=self.BrushSize.Value/100;
        end

    end


    methods(Access=protected)


        function updateInterpolationState(self)

            if self.Enabled&&self.InterpolationState
                self.Interpolate.Enabled=true;
            else
                self.Interpolate.Enabled=false;
            end

            self.ManualInterpolate.Enabled=self.Enabled;

        end


        function stateButtonPressed(self,evt)

            self.ActiveTool=evt.Source.Tag;

            if evt.EventData.OldValue
                evt.Source.Value=true;
            else
                deselectOtherStateButtons(self,evt);
                updateBrushSizeState(self);
                updateFloodFillState(self);
            end

            notify(self,'LabelToolSelected');

        end


        function updateBrushSizeState(self)

            if any(strcmp(self.ActiveTool,{'PaintBrush','Eraser'}))
                self.BrushLabel.Enabled=true;
                self.BrushSize.Enabled=true;
                self.Superpixels.Enabled=true;
            else
                self.BrushLabel.Enabled=false;
                self.BrushSize.Enabled=false;
                self.Superpixels.Enabled=false;
            end

        end


        function updateFloodFillState(self)

            if strcmp(self.ActiveTool,'FloodFill')
                self.Sensitivity.Enabled=true;
                self.RegionSize.Enabled=true;
            else
                self.Sensitivity.Enabled=false;
                self.RegionSize.Enabled=false;
            end

        end


        function brushSizeChanged(self,evt)
            if self.Superpixels.Value
                notify(self,'PaintBySuperpixels',images.internal.app.segmenter.volume.events.BrushSizeChangedEventData(evt.Source.Value/100));
            end
            notify(self,'BrushSizeChanged',images.internal.app.segmenter.volume.events.BrushSizeChangedEventData(evt.Source.Value/100));
        end


        function superpixelPressed(self,evt)
            if evt.Source.Value
                self.BrushLabel.Text=getString(message('images:segmenter:superpixelsSize'));
                notify(self,'PaintBySuperpixels',images.internal.app.segmenter.volume.events.BrushSizeChangedEventData(self.BrushSize.Value/100));
            else
                self.BrushLabel.Text=getString(message('images:segmenter:brushSize'));
                notify(self,'PaintBySuperpixels',images.internal.app.segmenter.volume.events.BrushSizeChangedEventData([]));
            end
        end


        function floodFillSensitivityChanged(self)
            notify(self,'FloodFillSensitivityChanged',images.internal.app.segmenter.volume.events.FloodFillSettingsEventData(self.Sensitivity.Value/200,self.RegionSize.Value/100));
        end


        function deselectOtherStateButtons(self,evt)

            buttons=getAllStateButtons(self);

            buttons=buttons(buttons~=evt.Source);

            for idx=1:numel(buttons)
                buttons(idx).Value=false;
            end

            TF=evt.Source==self.PaintBrush||evt.Source==self.Eraser;

            notify(self,'BrushSelected',images.internal.app.segmenter.volume.events.BrushSelectedEventData(TF));

        end


        function buttons=getAllStateButtons(self)


            buttons=[self.Select;self.Freehand;self.AssistedFreehand;...
            self.Polygon;self.PaintBrush;self.Eraser;self.FillRegion;self.FloodFill];
        end


        function interpolate(self)

            notify(self,'InterpolateRequested');

        end


        function manuallyInterpolate(self)

            notify(self,'InterpolateManually');

        end


        function hideLabelOnDraw(self,evt)

            self.HideLabelsOnDraw=evt.EventData.NewValue;

        end

    end


    methods(Access=protected)


        function createTab(self)

            createROISection(self);
            createBrushSection(self);
            createFillSection(self);
            createSelectSection(self);
            createInterpolateSection(self);
            createDisplaySection(self);

            disable(self);

        end

        function createROISection(self)

            section=addSection(self.Tab,getString(message('images:segmenter:roi')));


            column=section.addColumn();
            self.Freehand=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:drawFreehand')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Freehand_24.png')));
            self.Freehand.Tag='Freehand';
            self.Freehand.Description=getString(message('images:segmenter:drawFreehandTooltip'));
            self.Freehand.Value=true;
            column.add(self.Freehand);


            column=section.addColumn();
            self.AssistedFreehand=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:drawAssisted')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_AssistedFreehand_24.png')));
            self.AssistedFreehand.Tag='AssistedFreehand';
            self.AssistedFreehand.Description=getString(message('images:segmenter:drawAssistedTooltip'));
            column.add(self.AssistedFreehand);


            column=section.addColumn();
            self.Polygon=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:drawPolygon')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Polygon_24.png')));
            self.Polygon.Tag='Polygon';
            self.Polygon.Description=getString(message('images:segmenter:drawPolygonTooltip'));
            column.add(self.Polygon);


            addlistener(self.Freehand,'ValueChanged',@(src,evt)stateButtonPressed(self,evt));
            addlistener(self.AssistedFreehand,'ValueChanged',@(src,evt)stateButtonPressed(self,evt));
            addlistener(self.Polygon,'ValueChanged',@(src,evt)stateButtonPressed(self,evt));

        end

        function createBrushSection(self)

            section=addSection(self.Tab,getString(message('images:segmenter:brush')));


            column=section.addColumn();
            self.PaintBrush=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:paintBrush')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','icons','brush_24.png')));
            self.PaintBrush.Tag='PaintBrush';
            self.PaintBrush.Description=getString(message('images:segmenter:paintBrushTooltip'));
            column.add(self.PaintBrush);


            column=section.addColumn();
            self.Eraser=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:eraser')),matlab.ui.internal.toolstrip.Icon.CLEAR_24);
            self.Eraser.Tag='Eraser';
            self.Eraser.Description=getString(message('images:segmenter:eraserTooltip'));
            column.add(self.Eraser);


            column=section.addColumn('HorizontalAlignment','center','Width',120);
            self.BrushLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:brushSize')));
            self.BrushLabel.Tag='BrushSizeLabel';
            column.add(self.BrushLabel);

            self.BrushSize=matlab.ui.internal.toolstrip.Slider([0,100],50);
            self.BrushSize.Tag='BrushSize';
            self.BrushSize.Ticks=0;
            self.BrushSize.Description=getString(message('images:segmenter:brushSizeTooltip'));
            column.add(self.BrushSize);


            column=section.addColumn();
            self.Superpixels=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:superpixels')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_PaintBySuperpixels_24.png')));
            self.Superpixels.Tag='Superpixel';
            self.Superpixels.Description=getString(message('images:segmenter:superpixelsTooltip'));
            column.add(self.Superpixels);


            addlistener(self.PaintBrush,'ValueChanged',@(src,evt)stateButtonPressed(self,evt));
            addlistener(self.Eraser,'ValueChanged',@(src,evt)stateButtonPressed(self,evt));
            addlistener(self.BrushSize,'ValueChanged',@(src,evt)brushSizeChanged(self,evt));
            addlistener(self.Superpixels,'ValueChanged',@(src,evt)superpixelPressed(self,evt));

        end

        function createFillSection(self)

            section=addSection(self.Tab,getString(message('images:segmenter:fill')));


            column=section.addColumn();
            self.FillRegion=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:fillRegion')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_FillRegion_24.png')));
            self.FillRegion.Tag='FillRegion';
            self.FillRegion.Description=getString(message('images:segmenter:fillRegionTooltip'));
            column.add(self.FillRegion);





            self.FloodFill=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:floodFillRegion')),...
            matlab.ui.internal.toolstrip.Icon.MATLAB_24);
            self.FloodFill.Tag='FloodFill';
            self.FloodFill.Description=getString(message('images:segmenter:floodFillRegionTooltip'));










            self.Sensitivity=matlab.ui.internal.toolstrip.Slider([0,100],10);
            self.Sensitivity.Tag='Sensitivity';
            self.Sensitivity.Ticks=0;
            self.Sensitivity.Description=getString(message('images:segmenter:floodFillSensitivityTooltip'));


            self.RegionSize=matlab.ui.internal.toolstrip.Slider([0,100],50);
            self.RegionSize.Tag='Region Size';
            self.RegionSize.Ticks=0;
            self.RegionSize.Description=getString(message('images:segmenter:regionSizeTooltip'));



            addlistener(self.FillRegion,'ValueChanged',@(src,evt)stateButtonPressed(self,evt));
            addlistener(self.FloodFill,'ValueChanged',@(src,evt)stateButtonPressed(self,evt));
            addlistener(self.Sensitivity,'ValueChanged',@(~,~)floodFillSensitivityChanged(self));
            addlistener(self.RegionSize,'ValueChanged',@(~,~)floodFillSensitivityChanged(self));

        end

        function createSelectSection(self)

            section=addSection(self.Tab,getString(message('images:segmenter:select')));


            column=section.addColumn();
            self.Select=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:selectRegion')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_SelectRegion_24.png')));
            self.Select.Tag='Select';
            self.Select.Description=getString(message('images:segmenter:selectRegionTooltip'));
            column.add(self.Select);


            addlistener(self.Select,'ValueChanged',@(src,evt)stateButtonPressed(self,evt));

        end

        function createInterpolateSection(self)

            section=addSection(self.Tab,getString(message('images:segmenter:interpSectionName')));


            column=section.addColumn();
            self.Interpolate=matlab.ui.internal.toolstrip.Button(getString(message('images:segmenter:interpName')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Interp_24.png')));
            self.Interpolate.Tag='Interpolate';
            self.Interpolate.Description=getString(message('images:segmenter:interpDescription'));
            column.add(self.Interpolate);

            column=section.addColumn();
            self.ManualInterpolate=matlab.ui.internal.toolstrip.Button(getString(message('images:segmenter:manualInterpName')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_ManualInterp_24.png')));
            self.ManualInterpolate.Tag='ManualInterpolate';
            self.ManualInterpolate.Description=getString(message('images:segmenter:manualInterpDescription'));
            column.add(self.ManualInterpolate);


            addlistener(self.Interpolate,'ButtonPushed',@(~,~)interpolate(self));
            addlistener(self.ManualInterpolate,'ButtonPushed',@(~,~)manuallyInterpolate(self));

        end

        function createDisplaySection(self)


            section=addSection(self.Tab,getString(message('images:segmenter:labelDisplay')));

            column=section.addColumn();
            self.HideOnDraw=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:hideLabelOnDraw')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_HideLabels_24.png')));
            self.HideOnDraw.Tag='HideOnDraw';
            self.HideOnDraw.Description=getString(message('images:segmenter:hideLabelOnDrawTooltip'));
            column.add(self.HideOnDraw);


            addlistener(self.HideOnDraw,'ValueChanged',@(src,evt)hideLabelOnDraw(self,evt));

        end

    end


end