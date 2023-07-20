




classdef View<handle

    properties(Transient=true,SetAccess=private,...
        GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.volview.VolumeViewer,...
        ?images.internal.app.volview.Controller})
App
    end

    properties(Dependent)
VolumeMode
    end


    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)
VolVizTab
Display3DTab
    end

    properties(Access={?uitest.factory.Tester,...
        ?images.internal.app.volview.Controller})
VolumeSource
LabeledVolumeSource
    end


    properties(SetAccess=private,GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.volview.Controller})

xySliceFig
yzSliceFig
xzSliceFig


xySliceView
yzSliceView
xzSliceView


volumeRenderingFig
GridLayout


volumeRenderingView


renderingEditorFigure


renderingEditorView


orientationAxesFigure


orientationAxesView


ImportFromWorkspaceDlg
ExportDlg
    end


    properties(Access=private)



        volumeDocGroupTag='3DView';
        slicesDocGroupTag='2DSlice';

        volumeDocumentTag='volumeFig';
        xySliceDocumentTag='xySlice';
        yzSliceDocumentTag='yzSlice';
        xzSliceDocumentTag='xzSlice';

        AppCloseAttempted(1,1)logical=false;

        AppCloseAllowed(1,1)logical=true;

    end


    properties(SetAccess=private,GetAccess={?uitest.factory.Tester,...
        ?images.internal.app.volview.Controller})

NewSessionButton

ShowSlicesToggleButton
ShowVolumeToggleButton


CustomReferencingButton
UniformInWorldButton
UseFileMetadataButton


XAxisLabel
YAxisLabel
ZAxisLabel


XUnitsLabel
YUnitsLabel
ZUnitsLabel


XAxisUnitsEditField
YAxisUnitsEditField
ZAxisUnitsEditField

VolumeModeButton
LabelModeButton

RestoreDefaultButton
OrientationAxesToggleButton
BackgroundColorButton
GradientColorButton
UseGradientButton
DefaultLayoutButton
ExportButton
ExportConfigSubitem

IconRoot
NewSessionIcon
ImportVolume
ImportLabeledVolume
SliceIcon
VolIcon
LabelVolIcon
IsoIcon
MipIcon
RestoreIcon
ExportRenderingIcon
ExportIcon
OrientationAxesIcon
LayoutStackedIcon

    end

    events

ImportFromFile
ImportFromDicomFolder
ImportFromWorkspace
StartNewSession
BackgroundColorChange
ReplaceOrOverlayResult
VolumeDisplayChangeRequested

    end


    methods

        function self=View(setViewBusy)

            self.VolumeSource="";
            self.LabeledVolumeSource="";

            self.createAndSetupUIContainerApp(setViewBusy);

        end

        function delete(self)

            if~isempty(self.App)&&isvalid(self.App)
                imageslib.internal.apputil.manageToolInstances('remove','volumeViewer',self.App);
            end




            delete(self.renderingEditorView);
            delete(self.renderingEditorFigure);


            self.App.close();

        end

    end


    methods(Access=private)

        function createAndSetupUIContainerApp(self,setViewBusy)


            [x,y,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition();
            appOptions.Title=getString(message('images:volumeViewer:appName'));
            appOptions.Tag="VolumeViewer"+"_"+matlab.lang.internal.uuid;
            appOptions.Icon=fullfile(matlabroot,'toolbox','images','icons','volume_24.png');
            appOptions.DefaultLayout=self.getDefaultLayout();
            appOptions.WindowBounds=[x,y,width,height];
            appOptions.Product="Image Processing Toolbox";
            appOptions.Scope="Volume Viewer";
            self.App=matlab.ui.container.internal.AppContainer(appOptions);


            helpButton=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            addlistener(helpButton,'ButtonPushed',@(~,~)doc('volumeViewer'));
            self.App.add(helpButton);


            self.createIcons();
            self.createToolstripTabs();
            self.layoutTabs();


            self.addDocuments();

            self.appCloseAllowed(false);
            c1=onCleanup(@()self.appCloseAllowed(true));

            self.App.CanCloseFcn=@(~)self.canTheAppClose();


            self.App.Visible=true;

            if setViewBusy
                self.showAsBusy();
            else
                self.unshowAsBusy()
            end

            self.waitforFiguresToBeReady();

            if self.App.State~=matlab.ui.container.internal.appcontainer.AppState.RUNNING
                waitfor(self.App,'State');
            end

            if~isvalid(self.App)||isequal(self.App.State,matlab.ui.container.internal.appcontainer.AppState.TERMINATED)
                delete(self);
                return
            end

            drawnow;
            self.renderApp();

            if self.AppCloseAttempted
                delete(self)
            end

        end

        function waitforFiguresToBeReady(self)

            waitfor(self.xySliceFig,'FigureViewReady','on');
            waitfor(self.yzSliceFig,'FigureViewReady','on');
            waitfor(self.xzSliceFig,'FigureViewReady','on');
            waitfor(self.volumeRenderingFig,'FigureViewReady','on');
            waitfor(self.renderingEditorFigure,'FigureViewReady','on');

        end

        function renderApp(self)

            if isvalid(self.App)


                self.create2DSliceViewsWeb();


                self.createVolumeRenderingSettingsView();



                drawnow;


                self.createVolumeRenderingView();

            end

        end

        function TF=canTheAppClose(self)

            if~isvalid(self)
                TF=true;
                self.delete();
                return
            end

            self.AppCloseAttempted=true;
            if self.AppCloseAllowed
                TF=true;
                self.delete();
            else
                TF=false;
            end

        end

    end


    methods(Access=private)

        function createIcons(self)

            import matlab.ui.internal.toolstrip.*

            self.IconRoot=fullfile(matlabroot,'toolbox','images','icons');
            self.ImportVolume=Icon(fullfile(self.IconRoot,'importVolume_24.png'));
            self.ImportLabeledVolume=Icon(fullfile(self.IconRoot,'importLabeledVolume_24.png'));
            self.NewSessionIcon=matlab.ui.internal.toolstrip.Icon.NEW_24;
            self.SliceIcon=Icon(fullfile(self.IconRoot,'slice_plane_24.png'));
            self.VolIcon=Icon(fullfile(self.IconRoot,'volume_24.png'));
            self.LabelVolIcon=Icon(fullfile(self.IconRoot,'LabelVolume_24.png'));
            self.IsoIcon=Icon(fullfile(self.IconRoot,'isosurface_24.png'));
            self.MipIcon=Icon(fullfile(self.IconRoot,'mip_24.png'));
            self.RestoreIcon=Icon(fullfile(self.IconRoot,'Reset_24.png'));
            self.ExportIcon=Icon(fullfile(self.IconRoot,'CreateMask_24px.png'));
            self.ExportRenderingIcon=Icon(fullfile(self.IconRoot,'ExportRendering_24.png'));
            self.OrientationAxesIcon=Icon(fullfile(self.IconRoot,'Volume_OrientationAxes_24.png'));

        end

        function createToolstripTabs(self)

            import matlab.ui.internal.toolstrip.*

            tabgroup=TabGroup();
            tabgroup.Tag='VolumeViewerTabgroup';

            tabName=getString(message('images:volumeViewer:volVizTabName'));
            self.VolVizTab=matlab.ui.internal.toolstrip.Tab(tabName);
            tabgroup.add(self.VolVizTab);
            self.VolVizTab.Tag='tab_vol_viz';
            self.App.addTabGroup(tabgroup);

            tabName=getString(message('images:volumeViewer:display3DTabName'));
            self.Display3DTab=matlab.ui.internal.toolstrip.Tab(tabName);
            tabgroup.add(self.Display3DTab);
            self.Display3DTab.Tag='tab_3DDisplay';
            self.App.addTabGroup(tabgroup);

        end

        function layoutTabs(self)
            self.layoutVolVizTab();
            self.layout3DdisplayTab();
        end

        function layoutVolVizTab(self)
            self.createFileSection();
            self.createImportSection();

            self.createViewSection();
            self.createVolumeRenderingSection();
            self.createLayoutSection();
            self.createExportSection();
        end

        function layout3DdisplayTab(self)
            self.createSpatialReferencingSection();
            self.createOrientationSection();
            self.createColorSection();
        end

        function createFileSection(self)

            import matlab.ui.internal.toolstrip.*
            section=self.VolVizTab.addSection(upper(getString(message('images:volumeViewer:fileSection'))));


            column=section.addColumn();
            button=Button(getString(message('images:volumeViewer:newSessionButtonLabel')),self.NewSessionIcon);
            button.Tag='New Session';
            button.Description=getString(message('images:volumeViewer:newSessionButtonDescription'));
            button.Enabled=false;
            addlistener(button,'ButtonPushed',@(hobj,evt)self.newSessionClick());
            self.NewSessionButton=button;
            column.add(self.NewSessionButton);
        end

        function createImportSection(self)

            import matlab.ui.internal.toolstrip.*
            section=self.VolVizTab.addSection(upper(getString(message('images:volumeViewer:importSection'))));


            column1=section.addColumn();
            volType='volume';

            button1=SplitButton(getString(message('images:volumeViewer:importVolumeBtn')),self.ImportVolume);
            button1.Tag='Load Data';
            button1.Description=getString(message('images:volumeViewer:importVolumeDescription'));
            button1.ButtonPushedFcn=@(varargin)self.getVolumeFromFile(volType);

            popup1=PopupList();
            button1.Popup=popup1;
            popup1.Tag='LoadButtonPopUp';

            item=ListItem(getString(message('images:volumeViewer:importFromFile')),Icon.IMPORT_16);
            item.Tag='Load From File';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)self.getVolumeFromFile(volType);
            popup1.add(item);

            item=ListItem(getString(message('images:volumeViewer:importFromDicomFolder')),Icon.OPEN_16);
            item.Tag='Load From DICOM Folder';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)self.getVolumeFromDicomFolder(volType);
            popup1.add(item);

            item=ListItem(getString(message('images:volumeViewer:importFromWorkspace')),Icon.IMPORT_16);
            item.Tag='Import From Workspace';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)self.getVolumeFromWorkspace(volType);
            popup1.add(item);

            column1.add(button1);


            column2=section.addColumn();
            volType='labels';

            button2=SplitButton(getString(message('images:volumeViewer:importLabeledVolumeBtn')),self.ImportLabeledVolume);
            button2.Tag='Load Labeled Data';
            button2.Description=getString(message('images:volumeViewer:importLabeledVolumeDescription'));
            button2.ButtonPushedFcn=@(varargin)self.getVolumeFromFile(volType);

            popup2=PopupList();
            button2.Popup=popup2;
            popup2.Tag='LoadButtonPopUp';

            item=ListItem(getString(message('images:volumeViewer:importFromFile')),Icon.IMPORT_16);
            item.Tag='Load Labeled From File';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)self.getVolumeFromFile(volType);
            popup2.add(item);

            item=ListItem(getString(message('images:volumeViewer:importFromDicomFolder')),Icon.OPEN_16);
            item.Tag='Load Labeled From DICOM Folder';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)self.getVolumeFromDicomFolder(volType);
            popup2.add(item);

            item=ListItem(getString(message('images:volumeViewer:importFromWorkspace')),Icon.IMPORT_16);
            item.Tag='Import Labeled From Workspace';
            item.ShowDescription=false;
            item.ItemPushedFcn=@(varargin)self.getVolumeFromWorkspace(volType);
            popup2.add(item);

            column2.add(button2);

        end

        function createSpatialReferencingSection(self)

            import matlab.ui.internal.toolstrip.*


            section=self.Display3DTab.addSection(upper(getString(message('images:volumeViewer:spatialRefSectionName'))));
            section.Tag='spatialReferencing';


            column1=section.addColumn();
            buttonGroup=ButtonGroup();

            self.CustomReferencingButton=RadioButton(buttonGroup,getString(message('images:volumeViewer:specifyDimensionsButtonLabel')));
            self.CustomReferencingButton.Description=getString(message('images:volumeViewer:specifyDimensionsButtonDescription'));
            self.CustomReferencingButton.Tag='CustomReferencingButton';
            self.CustomReferencingButton.Enabled=false;
            column1.add(self.CustomReferencingButton);

            self.UniformInWorldButton=RadioButton(buttonGroup,getString(message('images:volumeViewer:upsampleToCubeButtonLabel')));
            self.UniformInWorldButton.Description=getString(message('images:volumeViewer:upsampleToCubeButtonDescription'));
            self.UniformInWorldButton.Tag='UniformInWorldButton';
            self.UniformInWorldButton.Enabled=false;
            column1.add(self.UniformInWorldButton);

            self.UseFileMetadataButton=RadioButton(buttonGroup,getString(message('images:volumeViewer:useMetadataButtonLabel')));
            self.UseFileMetadataButton.Description=getString(message('images:volumeViewer:useMetadataButtonDescription'));
            self.UseFileMetadataButton.Tag='UseFileMetadataButton';
            self.UseFileMetadataButton.Enabled=false;
            column1.add(self.UseFileMetadataButton);

            self.CustomReferencingButton.Value=true;

            section.addColumn('Width',10);


            column2=section.addColumn();

            self.XAxisLabel=Label(getString(message('images:volumeViewer:xAxisLabel')));
            self.XAxisLabel.Enabled=false;
            column2.add(self.XAxisLabel);

            self.YAxisLabel=Label(getString(message('images:volumeViewer:yAxisLabel')));
            self.YAxisLabel.Enabled=false;
            column2.add(self.YAxisLabel);

            self.ZAxisLabel=Label(getString(message('images:volumeViewer:zAxisLabel')));
            self.ZAxisLabel.Enabled=false;
            column2.add(self.ZAxisLabel);


            column3=section.addColumn('Width',70);

            self.XAxisUnitsEditField=EditField();
            self.XAxisUnitsEditField.Enabled=false;
            self.XAxisUnitsEditField.Tag='XAxisUnitsEditField';
            column3.add(self.XAxisUnitsEditField);

            self.YAxisUnitsEditField=EditField();
            self.YAxisUnitsEditField.Enabled=false;
            self.YAxisUnitsEditField.Tag='YAxisUnitsEditField';
            column3.add(self.YAxisUnitsEditField);

            self.ZAxisUnitsEditField=EditField();
            self.ZAxisUnitsEditField.Enabled=false;
            self.ZAxisUnitsEditField.Tag='ZAxisUnitsEditField';
            column3.add(self.ZAxisUnitsEditField);


            column4=section.addColumn();

            self.XUnitsLabel=Label(getString(message('images:volumeViewer:unitsLabel')));
            self.XUnitsLabel.Enabled=false;
            column4.add(self.XUnitsLabel);

            self.YUnitsLabel=Label(getString(message('images:volumeViewer:unitsLabel')));
            self.YUnitsLabel.Enabled=false;
            column4.add(self.YUnitsLabel);

            self.ZUnitsLabel=Label(getString(message('images:volumeViewer:unitsLabel')));
            self.ZUnitsLabel.Enabled=false;
            column4.add(self.ZUnitsLabel);
        end

        function createViewSection(self)

            import matlab.ui.internal.toolstrip.*

            section=self.VolVizTab.addSection(upper(getString(message('images:volumeViewer:viewSectionName'))));

            c=section.addColumn();
            buttonGroup=ButtonGroup();

            self.VolumeModeButton=RadioButton(buttonGroup,getString(message('images:volumeViewer:volumeModeVolume')));
            self.VolumeModeButton.Description=getString(message('images:volumeViewer:volumeModePopupDescription'));
            self.VolumeModeButton.Tag='VolumeModeButton';
            self.VolumeModeButton.Enabled=false;
            c.add(self.VolumeModeButton);

            self.LabelModeButton=RadioButton(buttonGroup,getString(message('images:volumeViewer:volumeModeLabels')));
            self.LabelModeButton.Description=getString(message('images:volumeViewer:volumeModePopupDescription'));
            self.LabelModeButton.Tag='LabelModeButton';
            self.LabelModeButton.Enabled=false;
            c.add(self.LabelModeButton);

            section.addColumn('Width',10);

            group=ButtonGroup();
            column1=section.addColumn();
            control=ToggleButton(getString(message('images:volumeViewer:viewVolumeButtonLabel')),self.VolIcon,group);
            column1.add(control);
            self.ShowVolumeToggleButton=control;
            self.ShowVolumeToggleButton.Tag='ShowVolumeToggleButton';
            self.ShowVolumeToggleButton.Description=getString(message('images:volumeViewer:showVolumeButtonDescription'));
            addlistener(self.ShowVolumeToggleButton,'ValueChanged',@(~,evt)self.toggle3DVolumeDisplay(evt.EventData.NewValue));

            column2=section.addColumn();

            control=ToggleButton(getString(message('images:volumeViewer:viewSlicesButtonLabel')),self.SliceIcon,group);
            column2.add(control);
            self.ShowSlicesToggleButton=control;
            self.ShowSlicesToggleButton.Tag='ShowSlicesToggleButton';
            self.ShowSlicesToggleButton.Description=getString(message('images:volumeViewer:show3DSlicesButtonDescription'));
            self.ShowVolumeToggleButton.Value=true;

            self.ShowSlicesToggleButton.Enabled=false;
            self.ShowVolumeToggleButton.Enabled=false;

        end

        function createVolumeRenderingSection(self)

            import matlab.ui.internal.toolstrip.*

            section=self.VolVizTab.addSection(upper(getString(message('images:volumeViewer:volumeRenderingSectionName'))));

            column1=section.addColumn();
            button=Button(getString(message('images:volumeViewer:restoreRenderingButtonLabel')),self.RestoreIcon);
            button.Tag='Restore Default';
            button.Enabled=false;
            button.Description=getString(message('images:volumeViewer:restoreDefaultButtonDescription'));
            self.RestoreDefaultButton=button;
            column1.add(button);

        end

        function createLayoutSection(self)

            import matlab.ui.internal.toolstrip.*

            section=self.VolVizTab.addSection(upper(getString(message('images:volumeViewer:layoutSectionName'))));
            column1=section.addColumn();

            twoRow=ListItem(getString(message('images:volumeViewer:layout2by2')),Icon.LAYOUT_16);
            twoRow.Tag=getString(message('images:volumeViewer:layout2by2'));
            twoRow.ShowDescription=false;
            addlistener(twoRow,'ItemPushed',@(~,~)self.setLayout2by2());

            threeRow=ListItem(getString(message('images:volumeViewer:layout3by2')),Icon.LAYOUT_16);
            threeRow.Tag=getString(message('images:volumeViewer:layout3by2'));
            threeRow.ShowDescription=false;
            addlistener(threeRow,'ItemPushed',@(~,~)self.setLayoutStack2DSlices());

            popup=matlab.ui.internal.toolstrip.PopupList();
            add(popup,twoRow);
            add(popup,threeRow);

            button1=SplitButton(getString(message('images:volumeViewer:layoutButtonLabel')),Icon.LAYOUT_24);
            button1.Tag='Default Layout';
            self.DefaultLayoutButton=button1;
            self.DefaultLayoutButton.Enabled=true;
            button1.Description=getString(message('images:volumeViewer:layoutButtonDescription'));
            column1.add(button1);
            addlistener(self.DefaultLayoutButton,'ButtonPushed',@(hobj,evt)self.setLayout2by2());

            self.DefaultLayoutButton.Popup=popup;

        end

        function createColorSection(self)

            import matlab.ui.internal.toolstrip.*

            section=self.Display3DTab.addSection(upper(getString(message('images:volumeViewer:colorSectionName'))));
            column1=section.addColumn();

            button1=Button(getString(message('images:volumeViewer:backgroundColorButtonLabel')));
            button1.Tag='Background Color';
            button1.Description=getString(message('images:volumeViewer:backgroundColorButtonDescription'));
            column1.add(button1);
            addlistener(button1,'ButtonPushed',@(hobj,evt)self.launchBackgroundColorDialog());
            self.BackgroundColorButton=button1;
            self.BackgroundColorButton.Enabled=false;

            button2=CheckBox(getString(message('images:volumeViewer:useGradientButtonLabel')));
            button2.Tag='Use Gradient';
            button2.Description=getString(message('images:volumeViewer:useGradientButtonDescription'));
            column1.add(button2);
            addlistener(button2,'ValueChanged',@(hobj,evt)self.useGradientValueChanged(evt.EventData.NewValue));
            self.UseGradientButton=button2;
            self.UseGradientButton.Enabled=false;

            button3=Button(getString(message('images:volumeViewer:gradientColorButtonLabel')));
            button3.Tag='Gradient Color';
            button3.Description=getString(message('images:volumeViewer:gradientColorButtonDescription'));
            column1.add(button3);
            addlistener(button3,'ButtonPushed',@(hobj,evt)self.launchGradientColorDialog());
            self.GradientColorButton=button3;
            self.GradientColorButton.Enabled=false;

        end

        function createOrientationSection(self)
            import matlab.ui.internal.toolstrip.*

            section=self.Display3DTab.addSection(upper(getString(message('images:volumeViewer:orientationSectionName'))));
            column1=section.addColumn();

            btnName=getString(message('images:volumeViewer:orientationAxesButtonLabel'));
            button=ToggleButton(btnName,self.OrientationAxesIcon);
            button.Tag='OrientationAxes';
            button.Description=getString(message('images:volumeViewer:orientationAxesButtonDescription'));
            column1.add(button);

            self.OrientationAxesToggleButton=button;
            self.OrientationAxesToggleButton.Value=true;
            self.OrientationAxesToggleButton.Enabled=false;
            addlistener(self.OrientationAxesToggleButton,'ValueChanged',@(~,evt)self.toggleOrientationAxes(evt.EventData.NewValue));

        end

        function createExportSection(self)
            import matlab.ui.internal.toolstrip.*
            section=self.VolVizTab.addSection(upper(getString(message('images:volumeViewer:exportSectionName'))));


            column1=section.addColumn();
            button=SplitButton(getString(message('images:volumeViewer:exportSectionName')),self.ExportIcon);
            button.Tag='Export';
            button.Description=getString(message('images:volumeViewer:exportButtonDescription'));
            button.Enabled=false;
            self.ExportButton=button;



            popup=PopupList();
            button.Popup=popup;

            subItem1=ListItem(getString(message('images:volumeViewer:exportRenderingSubItem')),self.ExportRenderingIcon);
            subItem1.Description=getString(message('images:volumeViewer:exportRenderingSubItemDescription'));
            subItem1.Tag='ExportRenderingSubItem';
            self.ExportConfigSubitem=subItem1;
            popup.add(subItem1);

            column1.add(button);
        end

    end


    methods(Access=private)

        function addDocuments(self)

            self.addVolumeRenderingDocument();
            self.add2DSliceDocuments();
            self.addRenderingEditorPanel();

        end

        function addVolumeRenderingDocument(self)

            group=matlab.ui.internal.FigureDocumentGroup();
            group.Title="Figures";
            group.Tag=self.volumeDocGroupTag;
            self.App.add(group);


            figOptions.Title=getString(message('images:volumeViewer:volumeDocumentName'));
            figOptions.DocumentGroupTag=group.Tag;

            hDocument=matlab.ui.internal.FigureDocument(figOptions);
            self.App.add(hDocument);
            self.volumeRenderingFig=hDocument.Figure;
            hDocument.Closable=false;
            hDocument.Tag=self.volumeDocumentTag;

            set(self.volumeRenderingFig,'NumberTitle','off',...
            'Units','pixels',...
            'Color',[0.0,0.329,0.529],...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'AutoResizeChildren','on');

            self.GridLayout=uigridlayout(self.volumeRenderingFig,[1,1],'Padding',0);

        end

        function add2DSliceDocuments(self)

            group=matlab.ui.internal.FigureDocumentGroup();
            group.Title="2DSlices";
            group.Tag=self.slicesDocGroupTag;
            self.App.add(group);

            figOptions.DocumentGroupTag=group.Tag;


            figOptions.Title=getString(message('images:volumeViewer:sliceDocumentName','XY'));
            figOptions.Tag=self.xySliceDocumentTag;
            hDocument=matlab.ui.internal.FigureDocument(figOptions);
            self.App.add(hDocument);
            self.xySliceFig=hDocument.Figure;
            hDocument.Closable=false;
            set(self.xySliceFig,'NumberTitle','off',...
            'Units','pixels',...
            'Color',[0,0,0],...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'AutoResizeChildren','off');
            figOptions.Title=getString(message('images:volumeViewer:sliceDocumentName','XZ'));
            figOptions.Tag=self.xzSliceDocumentTag;
            hDocument=matlab.ui.internal.FigureDocument(figOptions);
            self.App.add(hDocument);
            self.xzSliceFig=hDocument.Figure;
            hDocument.Closable=false;
            set(self.xzSliceFig,'NumberTitle','off',...
            'Units','pixels',...
            'Color',[0,0,0],...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'AutoResizeChildren','off');

            figOptions.Title=getString(message('images:volumeViewer:sliceDocumentName','YZ'));
            figOptions.Tag=self.yzSliceDocumentTag;
            hDocument=matlab.ui.internal.FigureDocument(figOptions);
            self.App.add(hDocument);
            self.yzSliceFig=hDocument.Figure;
            hDocument.Closable=false;
            set(self.yzSliceFig,'NumberTitle','off',...
            'Units','pixels',...
            'Color',[0,0,0],...
            'IntegerHandle','off',...
            'HandleVisibility','off',...
            'AutoResizeChildren','off');

        end

        function addRenderingEditorPanel(self)

            panelOptions.Tag="RenderingEditorPanel";
            panelOptions.Region="right";
            panelOptions.PermissibleRegions="right";
            panelOptions.Collapsible=1;
            panelOptions.Maximizable=false;
            panelOptions.PreferredWidth=340;
            panelOptions.Title=getString(message('images:volumeViewer:renderingEditorDocumentName'));
            hPanel=matlab.ui.internal.FigurePanel(panelOptions);
            self.renderingEditorFigure=hPanel.Figure;
            set(self.renderingEditorFigure,...
            'Units','pixels',...
            'HandleVisibility','off',...
            'AutoResizeChildren','off');
            self.App.add(hPanel);

        end

    end


    methods(Access=private)

        function create2DSliceViewsWeb(self)
            self.xySliceView=images.internal.app.volview.Scrollable2DImageSliceViewWeb(self.xySliceFig);
            self.xzSliceView=images.internal.app.volview.Scrollable2DImageSliceViewWeb(self.xzSliceFig);
            self.yzSliceView=images.internal.app.volview.Scrollable2DImageSliceViewWeb(self.yzSliceFig);

            self.xySliceView.setSliderTag('xySliceSlider');
            self.xzSliceView.setSliderTag('xzSliceSlider');
            self.yzSliceView.setSliderTag('yzSliceSlider');
        end

        function createVolumeRenderingView(self)
            self.volumeRenderingView=images.internal.app.volview.VolumeRenderer(self.GridLayout);
            addlistener(self.volumeRenderingView,'WarningThrown',@(src,evt)displayWarning(self,evt));
        end

        function createVolumeRenderingSettingsView(self)
            self.renderingEditorView=images.internal.app.volview.VolumeRenderingSettingsEditorWeb(self.renderingEditorFigure);
        end

    end


    methods(Access=private)

        function layout=getDefaultLayout(self)

            [~,~,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition();


            layout=struct;
            layout.majorVersion=2;
            layout.minorVersion=1;
            layout.panelLayout=struct('referenceWidth',width,'referenceHeight',height,'centerExpanded',false,'centerCollapsed',false);
            layout.toolstripCollapsed=false;
            layout.documentLayout.referenceWidth=width;
            layout.documentLayout.referenceHeight=height;

            layout.documentLayout.gridDimensions=struct('w',2,'h',2);
            layout.documentLayout.tileCount=4;
            layout.documentLayout.tileCoverage=[1,2;3,4];
            layout.documentLayout.emptyTileCount=0;

            layout.documentLayout.columnWeights=[0.5,0.5];
            layout.documentLayout.rowWeights=[0.5,0.5];
            layout.documentLayout.rowTop=[0;round(layout.documentLayout.referenceHeight/2);layout.documentLayout.referenceHeight];
            layout.documentLayout.columnLeft=[0;round(layout.documentLayout.referenceWidth/2);layout.documentLayout.referenceWidth];

            id=[self.slicesDocGroupTag,'_',self.xySliceDocumentTag];
            tile1=struct('children',struct('id',id),'showingChildId',id);

            id=[self.slicesDocGroupTag,'_',self.xzSliceDocumentTag];
            tile2=struct('children',struct('id',id),'showingChildId',id);

            id=[self.slicesDocGroupTag,'_',self.yzSliceDocumentTag];
            tile3=struct('children',struct('id',id),'showingChildId',id);

            id=[self.volumeDocGroupTag,'_',self.volumeDocumentTag];
            tile4=struct('children',struct('id',id),'showingChildId',id);

            layout.documentLayout.tileOccupancy=[tile1;tile2;tile3;tile4];


            layout.panelLayout.right.isCollapsed=false;
            layout.panelLayout.right.collapsed=false;

        end

        function setLayoutStack2DSlices(self)

            s=self.App.Layout;

            if isempty(fieldnames(s))

                [~,~,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition();

                s.panelLayout=struct('referenceWidth',width,'referenceHeight',height,'centerExpanded',false,'centerCollapsed',false);
                s.toolstripCollapsed=false;
                s.documentLayout.referenceWidth=width;
                s.documentLayout.referenceHeight=height;

            end


            s.documentLayout.gridDimensions=struct('w',2,'h',3);
            s.documentLayout.tileCount=4;
            s.documentLayout.tileCoverage=[1,2;3,2;4,2];
            s.documentLayout.emptyTileCount=0;

            s.documentLayout.columnWeights=[0.3,0.7];
            s.documentLayout.rowWeights=[1/3,1/3,1/3];
            s.documentLayout.rowTop=[0;round(s.documentLayout.referenceHeight/3);round(s.documentLayout.referenceHeight*2/3);s.documentLayout.referenceHeight];
            s.documentLayout.columnLeft=[0;round(s.documentLayout.referenceWidth*0.3);s.documentLayout.referenceWidth];

            id=[self.slicesDocGroupTag,'_',self.xySliceDocumentTag];
            tile1=struct('children',struct('id',id),'showingChildId',id);

            id=[self.volumeDocGroupTag,'_',self.volumeDocumentTag];
            tile2=struct('children',struct('id',id),'showingChildId',id);

            id=[self.slicesDocGroupTag,'_',self.yzSliceDocumentTag];
            tile3=struct('children',struct('id',id),'showingChildId',id);

            id=[self.slicesDocGroupTag,'_',self.xzSliceDocumentTag];
            tile4=struct('children',struct('id',id),'showingChildId',id);

            s.documentLayout.tileOccupancy=[tile1;tile2;tile3;tile4];


            s.panelLayout.right.isCollapsed=false;
            s.panelLayout.right.collapsed=false;

            self.App.Layout=s;

        end

        function setLayout2by2(self)

            s=self.App.Layout;

            if isempty(fieldnames(s))

                [~,~,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition();

                s.panelLayout=struct('referenceWidth',width,'referenceHeight',height,'centerExpanded',false,'centerCollapsed',false);
                s.toolstripCollapsed=false;
                s.documentLayout.referenceWidth=width;
                s.documentLayout.referenceHeight=height;

            end


            s.documentLayout.gridDimensions=struct('w',2,'h',2);
            s.documentLayout.tileCount=4;
            s.documentLayout.tileCoverage=[1,2;3,4];
            s.documentLayout.emptyTileCount=0;

            s.documentLayout.columnWeights=[0.5,0.5];
            s.documentLayout.rowWeights=[0.5,0.5];
            s.documentLayout.rowTop=[0;round(s.documentLayout.referenceHeight/2);s.documentLayout.referenceHeight];
            s.documentLayout.columnLeft=[0;round(s.documentLayout.referenceWidth/2);s.documentLayout.referenceWidth];

            id=[self.slicesDocGroupTag,'_',self.xySliceDocumentTag];
            tile1=struct('children',struct('id',id),'showingChildId',id);

            id=[self.slicesDocGroupTag,'_',self.xzSliceDocumentTag];
            tile2=struct('children',struct('id',id),'showingChildId',id);

            id=[self.slicesDocGroupTag,'_',self.yzSliceDocumentTag];
            tile3=struct('children',struct('id',id),'showingChildId',id);

            id=[self.volumeDocGroupTag,'_',self.volumeDocumentTag];
            tile4=struct('children',struct('id',id),'showingChildId',id);

            s.documentLayout.tileOccupancy=[tile1;tile2;tile3;tile4];


            s.panelLayout.right.isCollapsed=false;
            s.panelLayout.right.collapsed=false;

            self.App.Layout=s;

        end

    end


    methods

        function showAsBusy(self)
            self.App.Busy=true;
        end

        function unshowAsBusy(self)
            self.App.Busy=false;
        end

        function dataLoadingStarted(self)
            self.showPanels(false);
            self.showAsBusy();
        end

        function dataLoadingFinished(self)
            self.showPanels(true);
            self.unshowAsBusy();
        end

        function showPanels(self,TF)
            if~TF
                return
            end
            self.renderingEditorView.Panel.Visible=TF;

            self.xySliceView.Panel.Visible=TF;
            self.xzSliceView.Panel.Visible=TF;
            self.yzSliceView.Panel.Visible=TF;
            self.orientationAxesView.Panel.Visible=TF;
        end

        function bringAppInFocus(self)






            if ispc||ismac
                self.App.bringToFront();
            end

        end

        function appCloseAllowed(self,TF)
            if isvalid(self)
                self.AppCloseAllowed=TF;
            end
        end

    end


    methods

        function displayWarning(self,evt)
            uialert(self.volumeRenderingFig,...
            evt.Message,...
            'Warning',...
            'Icon','error',...
            'Modal',true);
        end

        function displayScaleFactorsWarningDlg(self,messageStr)

            self.unshowAsBusy();
            self.appCloseAllowed(false);
            c1=onCleanup(@()self.appCloseAllowed(true));

            uialert(self.volumeRenderingFig,...
            messageStr,...
            getString(message('images:volumeViewer:scaleFactorsLabeledVolume')),...
            'Icon','warning',...
            'Modal',true);

        end

        function displayFileLoadFailedDlg(self,messageStr)

            self.unshowAsBusy();
            self.appCloseAllowed(false);
            c1=onCleanup(@()self.appCloseAllowed(true));

            uialert(self.volumeRenderingFig,...
            messageStr,...
            getString(message('images:volumeViewer:invalidFile')),...
            'Icon','error',...
            'Modal',true);
        end

        function displayFolderLoadFailedDlg(self,messageStr)

            self.unshowAsBusy();
            self.appCloseAllowed(false);
            c1=onCleanup(@()self.appCloseAllowed(true));

            uialert(self.volumeRenderingFig,...
            messageStr,...
            getString(message('images:volumeViewer:invalidFolder')),...
            'Icon','error',...
            'Modal',true);
        end

        function displayVolSizesNotEqualDlg(self,messageStr)

            self.unshowAsBusy();
            self.appCloseAllowed(false);
            c1=onCleanup(@()self.appCloseAllowed(true));

            uialert(self.volumeRenderingFig,...
            messageStr,...
            getString(message('images:volumeViewer:volumeSizesNotEqual')),...
            'Icon','error',...
            'Modal',true);
        end

        function displayNumLabelsExceededDlg(self,messageStr)

            self.unshowAsBusy();
            self.appCloseAllowed(false);
            c1=onCleanup(@()self.appCloseAllowed(true));

            uialert(self.volumeRenderingFig,...
            messageStr,...
            getString(message('images:volumeViewer:numLabelsExceeded')),...
            'Icon','error',...
            'Modal',true);
        end

        function displayInvalidSpatialReferencingDlg(self,messageStr)

            self.unshowAsBusy();
            self.appCloseAllowed(false);
            c1=onCleanup(@()self.appCloseAllowed(true));

            uialert(self.volumeRenderingFig,...
            messageStr,...
            getString(message('images:volumeViewer:invalidSpatialReferencing')),...
            'Icon','error',...
            'Modal',true);
        end

        function newSessionClick(self)

            self.unshowAsBusy();
            self.appCloseAllowed(false);
            c1=onCleanup(@()self.appCloseAllowed(true));

            selection=uiconfirm(self.volumeRenderingFig,...
            getString(message('images:volumeViewer:startNewSession')),...
            getString(message('images:volumeViewer:newSessionButtonLabel')),...
            'Options',{getString(message('images:commonUIString:yes')),getString(message('images:commonUIString:cancel'))},...
            'DefaultOption',getString(message('images:commonUIString:cancel')));

            switch selection
            case getString(message('images:commonUIString:cancel'))
                return;
            case getString(message('images:commonUIString:yes'))
                self.notify('StartNewSession');
            end

        end

        function launchBackgroundColorDialog(self)

            self.appCloseAllowed(false);
            c1=onCleanup(@()self.appCloseAllowed(true));

            c=uisetcolor(self.volumeRenderingView.BackgroundColor,getString(message('images:volumeViewer:backgroundColorButtonLabel')));
            self.notify('BackgroundColorChange',images.internal.app.volview.events.BackgroundColorChangeEventData(c,self.volumeRenderingView.GradientColor,self.volumeRenderingView.UseGradient));

            self.bringAppInFocus();

        end

        function launchGradientColorDialog(self)

            self.appCloseAllowed(false);
            c1=onCleanup(@()self.appCloseAllowed(true));

            c=uisetcolor(self.volumeRenderingView.GradientColor,getString(message('images:volumeViewer:backgroundColorButtonLabel')));
            self.notify('BackgroundColorChange',images.internal.app.volview.events.BackgroundColorChangeEventData(self.volumeRenderingView.BackgroundColor,c,self.volumeRenderingView.UseGradient));

            self.bringAppInFocus();

        end

        function useGradientValueChanged(self,TF)
            self.GradientColorButton.Enabled=TF;
            self.notify('BackgroundColorChange',images.internal.app.volview.events.BackgroundColorChangeEventData(self.volumeRenderingView.BackgroundColor,self.volumeRenderingView.GradientColor,TF));
        end

        function launchExportDialog(self,config,viewerConfig)

            loc=imageslib.internal.app.utilities.ScreenUtilities.getToolCenter(self.App);
            dlgTitle=getString(message('images:volumeViewer:exportToWorkspace'));

            self.ExportDlg=images.internal.app.volview.ExportDialog(loc,dlgTitle,...
            ["objectConfig","sceneConfig"],["volshow settings","viewer3d settings"]);
            wait(self.ExportDlg);

            if~self.ExportDlg.Canceled
                if self.ExportDlg.VariableSelected(1)
                    assignin('base',self.ExportDlg.VariableName(1),config);
                end
                if self.ExportDlg.VariableSelected(2)
                    assignin('base',self.ExportDlg.VariableName(2),viewerConfig);
                end
            end

        end

        function checkReplaceOrOverlay(self,data)
            self.unshowAsBusy();
            import images.internal.app.volview.*
            refreshValue=checkReplaceOrOverlay(data);
            evtData=images.internal.app.volview.events.ReplaceOrOverlayResultEventData(refreshValue);
            self.notify('ReplaceOrOverlayResult',evtData);
        end

    end


    methods(Access=?tLoadDicomVolume)

        function toggleOrientationAxes(self,TF)

            self.showAsBusy();
            self.volumeRenderingView.OrientationAxes=TF;
            self.unshowAsBusy();

        end

        function toggle3DVolumeDisplay(self,TF)

            evtData=images.internal.app.volview.events.VolumeDisplayChangeEventData(TF);
            self.notify('VolumeDisplayChangeRequested',evtData);

        end


        function getVolumeFromFile(self,volType)

            [filename,userCanceled]=images.internal.app.volview.volgetfile();
            if~userCanceled
                showAsBusy(self);
                self.notify('ImportFromFile',images.internal.app.volview.events.ImportFromFileEventData(filename,volType));
                unshowAsBusy(self);
            end

            self.bringAppInFocus();

        end

        function getVolumeFromDicomFolder(self,volType)

            [directorySelected,userCanceled]=images.internal.app.volview.volgetfolder();
            if~userCanceled
                showAsBusy(self);
                self.notify('ImportFromDicomFolder',images.internal.app.volview.events.ImportFromDicomFolderEventData(directorySelected,volType));
                unshowAsBusy(self);
            end
        end

        function getVolumeFromWorkspace(self,volType)

            loc=imageslib.internal.app.utilities.ScreenUtilities.getToolCenter(self.App);
            if strcmp(volType,'volume')
                self.ImportFromWorkspaceDlg=images.internal.app.utilities.VariableDialog(loc,getString(message('images:volumeViewer:importVolume')),...
                getString(message('images:volumeViewer:variables')),'grayOrLogicalVolume3D');
                wait(self.ImportFromWorkspaceDlg);

            elseif strcmp(volType,'labels')
                self.ImportFromWorkspaceDlg=images.internal.app.utilities.VariableDialog(loc,getString(message('images:volumeViewer:importLabels')),...
                getString(message('images:volumeViewer:variables')),'labelVolume3D');
                wait(self.ImportFromWorkspaceDlg);

            else
                assert(true,'Invalid volType in',mfilename);
            end

            if~self.ImportFromWorkspaceDlg.Canceled
                V=evalin('base',self.ImportFromWorkspaceDlg.SelectedVariable);

                variableName=self.ImportFromWorkspaceDlg.SelectedVariable;
                showAsBusy(self);
                self.notify('ImportFromWorkspace',images.internal.app.volview.events.ImportFromWorkspaceEventData(V,variableName,volType));
                unshowAsBusy(self);
            end

        end


    end


    methods

        function set.VolumeMode(self,mode)
            str=validatestring(mode,{'volume','mip','iso','labels','mixed'});

            switch str
            case 'volume'
                self.ShowVolumeToggleButton.Icon=self.VolIcon;
                self.ShowVolumeToggleButton.Text=getString(message('images:volumeViewer:viewVolumeButtonLabel'));

                self.renderingEditorView.RenderingStylePopup.Visible='on';
                self.renderingEditorView.IsosurfacePanel.Visible='off';
                self.renderingEditorView.VolumeRenderingPanel.Visible='on';
                self.renderingEditorView.LightingPanel.Visible='on';

                self.renderingEditorView.LabelVolumeRenderingPanel.Visible='off';
                self.renderingEditorView.LabelVolumeRenderingPanel.HitTest='off';

            case 'mip'
                self.ShowVolumeToggleButton.Icon=self.VolIcon;
                self.ShowVolumeToggleButton.Text=getString(message('images:volumeViewer:viewVolumeButtonLabel'));

                self.renderingEditorView.RenderingStylePopup.Visible='on';
                self.renderingEditorView.IsosurfacePanel.Visible='off';
                self.renderingEditorView.VolumeRenderingPanel.Visible='on';
                self.renderingEditorView.LightingPanel.Visible='off';

                self.renderingEditorView.LabelVolumeRenderingPanel.Visible='off';
                self.renderingEditorView.LabelVolumeRenderingPanel.HitTest='off';

            case 'iso'
                self.ShowVolumeToggleButton.Icon=self.VolIcon;
                self.ShowVolumeToggleButton.Text=getString(message('images:volumeViewer:viewVolumeButtonLabel'));

                self.renderingEditorView.RenderingStylePopup.Visible='on';
                self.renderingEditorView.IsosurfacePanel.Visible='on';
                self.renderingEditorView.VolumeRenderingPanel.Visible='off';

                self.renderingEditorView.LabelVolumeRenderingPanel.Visible='off';
                self.renderingEditorView.LabelVolumeRenderingPanel.HitTest='off';

            case 'labels'
                self.ShowVolumeToggleButton.Icon=self.LabelVolIcon;
                self.ShowVolumeToggleButton.Text=getString(message('images:volumeViewer:viewLabelsButtonLabel'));

                self.renderingEditorView.RenderingStylePopup.Visible='off';
                self.renderingEditorView.IsosurfacePanel.Visible='off';
                self.renderingEditorView.VolumeRenderingPanel.Visible='off';

                self.renderingEditorView.LabelVolumeRenderingPanel.Visible='on';
                self.renderingEditorView.LabelVolumeRenderingPanel.HitTest='on';

                self.renderingEditorView.LabelMode='labels';

            case 'mixed'
                self.ShowVolumeToggleButton.Icon=self.LabelVolIcon;
                self.ShowVolumeToggleButton.Text=getString(message('images:volumeViewer:viewLabelsButtonLabel'));

                self.renderingEditorView.RenderingStylePopup.Visible='off';
                self.renderingEditorView.IsosurfacePanel.Visible='off';
                self.renderingEditorView.VolumeRenderingPanel.Visible='off';

                self.renderingEditorView.VolumeRenderingPanel.Parent.Visible='on';

                self.renderingEditorView.LabelVolumeRenderingPanel.Visible='on';
                self.renderingEditorView.LabelVolumeRenderingPanel.HitTest='on';

                self.renderingEditorView.LabelMode='mixed';
            end
        end

        function setBackgroundColor(self,color,gradColor,useGrad)

            self.BackgroundColorButton.Icon=constructColorIconFromRGBTriplet(color,[16,16]);
            self.GradientColorButton.Icon=constructColorIconFromRGBTriplet(gradColor,[16,16]);
            self.UseGradientButton.Value=useGrad;

            if self.UseGradientButton.Enabled
                self.GradientColorButton.Enabled=self.UseGradientButton.Value;
            end

            self.GridLayout.BackgroundColor=color;
            self.volumeRenderingFig.Color=color;
            self.volumeRenderingView.BackgroundColor=color;
            self.volumeRenderingView.GradientColor=gradColor;
            self.volumeRenderingView.UseGradient=useGrad;

        end

        function setCustomReferencingButtonActive(self)
            self.CustomReferencingButton.Value=true;
        end

        function setSpatialReferencingEditFields(self,xSize,ySize,zSize)
            self.XAxisUnitsEditField.Value=num2str(xSize);
            self.YAxisUnitsEditField.Value=num2str(ySize);
            self.ZAxisUnitsEditField.Value=num2str(zSize);
        end

    end


    methods

        function enableViewControlsOnDataLoad(self,data)

            self.NewSessionButton.Enabled=true;
            self.CustomReferencingButton.Enabled=true;
            self.UniformInWorldButton.Enabled=true;

            self.XAxisLabel.Enabled=true;
            self.YAxisLabel.Enabled=true;
            self.ZAxisLabel.Enabled=true;

            self.XUnitsLabel.Enabled=true;
            self.YUnitsLabel.Enabled=true;
            self.ZUnitsLabel.Enabled=true;

            self.XAxisUnitsEditField.Enabled=true;
            self.YAxisUnitsEditField.Enabled=true;
            self.ZAxisUnitsEditField.Enabled=true;

            self.ShowSlicesToggleButton.Enabled=true;
            self.ShowVolumeToggleButton.Enabled=true;
            self.RestoreDefaultButton.Enabled=true;
            self.BackgroundColorButton.Enabled=true;
            self.GradientColorButton.Enabled=self.UseGradientButton.Value;
            self.UseGradientButton.Enabled=true;
            self.OrientationAxesToggleButton.Enabled=true;
            self.ExportButton.Enabled=true;

            if strcmp(data.VolumeDisplayMode,'volume')
                self.VolumeModeButton.Value=true;
            elseif strcmp(data.VolumeDisplayMode,'labels')
                self.LabelModeButton.Value=true;
                self.renderingEditorView.EmbedLabelsCheckbox.Value=0;
            elseif strcmp(data.VolumeDisplayMode,'mixed')
                self.LabelModeButton.Value=true;
                self.renderingEditorView.EmbedLabelsCheckbox.Value=1;
            end

            if data.HasVolumeData&&data.HasLabeledVolumeData
                self.VolumeModeButton.Enabled=true;
                self.LabelModeButton.Enabled=true;

                self.renderingEditorView.EmbedLabelsCheckbox.Enable='on';
            elseif data.HasVolumeData
                self.VolumeModeButton.Enabled=true;
                self.LabelModeButton.Enabled=false;
                self.renderingEditorView.EmbedLabelsCheckbox.Enable='off';

            elseif data.HasLabeledVolumeData
                self.VolumeModeButton.Enabled=false;
                self.LabelModeButton.Enabled=true;
                self.renderingEditorView.EmbedLabelsCheckbox.Enable='off';
            end

        end

        function disableViewControlsOnNewSession(self)

            self.NewSessionButton.Enabled=false;
            self.CustomReferencingButton.Enabled=false;
            self.UniformInWorldButton.Enabled=false;

            self.XAxisLabel.Enabled=false;
            self.YAxisLabel.Enabled=false;
            self.ZAxisLabel.Enabled=false;

            self.XUnitsLabel.Enabled=false;
            self.YUnitsLabel.Enabled=false;
            self.ZUnitsLabel.Enabled=false;

            self.XAxisUnitsEditField.Enabled=false;
            self.YAxisUnitsEditField.Enabled=false;
            self.ZAxisUnitsEditField.Enabled=false;

            self.ShowSlicesToggleButton.Enabled=false;
            self.ShowVolumeToggleButton.Enabled=false;
            self.RestoreDefaultButton.Enabled=false;
            self.BackgroundColorButton.Enabled=false;
            self.GradientColorButton.Enabled=false;
            self.UseGradientButton.Enabled=false;
            self.OrientationAxesToggleButton.Enabled=false;
            self.ExportButton.Enabled=false;

            self.renderingEditorView.Panel.Visible='off';
            self.orientationAxesView.Panel.Visible='off';

            self.xySliceView.reset();
            self.xzSliceView.reset();
            self.yzSliceView.reset();

            self.VolumeModeButton.Enabled=false;
            self.LabelModeButton.Enabled=false;
            self.VolumeModeButton.Value=false;
            self.LabelModeButton.Value=false;

        end

    end

end

function icon=constructColorIconFromRGBTriplet(rgbColor,iconSize)

    img=zeros([iconSize,3]);
    img(:,:,1)=rgbColor(1);
    img(:,:,2)=rgbColor(2);
    img(:,:,3)=rgbColor(3);

    icon=matlab.ui.internal.toolstrip.Icon(im2uint8(img));

end
