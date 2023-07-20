classdef LabelTab<images.internal.app.segmenter.volume.display.LabelTab




    events
LevelTraceSelected
LevelTraceThresholdChanged
    end

    properties(Dependent)
LevelTraceThreshold
    end

    properties
        InterpolationAllowed(1,1)logical=true;
    end

    properties(SetAccess=private,Hidden)

LevelTracing

LevelTracingThresholdLabel
LevelTracingThresholdSlider

    end

    methods

        function self=LabelTab()
            self@images.internal.app.segmenter.volume.display.LabelTab();
        end


        function enable(self)

            enable@images.internal.app.segmenter.volume.display.LabelTab(self);

            self.updateLevelTracingState();

        end


        function disable(self)

            disable@images.internal.app.segmenter.volume.display.LabelTab(self);

            self.LevelTracingThresholdLabel.Enabled=false;
            self.LevelTracingThresholdSlider.Enabled=false;

        end


        function val=get.LevelTraceThreshold(self)
            val=self.LevelTracingThresholdSlider.Value;
        end


        function selectDefaultDrawingTool(self)

            self.Freehand.Value=true;

            if self.Enabled

                self.ActiveTool=self.Freehand.Tag;

                self.updateBrushSizeState();
                self.updateFloodFillState();
                self.updateLevelTracingState();

            else
                self.ActiveTool='None';
            end

        end


        function set.InterpolationAllowed(self,TF)
            self.InterpolationAllowed=TF;
            self.updateInterpolationState();
        end

    end


    methods(Access=protected)


        function createTab(self)

            self.createROISection();
            self.createBrushSection();
            self.createLevelTracingSection();
            self.createFillSection();
            self.createSelectSection();

            self.createInterpolateSection();
            self.createDisplaySection();

            self.disable();

        end


        function createLevelTracingSection(self)

            section=addSection(self.Tab,getString(message('medical:medicalLabeler:levelTracing')));


            icon=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','TraceBoundary_24.png');
            name=getString(message('medical:medicalLabeler:traceBoundary'));
            self.LevelTracing=matlab.ui.internal.toolstrip.ToggleButton(name,icon);
            self.LevelTracing.Tag='LevelTracing';
            self.LevelTracing.Description=getString(message('medical:medicalLabeler:traceBoundaryDescription'));
            addlistener(self.LevelTracing,'ValueChanged',@(src,evt)stateButtonPressed(self,evt));

            column=section.addColumn();
            column.add(self.LevelTracing);

            self.LevelTracingThresholdLabel=matlab.ui.internal.toolstrip.Label(getString(message('medical:medicalLabeler:threshold')));
            self.LevelTracingThresholdLabel.Description=getString(message('medical:medicalLabeler:thresholdDescription'));
            self.LevelTracingThresholdLabel.Tag="LevelTracingThresholdLabel";

            self.LevelTracingThresholdSlider=matlab.ui.internal.toolstrip.Slider([0,0.5],0.05);
            self.LevelTracingThresholdSlider.Tag='LevelTracingThreshold';
            self.LevelTracingThresholdSlider.Ticks=0;
            self.LevelTracingThresholdSlider.Description=getString(message('medical:medicalLabeler:thresholdDescription'));
            addlistener(self.LevelTracingThresholdSlider,'ValueChanging',@(src,evt)levelTraceThresholdChanged(self,evt));

            column=section.addColumn('HorizontalAlignment','center','Width',120);
            column.add(self.LevelTracingThresholdLabel);
            column.add(self.LevelTracingThresholdSlider);

        end


        function buttons=getAllStateButtons(self)


            buttons=[self.Select;self.Freehand;self.AssistedFreehand;...
            self.Polygon;self.PaintBrush;self.Eraser;self.FillRegion;self.FloodFill;self.LevelTracing];
        end


        function stateButtonPressed(self,evt)

            self.ActiveTool=evt.Source.Tag;

            if evt.EventData.OldValue
                evt.Source.Value=true;
            else
                self.deselectOtherStateButtons(evt);
                self.updateBrushSizeState();
                self.updateFloodFillState();
                self.updateLevelTracingState();
            end

            self.notify('LabelToolSelected');

        end


        function deselectOtherStateButtons(self,evt)

            deselectOtherStateButtons@images.internal.app.segmenter.volume.display.LabelTab(self,evt);
            self.notify('LevelTraceSelected',medical.internal.app.labeler.events.ValueEventData(self.LevelTracing.Value));

        end


        function updateLevelTracingState(self)

            if strcmp(self.ActiveTool,'LevelTracing')
                self.LevelTracingThresholdLabel.Enabled=true;
                self.LevelTracingThresholdSlider.Enabled=true;
            else
                self.LevelTracingThresholdLabel.Enabled=false;
                self.LevelTracingThresholdSlider.Enabled=false;
            end

        end


        function updateInterpolationState(self)

            if self.Enabled&&self.InterpolationState&&self.InterpolationAllowed
                self.Interpolate.Enabled=true;
            else
                self.Interpolate.Enabled=false;
            end

            self.ManualInterpolate.Enabled=self.Enabled&&self.InterpolationAllowed;

        end


        function levelTraceThresholdChanged(self,evt)
            evt=medical.internal.app.labeler.events.ValueEventData(evt.EventData.NewValue);
            self.notify('LevelTraceThresholdChanged',evt);
        end

    end

end
