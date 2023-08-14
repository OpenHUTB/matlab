classdef VolumeRenderingSettingsEditor<handle

    properties
Panel
VolumeRenderingPanel
IsosurfacePanel

AlphaMapEditor
ColorMapEditor

RenderingStylePopup
LightingToggle


IsovalSlider
IsovalSliderText
IsosurfaceColorButton
IsosurfaceColor

ColorMapEditorPanel

UseShaders

    end


    properties
LabelVolumeRenderingPanel
LabelBrowserPanel
OpacitySliderSubpanel
LabelSubpanel
VolumeSubpanel
ColormapList
EmbedLabelsCheckbox


LabelSelectAllBtn
LabelInvertSelectionBtn
LabelsBrowser
OpacitySliderText
OpacitySlider
LabelColorPickerText
LabelColorPickerBtn
ShowLabelCheckbox

ThresholdSliderText
ThresholdSlider
VolumeOpacitySliderText
VolumeOpacitySlider


OpacitySliderListener
ShowToggleListener
    end

    properties(Dependent)
Enable
LabelMode
    end

    events
ColormapChange
AlphamapChange
IsosurfaceColorChange
LabelOpacityChange
LabelColorChange
LabelShowFlagChange
    end

    methods

        function self=VolumeRenderingSettingsEditor(hFig)

            self.Panel=uipanel('Parent',hFig,'BorderType','none','Units','normalized','Visible','off','Position',[0,0,1,1]);

            self.IsosurfacePanel=uipanel('Parent',self.Panel,'BorderType','none');

            self.VolumeRenderingPanel=uiflowcontainer('v0','Parent',self.Panel,...
            'Units','normalized','Position',[0,0,1,0.9],'FlowDirection','TopDown');

            self.IsosurfacePanel.Units='normalized';
            self.IsosurfacePanel.Position=[0,0,1,0.9];
            self.IsosurfacePanel.Visible='off';

            self.UseShaders=iptgetpref('VolumeViewerUseHardware');

            if self.UseShaders
                self.RenderingStylePopup=uicontrol('Style','popupmenu','String',...
                {getString(message('images:volumeViewerToolgroup:volRenderingCategoryName')),...
                getString(message('images:volumeViewerToolgroup:mipCategoryName')),...
                getString(message('images:volumeViewerToolgroup:isosurfaceCategoryName'))},...
                'Units','normalized','Parent',self.Panel);
            else
                self.RenderingStylePopup=uicontrol('Style','popupmenu','String',...
                {getString(message('images:volumeViewerToolgroup:volRenderingCategoryName')),...
                getString(message('images:volumeViewerToolgroup:mipCategoryName'))},...
                'Units','normalized','Parent',self.Panel);
            end

            self.RenderingStylePopup.Value=1;
            self.RenderingStylePopup.Position=[0.12,0.9,0.75,0.05];
            self.RenderingStylePopup.Tag='renderingStylePopup';
            self.RenderingStylePopup.TooltipString=getString(message('images:volumeViewerToolgroup:renderingStyleDescription'));

            self.LabelVolumeRenderingPanel=uipanel('Parent',self.Panel,...
            'BorderType','line',...
            'Visible','off',...
            'Units','normalized',...
            'Position',[0,0,1,1],...
            'SizeChangedFcn',@(hObj,evt)self.manageLabelVolumeRenderingPanelResize);
            self.ColormapList=images.internal.app.volviewToolgroup.MapListManager('labelColormap');

            self.layoutIsosurfacePanel();
            self.layoutVolumeRenderingPanel();
            self.layoutLabelVolumeRenderingPanel();

        end

        function delete(self)
            delete(self.LabelsBrowser);
        end

        function layoutIsosurfacePanel(self)

            self.IsovalSlider=uicontrol('Style','slider','Units','Pixels','Tag','isosurfaceSlider',...
            'Parent',self.IsosurfacePanel);

            self.IsovalSlider.TooltipString=getString(message('images:volumeViewerToolgroup:isovalSlider'));

            self.IsovalSliderText=uicontrol('style','text','Parent',self.IsosurfacePanel,...
            'Tag','isosurfaceSliderText',...
            'String',getString(message('images:volumeViewerToolgroup:isovalue')),'Units','normalized');

            self.IsovalSliderText.Position(1:2)=[0.05,0.95];
            self.IsovalSliderText.Units='Pixels';

            self.IsovalSlider.Min=1/256;
            self.IsovalSlider.Max=1;
            self.IsovalSlider.SliderStep=[1/256,10/256];
            self.IsovalSlider.Value=0.5;

            self.IsosurfaceColorButton=uicontrol('Style','pushbutton','Tag','isosurfaceColorButton',...
            'Parent',self.IsosurfacePanel,'Units','normalized','String',getString(message('images:volumeViewerToolgroup:color')));

            self.IsosurfaceColorButton.TooltipString=getString(message('images:volumeViewerToolgroup:isosurfaceColorTooltip'));

            self.IsosurfaceColorButton.Position=[0.05,0.80,0.2,0.05];
            self.IsosurfaceColorButton.Callback=@(hobj,evt)self.setIsocolorPush();

            self.IsosurfacePanel.SizeChangedFcn=@(hobj,evt)self.manageIsosurfacePanelSizeChange();

            self.IsosurfaceColor=[1,0,0];

        end

        function manageIsosurfacePanelSizeChange(self)

            self.IsosurfacePanel.Units='pixels';
            panelSize=self.IsosurfacePanel.Position(3:4);
            self.IsosurfacePanel.Units='normalized';

            self.IsovalSliderText.Position(1:2)=[0.05*panelSize(1),0.95*panelSize(2)];
            self.IsovalSliderText.Position(3:4)=self.IsovalSliderText.Extent(3:4);

            self.IsosurfacePanel.Units='pixels';
            panelSize=self.IsosurfacePanel.Position(3:4);
            self.IsosurfacePanel.Units='normalized';

            self.IsovalSlider.Position=[0.05*panelSize(1),0.90*panelSize(2),0.9*panelSize(1),20];

        end

        function setIsocolorPush(self)

            import images.internal.app.volviewToolgroup.*

            newcolor=uisetcolor(self.IsosurfaceColor);
            self.notify('IsosurfaceColorChange',ColormapChangeEventData(newcolor));

        end

        function layoutVolumeRenderingPanel(self)

            amapEditorPanel=uipanel('Parent',self.VolumeRenderingPanel,'Units','Normalized',...
            'BorderType','none');

            amapEditorPanel.HeightLimits=[250,350];
            self.AlphaMapEditor=images.internal.app.volviewToolgroup.AlphamapEditor(amapEditorPanel,...
            [0,0;1.0,1.0]);

            self.ColorMapEditorPanel=uipanel('Parent',self.VolumeRenderingPanel,'Units','Pixels',...
            'BorderType','none');

            self.ColorMapEditorPanel.HeightLimits=[10,120];
            colorPoints=[0,0,0,0;1.0,1.0,1.0,1.0];
            self.ColorMapEditor=images.internal.app.volviewToolgroup.ColormapDesigner(self.ColorMapEditorPanel,colorPoints);

            togglePanel=uipanel('Parent',self.VolumeRenderingPanel,'BorderType','none');
            togglePanel.HeightLimits=[20,25];

            if self.UseShaders

                self.LightingToggle=uicontrol('Style','checkbox','Parent',togglePanel,'Units','Normalized',...
                'String',getString(message('images:volumeViewerToolgroup:lighting')),'Position',[0.1,0,0.8,1],...
                'Tag','LightingToggle');

                self.LightingToggle.TooltipString=getString(message('images:volumeViewerToolgroup:lightingTooltip'));

            end

        end

        function set.Enable(self,TF)

            if TF
                self.RenderingStylePopup.Enable='on';
                self.LightingToggle.Enable='on';
                self.IsovalSlider.Enable='on';
                self.IsosurfaceColorButton.Enable='on';
                self.AlphaMapEditor.Enable=TF;
                self.ColorMapEditor.Enable=TF;

                if self.EmbedLabelsCheckbox.Value
                    self.LabelMode='mixed';
                else
                    self.LabelMode='labels';
                end

            else
                self.RenderingStylePopup.Enable='off';
                self.LightingToggle.Enable='off';
                self.IsovalSlider.Enable='off';
                self.IsosurfaceColorButton.Enable='off';
                self.AlphaMapEditor.Enable=TF;
                self.ColorMapEditor.Enable=TF;

                self.OpacitySliderText.Enable='off';
                self.OpacitySlider.Enable='off';
                self.ThresholdSliderText.Enable='off';
                self.ThresholdSlider.Enable='off';
                self.VolumeOpacitySliderText.Enable='off';
                self.VolumeOpacitySlider.Enable='off';
            end
        end
    end


    methods
        function manageLabelVolumeRenderingPanelResize(self)

            self.LabelVolumeRenderingPanel.Units='points';
            labelVolumeRenderingPanelSize=self.LabelVolumeRenderingPanel.Position;
            self.LabelVolumeRenderingPanel.Units='normalized';

            if labelVolumeRenderingPanelSize(3)<30||labelVolumeRenderingPanelSize(4)<100
                return;
            end

            self.EmbedLabelsCheckbox.Position(2)=labelVolumeRenderingPanelSize(4)-25;

            self.LabelSubpanel.Position(2)=labelVolumeRenderingPanelSize(4)-320;
            self.LabelSubpanel.Position(3)=labelVolumeRenderingPanelSize(3);
            labelPanelSize=self.LabelSubpanel.Position;

            self.LabelSelectAllBtn.Position(2)=labelPanelSize(4)-35;
            self.LabelInvertSelectionBtn.Position(2)=labelPanelSize(4)-35;

            self.LabelBrowserPanel.Position(2)=labelPanelSize(4)-220;
            self.LabelBrowserPanel.Position(3)=labelPanelSize(3)-7;
            self.LabelBrowserPanel.Position(4)=180;

            self.LabelColorPickerText.Position(2)=0.15*labelPanelSize(4);
            self.LabelColorPickerBtn.Position(2)=0.13*labelPanelSize(4);

            self.ShowLabelCheckbox.Position(2)=0.15*labelPanelSize(4);

            self.OpacitySliderSubpanel.Units='points';
            labelOpacityPanelSize=self.OpacitySliderSubpanel.Position;
            self.OpacitySliderSubpanel.Units='normalized';
            self.OpacitySliderText.Position(2)=0.3*labelOpacityPanelSize(4);
            self.OpacitySlider.Position(2)=0.3*labelOpacityPanelSize(4);

            self.VolumeSubpanel.Position(2)=max(0,labelVolumeRenderingPanelSize(4)-410);
            self.VolumeSubpanel.Position(3)=labelVolumeRenderingPanelSize(3);
            volPanelSize=self.VolumeSubpanel.Position;

            self.ThresholdSliderText.Position(2)=0.5*volPanelSize(4);
            self.ThresholdSlider.Position(2)=0.5*volPanelSize(4);

            self.VolumeOpacitySliderText.Position(2)=0.15*volPanelSize(4);
            self.VolumeOpacitySlider.Position(2)=0.15*volPanelSize(4);

        end

        function layoutLabelVolumeRenderingPanel(self)

            self.EmbedLabelsCheckbox=uicontrol('Parent',self.LabelVolumeRenderingPanel,...
            'Style','checkbox',...
            'String',getString(message('images:volumeViewerToolgroup:embedLabels')),...
            'Tag','EmbedLabelsToggle',...
            'Value',1,...
            'TooltipString',getString(message('images:volumeViewerToolgroup:embedLabelsTooltip')));
            self.EmbedLabelsCheckbox.Units='points';
            self.EmbedLabelsCheckbox.Position(1)=15;
            self.EmbedLabelsCheckbox.Position(3)=150;
            self.EmbedLabelsCheckbox.FontSize=self.EmbedLabelsCheckbox.FontSize+1;

            self.LabelSubpanel=uipanel(...
            'Parent',self.LabelVolumeRenderingPanel,...
            'Title',getString(message('images:volumeViewerToolgroup:viewLabelsButtonLabel')),...
            'Visible','on');
            self.LabelSubpanel.Units='points';
            self.LabelSubpanel.Position(1)=0;
            self.LabelSubpanel.Position(4)=290;
            self.LabelSubpanel.FontSize=self.LabelSubpanel.FontSize+2;

            self.LabelSelectAllBtn=uicontrol('Parent',self.LabelSubpanel,...
            'Style','pushbutton',...
            'Tag','LabelSelectAllBtn',...
            'String',getString(message('images:volumeViewerToolgroup:selectAll')),...
            'Callback',@(hObj,evt)self.selectAllLabels(),...
            'TooltipString',getString(message('images:volumeViewerToolgroup:selectAllBtnTooltip')));
            self.LabelSelectAllBtn.Units='points';
            self.LabelSelectAllBtn.Position(2:4)=[240,70,18];

            self.LabelInvertSelectionBtn=uicontrol('Parent',self.LabelSubpanel,...
            'Style','pushbutton',...
            'Tag','LabelInvertSelectionBtn',...
            'String',getString(message('images:volumeViewerToolgroup:invertSelection')),...
            'Units','points',...
            'Callback',@(hObj,evt)self.invertSelection(),...
            'TooltipString',getString(message('images:volumeViewerToolgroup:invertSelectionBtnTooltip')));
            self.LabelInvertSelectionBtn.Units='points';
            self.LabelInvertSelectionBtn.Position=[100,0,80,18];

            self.LabelBrowserPanel=uipanel('Parent',self.LabelSubpanel,...
            'BorderType','line',...
            'Tag','LabelBrowserPanel',...
            'Units','points');
            self.LabelBrowserPanel.Position(1)=3;

            self.LabelsBrowser=images.internal.app.volviewToolgroup.LabelsBrowser(self.LabelBrowserPanel);


            addlistener(self.LabelsBrowser,'SelectionChange',@(hObj,evt)self.reactToSelectionAndColormapChange());

            self.LabelColorPickerText=uicontrol('Parent',self.LabelSubpanel,...
            'Style','text',...
            'String',getString(message('images:volumeViewerToolgroup:color')),...
            'HorizontalAlignment','left',...
            'TooltipString',getString(message('images:volumeViewerToolgroup:labelColorPickerTooltip')));
            self.LabelColorPickerText.Units='points';
            self.LabelColorPickerText.Position(1:3)=[10,40,30];

            self.LabelColorPickerBtn=uicontrol('Parent',self.LabelSubpanel,...
            'Style','pushbutton',...
            'Tag','LabelColorPickerBtn',...
            'CData',makeColorPatch([0.5,0.0,0.0]),...
            'Callback',@(hObj,evt)self.pickLabelColor(),...
            'TooltipString',getString(message('images:volumeViewerToolgroup:labelColorPickerTooltip')));
            self.LabelColorPickerBtn.Units='points';
            self.LabelColorPickerBtn.Position=[40,40,28,28];

            self.ShowLabelCheckbox=uicontrol('Parent',self.LabelSubpanel,...
            'Style','checkbox',...
            'String',getString(message('images:volumeViewerToolgroup:showLabel')),...
            'Tag','ShowLabelToggle',...
            'Value',1,...
            'TooltipString',getString(message('images:volumeViewerToolgroup:labelShowToggleTooltipUnchecked')));
            self.ShowLabelCheckbox.Units='points';
            self.ShowLabelCheckbox.Position(1:3)=[100,40,90];
            self.ShowToggleListener=addlistener(self.ShowLabelCheckbox,'Value','PostSet',...
            @(hObj,evt)self.notifyOfShowFlagChange(evt.AffectedObject.Value));


            self.OpacitySliderSubpanel=uipanel('Parent',self.LabelSubpanel,...
            'BorderType','none',...
            'Units','normalized',...
            'Position',[0,0,1,0.12]);

            self.OpacitySliderText=uicontrol('Parent',self.OpacitySliderSubpanel,...
            'Style','text',...
            'String',getString(message('images:volumeViewerToolgroup:opacity')),...
            'HorizontalAlignment','left');
            self.OpacitySliderText.Units='points';
            self.OpacitySliderText.Position(1:3)=[10,10,60];

            self.OpacitySlider=uicontrol('Parent',self.OpacitySliderSubpanel,...
            'Style','Slider',...
            'Tag','LabelOpacitySlider',...
            'Min',0,...
            'Max',1,...
            'Value',1,...
            'TooltipString',getString(message('images:volumeViewerToolgroup:opacitySliderTooltip')));
            self.OpacitySlider.Units='points';
            self.OpacitySlider.Position(1:3)=[70,10,115];
            self.OpacitySliderListener=addlistener(self.OpacitySlider,'Value','PostSet',...
            @(hObj,evt)self.notifyOfOpacityChange(evt.AffectedObject.Value));


            self.VolumeSubpanel=uipanel(...
            'Parent',self.LabelVolumeRenderingPanel,...
            'Title',getString(message('images:volumeViewerToolgroup:viewVolumeButtonLabel')),...
            'Visible','on');
            self.VolumeSubpanel.Units='points';
            self.VolumeSubpanel.Position(1)=0;
            self.VolumeSubpanel.Position(4)=70;
            self.VolumeSubpanel.FontSize=self.VolumeSubpanel.FontSize+2;

            self.ThresholdSliderText=uicontrol('Parent',self.VolumeSubpanel,...
            'Style','text',...
            'String',getString(message('images:volumeViewerToolgroup:threshold')),...
            'HorizontalAlignment','left',...
            'TooltipString',getString(message('images:volumeViewerToolgroup:thresholdSliderTooltip')));
            self.ThresholdSliderText.Units='points';
            self.ThresholdSliderText.Position(1:3)=[10,45,60];

            self.ThresholdSlider=uicontrol('Parent',self.VolumeSubpanel,...
            'Style','Slider',...
            'Tag','VolumeThresholdSlider',...
            'Min',0,...
            'Max',255,...
            'Value',100,...
            'Units','points',...
            'TooltipString',getString(message('images:volumeViewerToolgroup:thresholdSliderTooltip')));
            self.ThresholdSlider.Position(1:3)=[70,45,115];

            self.VolumeOpacitySliderText=uicontrol('Parent',self.VolumeSubpanel,...
            'Style','text',...
            'String',getString(message('images:volumeViewerToolgroup:opacity')),...
            'HorizontalAlignment','left',...
            'TooltipString',getString(message('images:volumeViewerToolgroup:volumeOpacitySliderTooltip')));
            self.VolumeOpacitySliderText.Units='points';
            self.VolumeOpacitySliderText.Position(1)=10;
            self.VolumeOpacitySliderText.Position(3)=60;

            self.VolumeOpacitySlider=uicontrol('Parent',self.VolumeSubpanel,...
            'Style','Slider',...
            'Tag','VolumeOpacitySlider',...
            'Min',0,...
            'Max',1,...
            'Value',0.5,...
            'Units','points',...
            'TooltipString',getString(message('images:volumeViewerToolgroup:volumeOpacitySliderTooltip')));
            self.VolumeOpacitySlider.Position(1)=70;
            self.VolumeOpacitySlider.Position(3)=115;

        end
    end


    methods

        function reactToSelectionAndColormapChange(self)
            browser=self.LabelsBrowser;


            if numel(browser.CurrentSelection)==1

                labelIdx=browser.CurrentSelection;
                opacity=browser.LabelConfiguration.Opacities(labelIdx);
                color=browser.LabelConfiguration.LabelColors(labelIdx,:);
                showFlag=browser.LabelConfiguration.ShowFlags(labelIdx);
            else




                labelIdx=browser.CurrentSelection(1);
                opacity=browser.LabelConfiguration.Opacities(labelIdx);
                for k=2:numel(browser.CurrentSelection)
                    labelIdx=browser.CurrentSelection(k);
                    if opacity~=browser.LabelConfiguration.Opacities(labelIdx)
                        opacity=1;
                        break
                    end
                end



                labelIdx=browser.CurrentSelection(1);
                color=browser.LabelConfiguration.Colormap(labelIdx,:);
                for k=2:numel(browser.CurrentSelection)
                    labelIdx=browser.CurrentSelection(k);
                    if any(color~=browser.LabelConfiguration.Colormap(labelIdx,:))
                        color=uint8([255,255,255]);
                        break
                    end
                end



                labelIdx=browser.CurrentSelection(1);
                showFlag=browser.LabelConfiguration.ShowFlags(labelIdx);
                for k=2:numel(browser.CurrentSelection)
                    labelIdx=browser.CurrentSelection(k);
                    if showFlag~=browser.LabelConfiguration.ShowFlags(labelIdx)
                        showFlag=true;
                        break
                    end
                end
            end


            self.OpacitySliderListener.Enabled=false;
            self.ShowToggleListener.Enabled=false;


            self.OpacitySlider.Value=min(1,max(0,opacity));
            self.LabelColorPickerBtn.CData=makeColorPatch(color);
            if showFlag
                self.ShowLabelCheckbox.Value=self.ShowLabelCheckbox.Max;
                self.ShowLabelCheckbox.TooltipString=getString(message('images:volumeViewerToolgroup:labelShowToggleTooltipChecked'));
            else
                self.ShowLabelCheckbox.Value=self.ShowLabelCheckbox.Min;
                self.ShowLabelCheckbox.TooltipString=getString(message('images:volumeViewerToolgroup:labelShowToggleTooltipUnchecked'));
            end


            self.OpacitySliderListener.Enabled=true;
            self.ShowToggleListener.Enabled=true;
        end

        function selectAllLabels(self)
            allLabels=1:self.LabelsBrowser.NumberOfThumbnails;
            self.LabelsBrowser.setSelection(allLabels);
        end

        function invertSelection(self)
            selection=self.LabelsBrowser.CurrentSelection;
            mask=true(1,self.LabelsBrowser.NumberOfThumbnails);
            mask(selection)=false;
            inverseSelection=find(mask);
            if isempty(inverseSelection)

                inverseSelection=1;
            end
            self.LabelsBrowser.setSelection(inverseSelection);
        end

        function notifyOfOpacityChange(self,opacity)
            self.ShowToggleListener.Enabled=false;
            if opacity==0
                self.ShowLabelCheckbox.Value=false;
            else
                self.ShowLabelCheckbox.Value=true;
            end
            self.ShowToggleListener.Enabled=true;

            labelIdx=self.LabelsBrowser.CurrentSelection;
            self.notify('LabelOpacityChange',images.internal.app.volviewToolgroup.LabelRenderingChangeEventData(...
            labelIdx,opacity));
        end

        function pickLabelColor(self)
            import images.internal.app.volviewToolgroup.*

            labelIdx=self.LabelsBrowser.CurrentSelection;
            oldcolor=reshape(self.LabelColorPickerBtn.CData(1,1,:),[1,3]);
            newcolor=uisetcolor(oldcolor);

            if~isequal(oldcolor,newcolor)

                self.LabelColorPickerBtn.CData=makeColorPatch(newcolor);


                self.LabelsBrowser.recreateThumbnails(labelIdx);


                self.notify('LabelColorChange',LabelRenderingChangeEventData(labelIdx,newcolor))
            end
        end

        function notifyOfShowFlagChange(self,value)
            import images.internal.app.volviewToolgroup.*
            showFlag=logical(value);

            self.OpacitySliderListener.Enabled=false;
            self.OpacitySlider.Value=value;
            self.OpacitySliderListener.Enabled=true;


            if showFlag
                self.ShowLabelCheckbox.TooltipString=getString(message('images:volumeViewerToolgroup:labelShowToggleTooltipChecked'));
            else
                self.ShowLabelCheckbox.TooltipString=getString(message('images:volumeViewerToolgroup:labelShowToggleTooltipUnchecked'));
            end

            labelIdx=self.LabelsBrowser.CurrentSelection;
            self.notify('LabelShowFlagChange',LabelRenderingChangeEventData(labelIdx,showFlag));
        end
    end


    methods
        function set.LabelMode(self,mode)

            if strcmp(mode,'labels')
                self.OpacitySliderText.Enable='on';
                self.OpacitySlider.Enable='on';

                self.ThresholdSliderText.Enable='off';
                self.ThresholdSlider.Enable='off';
                self.VolumeOpacitySliderText.Enable='off';
                self.VolumeOpacitySlider.Enable='off';
            else
                self.OpacitySliderText.Enable='off';
                self.OpacitySlider.Enable='off';

                self.ThresholdSliderText.Enable='on';
                self.ThresholdSlider.Enable='on';
                self.VolumeOpacitySliderText.Enable='on';
                self.VolumeOpacitySlider.Enable='on';


            end
        end
    end


end

function cdata=makeColorPatch(color)
    cdata=ones(32,32,3).*reshape(im2double(color),[1,1,3]);
end