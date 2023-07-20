classdef VolumeRenderingSettingsEditorWeb<handle




    properties(SetAccess=private,GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.volview.Controller,...
        ?images.internal.app.volview.View})

        Panel matlab.ui.container.Panel

        VolumeRenderingPanel matlab.ui.container.Panel
        LightingPanel matlab.ui.container.Panel
        IsosurfacePanel matlab.ui.container.Panel

        LabelVolumeRenderingPanel matlab.ui.container.Panel

        RenderingStylePopup matlab.ui.control.DropDown

        EmbedLabelsCheckbox matlab.ui.control.CheckBox

    end

    properties(SetAccess=private,GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.volview.Controller})

AlphaMapEditor
ColorMapEditor

LabelsBrowser

    end


    properties(SetAccess=private,GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.volview.Controller})

LightingToggle


IsovalSlider
IsovalSliderText
IsosurfaceColorButton
IsosurfaceColor

ColorMapEditorPanel


UseShaders

    end


    properties(SetAccess=private,GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.volview.Controller})

LabelBrowserPanel
OpacitySliderSubpanel
LabelSubpanel
VolumeSubpanel
ColormapList



LabelSelectAllBtn
LabelInvertSelectionBtn
OpacitySliderText
OpacitySlider
LabelColorPickerText
LabelColorPickerBtn
ShowLabelCheckbox

ThresholdSliderText
ThresholdSlider
VolumeOpacitySliderText
VolumeOpacitySlider

LabelSubPanelGrid

    end

    properties(Dependent)
Enable
LabelMode
    end

    properties(Constant)

        Border=20
        UIComponentHeight=20;

        MaxLabelBrowserPanelHeight=200;

    end

    events

RenderingTechniqueChanged

IsovalueChanged
IsosurfaceColorChange

LightingToggled

ColormapChange
AlphamapChange

LabelOverlayViewToggled
LabelOpacityChange
LabelColorChange
LabelShowFlagChange
OverlayOpacityThresholdChanged
OverlayVolumeOpacityChanged

BringAppInFocus

    end

    methods

        function self=VolumeRenderingSettingsEditorWeb(hFig)

            self.Panel=uipanel('Parent',hFig,...
            'BorderType','none',...
            'Units','normalized',...
            'Visible','off',...
            'Position',[0,0,1,1],...
            'AutoResizeChildren','off',...
            'SizeChangedFcn',@(~,~)self.manageResize());

            panelUnits=self.Panel.Units;
            self.Panel.Units='pixels';
            hParentPos=self.Panel.Position;
            hParentPos(hParentPos<1)=1;
            self.Panel.Units=panelUnits;


            renderingStyleDropdownPos=[self.Border,hParentPos(4)-self.Border-self.UIComponentHeight,...
            300,self.UIComponentHeight];

            self.UseShaders=iptgetpref('VolumeViewerUseHardware');

            if self.UseShaders
                items={getString(message('images:volumeViewer:volRenderingCategoryName')),...
                getString(message('images:volumeViewer:mipCategoryName')),...
                getString(message('images:volumeViewer:isosurfaceCategoryName'))};
                itemsData=1:3;

            else
                items={getString(message('images:volumeViewer:volRenderingCategoryName')),...
                getString(message('images:volumeViewer:mipCategoryName'))};
                itemsData=1:2;
            end

            self.RenderingStylePopup=uidropdown('Parent',self.Panel,...
            'Items',items,...
            'ItemsData',itemsData,...
            'Value',1,...
            'Position',renderingStyleDropdownPos,...
            'Tag','renderingStylePopup',...
            'Tooltip',getString(message('images:volumeViewer:renderingStyleDescription')),...
            'ValueChangedFcn',@(~,evt)self.notify('RenderingTechniqueChanged',evt));


            renderingPanelPos=[self.Border,1,300,hParentPos(4)-2*self.Border-self.UIComponentHeight];

            self.IsosurfacePanel=uipanel('Parent',self.Panel,...
            'BorderType','none',...
            'Units','pixels',...
            'Visible','off',...
            'Position',renderingPanelPos);

            self.VolumeRenderingPanel=uipanel('Parent',self.Panel,...
            'BorderType','none',...
            'Units','pixels',...
            'Visible','off',...
            'Position',renderingPanelPos);


            labelRenderingPanelPos=[self.Border,1,300,hParentPos(4)];
            self.LabelVolumeRenderingPanel=uipanel('Parent',self.Panel,...
            'BorderType','none',...
            'Visible','off',...
            'Units','pixels',...
            'Position',labelRenderingPanelPos);

            self.ColormapList=images.internal.app.volview.MapListManager('labelColormap');


            self.layoutIsosurfacePanel();
            self.layoutVolumeRenderingPanel();
            self.layoutLabelVolumeRenderingPanel();

        end

        function delete(self)
            delete(self.LabelsBrowser);
            delete(self.AlphaMapEditor);
            delete(self.ColorMapEditor);
        end

    end


    methods

        function set.Enable(self,TF)

            if TF
                self.RenderingStylePopup.Enable='on';
                self.LightingToggle.Enable='on';
                self.IsovalSlider.Enable='on';
                self.IsovalSliderText.Enable='on';
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
                self.IsovalSliderText.Enable='off';
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

        function setLabelConfiguration(self,config)
            self.LabelsBrowser.LabelConfiguration=config;

            usedHeight=self.LabelsBrowser.getUsedHeight();
            labelBrowserPanelHeight=min(self.MaxLabelBrowserPanelHeight,usedHeight);


            self.LabelSubPanelGrid.RowHeight{2}=labelBrowserPanelHeight;

        end

        function setIsosurfaceColor(self,color)
            self.IsosurfaceColor=color;
        end

    end



    methods(Access=private)

        function layoutIsosurfacePanel(self)

            grid1=uigridlayout('Parent',self.IsosurfacePanel,...
            'ColumnWidth',{'fit','1x'},...
            'RowHeight',{'fit','fit',10,'fit'},...
            'RowSpacing',0);

            self.IsovalSliderText=uilabel('Parent',grid1,...
            'Tag','isosurfaceSliderText',...
            'Text',getString(message('images:volumeViewer:isovalue')),...
            'FontSize',12);
            self.IsovalSliderText.Layout.Row=1;
            self.IsovalSliderText.Layout.Column=1;

            grid2=uigridlayout(grid1,[1,1]);
            grid2.Layout.Row=2;
            grid2.Layout.Column=[1,2];

            self.IsovalSlider=uislider('Parent',grid2,...
            'Limits',[0,1],...
            'Value',0.5,...
            'Tag','isosurfaceSlider',...
            'MajorTicks',[],...
            'MajorTickLabels',{},...
            'MinorTicks',[],...
            'Tooltip',getString(message('images:volumeViewer:isovalSlider')),...
            'ValueChangingFcn',@(~,evt)self.notify('IsovalueChanged',evt));
            self.IsovalSlider.Layout.Row=1;
            self.IsovalSlider.Layout.Column=[1,2];

            self.IsosurfaceColorButton=uibutton('Parent',grid1,...
            'Text',getString(message('images:volumeViewer:color')),...
            'FontSize',12,...
            'HorizontalAlignment','center',...
            'Tag','isosurfaceColorButton',...
            'ButtonPushedFcn',@(hobj,evt)self.setIsocolorPush(),...
            'Tooltip',getString(message('images:volumeViewer:isosurfaceColorTooltip')));
            self.IsosurfaceColorButton.Layout.Row=4;
            self.IsosurfaceColorButton.Layout.Column=1;

            self.IsosurfaceColor=[1,0,0];

        end

        function layoutVolumeRenderingPanel(self)

            alphamapPanelHeight=340;
            colormapPanelHeight=130;
            lightingPanelHeight=50;
            controlHeight=30;
            gapBewteenPanels=30;

            grid=uigridlayout('Parent',self.VolumeRenderingPanel,...
            'RowHeight',{alphamapPanelHeight,colormapPanelHeight,lightingPanelHeight},...
            'ColumnWidth',{'1x'},...
            'RowSpacing',gapBewteenPanels,...
            'ColumnSpacing',0,...
            'Padding',0,...
            'Scrollable','on');


            amapEditorPanel=uipanel('Parent',grid,...
            'Units','pixels',...
            'BorderType','none',...
            'FontWeight','bold',...
            'Title',getString(message('images:volumeViewer:alpha')));
            amapEditorPanel.Layout.Row=1;
            amapEditorPanel.Layout.Column=1;

            self.AlphaMapEditor=images.internal.app.volview.AlphamapEditorWeb(amapEditorPanel,...
            [0,0;1.0,1.0]);



            self.ColorMapEditorPanel=uipanel('Parent',grid,...
            'Units','Pixels',...
            'BorderType','none',...
            'FontWeight','bold',...
            'Title',getString(message('images:volumeViewer:color')));
            self.ColorMapEditorPanel.Layout.Row=2;
            self.ColorMapEditorPanel.Layout.Column=1;

            colorPoints=[0,0,0,0;1.0,1.0,1.0,1.0];
            self.ColorMapEditor=images.internal.app.volview.ColormapDesignerWeb(self.ColorMapEditorPanel,colorPoints);


            self.LightingPanel=uipanel('Parent',grid,...
            'Units','Pixels',...
            'BorderType','none',...
            'FontWeight','bold',...
            'Title',getString(message('images:volumeViewer:illumination')));
            self.LightingPanel.Layout.Row=3;
            self.LightingPanel.Layout.Column=1;

            if self.UseShaders

                self.LightingToggle=uicheckbox('Parent',self.LightingPanel,...
                'Text',getString(message('images:volumeViewer:lighting')),...
                'Position',[self.Border,1,100,controlHeight],...
                'Tag','LightingToggle',...
                'Tooltip',getString(message('images:volumeViewer:lightingTooltip')),...
                'ValueChangedFcn',@(~,evt)self.notify('LightingToggled',evt));

            end

        end

    end


    methods(Access=private)

        function setIsocolorPush(self)

            import images.internal.app.volview.events.*

            newcolor=uisetcolor(self.IsosurfaceColor);
            self.notify('BringAppInFocus');
            self.notify('IsosurfaceColorChange',ColormapChangeEventData(newcolor));

        end

        function manageResize(self)

            panelUnits=self.Panel.Units;
            self.Panel.Units='pixels';
            hParentPos=self.Panel.Position;
            self.Panel.Units=panelUnits;

            pos=[self.Border,hParentPos(4)-self.Border-self.UIComponentHeight,...
            300,self.UIComponentHeight];
            pos(pos<1)=1;
            self.RenderingStylePopup.Position=pos;

            pos=[self.Border,1,300,hParentPos(4)-2*self.Border-self.UIComponentHeight];
            pos(pos<1)=1;
            self.IsosurfacePanel.Position=pos;
            self.VolumeRenderingPanel.Position=pos;


            pos=[self.Border,1,300,hParentPos(4)];
            pos(pos<1)=1;
            self.LabelVolumeRenderingPanel.Position=pos;

        end

    end




    methods(Access=private)

        function layoutLabelVolumeRenderingPanel(self)

            labelSubpanelHeight=335;
            volumeSubpanelHeight=80;

            hParentPos=self.LabelVolumeRenderingPanel.Position;

            pos=[1,hParentPos(4)-self.Border-self.UIComponentHeight-self.Border-labelSubpanelHeight-2*self.Border-volumeSubpanelHeight,...
            hParentPos(3),...
            volumeSubpanelHeight+2*self.Border+labelSubpanelHeight+self.Border+self.UIComponentHeight];
            panel=uipanel('Parent',self.LabelVolumeRenderingPanel,...
            'Units','pixels',...
            'Position',pos,...
            'BorderType','none',...
            'BackgroundColor','k');

            grid=uigridlayout('Parent',panel,...
            'ColumnWidth',{'1x'},...
            'RowHeight',{20,'fit','fit'},...
            'RowSpacing',self.Border,...
            'Padding',0);

            self.EmbedLabelsCheckbox=uicheckbox('Parent',grid,...
            'Text',getString(message('images:volumeViewer:embedLabels')),...
            'Tag','EmbedLabelsToggle',...
            'Value',1,...
            'FontSize',12,...
            'ValueChangedFcn',@(~,evt)self.notify('LabelOverlayViewToggled',evt),...
            'Tooltip',getString(message('images:volumeViewer:embedLabelsTooltip')));
            self.EmbedLabelsCheckbox.Layout.Column=1;
            self.EmbedLabelsCheckbox.Layout.Row=1;


            self.LabelSubpanel=uipanel(...
            'Parent',grid,...
            'Title',getString(message('images:volumeViewer:viewLabelsButtonLabel')),...
            'FontSize',12,...
            'FontWeight','bold',...
            'BorderType','none',...
            'Visible','on');
            self.LabelSubpanel.Layout.Column=1;
            self.LabelSubpanel.Layout.Row=2;


            self.VolumeSubpanel=uipanel(...
            'Parent',grid,...
            'Title',getString(message('images:volumeViewer:volumeOverlayDocumentName')),...
            'FontSize',12,...
            'FontWeight','bold',...
            'BorderType','none',...
            'Visible','on');
            self.VolumeSubpanel.Layout.Column=1;
            self.VolumeSubpanel.Layout.Row=3;

            self.layoutLabelSubpanel();
            self.layoutVolumeSubpanel();

        end

        function layoutLabelSubpanel(self)

            outerGridColumnSpacing=10;
            outerGridColumnWidth=120;

            labelBrowserPanelHeight=self.MaxLabelBrowserPanelHeight;

            grid=uigridlayout('Parent',self.LabelSubpanel,...
            'ColumnWidth',{outerGridColumnWidth,outerGridColumnWidth},...
            'RowHeight',{'fit',labelBrowserPanelHeight,32,'fit'},...
            'ColumnSpacing',outerGridColumnSpacing);
            self.LabelSubPanelGrid=grid;

            self.LabelSelectAllBtn=uibutton('Parent',grid,...
            'Tag','LabelSelectAllBtn',...
            'Text',getString(message('images:volumeViewer:selectAll')),...
            'ButtonPushedFcn',@(hObj,evt)self.selectAllLabels(),...
            'Tooltip',getString(message('images:volumeViewer:selectAllBtnTooltip')));
            self.LabelSelectAllBtn.Layout.Row=1;
            self.LabelSelectAllBtn.Layout.Column=1;

            self.LabelInvertSelectionBtn=uibutton('Parent',grid,...
            'Tag','LabelInvertSelectionBtn',...
            'Text',getString(message('images:volumeViewer:invertSelection')),...
            'ButtonPushedFcn',@(hObj,evt)self.invertSelection(),...
            'Tooltip',getString(message('images:volumeViewer:invertSelectionBtnTooltip')));
            self.LabelSelectAllBtn.Layout.Row=1;
            self.LabelSelectAllBtn.Layout.Column=1;

            grid1=uigridlayout('Parent',grid,...
            'ColumnWidth',{'1x'},...
            'RowHeight',{'fit'},...
            'Padding',0);
            grid1.Layout.Row=2;
            grid1.Layout.Column=[1,2];

            hPanel=uipanel('Parent',grid1,...
            'BorderType','none',...
            'Tag','LabelBrowserPanel',...
            'Units','pixels',...
            'AutoResizeChildren','off',...
            'BackgroundColor','r');
            hPanel.Layout.Row=1;
            hPanel.Layout.Column=1;




            self.LabelBrowserPanel=uipanel('Parent',hPanel,...
            'BorderType','none',...
            'Units','normalized',...
            'Position',[0,0,1,1],...
            'AutoResizeChildren','off',...
            'BackgroundColor','g');


            self.LabelBrowserPanel.Units='pixels';
            self.LabelBrowserPanel.Position=[1,21,250,200];

            self.LabelsBrowser=images.internal.app.volview.LabelsBrowserWeb(self.LabelBrowserPanel);



            addlistener(self.LabelsBrowser,'SelectionChange',@(hObj,evt)self.reactToSelectionAndColormapChange());

            grid2=uigridlayout('Parent',grid,...
            'ColumnWidth',{'fit',32},...
            'RowHeight',32,...
            'Padding',0);
            grid2.Layout.Row=3;
            grid2.Layout.Column=1;

            self.LabelColorPickerText=uilabel('Parent',grid2,...
            'Text',getString(message('images:volumeViewer:color')),...
            'HorizontalAlignment','left',...
            'FontSize',12,...
            'FontWeight','normal',...
            'Tooltip',getString(message('images:volumeViewer:labelColorPickerTooltip')));
            self.LabelColorPickerText.Layout.Row=1;
            self.LabelColorPickerText.Layout.Column=1;

            self.LabelColorPickerBtn=uibutton('Parent',grid2,...
            'Tag','LabelColorPickerBtn',...
            'Icon',makeColorPatch([0.5,0.0,0.0]),...
            'Text','',...
            'HorizontalAlignment','center',...
            'VerticalAlignment','center',...
            'IconAlignment','center',...
            'ButtonPushedFcn',@(hObj,evt)self.pickLabelColor(),...
            'Tooltip',getString(message('images:volumeViewer:labelColorPickerTooltip')));
            self.LabelColorPickerBtn.Layout.Row=1;
            self.LabelColorPickerBtn.Layout.Column=2;

            self.ShowLabelCheckbox=uicheckbox('Parent',grid,...
            'Text',getString(message('images:volumeViewer:showLabel')),...
            'Tag','ShowLabelToggle',...
            'Value',1,...
            'ValueChangedFcn',@(hObj,evt)self.notifyOfShowFlagChange(evt.Value),...
            'Tooltip',getString(message('images:volumeViewer:labelShowToggleTooltipUnchecked')));
            self.ShowLabelCheckbox.Layout.Row=3;
            self.ShowLabelCheckbox.Layout.Column=2;


            grid3=uigridlayout('Parent',grid,...
            'ColumnWidth',{60,'1x'},...
            'RowHeight',{'fit'},...
            'Padding',0);
            grid3.Layout.Row=4;
            grid3.Layout.Column=[1,2];

            self.OpacitySliderText=uilabel('Parent',grid3,...
            'Text',getString(message('images:volumeViewer:opacity')),...
            'HorizontalAlignment','left',...
            'VerticalAlignment','center');
            self.OpacitySliderText.Layout.Row=1;
            self.OpacitySliderText.Layout.Column=1;

            self.OpacitySlider=uislider('Parent',grid3,...
            'Tag','LabelOpacitySlider',...
            'Limits',[0,1],...
            'Value',1,...
            'MajorTicks',[],...
            'MajorTickLabels',{},...
            'MinorTicks',[],...
            'ValueChangingFcn',@(hObj,evt)self.notifyOfOpacityChange(evt.Value),...
            'Tooltip',getString(message('images:volumeViewer:opacitySliderTooltip')));
            self.OpacitySlider.Layout.Row=1;
            self.OpacitySlider.Layout.Column=2;

        end

        function layoutVolumeSubpanel(self)

            grid=uigridlayout('Parent',self.VolumeSubpanel,...
            'ColumnWidth',{60,180},...
            'RowHeight',{'fit','fit'});

            self.ThresholdSliderText=uilabel('Parent',grid,...
            'Text',getString(message('images:volumeViewer:threshold')),...
            'HorizontalAlignment','left',...
            'Tooltip',getString(message('images:volumeViewer:thresholdSliderTooltip')));
            self.ThresholdSliderText.Layout.Row=1;
            self.ThresholdSliderText.Layout.Column=1;

            self.ThresholdSlider=uislider('Parent',grid,...
            'Tag','VolumeThresholdSlider',...
            'Limits',[0,255],...
            'Value',100,...
            'MajorTicks',[],...
            'MajorTickLabels',{},...
            'MinorTicks',[],...
            'ValueChangingFcn',@(hObj,evt)self.notify('OverlayOpacityThresholdChanged',evt),...
            'Tooltip',getString(message('images:volumeViewer:thresholdSliderTooltip')));
            self.ThresholdSlider.Layout.Row=1;
            self.ThresholdSlider.Layout.Column=2;

            self.VolumeOpacitySliderText=uilabel('Parent',grid,...
            'Text',getString(message('images:volumeViewer:opacity')),...
            'HorizontalAlignment','left',...
            'Tooltip',getString(message('images:volumeViewer:volumeOpacitySliderTooltip')));
            self.VolumeOpacitySliderText.Layout.Row=2;
            self.VolumeOpacitySliderText.Layout.Column=1;

            self.VolumeOpacitySlider=uislider('Parent',grid,...
            'Tag','VolumeOpacitySlider',...
            'Limits',[0,1],...
            'Value',0.5,...
            'MajorTicks',[],...
            'MajorTickLabels',{},...
            'MinorTicks',[],...
            'ValueChangingFcn',@(hObj,evt)self.notify('OverlayVolumeOpacityChanged',evt),...
            'Tooltip',getString(message('images:volumeViewer:volumeOpacitySliderTooltip')));
            self.VolumeOpacitySlider.Layout.Row=2;
            self.VolumeOpacitySlider.Layout.Column=2;

        end

    end


    methods(Access=private)

        function reactToSelectionAndColormapChange(self)
            browser=self.LabelsBrowser;

            if isempty(browser.SelectedEntires)
                self.LabelColorPickerBtn.Enable=false;
                self.ShowLabelCheckbox.Enable=false;
                return
            else
                self.LabelColorPickerBtn.Enable=true;
                self.ShowLabelCheckbox.Enable=true;
            end


            if numel(browser.SelectedEntires)==1

                labelIdx=browser.SelectedEntires;
                opacity=browser.LabelConfiguration.Opacities(labelIdx);
                color=browser.LabelConfiguration.LabelColors(labelIdx,:);
                showFlag=browser.LabelConfiguration.ShowFlags(labelIdx);
            else




                labelIdx=browser.SelectedEntires(1);
                opacity=browser.LabelConfiguration.Opacities(labelIdx);
                for k=2:numel(browser.SelectedEntires)
                    labelIdx=browser.SelectedEntires(k);
                    if opacity~=browser.LabelConfiguration.Opacities(labelIdx)
                        opacity=1;
                        break
                    end
                end



                labelIdx=browser.SelectedEntires(1);
                color=browser.LabelConfiguration.Colormap(labelIdx,:);
                for k=2:numel(browser.SelectedEntires)
                    labelIdx=browser.SelectedEntires(k);
                    if any(color~=browser.LabelConfiguration.Colormap(labelIdx,:))
                        color=uint8([255,255,255]);
                        break
                    end
                end



                labelIdx=browser.SelectedEntires(1);
                showFlag=browser.LabelConfiguration.ShowFlags(labelIdx);
                for k=2:numel(browser.SelectedEntires)
                    labelIdx=browser.SelectedEntires(k);
                    if showFlag~=browser.LabelConfiguration.ShowFlags(labelIdx)
                        showFlag=true;
                        break
                    end
                end
            end


            self.OpacitySlider.Value=min(1,max(0,opacity));
            self.LabelColorPickerBtn.Icon=makeColorPatch(color);
            if showFlag
                self.ShowLabelCheckbox.Value=true;
                self.ShowLabelCheckbox.Tooltip=getString(message('images:volumeViewer:labelShowToggleTooltipChecked'));
            else
                self.ShowLabelCheckbox.Value=false;
                self.ShowLabelCheckbox.Tooltip=getString(message('images:volumeViewer:labelShowToggleTooltipUnchecked'));
            end

        end

        function selectAllLabels(self)
            allLabels=1:self.LabelsBrowser.LabelConfiguration.NumLabels;
            self.LabelsBrowser.SelectedEntires=allLabels;

            self.reactToSelectionAndColormapChange();
        end

        function invertSelection(self)
            selection=self.LabelsBrowser.SelectedEntires;
            mask=true(1,self.LabelsBrowser.LabelConfiguration.NumLabels);
            mask(selection)=false;
            inverseSelection=find(mask);
            if isempty(inverseSelection)

                inverseSelection=1;
            end
            self.LabelsBrowser.SelectedEntires=inverseSelection;

            self.reactToSelectionAndColormapChange();
        end

        function notifyOfOpacityChange(self,opacity)

            if opacity==0
                self.ShowLabelCheckbox.Value=false;
            else
                self.ShowLabelCheckbox.Value=true;
            end

            labelIdx=self.LabelsBrowser.SelectedEntires;
            self.notify('LabelOpacityChange',images.internal.app.volview.events.LabelRenderingChangeEventData(...
            labelIdx,opacity));
        end

        function pickLabelColor(self)
            import images.internal.app.volview.events.*

            labelIdx=self.LabelsBrowser.SelectedEntires;
            oldcolor=reshape(self.LabelColorPickerBtn.Icon(1,1,:),[1,3]);
            newcolor=uisetcolor(oldcolor);
            self.notify('BringAppInFocus');

            if~isequal(oldcolor,newcolor)

                self.LabelColorPickerBtn.Icon=makeColorPatch(newcolor);


                self.LabelsBrowser.updateColor(labelIdx,newcolor);


                self.notify('LabelColorChange',LabelRenderingChangeEventData(labelIdx,newcolor))
            end
        end

        function notifyOfShowFlagChange(self,value)

            import images.internal.app.volview.events.*
            showFlag=logical(value);

            self.OpacitySlider.Value=double(value);


            if showFlag
                self.ShowLabelCheckbox.Tooltip=getString(message('images:volumeViewer:labelShowToggleTooltipChecked'));
            else
                self.ShowLabelCheckbox.Tooltip=getString(message('images:volumeViewer:labelShowToggleTooltipUnchecked'));
            end

            labelIdx=self.LabelsBrowser.SelectedEntires;
            self.notify('LabelShowFlagChange',LabelRenderingChangeEventData(labelIdx,showFlag));

        end

    end


end

function cdata=makeColorPatch(color)
    cdata=ones(32,32,3).*reshape(im2double(color),[1,1,3]);
end
