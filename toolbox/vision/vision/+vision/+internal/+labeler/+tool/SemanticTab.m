classdef SemanticTab<vision.internal.uitools.NewAbstractTab2




    properties(Access=protected)

PolygonSection
SmartPolygonSection
FreehandSection
GrabCutSection
PaintBrushSection
FloodFillSection
SuperpixelSection
LabelOpacitySection
    end

    properties
UseAppContainer
    end

    methods(Access=public)
        function this=SemanticTab(tool)

            tabName=getString(message('vision:labeler:SemanticTabTitle'));
            this@vision.internal.uitools.NewAbstractTab2(tool,tabName);

            this.UseAppContainer=useAppContainer();

            this.createWidgets();
            this.installListeners();


            resetDrawingTools(this)
        end

        function testers=getTesters(this)%#ok<STOUT,MANU>

        end

        function enableControls(this)
            this.PolygonSection.PolygonButton.Enabled=true;
            this.FreehandSection.AssistedFreehandButton.Enabled=true;
            this.PaintBrushSection.Section.enableAll();
            this.FloodFillSection.Section.enableAll();
            this.SuperpixelSection.Section.enableAll();
            this.LabelOpacitySection.Section.enableAll();
            if this.UseAppContainer
                this.SmartPolygonSection.SmartPolygonButton.Enabled=true;
            else
                this.PolygonSection.SmartPolygonButton.Enabled=true;
            end
        end

        function enableControlsForPlayback(this)
            enableControls(this);
        end

        function disableControls(this)
            this.PolygonSection.Section.disableAll();
            this.FreehandSection.Section.disableAll();
            this.PaintBrushSection.Section.disableAll();
            this.FloodFillSection.Section.disableAll();
            this.SuperpixelSection.Section.disableAll();
            this.LabelOpacitySection.Section.disableAll();
            if~this.UseAppContainer
                hideGrabCutEditingTools(this);
            else
                this.SmartPolygonSection.Section.disableAll();
            end
        end

        function disableControlsForPlayback(this)
            disableControls(this);
        end

        function enableDrawingTools(this)
            this.PolygonSection.PolygonButton.Enabled=true;
            this.FreehandSection.AssistedFreehandButton.Enabled=true;
            this.PaintBrushSection.Section.enableAll();
            this.FloodFillSection.Section.enableAll();
            this.SuperpixelSection.Section.enableAll();
            this.LabelOpacitySection.Section.enableAll();

            if this.UseAppContainer
                this.SmartPolygonSection.SmartPolygonButton.Enabled=true;
                if isGrabCutEditToolSelected(this)
                    enableSmartPolygonEditTools(this);
                end
            else
                this.PolygonSection.SmartPolygonButton.Enabled=true;
                if isGrabCutEditToolSelected(this)
                    enableGrabCutEditTools(this);
                end
            end
        end

        function disableDrawingTools(this)
            this.PolygonSection.Section.disableAll();
            this.FreehandSection.Section.disableAll();
            this.PaintBrushSection.Section.disableAll();
            this.FloodFillSection.Section.disableAll();
            this.SuperpixelSection.Section.disableAll();
            this.LabelOpacitySection.Section.disableAll();
            if this.UseAppContainer
                this.SmartPolygonSection.Section.disableAll();
            end
        end

        function enableGrabCutEditTools(this)
            this.GrabCutSection.GrabCutForegroundButton.Enabled=true;
            this.GrabCutSection.GrabCutBackgroundButton.Enabled=true;
            this.GrabCutSection.GrabCutEraseButton.Enabled=true;
            this.PolygonSection.SmartPolygonEditorButton.Enabled=true;
        end

        function deselectAndDisableGrabCutEditTools(this)
            closeGrabCutEditTools(this);
            disableGrabCutEditTools(this);
            hideGrabCutEditingTools(this);
        end

        function closeGrabCutEditTools(this)
            if isGrabCutEditToolSelected(this)
                this.PolygonSection.SmartPolygonButton.Value=true;
                doSmartPolygon(this,'grabcutauto')
            end
            deselectGrabCutEditTools(this);
        end

        function showGrabCutEditingTools(this)
            this.createGrabCutSection();
            installGrabCutEditListeners(this);
            tool=getParent(this);
            showTearOffDialog(tool,this.GrabCutSection.Popup,this.PolygonSection.SmartPolygonEditorButton,true);
        end

        function hideGrabCutEditingTools(this)
            close(this.GrabCutSection.Popup);
        end

        function deselectAndDisableSmartPolygonEditTools(this)
            isSmartPolygonEditOn(this);
            deselectSmartPolygonEditTools(this);
            disableSmartPolygonEditTools(this);
        end

        function enableSmartPolygonEditTools(this)
            this.SmartPolygonSection.GrabCutForegroundButton.Enabled=true;
            this.SmartPolygonSection.GrabCutBackgroundButton.Enabled=true;
            this.SmartPolygonSection.GrabCutEraseButton.Enabled=true;
        end

        function resetDrawingTools(this)
            this.PolygonSection.PolygonButton.Value=true;
            this.FreehandSection.AssistedFreehandButton.Value=false;
            this.PaintBrushSection.PaintBrushButton.Value=false;
            this.PaintBrushSection.EraseButton.Value=false;
            this.FloodFillSection.FloodFillButton.Value=false;
            this.LabelOpacitySection.OpacitySlider.Value=50;
            this.PaintBrushSection.MarkerSlider.Value=50;
            this.SuperpixelSection.SuperpixelButton.Value=false;
            this.SuperpixelSection.SuperpixelGridCountSlider.Value=400;
            if this.UseAppContainer
                this.SmartPolygonSection.SmartPolygonButton.Value=false;
                deselectAndDisableSmartPolygonEditTools(this);
            else
                this.PolygonSection.SmartPolygonButton.Value=false;
            end
        end

        function reactToModeChange(this,mode)

            switch mode
            case 'ZoomIn'
                disableDrawingTools(this);
                if~this.UseAppContainer
                    disableGrabCutEditTools(this);
                else
                    disableSmartPolygonEditTools(this);
                end
            case 'ZoomOut'
                disableDrawingTools(this);
                if~this.UseAppContainer
                    disableGrabCutEditTools(this);
                else
                    disableSmartPolygonEditTools(this);
                end
            case 'Pan'
                disableDrawingTools(this);
                if~this.UseAppContainer
                    disableGrabCutEditTools(this);
                else
                    disableSmartPolygonEditTools(this);
                end
            case 'ROI'
                enableDrawingTools(this);
            case 'none'
                disableDrawingTools(this);
                if~this.UseAppContainer
                    disableGrabCutEditTools(this);
                else
                    disableSmartPolygonEditTools(this);
                end
            end
        end

        function TF=getTearAwayVisibility(this)
            TF=this.GrabCutSection.Popup.Visible;
        end

        function alpha=getAlpha(this)
            alpha=this.LabelOpacitySection.OpacitySlider.Value;
        end

        function sz=getMarkerSize(this)
            sz=this.PaintBrushSection.MarkerSlider.Value;
        end

        function count=getSuperpixelParameters(this)
            count=this.SuperpixelSection.SuperpixelGridCountSlider.Value;
        end

        function tf=isSuperpixelEnabled(this)
            tf=this.SuperpixelSection.SuperpixelButton.Value;
        end

        function mode=getDrawMode(this)
            if this.PolygonSection.PolygonButton.Value
                mode='polygon';
            elseif this.FloodFillSection.FloodFillButton.Value
                mode='floodfill';
            elseif this.SuperpixelSection.SuperpixelButton.Value
                mode='superpixel';
            elseif this.PaintBrushSection.PaintBrushButton.Value
                mode='draw';
            elseif this.PaintBrushSection.EraseButton.Value
                mode='erase';
            elseif~this.UseAppContainer
                if this.PolygonSection.SmartPolygonButton.Value
                    mode='grabcutauto';
                end
            elseif this.UseAppContainer
                if this.SmartPolygonSection.SmartPolygonButton.Value
                    mode='grabcutauto';
                end
            elseif this.FreehandSection.AssistedFreehandButton.Value
                mode='assistedfreehand';
            else
                mode='auto';
            end
        end

        function setPixelOpacitySliderValue(this,value)
            this.LabelOpacitySection.OpacitySlider.Value=value;
        end
    end

    methods(Access=protected)

        function createWidgets(this)
            this.createPolygonSection();
            if this.UseAppContainer
                this.createSmartPolygonSection();
            else
                this.createGrabCutSection;
            end
            this.createFreehandSection();
            this.createPaintBrushSection();
            this.createFloodFillSection();
            this.createSuperpixelSection();
            this.createLabelOpacitySection();
        end

        function createPolygonSection(this)
            this.PolygonSection=vision.internal.labeler.tool.sections.PolygonSection;
            this.addSectionToTab(this.PolygonSection);
        end

        function createSmartPolygonSection(this)
            this.SmartPolygonSection=vision.internal.labeler.tool.sections.SmartPolygonSection;
            this.addSectionToTab(this.SmartPolygonSection);
        end

        function createFreehandSection(this)
            this.FreehandSection=vision.internal.labeler.tool.sections.FreehandSection;
            this.addSectionToTab(this.FreehandSection);
        end

        function createGrabCutSection(this)
            this.GrabCutSection=vision.internal.labeler.tool.sections.GrabCutSection;
        end

        function createPaintBrushSection(this)
            this.PaintBrushSection=vision.internal.labeler.tool.sections.PaintBrushSection;
            this.addSectionToTab(this.PaintBrushSection);
        end

        function createFloodFillSection(this)
            this.FloodFillSection=vision.internal.labeler.tool.sections.FloodFillSection;
            this.addSectionToTab(this.FloodFillSection);
        end

        function createSuperpixelSection(this)
            this.SuperpixelSection=vision.internal.labeler.tool.sections.SuperpixelSection;
            this.addSectionToTab(this.SuperpixelSection);
        end

        function createLabelOpacitySection(this)
            this.LabelOpacitySection=vision.internal.labeler.tool.sections.LabelOpacitySection;
            this.addSectionToTab(this.LabelOpacitySection);
        end

        function doPolygon(this)
            if this.PolygonSection.PolygonButton.Value
                this.PolygonSection.SmartPolygonButton.Value=false;
                this.FreehandSection.AssistedFreehandButton.Value=false;
                this.PaintBrushSection.PaintBrushButton.Value=false;
                this.PaintBrushSection.EraseButton.Value=false;
                this.FloodFillSection.FloodFillButton.Value=false;
                this.SuperpixelSection.SuperpixelButton.Value=false;
                disableSuperpixelControls(this);
                if~this.UseAppContainer
                    deselectGrabCutEditTools(this);
                    disableGrabCutEditTools(this);
                else
                    this.SmartPolygonSection.SmartPolygonButton.Value=false;
                    deselectSmartPolygonEditTools(this);
                    disableSmartPolygonEditTools(this);
                end
                setPixelLabelMode(getParent(this),'polygon');
            elseif~this.isDrawStateValid()

                this.PolygonSection.PolygonButton.Value=true;
            end
        end

        function doAssistedFreehand(this,mode)
            if this.FreehandSection.AssistedFreehandButton.Value
                this.PolygonSection.PolygonButton.Value=false;
                this.PaintBrushSection.PaintBrushButton.Value=false;
                this.PaintBrushSection.EraseButton.Value=false;
                this.FloodFillSection.FloodFillButton.Value=false;
                this.SuperpixelSection.SuperpixelButton.Value=false;
                disableSuperpixelControls(this);
                if this.UseAppContainer
                    this.SmartPolygonSection.SmartPolygonButton.Value=false;
                    deselectSmartPolygonEditTools(this);
                    disableSmartPolygonEditTools(this);
                else
                    this.PolygonSection.SmartPolygonButton.Value=false;
                    deselectGrabCutEditTools(this);
                    disableGrabCutEditTools(this);
                end
                setPixelLabelMode(getParent(this),mode);
            elseif~this.isDrawStateValid()

                this.FreehandSection.AssistedFreehandButton.Value=true;
            end
        end

        function doSmartPolygon(this,mode)
            if~this.UseAppContainer

                if this.PolygonSection.SmartPolygonButton.Value
                    this.PolygonSection.PolygonButton.Value=false;
                    this.FreehandSection.AssistedFreehandButton.Value=false;
                    this.PaintBrushSection.PaintBrushButton.Value=false;
                    this.PaintBrushSection.EraseButton.Value=false;
                    this.FloodFillSection.FloodFillButton.Value=false;
                    this.SuperpixelSection.SuperpixelButton.Value=false;
                    deselectGrabCutEditTools(this);
                    disableGrabCutEditTools(this);
                    disableSuperpixelControls(this);







                    setPixelLabelMode(getParent(this),mode);
                elseif~this.isDrawStateValid()

                    this.PolygonSection.SmartPolygonButton.Value=true;
                end
            else
                if this.SmartPolygonSection.SmartPolygonButton.Value
                    this.PolygonSection.PolygonButton.Value=false;
                    this.FreehandSection.AssistedFreehandButton.Value=false;
                    this.PaintBrushSection.PaintBrushButton.Value=false;
                    this.PaintBrushSection.EraseButton.Value=false;
                    this.FloodFillSection.FloodFillButton.Value=false;
                    this.SuperpixelSection.SuperpixelButton.Value=false;
                    disableSuperpixelControls(this);
                    deselectSmartPolygonEditTools(this);
                    disableSmartPolygonEditTools(this);
                    setPixelLabelMode(getParent(this),mode);
                elseif~this.isDrawStateValid()

                    this.SmartPolygonSection.SmartPolygonButton.Value=true;
                end
            end

        end

        function doSmartPolygonEditor(this)
            showGrabCutEditingTools(this);
        end

        function doGrabCutForeground(this)
            if~this.UseAppContainer
                if this.GrabCutSection.GrabCutForegroundButton.Selected
                    this.GrabCutSection.GrabCutBackgroundButton.Selected=false;
                    this.GrabCutSection.GrabCutEraseButton.Selected=false;
                    this.PolygonSection.SmartPolygonButton.Value=false;
                    this.FreehandSection.AssistedFreehandButton.Value=false;
                    this.PolygonSection.PolygonButton.Value=false;
                    this.PaintBrushSection.PaintBrushButton.Value=false;
                    this.PaintBrushSection.EraseButton.Value=false;
                    this.FloodFillSection.FloodFillButton.Value=false;
                    this.SuperpixelSection.SuperpixelButton.Value=false;
                    setPixelLabelMode(getParent(this),'grabcutforeground');
                elseif~this.isDrawStateValid()

                    this.GrabCutSection.GrabCutForegroundButton.Selected=true;
                end
            else
                if this.SmartPolygonSection.GrabCutForegroundButton.Value
                    this.SmartPolygonSection.GrabCutBackgroundButton.Value=false;
                    this.SmartPolygonSection.GrabCutEraseButton.Value=false;
                    this.SmartPolygonSection.SmartPolygonButton.Value=false;
                    this.FreehandSection.AssistedFreehandButton.Value=false;
                    this.PolygonSection.PolygonButton.Value=false;
                    this.PaintBrushSection.PaintBrushButton.Value=false;
                    this.PaintBrushSection.EraseButton.Value=false;
                    this.FloodFillSection.FloodFillButton.Value=false;
                    this.SuperpixelSection.SuperpixelButton.Value=false;
                    setPixelLabelMode(getParent(this),'grabcutforeground');
                elseif~this.isDrawStateValid()

                    this.SmartPolygonSection.GrabCutForegroundButton.Enabled=true;
                    this.SmartPolygonSection.GrabCutForegroundButton.Value=true;
                end
            end
        end

        function doGrabCutBackground(this)
            if~this.UseAppContainer
                if this.GrabCutSection.GrabCutBackgroundButton.Selected
                    this.GrabCutSection.GrabCutForegroundButton.Selected=false;
                    this.GrabCutSection.GrabCutEraseButton.Selected=false;
                    this.PolygonSection.SmartPolygonButton.Value=false;
                    this.FreehandSection.AssistedFreehandButton.Value=false;
                    this.PolygonSection.PolygonButton.Value=false;
                    this.PaintBrushSection.PaintBrushButton.Value=false;
                    this.PaintBrushSection.EraseButton.Value=false;
                    this.FloodFillSection.FloodFillButton.Value=false;
                    this.SuperpixelSection.SuperpixelButton.Value=false;
                    setPixelLabelMode(getParent(this),'grabcutbackground');
                elseif~this.isDrawStateValid()

                    this.GrabCutSection.GrabCutBackgroundButton.Selected=true;
                end
            else
                if this.SmartPolygonSection.GrabCutBackgroundButton.Value
                    this.SmartPolygonSection.GrabCutForegroundButton.Value=false;
                    this.SmartPolygonSection.GrabCutEraseButton.Value=false;
                    this.SmartPolygonSection.SmartPolygonButton.Value=false;
                    this.FreehandSection.AssistedFreehandButton.Value=false;
                    this.PolygonSection.PolygonButton.Value=false;
                    this.PaintBrushSection.PaintBrushButton.Value=false;
                    this.PaintBrushSection.EraseButton.Value=false;
                    this.FloodFillSection.FloodFillButton.Value=false;
                    this.SuperpixelSection.SuperpixelButton.Value=false;
                    setPixelLabelMode(getParent(this),'grabcutbackground');
                elseif~this.isDrawStateValid()

                    this.SmartPolygonSection.GrabCutBackgroundButton.Enabled=true;
                    this.SmartPolygonSection.GrabCutBackgroundButton.Value=true;
                end
            end
        end

        function doGrabCutErase(this)
            if~this.UseAppContainer
                if this.GrabCutSection.GrabCutEraseButton.Selected
                    this.GrabCutSection.GrabCutBackgroundButton.Selected=false;
                    this.GrabCutSection.GrabCutForegroundButton.Selected=false;
                    this.PolygonSection.SmartPolygonButton.Value=false;
                    this.FreehandSection.AssistedFreehandButton.Value=false;
                    this.PolygonSection.PolygonButton.Value=false;
                    this.PaintBrushSection.PaintBrushButton.Value=false;
                    this.PaintBrushSection.EraseButton.Value=false;
                    this.FloodFillSection.FloodFillButton.Value=false;
                    this.SuperpixelSection.SuperpixelButton.Value=false;
                    setPixelLabelMode(getParent(this),'grabcuterase');
                elseif~this.isDrawStateValid()

                    this.GrabCutSection.GrabCutEraseButton.Enabled=true;
                end
            else
                if this.SmartPolygonSection.GrabCutEraseButton.Value
                    this.SmartPolygonSection.GrabCutBackgroundButton.Value=false;
                    this.SmartPolygonSection.GrabCutForegroundButton.Value=false;
                    this.SmartPolygonSection.SmartPolygonButton.Value=false;
                    this.FreehandSection.AssistedFreehandButton.Value=false;
                    this.PolygonSection.PolygonButton.Value=false;
                    this.PaintBrushSection.PaintBrushButton.Value=false;
                    this.PaintBrushSection.EraseButton.Value=false;
                    this.FloodFillSection.FloodFillButton.Value=false;
                    this.SuperpixelSection.SuperpixelButton.Value=false;
                    setPixelLabelMode(getParent(this),'grabcuterase');
                elseif~this.isDrawStateValid()

                    this.SmartPolygonSection.GrabCutEraseButton.Enabled=true;
                    this.SmartPolygonSection.GrabCutEraseButton.Value=true;

                end
            end
        end

        function doFloodFill(this)
            if this.FloodFillSection.FloodFillButton.Value
                this.PaintBrushSection.PaintBrushButton.Value=false;
                this.PaintBrushSection.EraseButton.Value=false;
                this.FreehandSection.AssistedFreehandButton.Value=false;
                this.PolygonSection.PolygonButton.Value=false;
                this.SuperpixelSection.SuperpixelButton.Value=false;
                disableSuperpixelControls(this);
                if~this.UseAppContainer
                    this.PolygonSection.SmartPolygonButton.Value=false;
                    deselectGrabCutEditTools(this);
                    disableGrabCutEditTools(this);
                else
                    this.SmartPolygonSection.SmartPolygonButton.Value=false;
                    deselectSmartPolygonEditTools(this);
                    disableSmartPolygonEditTools(this);
                end
                setPixelLabelMode(getParent(this),'floodfill');
            elseif~this.isDrawStateValid()

                this.FloodFillSection.FloodFillButton.Value=true;
            end
        end

        function enableSuperpixelLayout(this)
            if this.SuperpixelSection.SuperpixelButton.Value
                setPixelLabelMode(getParent(this),'superpixel');
                updateSuperpixelLayout(getParent(this),...
                this.SuperpixelSection.SuperpixelGridCountSlider.Value,false);
            else
                disableSuperpixelLayout(this);
            end
        end

        function updateSuperpixelLayout(this)
            updateSuperpixelLayout(getParent(this),...
            this.SuperpixelSection.SuperpixelGridCountSlider.Value,true);
        end

        function disableSuperpixelLayout(this)
            updateSuperpixelLayout(getParent(this),0,true);
        end

        function disableSuperpixelControls(this)
            disableSuperpixelLayout(this);
        end

        function doPaintBrush(this)
            if this.PaintBrushSection.PaintBrushButton.Value
                this.FreehandSection.AssistedFreehandButton.Value=false;
                this.PolygonSection.PolygonButton.Value=false;
                this.PaintBrushSection.EraseButton.Value=false;
                this.FloodFillSection.FloodFillButton.Value=false;
                this.SuperpixelSection.SuperpixelButton.Value=false;
                disableSuperpixelControls(this);
                if~this.UseAppContainer
                    this.PolygonSection.SmartPolygonButton.Value=false;
                    deselectGrabCutEditTools(this);
                    disableGrabCutEditTools(this);
                else
                    this.SmartPolygonSection.SmartPolygonButton.Value=false;
                    deselectSmartPolygonEditTools(this);
                    disableSmartPolygonEditTools(this);
                end
                setPixelLabelMode(getParent(this),'draw');
            elseif~this.isDrawStateValid()

                this.PaintBrushSection.PaintBrushButton.Value=true;
            end
        end

        function doSuperpixel(this)
            if this.SuperpixelSection.SuperpixelButton.Value
                this.FreehandSection.AssistedFreehandButton.Value=false;
                this.PolygonSection.PolygonButton.Value=false;
                this.PaintBrushSection.EraseButton.Value=false;
                this.FloodFillSection.FloodFillButton.Value=false;
                this.PaintBrushSection.PaintBrushButton.Value=false;
                enableSuperpixelLayout(this);
                if~this.UseAppContainer
                    this.PolygonSection.SmartPolygonButton.Value=false;
                    deselectGrabCutEditTools(this);
                    disableGrabCutEditTools(this);
                else
                    this.SmartPolygonSection.SmartPolygonButton.Value=false;
                    deselectSmartPolygonEditTools(this);
                    disableSmartPolygonEditTools(this);
                end
                setPixelLabelMode(getParent(this),'Superpixel');
            elseif~this.isDrawStateValid()

                this.SuperpixelSection.SuperpixelButton.Value=true;
            end
        end

        function doErase(this)
            if this.PaintBrushSection.EraseButton.Value
                this.FreehandSection.AssistedFreehandButton.Value=false;
                this.PolygonSection.PolygonButton.Value=false;
                this.PaintBrushSection.PaintBrushButton.Value=false;
                this.FloodFillSection.FloodFillButton.Value=false;
                this.SuperpixelSection.SuperpixelButton.Value=false;
                disableSuperpixelControls(this);
                if~this.UseAppContainer
                    this.PolygonSection.SmartPolygonButton.Value=false;
                    deselectGrabCutEditTools(this);
                    disableGrabCutEditTools(this);
                else
                    this.SmartPolygonSection.SmartPolygonButton.Value=false;
                    deselectSmartPolygonEditTools(this);
                    disableSmartPolygonEditTools(this);
                end
                setPixelLabelMode(getParent(this),'erase');
            elseif~this.isDrawStateValid()

                this.PaintBrushSection.EraseButton.Value=true;
            end
        end

        function setMarkerSize(this)
            sz=this.PaintBrushSection.MarkerSlider.Value;
            setPixelLabelMarkerSize(getParent(this),sz);
        end

        function setAlpha(this)
            alpha=this.LabelOpacitySection.OpacitySlider.Value;
            setPixelLabelAlpha(getParent(this),alpha);
        end

        function TF=isDrawStateValid(this)

            if~this.UseAppContainer
                TF=any([this.PolygonSection.PolygonButton.Value,...
                this.PaintBrushSection.PaintBrushButton.Value,...
                this.PaintBrushSection.EraseButton.Value,...
                this.FreehandSection.AssistedFreehandButton.Value,...
                this.PolygonSection.SmartPolygonButton.Value,...
                this.FloodFillSection.FloodFillButton.Value,...
                this.SuperpixelSection.SuperpixelButton.Value,...
                this.GrabCutSection.GrabCutForegroundButton.Selected,...
                this.GrabCutSection.GrabCutBackgroundButton.Selected,...
                this.GrabCutSection.GrabCutEraseButton.Selected]);
            else
                TF=any([this.PolygonSection.PolygonButton.Value,...
                this.PaintBrushSection.PaintBrushButton.Value,...
                this.PaintBrushSection.EraseButton.Value,...
                this.FreehandSection.AssistedFreehandButton.Value,...
                this.SmartPolygonSection.SmartPolygonButton.Value,...
                this.FloodFillSection.FloodFillButton.Value,...
                this.SuperpixelSection.SuperpixelButton.Value,...
                this.SmartPolygonSection.GrabCutForegroundButton.Value,...
                this.SmartPolygonSection.GrabCutBackgroundButton.Value,...
                this.SmartPolygonSection.GrabCutEraseButton.Value]);
            end

        end

        function TF=isGrabCutEditToolSelected(this)
            if~this.UseAppContainer
                TF=any([this.GrabCutSection.GrabCutForegroundButton.Selected,...
                this.GrabCutSection.GrabCutBackgroundButton.Selected,...
                this.GrabCutSection.GrabCutEraseButton.Selected]);
            else
                TF=any([this.SmartPolygonSection.GrabCutForegroundButton.Value,...
                this.SmartPolygonSection.GrabCutBackgroundButton.Value,...
                this.SmartPolygonSection.GrabCutEraseButton.Value]);
            end
        end

        function deselectGrabCutEditTools(this)
            this.GrabCutSection.GrabCutForegroundButton.Selected=false;
            this.GrabCutSection.GrabCutBackgroundButton.Selected=false;
            this.GrabCutSection.GrabCutEraseButton.Selected=false;
        end

        function disableGrabCutEditTools(this)
            this.GrabCutSection.GrabCutForegroundButton.Enabled=false;
            this.GrabCutSection.GrabCutBackgroundButton.Enabled=false;
            this.GrabCutSection.GrabCutEraseButton.Enabled=false;
            this.PolygonSection.SmartPolygonEditorButton.Enabled=false;
        end

        function isSmartPolygonEditOn(this)
            if isGrabCutEditToolSelected(this)
                this.SmartPolygonSection.SmartPolygonButton.Value=true;
                doSmartPolygon(this,'grabcutauto');
            end
            deselectSmartPolygonEditTools(this);
        end

        function deselectSmartPolygonEditTools(this)
            this.SmartPolygonSection.GrabCutForegroundButton.Value=false;
            this.SmartPolygonSection.GrabCutBackgroundButton.Value=false;
            this.SmartPolygonSection.GrabCutEraseButton.Value=false;
        end

        function disableSmartPolygonEditTools(this)
            this.SmartPolygonSection.GrabCutForegroundButton.Enabled=false;
            this.SmartPolygonSection.GrabCutBackgroundButton.Enabled=false;
            this.SmartPolygonSection.GrabCutEraseButton.Enabled=false;
        end


        function installListeners(this)
            this.installListenersPolygonSection();
            this.installListenersPaintBrushSection();
            this.installListenersFloodFillSection();
            this.installListenersSuperpixelSection();
            this.installListenersLabelOpacitySection();
            if this.UseAppContainer
                this.installListenersSmartPolygonSection();
            end
        end

        function installListenersPolygonSection(this)
            addlistener(this.PolygonSection.PolygonButton,'ValueChanged',@(~,~)this.doPolygon());
            addlistener(this.FreehandSection.AssistedFreehandButton,'ValueChanged',@(~,~)this.doAssistedFreehand('assistedfreehand'));
            if~this.UseAppContainer
                addlistener(this.PolygonSection.SmartPolygonButton,'ValueChanged',@(~,~)this.doSmartPolygon('grabcutpolygon'));
                addlistener(this.PolygonSection.SmartPolygonEditorButton,'ButtonPushed',@(~,~)this.doSmartPolygonEditor());
            end
        end

        function installListenersSmartPolygonSection(this)
            addlistener(this.SmartPolygonSection.SmartPolygonButton,'ValueChanged',@(~,~)this.doSmartPolygon('grabcutpolygon'));
            addlistener(this.SmartPolygonSection.GrabCutForegroundButton,'ValueChanged',@(~,~)this.doGrabCutForeground());
            addlistener(this.SmartPolygonSection.GrabCutBackgroundButton,'ValueChanged',@(~,~)this.doGrabCutBackground());
            addlistener(this.SmartPolygonSection.GrabCutEraseButton,'ValueChanged',@(~,~)this.doGrabCutErase());
        end

        function installGrabCutEditListeners(this)
            addlistener(this.GrabCutSection.Popup,'CloseEvent',@(~,~)this.closeGrabCutEditTools());
            addlistener(this.GrabCutSection.GrabCutForegroundButton,'ItemStateChanged',@(~,~)this.doGrabCutForeground());
            addlistener(this.GrabCutSection.GrabCutBackgroundButton,'ItemStateChanged',@(~,~)this.doGrabCutBackground());
            addlistener(this.GrabCutSection.GrabCutEraseButton,'ItemStateChanged',@(~,~)this.doGrabCutErase());
        end

        function installListenersPaintBrushSection(this)
            addlistener(this.PaintBrushSection.PaintBrushButton,'ValueChanged',@(~,~)this.doPaintBrush());
            addlistener(this.PaintBrushSection.EraseButton,'ValueChanged',@(~,~)this.doErase());
            addlistener(this.PaintBrushSection.MarkerSlider,'ValueChanged',@(~,~)this.setMarkerSize());
        end

        function installListenersFloodFillSection(this)
            addlistener(this.FloodFillSection.FloodFillButton,'ValueChanged',@(~,~)this.doFloodFill());
        end

        function installListenersSuperpixelSection(this)
            addlistener(this.SuperpixelSection.SuperpixelButton,'ValueChanged',@(~,~)this.doSuperpixel());
            addlistener(this.SuperpixelSection.SuperpixelGridCountSlider,'ValueChanged',@(~,~)this.updateSuperpixelLayout());
        end

        function installListenersLabelOpacitySection(this)
            addlistener(this.LabelOpacitySection.OpacitySlider,'ValueChanged',@(~,~)this.setAlpha());
        end

    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end
